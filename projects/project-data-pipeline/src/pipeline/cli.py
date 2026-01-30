"""
Command Line Interface for Data Pipeline

Orchestrates the complete Salesforce -> Transform -> Tableau pipeline.
Provides commands for running the full pipeline or individual steps.
"""

import argparse
import logging
import sys
import yaml
import pandas as pd
import json
from datetime import date, datetime
from pathlib import Path
from typing import Dict, List, Any

from .salesforce_export import SalesforceExporter
from .transformer import DataTransformer
from .tableau_publish import TableauPublisher
from .notifier import notify_status


def setup_logging(level: str = 'INFO'):
    """Setup logging configuration."""
    logging.basicConfig(
        level=getattr(logging, level.upper()),
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(sys.stdout)
        ]
    )


def load_config(config_path: str) -> Dict[str, Any]:
    """Load YAML configuration file."""
    try:
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)
        return config
    except Exception as e:
        logging.error(f"Failed to load config from {config_path}: {e}")
        raise


def run_export_step(config: Dict[str, Any]) -> List[str]:
    """Run Salesforce export step."""
    logger = logging.getLogger(__name__)
    exporter = SalesforceExporter()
    exported_files = []
    
    reports = config.get('reports', [])
    if not reports:
        logger.warning("No reports configured for export")
        return exported_files
    
    for report_config in reports:
        try:
            report_id = report_config['report_id']
            output_path = report_config['output']
            
            logger.info(f"Exporting report {report_id} to {output_path}")
            exported_file = exporter.export_report_to_csv(report_id, output_path)
            exported_files.append(exported_file)
            
        except Exception as e:
            logger.error(f"Failed to export report {report_config}: {e}")
            raise
    
    return exported_files


def run_transform_step(config: Dict[str, Any]) -> List[str]:
    """Run data transformation step."""
    logger = logging.getLogger(__name__)
    transformed_files = []
    
    transforms = config.get('transforms', [])
    if not transforms:
        logger.warning("No transforms configured")
        return transformed_files
    
    for transform_config in transforms:
        try:
            input_file = transform_config['input']
            output_file = transform_config['output']
            steps = transform_config.get('steps', [])
            
            logger.info(f"Transforming {input_file} -> {output_file}")
            
            # Load, transform, and save
            transformer = DataTransformer()
            transformer.load_csv(input_file)
            
            if steps:
                transformer.apply_transforms(steps)
            
            transformer.save_csv(output_file)
            transformed_files.append(output_file)
            
            # Log summary
            summary = transformer.get_summary()
            logger.info(f"Transform complete: {summary['rows']} rows, {summary['columns']} columns")
            
        except Exception as e:
            logger.error(f"Failed to transform {transform_config}: {e}")
            raise
    
    return transformed_files


def run_publish_step(config: Dict[str, Any]) -> List[str]:
    """Run Tableau publishing step."""
    logger = logging.getLogger(__name__)
    published_items = []
    
    publish_config = config.get('publish', {})
    if not publish_config.get('enabled', False):
        logger.info("Publishing disabled in config")
        return published_items
    
    try:
        with TableauPublisher() as publisher:
            # Publish datasource if configured
            if 'datasource' in publish_config and 'file' in publish_config:
                datasource_name = publish_config['datasource']
                file_path = publish_config['file']
                project_name = publish_config.get('project', 'Default')
                
                logger.info(f"Publishing datasource '{datasource_name}' from {file_path}")
                datasource_id = publisher.publish_datasource(
                    file_path=file_path,
                    datasource_name=datasource_name,
                    project_name=project_name
                )
                published_items.append(f"datasource:{datasource_id}")
            
            # Create workbook if configured
            if 'workbook' in publish_config:
                workbook_name = publish_config['workbook']
                project_name = publish_config.get('project', 'Default')
                
                logger.info(f"Creating workbook '{workbook_name}'")
                workbook_id = publisher.create_workbook(
                    workbook_name=workbook_name,
                    project_name=project_name
                )
                published_items.append(f"workbook:{workbook_id}")
                
    except Exception as e:
        logger.error(f"Failed to publish to Tableau: {e}")
        raise
    
    return published_items


