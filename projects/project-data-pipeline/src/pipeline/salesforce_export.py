"""
Salesforce Report Export Module

Exports Salesforce reports to CSV format using the Reports API.
Handles authentication, report execution, and data retrieval.
"""

import os
import csv
import logging
from typing import Dict, List, Optional
from simple_salesforce import Salesforce
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

logger = logging.getLogger(__name__)


class SalesforceExporter:
    """Handles Salesforce report exports to CSV."""
    
    def __init__(self):
        """Initialize Salesforce connection using environment variables."""
        self.sf = None
        self._connect()
    
    def _connect(self):
        """Establish connection to Salesforce using credentials from .env."""
        try:
            # Prefer token-based auth if provided (e.g., from Salesforce CLI)
            access_token = os.getenv('SF_ACCESS_TOKEN')
            instance_url = os.getenv('SF_INSTANCE_URL')
            if access_token and instance_url:
                self.sf = Salesforce(instance_url=instance_url, session_id=access_token)
                logger.info("Successfully connected to Salesforce using access token")
                return
            
            # Fallback to username/password/token auth
            username = os.getenv('SF_USERNAME')
            password = os.getenv('SF_PASSWORD')
            security_token = os.getenv('SF_SECURITY_TOKEN')
            domain = os.getenv('SF_DOMAIN', 'login')
            
            if not all([username, password, security_token]):
                raise ValueError("Missing Salesforce credentials: provide SF_ACCESS_TOKEN & SF_INSTANCE_URL or SF_USERNAME/SF_PASSWORD/SF_SECURITY_TOKEN")
            
            self.sf = Salesforce(
                username=username,
                password=password,
                security_token=security_token,
                domain=domain
            )
            logger.info("Successfully connected to Salesforce with username/password")
            
        except Exception as e:
            logger.error(f"Failed to connect to Salesforce: {e}")
            raise
    
    def export_report_to_csv(self, report_id: str, output_path: str) -> str:
        """
        Export a Salesforce report to CSV file.
        
        Args:
            report_id: Salesforce report ID (e.g., '00OXXXXXXXXXXXX')
            output_path: Local file path to save CSV
            
        Returns:
            Path to the exported CSV file
        """
        try:
            logger.info(f"Exporting report {report_id} to {output_path}")
            
            # Execute the report via Analytics Reports API
            report_data = self.sf.restful(
                f'analytics/reports/{report_id}',
                params={'includeDetails': 'true'}
            )
            logger.info(f"Report name: {report_data.get('name', 'Unknown')}")
            
            # Extract data rows
            rows = report_data.get('factMap', {}).get('T!T', {}).get('rows', [])
            if not rows:
                logger.warning(f"No data found in report {report_id}")
                return output_path
            
            # Get column metadata
            columns = report_data.get('reportMetadata', {}).get('detailColumns', [])
            
            # Create output directory if it doesn't exist
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            
            # Write CSV file
            with open(output_path, 'w', newline='', encoding='utf-8') as csvfile:
                if columns:
                    # Write header
                    writer = csv.writer(csvfile)
                    writer.writerow(columns)
                    
                    # Write data rows
                    for row in rows:
                        # Extract data values from row structure
                        data_values = []
                        for data in row.get('dataCells', []):
                            data_values.append(data.get('value', ''))
                        writer.writerow(data_values)
                else:
                    logger.warning("No column metadata found, writing raw data")
                    writer = csv.writer(csvfile)
                    for row in rows:
                        writer.writerow([str(row)])
            
            logger.info(f"Successfully exported {len(rows)} rows to {output_path}")
            return output_path
            
        except Exception as e:
            logger.error(f"Failed to export report {report_id}: {e}")
            raise
    
    def list_reports(self, folder_id: Optional[str] = None) -> List[Dict]:
        """
        List available reports in Salesforce.
        
        Args:
            folder_id: Optional folder ID to filter reports
            
        Returns:
            List of report metadata dictionaries
        """
        try:
            query = "SELECT Id, Name, DeveloperName, FolderName FROM Report"
            if folder_id:
                query += f" WHERE FolderId = '{folder_id}'"
            
            result = self.sf.query(query)
            reports = result.get('records', [])
            
            logger.info(f"Found {len(reports)} reports")
            return reports
            
        except Exception as e:
            logger.error(f"Failed to list reports: {e}")
            raise
    
    def get_report_metadata(self, report_id: str) -> Dict:
        """
        Get metadata for a specific report.
        
        Args:
            report_id: Salesforce report ID
            
        Returns:
            Report metadata dictionary
        """
        try:
            report = self.sf.restful(f'reports/{report_id}')
            return report
            
        except Exception as e:
            logger.error(f"Failed to get report metadata for {report_id}: {e}")
            raise


