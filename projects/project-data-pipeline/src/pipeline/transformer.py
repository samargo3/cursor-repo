"""
Data Transformation Module

Applies YAML-defined transformations to CSV data using pandas.
Supports column operations, filtering, aggregations, and custom expressions.
"""

import pandas as pd
import numpy as np
import logging
from typing import Dict, List, Any, Union
from pathlib import Path

logger = logging.getLogger(__name__)


class DataTransformer:
    """Handles data transformations based on YAML configuration."""
    
    def __init__(self):
        """Initialize the transformer."""
        self.df = None
    
    def load_csv(self, file_path: str) -> 'DataTransformer':
        """
        Load CSV file into pandas DataFrame.
        
        Args:
            file_path: Path to CSV file
            
        Returns:
            Self for method chaining
        """
        try:
            logger.info(f"Loading CSV from {file_path}")
            self.df = pd.read_csv(file_path)
            logger.info(f"Loaded {len(self.df)} rows and {len(self.df.columns)} columns")
            return self
            
        except Exception as e:
            logger.error(f"Failed to load CSV {file_path}: {e}")
            raise
    
    def apply_transforms(self, transforms: List[Dict]) -> 'DataTransformer':
        """
        Apply a list of transformations to the DataFrame.
        
        Args:
            transforms: List of transformation dictionaries
            
        Returns:
            Self for method chaining
        """
        for i, transform in enumerate(transforms):
            try:
                logger.info(f"Applying transform {i+1}/{len(transforms)}: {transform.get('type', 'unknown')}")
                self._apply_single_transform(transform)
                
            except Exception as e:
                logger.error(f"Failed to apply transform {i+1}: {e}")
                raise
        
        return self
    
    def _apply_single_transform(self, transform: Dict):
        """Apply a single transformation step."""
        transform_type = transform.get('type')
        
        if transform_type == 'rename_columns':
            self._rename_columns(transform.get('mapping', {}))
            
        elif transform_type == 'filter_rows':
            self._filter_rows(transform.get('expr', ''))
            
        elif transform_type == 'derive_column':
            self._derive_column(
                transform.get('name', ''),
                transform.get('expr', '')
            )
        
        elif transform_type == 'add_constant_column':
            self._add_constant_column(
                transform.get('name', ''),
                transform.get('value', None)
            )
        
        elif transform_type == 'data_quality_check':
            self._data_quality_check(transform.get('checks', []))
        
        elif transform_type == 'extract_currency':
            self._extract_currency(
                transform.get('column', ''),
                transform.get('output_column', '')
            )
        
        elif transform_type == 'extract_currency_code':
            self._extract_currency_code(
                transform.get('column', ''),
                transform.get('output_column', '')
            )
        
        elif transform_type == 'resolve_ids_to_names':
            self._resolve_ids_to_names(
                transform.get('mappings', [])
            )
            
        elif transform_type == 'drop_columns':
            self._drop_columns(transform.get('columns', []))
            
        elif transform_type == 'sort_rows':
            self._sort_rows(
                transform.get('by', []),
                transform.get('ascending', True)
            )
            
        elif transform_type == 'group_aggregate':
            self._group_aggregate(
                transform.get('group_by', []),
                transform.get('aggregations', {})
            )
            
        elif transform_type == 'pivot_table':
            self._pivot_table(
                transform.get('index', []),
                transform.get('columns', []),
                transform.get('values', []),
                transform.get('aggfunc', 'sum')
            )
        
        elif transform_type == 'select_columns':
            self._select_columns(transform.get('columns', []))
        
        elif transform_type == 'cast_dtypes':
            self._cast_dtypes(transform.get('dtypes', {}))

        elif transform_type == 'coalesce_columns':
            self._coalesce_columns(
                transform.get('target', ''),
                transform.get('sources', [])
            )
        
        elif transform_type == 'clean_html_content':
            self._clean_html_content(transform.get('columns', []))
            
        else:
            raise ValueError(f"Unknown transform type: {transform_type}")
    
    def _rename_columns(self, mapping: Dict[str, str]):
        """Rename columns according to mapping."""
        self.df = self.df.rename(columns=mapping)
        logger.info(f"Renamed columns: {mapping}")
    
    def _filter_rows(self, expr: str):
        """Filter rows using pandas query expression."""
        if not expr:
            return
        
        original_count = len(self.df)
        self.df = self.df.query(expr)
        filtered_count = len(self.df)
        logger.info(f"Filtered rows: {original_count} -> {filtered_count} (removed {original_count - filtered_count})")
    
    def _derive_column(self, name: str, expr: str):
        """Create a new column using pandas eval expression."""
        if not name or not expr:
            return
        
        try:
            # Use pandas eval for safe expression evaluation
            self.df[name] = self.df.eval(expr)
            logger.info(f"Created derived column '{name}' with expression: {expr}")
        except Exception as e:
            logger.error(f"Failed to create derived column '{name}': {e}")
            raise
    
    def _add_constant_column(self, name: str, value: Any):
        """Add a column with a constant value for all rows."""
        if not name:
            return
        self.df[name] = value
        logger.info(f"Added constant column '{name}' with value: {value}")

    def _clean_html_content(self, columns: List[str]):
        """Clean HTML tags and normalize whitespace in specified columns."""
        import re
        for col in columns:
            if col in self.df.columns:
                # Remove HTML tags and normalize whitespace
                self.df[col] = self.df[col].astype(str).str.replace(r'<[^>]+>', '', regex=True)
                self.df[col] = self.df[col].str.replace(r'\s+', ' ', regex=True).str.strip()
                # Replace 'nan' strings with actual NaN
                self.df[col] = self.df[col].replace('nan', pd.NA)
                logger.info(f"Cleaned HTML content in column '{col}'")
    
    def _data_quality_check(self, checks: List[Dict]):
        """Perform data quality checks and log results."""
        if not checks:
            return
        
        logger.info("=== DATA QUALITY CHECKS ===")
        for i, check in enumerate(checks):
            check_type = check.get('type')
            check_name = check.get('name', f'Check {i+1}')
            
            try:
                if check_type == 'null_check':
                    self._check_nulls(check_name, check.get('columns', []))
                elif check_type == 'range_check':
                    self._check_range(check_name, check.get('column', ''), check.get('min'), check.get('max'))
                elif check_type == 'value_check':
                    self._check_values(check_name, check.get('column', ''), check.get('allowed_values', []))
                elif check_type == 'row_count_check':
                    self._check_row_count(check_name, check.get('min_rows', 0), check.get('max_rows', float('inf')))
                else:
                    logger.warning(f"Unknown check type: {check_type}")
            except Exception as e:
                logger.error(f"Data quality check '{check_name}' failed: {e}")
    
    def _check_nulls(self, check_name: str, columns: List[str]):
        """Check for null values in specified columns."""
        if not columns:
            return
        
        null_counts = {}
        for col in columns:
            if col in self.df.columns:
                null_count = self.df[col].isnull().sum()
                null_counts[col] = null_count
        
        total_nulls = sum(null_counts.values())
        if total_nulls > 0:
            logger.warning(f"{check_name}: Found {total_nulls} null values: {null_counts}")
        else:
            logger.info(f"{check_name}: No null values found in {columns}")
    
    def _check_range(self, check_name: str, column: str, min_val: float = None, max_val: float = None):
        """Check if values in column are within specified range."""
        if column not in self.df.columns:
            logger.warning(f"{check_name}: Column '{column}' not found")
            return
        
        numeric_data = pd.to_numeric(self.df[column], errors='coerce')
        out_of_range = 0
        
        if min_val is not None:
            out_of_range += (numeric_data < min_val).sum()
        if max_val is not None:
            out_of_range += (numeric_data > max_val).sum()
        
        if out_of_range > 0:
            logger.warning(f"{check_name}: {out_of_range} values out of range [{min_val}, {max_val}] in '{column}'")
        else:
            logger.info(f"{check_name}: All values in range [{min_val}, {max_val}] for '{column}'")
    
    def _check_values(self, check_name: str, column: str, allowed_values: List[str]):
        """Check if values in column are in allowed list."""
        if column not in self.df.columns:
            logger.warning(f"{check_name}: Column '{column}' not found")
            return
        
        invalid_values = ~self.df[column].isin(allowed_values)
        invalid_count = invalid_values.sum()
        
        if invalid_count > 0:
            unique_invalid = self.df[column][invalid_values].unique()
            logger.warning(f"{check_name}: {invalid_count} invalid values in '{column}': {list(unique_invalid)}")
        else:
            logger.info(f"{check_name}: All values valid in '{column}'")
    
    def _check_row_count(self, check_name: str, min_rows: int, max_rows: float):
        """Check if row count is within expected range."""
        row_count = len(self.df)
        if row_count < min_rows or row_count > max_rows:
            logger.warning(f"{check_name}: Row count {row_count} outside expected range [{min_rows}, {max_rows}]")
        else:
            logger.info(f"{check_name}: Row count {row_count} within expected range [{min_rows}, {max_rows}]")
    
    def _extract_currency(self, column: str, output_column: str):
        """Extract numeric value from Salesforce currency OrderedDict format."""
        if column not in self.df.columns:
            logger.warning(f"Column '{column}' not found for currency extraction")
            return
        
        if not output_column:
            output_column = f"{column}_numeric"
        
        def extract_amount(value):
            if pd.isna(value) or value == '':
                return None
            try:
                # Handle OrderedDict format: OrderedDict([('amount', 120000), ('currency', 'USD')])
                if 'OrderedDict' in str(value):
                    import re
                    # Use regex to extract the amount value
                    match = re.search(r"'amount',\s*(\d+(?:\.\d+)?)", str(value))
                    if match:
                        return float(match.group(1))
                    else:
                        return None
                else:
                    # Try direct conversion for simple values
                    return float(value)
            except (ValueError, AttributeError):
                return None
        
        self.df[output_column] = self.df[column].apply(extract_amount)
        logger.info(f"Extracted currency values from '{column}' to '{output_column}'")
    
    def _extract_currency_code(self, column: str, output_column: str):
        """Extract currency code (e.g., USD) from Salesforce currency OrderedDict format."""
        if column not in self.df.columns:
            logger.warning(f"Column '{column}' not found for currency code extraction")
            return
        
        if not output_column:
            output_column = f"{column}_currency"
        
        def extract_code(value):
            if pd.isna(value) or value == '':
                return None
            try:
                text = str(value)
                if 'OrderedDict' in text:
                    import re
                    match = re.search(r"'currency',\s*'([A-Z]{3})'", text)
                    if match:
                        return match.group(1)
                    return None
                return None
            except Exception:
                return None
        
        self.df[output_column] = self.df[column].apply(extract_code)
        logger.info(f"Extracted currency codes from '{column}' to '{output_column}'")
    
    def _resolve_ids_to_names(self, mappings: List[Dict]):
        """Resolve Salesforce IDs to actual names using SOQL queries."""
        if not mappings:
            return
        
        # Import here to avoid circular imports
        try:
            from .salesforce_export import SalesforceExporter
            sf_exporter = SalesforceExporter()
            sf = sf_exporter.sf
        except Exception as e:
            logger.error(f"Failed to connect to Salesforce for ID resolution: {e}")
            return
        
        logger.info("=== RESOLVING IDs TO NAMES ===")
        
        for mapping in mappings:
            column = mapping.get('column', '')
            object_type = mapping.get('object_type', '')
            name_field = mapping.get('name_field', 'Name')
            
            if not column or not object_type or column not in self.df.columns:
                logger.warning(f"Skipping invalid mapping: {mapping}")
                continue
            
            try:
                # Get unique IDs from the column
                unique_ids = self.df[column].dropna().unique()
                if len(unique_ids) == 0:
                    logger.info(f"No IDs found in column '{column}'")
                    continue
                
                logger.info(f"Resolving {len(unique_ids)} {object_type} IDs in column '{column}'")
                
                # Query Salesforce to get ID -> Name mappings
                id_to_name = {}
                batch_size = 200  # Salesforce SOQL limit
                
                for i in range(0, len(unique_ids), batch_size):
                    batch_ids = unique_ids[i:i + batch_size]
                    # Create SOQL query with IN clause
                    id_list = "', '".join(batch_ids)
                    query = f"SELECT Id, {name_field} FROM {object_type} WHERE Id IN ('{id_list}')"
                    
                    try:
                        result = sf.query(query)
                        for record in result['records']:
                            id_to_name[record['Id']] = record[name_field]
                    except Exception as e:
                        logger.warning(f"Failed to query batch {i//batch_size + 1}: {e}")
                
                # Replace IDs with names in the DataFrame
                original_count = len(self.df)
                self.df[column] = self.df[column].map(id_to_name).fillna(self.df[column])
                resolved_count = (self.df[column] != self.df[column].map(id_to_name).fillna(self.df[column])).sum()
                
                logger.info(f"Resolved {len(id_to_name)} {object_type} IDs to names in column '{column}'")
                
            except Exception as e:
                logger.error(f"Failed to resolve IDs for column '{column}': {e}")
        
        logger.info("=== ID RESOLUTION COMPLETE ===")
    
    def _drop_columns(self, columns: List[str]):
        """Drop specified columns."""
        if not columns:
            return
        
        existing_columns = [col for col in columns if col in self.df.columns]
        if existing_columns:
            self.df = self.df.drop(columns=existing_columns)
            logger.info(f"Dropped columns: {existing_columns}")
        
        missing_columns = [col for col in columns if col not in self.df.columns]
        if missing_columns:
            logger.warning(f"Columns not found for dropping: {missing_columns}")
    
    def _sort_rows(self, by: List[str], ascending: Union[bool, List[bool]] = True):
        """Sort rows by specified columns."""
        if not by:
            return
        
        existing_columns = [col for col in by if col in self.df.columns]
        if existing_columns:
            self.df = self.df.sort_values(by=existing_columns, ascending=ascending)
            logger.info(f"Sorted by columns: {existing_columns}")
        
        missing_columns = [col for col in by if col not in self.df.columns]
        if missing_columns:
            logger.warning(f"Columns not found for sorting: {missing_columns}")
    
    def _group_aggregate(self, group_by: List[str], aggregations: Dict[str, str]):
        """Group by columns and apply aggregations."""
        if not group_by or not aggregations:
            return
        
        existing_group_cols = [col for col in group_by if col in self.df.columns]
        if not existing_group_cols:
            logger.warning("No valid group-by columns found")
            return
        
        # Build aggregation dictionary
        agg_dict = {}
        for col, func in aggregations.items():
            if col in self.df.columns:
                agg_dict[col] = func
            else:
                logger.warning(f"Column '{col}' not found for aggregation")
        
        if agg_dict:
            self.df = self.df.groupby(existing_group_cols).agg(agg_dict).reset_index()
            logger.info(f"Grouped by {existing_group_cols} with aggregations: {agg_dict}")
    
    def _pivot_table(self, index: List[str], columns: List[str], values: List[str], aggfunc: str = 'sum'):
        """Create pivot table."""
        if not index or not values:
            return
        
        existing_index = [col for col in index if col in self.df.columns]
        existing_values = [col for col in values if col in self.df.columns]
        
        if not existing_index or not existing_values:
            logger.warning("Missing required columns for pivot table")
            return
        
        columns_param = [col for col in columns if col in self.df.columns] if columns else None
        
        self.df = pd.pivot_table(
            self.df,
            index=existing_index,
            columns=columns_param,
            values=existing_values,
            aggfunc=aggfunc,
            fill_value=0
        ).reset_index()
        
        logger.info(f"Created pivot table with index: {existing_index}, values: {existing_values}")
    
    def _select_columns(self, columns: List[str]):
        """Select and order columns. Ignores columns that do not exist; preserves only provided ones."""
        if not columns:
            return
        existing = [c for c in columns if c in self.df.columns]
        if not existing:
            logger.warning("No matching columns found to select")
            return
        self.df = self.df[existing]
        logger.info(f"Selected and ordered columns: {existing}")
    
    def _cast_dtypes(self, dtypes: Dict[str, str]):
        """Cast columns to specified dtypes. Supported: float64, int64, bool, string, datetime64[ns]."""
        if not dtypes:
            return
        for col, dtype in dtypes.items():
            if col not in self.df.columns:
                logger.warning(f"Column '{col}' not found for dtype casting")
                continue
            try:
                if dtype in ('float', 'float64'):
                    self.df[col] = pd.to_numeric(self.df[col], errors='coerce')
                elif dtype in ('int', 'int64'):
                    # Convert common boolean-like strings to 0/1 then to int
                    self.df[col] = (self.df[col]
                        .replace({True: 1, False: 0, 'True': 1, 'False': 0, 'true': 1, 'false': 0})
                    )
                    self.df[col] = pd.to_numeric(self.df[col], errors='coerce').astype('Int64').astype('float').fillna(0).astype('int64')
                elif dtype in ('bool', 'boolean'):
                    self.df[col] = self.df[col].astype(str).str.lower().isin(['true', '1', 'yes', 'y'])
                elif dtype in ('str', 'string', 'object'):
                    self.df[col] = self.df[col].astype(str)
                elif dtype.startswith('datetime'):
                    self.df[col] = pd.to_datetime(self.df[col], errors='coerce')
                else:
                    logger.warning(f"Unsupported dtype '{dtype}' for column '{col}'")
            except Exception as e:
                logger.warning(f"Failed to cast column '{col}' to {dtype}: {e}")

    def _coalesce_columns(self, target: str, sources: List[str]):
        """Fill target column with the first non-null from sources in order. Creates target if missing."""
        if not sources:
            return
        if target and target not in self.df.columns:
            # initialize target with NaN
            self.df[target] = pd.NA
        work_col = target if target else sources[0]
        series = self.df[work_col] if work_col in self.df.columns else pd.Series([pd.NA]*len(self.df))
        for col in sources:
            if col in self.df.columns:
                series = series.combine_first(self.df[col])
        if target:
            self.df[target] = series
        else:
            # overwrite the first source if no explicit target was given
            self.df[sources[0]] = series
        logger.info(f"Coalesced columns into '{target or sources[0]}': {sources}")
    
    def save_csv(self, output_path: str) -> str:
        """
        Save DataFrame to CSV file.
        
        Args:
            output_path: Path to save CSV file
            
        Returns:
            Path to saved file
        """
        try:
            # Create output directory if it doesn't exist
            Path(output_path).parent.mkdir(parents=True, exist_ok=True)
            
            self.df.to_csv(output_path, index=False)
            logger.info(f"Saved {len(self.df)} rows to {output_path}")
            return output_path
            
        except Exception as e:
            logger.error(f"Failed to save CSV to {output_path}: {e}")
            raise
    
    def get_summary(self) -> Dict[str, Any]:
        """
        Get summary statistics of the current DataFrame.
        
        Returns:
            Dictionary with summary information
        """
        if self.df is None:
            return {}
        
        return {
            'rows': len(self.df),
            'columns': len(self.df.columns),
            'column_names': list(self.df.columns),
            'dtypes': self.df.dtypes.to_dict(),
            'memory_usage': self.df.memory_usage(deep=True).sum(),
            'null_counts': self.df.isnull().sum().to_dict()
        }