def run_append_step(config: Dict[str, Any]) -> int:
    """Run append/post-processing step (append transformed snapshots to a master CSV)."""
    logger = logging.getLogger(__name__)
    appended_count = 0
    appends = config.get('postprocess', {}).get('append', [])
    if not appends:
        return appended_count

    for append_cfg in appends:
        try:
            source_file = append_cfg['source']
            master_file = append_cfg['master']
            dedupe = append_cfg.get('dedupe', {})  # {'key': 'OpportunityId', 'keep': 'latest'}

            logger.info(f"Appending {source_file} -> {master_file}")

            # Read source
            src_df = pd.read_csv(source_file)

            # Ensure master exists; if not, write with header
            try:
                master_df = pd.read_csv(master_file)
                # Align columns (union) to avoid schema drift failures
                all_cols = list({*master_df.columns.tolist(), *src_df.columns.tolist()})
                master_df = master_df.reindex(columns=all_cols)
                src_df = src_df.reindex(columns=all_cols)
                combined_df = pd.concat([master_df, src_df], ignore_index=True)
            except FileNotFoundError:
                combined_df = src_df

            # Optional dedupe
            if dedupe and 'key' in dedupe:
                key = dedupe['key']
                keep_strategy = dedupe.get('keep', 'latest')
                if key in combined_df.columns:
                    if keep_strategy == 'latest' and 'snapshot_date' in combined_df.columns:
                        combined_df = combined_df.sort_values(by=['snapshot_date']).drop_duplicates(subset=[key], keep='last')
                    else:
                        combined_df = combined_df.drop_duplicates(subset=[key], keep='last')
                else:
                    logger.warning(f"Dedupe key '{key}' not found in columns; skipping dedupe")

            # Save master
            Path(master_file).parent.mkdir(parents=True, exist_ok=True)
            combined_df.to_csv(master_file, index=False)
            logger.info(f"Appended rows. Master now has {len(combined_df)} rows")
            appended_count += len(src_df)

        except Exception as e:
            logger.error(f"Failed to append {append_cfg}: {e}")
            raise

    return appended_count


def run_full_pipeline(config_path: str, dry_run: bool = False):
    """Run the complete pipeline."""
    logger = logging.getLogger(__name__)
    
    # Load configuration
    config = load_config(config_path)
    
    # Apply simple date templating to all string values in config
    def _apply_date(value: Any):
        if isinstance(value, str):
            return value.replace('{date}', date.today().isoformat())
        if isinstance(value, list):
            return [ _apply_date(v) for v in value ]
        if isinstance(value, dict):
            return { k: _apply_date(v) for k, v in value.items() }
        return value
    config = _apply_date(config)
    logger.info(f"Loaded configuration from {config_path}")
    
    if dry_run:
        logger.info("DRY RUN MODE - No actual operations will be performed")
        return
    
    try:
        # Step 1: Export from Salesforce
        logger.info("=== STEP 1: Salesforce Export ===")
        exported_files = run_export_step(config)
        logger.info(f"Exported {len(exported_files)} files")
        
        # Step 2: Transform data
        logger.info("=== STEP 2: Data Transformation ===")
        transformed_files = run_transform_step(config)
        logger.info(f"Transformed {len(transformed_files)} files")
        
        # Step 3: Append/Postprocess
        logger.info("=== STEP 3: Post-processing (Append) ===")
        appended_rows = run_append_step(config)
        logger.info(f"Appended from transformed outputs: {appended_rows} new rows")

        # Step 4: Publish to Tableau
        logger.info("=== STEP 4: Tableau Publishing ===")
        published_items = run_publish_step(config)
        logger.info(f"Published {len(published_items)} items")
        
        logger.info("=== PIPELINE COMPLETE ===")
        summary_data = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'config_path': config_path,
            'exported_count': len(exported_files),
            'transformed_count': len(transformed_files),
            'appended_rows': appended_rows,
            'published_count': len(published_items),
            'status': 'success'
        }
        logger.info(f"Summary: {summary_data['exported_count']} exported, {summary_data['transformed_count']} transformed, {summary_data['appended_rows']} appended, {summary_data['published_count']} published")

        # Write a machine-readable status file
        logs_dir = Path('logs')
        logs_dir.mkdir(parents=True, exist_ok=True)
        status_file = logs_dir / 'last_run_status.json'
        with open(status_file, 'w') as f:
            json.dump(summary_data, f, indent=2)

        # Send notifications
        try:
            notify_status(summary_data)
        except Exception:
            pass

        # Emit a clear success marker for grepping
        print("PIPELINE SUCCESS")
        
    except Exception as e:
        logger.error(f"Pipeline failed: {e}")
        # Record failure status for downstream status checks
        try:
            logs_dir = Path('logs')
            logs_dir.mkdir(parents=True, exist_ok=True)
            status_file = logs_dir / 'last_run_status.json'
            failure_summary = {
                'timestamp': datetime.utcnow().isoformat() + 'Z',
                'config_path': config_path,
                'exported_count': 0,
                'transformed_count': 0,
                'appended_rows': 0,
                'published_count': 0,
                'status': 'failure',
                'error': str(e),
            }
            with open(status_file, 'w') as f:
                json.dump(failure_summary, f, indent=2)
            print("PIPELINE FAILURE")
            try:
                notify_status(failure_summary)
            except Exception:
                pass
        except Exception:
            # Best-effort write; do not mask original failure
            pass
        sys.exit(1)


