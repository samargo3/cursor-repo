"""
Validation utility to compare a produced CSV (snapshot or master)
against a reference sample export from Salesforce. Fails fast on
schema or value mismatches.

Usage:
  python -m src.pipeline.validate \
    --sample "/Users/you/Documents/Data Sets/sample.csv" \
    --file data/output/opportunities_weekly_master.csv \
    --key "Opportunity ID" \
    [--max-row-diffs 10] [--strict]
"""

from __future__ import annotations

import argparse
import sys
from typing import List, Dict

import pandas as pd


def load_csv(path: str) -> pd.DataFrame:
    try:
        return pd.read_csv(path)
    except Exception as exc:
        print(f"ERROR: Failed to read CSV '{path}': {exc}")
        sys.exit(2)


def compare_schema(sample: pd.DataFrame, current: pd.DataFrame) -> Dict[str, List[str]]:
    sample_cols = list(sample.columns)
    current_cols = list(current.columns)

    missing_in_current = [c for c in sample_cols if c not in current_cols]
    extra_in_current = [c for c in current_cols if c not in sample_cols]
    order_mismatch = (sample_cols != current_cols)

    return {
        "missing_in_current": missing_in_current,
        "extra_in_current": extra_in_current,
        "order_mismatch": ["Column order differs"] if order_mismatch else [],
    }


def compare_values(sample: pd.DataFrame, current: pd.DataFrame, key: str, max_examples: int = 5) -> Dict[str, object]:
    if key not in sample.columns or key not in current.columns:
        return {"error": f"Key column '{key}' must exist in both sample and current."}

    common_cols = [c for c in sample.columns if c in current.columns]

    merged = sample[common_cols].merge(
        current[common_cols], on=key, how="inner", suffixes=("_s", "_c")
    )

    # If many rows, limit checks to shared keys present in both
    mismatches: Dict[str, int] = {}
    examples: Dict[str, pd.DataFrame] = {}

    for col in common_cols:
        if col == key:
            continue
        a = merged[f"{col}_s"].astype(str).fillna("")
        b = merged[f"{col}_c"].astype(str).fillna("")
        diff_mask = a != b
        count = int(diff_mask.sum())
        if count > 0:
            mismatches[col] = count
            examples[col] = merged.loc[diff_mask, [key, f"{col}_s", f"{col}_c"]].head(max_examples)

    return {"mismatches": mismatches, "examples": examples, "joined_rows": len(merged)}


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate CSV against a Salesforce sample export")
    parser.add_argument("--sample", required=True, help="Path to sample CSV (manual export)")
    parser.add_argument("--file", required=True, help="Path to produced CSV (snapshot or master)")
    parser.add_argument("--key", required=True, help="Join key column, e.g., 'Opportunity ID'")
    parser.add_argument("--max-row-diffs", type=int, default=10, help="Max example rows per mismatched column to print")
    parser.add_argument("--strict", action="store_true", help="Exit non-zero on any mismatch")
    args = parser.parse_args()

    sample = load_csv(args.sample)
    current = load_csv(args.file)

    print("=== Schema Comparison ===")
    schema_diff = compare_schema(sample, current)
    for k, v in schema_diff.items():
        print(f"{k}: {v}")

    has_schema_issue = any(len(v) > 0 for v in schema_diff.values())

    print("\n=== Value Comparison ===")
    values = compare_values(sample, current, args.key, args.max_row_diffs)
    if "error" in values:
        print("ERROR:", values["error"])
        sys.exit(2)

    print(f"Joined rows on key '{args.key}': {values['joined_rows']}")
    mismatches: Dict[str, int] = values.get("mismatches", {})  # type: ignore
    if mismatches:
        # Print top 10 mismatched columns
        top = sorted(mismatches.items(), key=lambda x: -x[1])[:10]
        print("Top mismatched columns:", top)

        # Print examples
        examples: Dict[str, pd.DataFrame] = values.get("examples", {})  # type: ignore
        for col, df in examples.items():
            print(f"\nExamples for {col}:")
            try:
                print(df.to_string(index=False))
            except Exception:
                print(df.head().to_string(index=False))
    else:
        print("No value mismatches detected on common columns.")

    if args.strict and (has_schema_issue or bool(mismatches)):
        print("\nSTRICT MODE: Mismatches detected. Exiting with code 1.")
        sys.exit(1)

    print("\nValidation complete.")


if __name__ == "__main__":
    main()


