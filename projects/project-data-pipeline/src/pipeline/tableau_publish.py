"""
Tableau Publishing Module

Publishes CSV data to Tableau Server as datasources and workbooks.
Handles authentication, file upload, and metadata management.
"""

import os
import logging
from typing import Dict, List, Optional, Union
from pathlib import Path
import tableauserverclient as TSC
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

logger = logging.getLogger(__name__)


class TableauPublisher:
    """Handles publishing data to Tableau Server."""
    
    def __init__(self):
        """Initialize Tableau Server connection using environment variables."""
        self.server = None
        self.auth = None
        self._connect()
    
    def _connect(self):
        """Establish connection to Tableau Server."""
        try:
            server_url = os.getenv('TABLEAU_SERVER_URL')
            site = os.getenv('TABLEAU_SITE', '')
            username = os.getenv('TABLEAU_USERNAME')
            password = os.getenv('TABLEAU_PASSWORD')
            
            if not all([server_url, username, password]):
                raise ValueError("Missing required Tableau credentials in .env file")
            
            # Create authentication object
            self.auth = TSC.TableauAuth(username, password, site_id=site)
            
            # Create server object
            self.server = TSC.Server(server_url, use_server_version=True)
            
            # Sign in
            self.server.auth.sign_in(self.auth)
            logger.info(f"Successfully connected to Tableau Server: {server_url}")
            
        except Exception as e:
            logger.error(f"Failed to connect to Tableau Server: {e}")
            raise
    
    def publish_datasource(self, 
                          file_path: str, 
                          datasource_name: str, 
                          project_name: str = 'Default',
                          overwrite: bool = True) -> str:
        """
        Publish a CSV file as a Tableau datasource.
        
        Args:
            file_path: Path to CSV file
            datasource_name: Name for the datasource in Tableau
            project_name: Project name (default: 'Default')
            overwrite: Whether to overwrite existing datasource
            
        Returns:
            Datasource ID
        """
        try:
            logger.info(f"Publishing datasource '{datasource_name}' from {file_path}")
            
            # Get or create project
            project = self._get_or_create_project(project_name)
            
            # Create datasource item
            datasource_item = TSC.DatasourceItem(project.id, name=datasource_name)
            
            # Check if datasource already exists
            existing_datasource = self._find_datasource(datasource_name, project.id)
            if existing_datasource and overwrite:
                logger.info(f"Overwriting existing datasource: {existing_datasource.id}")
                datasource_item = existing_datasource
            
            # Publish the datasource
            with open(file_path, 'rb') as f:
                if existing_datasource and overwrite:
                    # Update existing datasource
                    self.server.datasources.update(datasource_item, f)
                    datasource_id = existing_datasource.id
                else:
                    # Create new datasource
                    new_datasource = self.server.datasources.publish(datasource_item, f, 'overwrite')
                    datasource_id = new_datasource.id
            
            logger.info(f"Successfully published datasource '{datasource_name}' with ID: {datasource_id}")
            return datasource_id
            
        except Exception as e:
            logger.error(f"Failed to publish datasource '{datasource_name}': {e}")
            raise
    
    def create_workbook(self, 
                       workbook_name: str, 
                       project_name: str = 'Default',
                       datasource_id: Optional[str] = None) -> str:
        """
        Create a new workbook in Tableau.
        
        Args:
            workbook_name: Name for the workbook
            project_name: Project name
            datasource_id: Optional datasource ID to connect
            
        Returns:
            Workbook ID
        """
        try:
            logger.info(f"Creating workbook '{workbook_name}'")
            
            # Get project
            project = self._get_or_create_project(project_name)
            
            # Create workbook item
            workbook_item = TSC.WorkbookItem(project.id, name=workbook_name)
            
            # Publish empty workbook
            new_workbook = self.server.workbooks.publish(workbook_item, '', 'CreateNew')
            
            logger.info(f"Successfully created workbook '{workbook_name}' with ID: {new_workbook.id}")
            return new_workbook.id
            
        except Exception as e:
            logger.error(f"Failed to create workbook '{workbook_name}': {e}")
            raise
    
    def list_projects(self) -> List[Dict]:
        """
        List all projects on the server.
        
        Returns:
            List of project metadata dictionaries
        """
        try:
            projects = list(TSC.Pager(self.server.projects))
            project_list = []
            
            for project in projects:
                project_list.append({
                    'id': project.id,
                    'name': project.name,
                    'description': project.description,
                    'content_permissions': project.content_permissions
                })
            
            logger.info(f"Found {len(project_list)} projects")
            return project_list
            
        except Exception as e:
            logger.error(f"Failed to list projects: {e}")
            raise
    
    def list_datasources(self, project_name: Optional[str] = None) -> List[Dict]:
        """
        List datasources on the server.
        
        Args:
            project_name: Optional project name to filter
            
        Returns:
            List of datasource metadata dictionaries
        """
        try:
            datasources = list(TSC.Pager(self.server.datasources))
            datasource_list = []
            
            for datasource in datasources:
                if project_name:
                    # Get project info to filter
                    project = self._get_project_by_name(project_name)
                    if datasource.project_id != project.id:
                        continue
                
                datasource_list.append({
                    'id': datasource.id,
                    'name': datasource.name,
                    'project_id': datasource.project_id,
                    'created_at': datasource.created_at,
                    'updated_at': datasource.updated_at
                })
            
            logger.info(f"Found {len(datasource_list)} datasources")
            return datasource_list
            
        except Exception as e:
            logger.error(f"Failed to list datasources: {e}")
            raise
    
    def _get_or_create_project(self, project_name: str):
        """Get existing project or create new one."""
        try:
            # Try to find existing project
            project = self._get_project_by_name(project_name)
            if project:
                return project
            
            # Create new project
            logger.info(f"Creating new project: {project_name}")
            new_project = TSC.ProjectItem(name=project_name)
            project = self.server.projects.create(new_project)
            return project
            
        except Exception as e:
            logger.error(f"Failed to get or create project '{project_name}': {e}")
            raise
    
    def _get_project_by_name(self, project_name: str):
        """Get project by name."""
        try:
            projects = list(TSC.Pager(self.server.projects))
            for project in projects:
                if project.name == project_name:
                    return project
            return None
            
        except Exception as e:
            logger.error(f"Failed to get project '{project_name}': {e}")
            raise
    
    def _find_datasource(self, datasource_name: str, project_id: str):
        """Find datasource by name and project."""
        try:
            datasources = list(TSC.Pager(self.server.datasources))
            for datasource in datasources:
                if datasource.name == datasource_name and datasource.project_id == project_id:
                    return datasource
            return None
            
        except Exception as e:
            logger.error(f"Failed to find datasource '{datasource_name}': {e}")
            raise
    
    def close(self):
        """Close the Tableau Server connection."""
        try:
            if self.server and self.auth:
                self.server.auth.sign_out()
                logger.info("Disconnected from Tableau Server")
        except Exception as e:
            logger.warning(f"Error during disconnect: {e}")
    
    def __enter__(self):
        """Context manager entry."""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.close()