def list_salesforce_reports():
    """List available Salesforce reports."""
    logger = logging.getLogger(__name__)
    
    try:
        exporter = SalesforceExporter()
        reports = exporter.list_reports()
        
        if not reports:
            logger.info("No reports found")
            return
        
        logger.info(f"Found {len(reports)} reports:")
        for report in reports:
            logger.info(f"  {report['Id']} - {report['Name']} (Folder: {report.get('FolderName', 'Unknown')})")
            
    except Exception as e:
        logger.error(f"Failed to list reports: {e}")
        sys.exit(1)


def list_tableau_projects():
    """List available Tableau projects."""
    logger = logging.getLogger(__name__)
    
    try:
        with TableauPublisher() as publisher:
            projects = publisher.list_projects()
            
            if not projects:
                logger.info("No projects found")
                return
            
            logger.info(f"Found {len(projects)} projects:")
            for project in projects:
                logger.info(f"  {project['id']} - {project['name']}")
                
    except Exception as e:
        logger.error(f"Failed to list projects: {e}")
        sys.exit(1)


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(
        description='Salesforce to Tableau Data Pipeline',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Run full pipeline
  python -m src.pipeline.cli run --config configs/sample.yaml
  
  # Dry run to validate config
  python -m src.pipeline.cli run --config configs/sample.yaml --dry-run
  
  # List Salesforce reports
  python -m src.pipeline.cli list-reports
  
  # List Tableau projects
  python -m src.pipeline.cli list-projects
        """
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Run command
    run_parser = subparsers.add_parser('run', help='Run the data pipeline')
    run_parser.add_argument('--config', required=True, help='Path to YAML config file')
    run_parser.add_argument('--dry-run', action='store_true', help='Validate config without executing')
    run_parser.add_argument('--log-level', default='INFO', choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'])
    
    # List commands
    subparsers.add_parser('list-reports', help='List Salesforce reports')
    subparsers.add_parser('list-projects', help='List Tableau projects')

    # Status command
    status_parser = subparsers.add_parser('status', help='Show last pipeline run status')
    status_parser.add_argument('--json', action='store_true', help='Output raw JSON status')
    status_parser.add_argument('--warn-stale-hours', type=int, default=30, help='Warn if last run is older than N hours')
    
    args = parser.parse_args()
    
    # Setup logging
    setup_logging(args.log_level if hasattr(args, 'log_level') else 'INFO')
    
    # Execute command
    if args.command == 'run':
        run_full_pipeline(args.config, args.dry_run)
    elif args.command == 'list-reports':
        list_salesforce_reports()
    elif args.command == 'list-projects':
        list_tableau_projects()
    elif args.command == 'status':
        # Print a concise status summary from logs/last_run_status.json
        status_path = Path('logs') / 'last_run_status.json'
        if not status_path.exists():
            print("No status found. Run the pipeline first.")
            return
        try:
            with open(status_path, 'r') as f:
                data = json.load(f)
        except Exception as exc:
            print(f"Failed to read status file: {exc}")
            sys.exit(2)

        if getattr(args, 'json', False):
            print(json.dumps(data, indent=2))
            return

        ts = data.get('timestamp')
        status_val = data.get('status', 'unknown')
        exported = data.get('exported_count', 0)
        transformed = data.get('transformed_count', 0)
        appended = data.get('appended_rows', 0)
        published = data.get('published_count', 0)
        error_msg = data.get('error')

        # Staleness check
        stale_warning = ''
        try:
            if ts:
                # parse simple ISO 8601 with Z
                dt = datetime.fromisoformat(ts.replace('Z', '+00:00'))
                age_hours = (datetime.utcnow() - dt.replace(tzinfo=None)).total_seconds() / 3600.0
                if age_hours > args.warn_stale_hours:
                    stale_warning = f" [STALE: {age_hours:.1f}h old]"
        except Exception:
            pass

        print(f"Last run: {ts}{stale_warning}")
        print(f"Status: {status_val}")
        if status_val == 'success':
            print(f"Exported: {exported} | Transformed: {transformed} | Appended rows: {appended} | Published: {published}")
            print("OK")
        else:
            print(f"Error: {error_msg}")
            print("NOT OK")
    else:
        parser.print_help()


if __name__ == '__main__':
    main()


