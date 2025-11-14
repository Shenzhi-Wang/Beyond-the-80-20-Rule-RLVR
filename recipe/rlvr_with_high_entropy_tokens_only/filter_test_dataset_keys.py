#!/usr/bin/env python3
"""Filter parquet files to keep only specified columns: data_source, prompt, reward_model, extra_info."""

from argparse import ArgumentParser
from pathlib import Path

import pandas as pd


def filter_parquet_file(input_path: str, output_path: str, required_keys: list[str]) -> None:
    """Filter a parquet file to keep only specified columns.
    
    Args:
        input_path: Path to input parquet file
        output_path: Path to output parquet file
        required_keys: List of column names to keep
    """
    print(f"Reading {input_path}...")
    df = pd.read_parquet(input_path)
    
    print(f"Original columns: {list(df.columns)}")
    print(f"Original shape: {df.shape}")
    
    # Check which required keys exist in the dataframe
    available_keys = [key for key in required_keys if key in df.columns]
    missing_keys = [key for key in required_keys if key not in df.columns]
    
    if missing_keys:
        print(f"Warning: Missing keys {missing_keys} in {input_path}")
    
    if not available_keys:
        raise ValueError(f"None of the required keys {required_keys} found in {input_path}")
    
    # Filter to keep only the available required keys
    filtered_df = df[available_keys].copy()
    
    print(f"Filtered columns: {list(filtered_df.columns)}")
    print(f"Filtered shape: {filtered_df.shape}")
    
    # Create output directory if it doesn't exist
    output_path_obj = Path(output_path)
    output_path_obj.parent.mkdir(parents=True, exist_ok=True)
    
    # Save filtered dataframe
    print(f"Saving to {output_path}...")
    filtered_df.to_parquet(output_path, index=False)
    print(f"Successfully saved filtered data to {output_path}")


def main():
    parser = ArgumentParser(description="Filter parquet files to keep only specified columns")
    parser.add_argument(
        "--input_file",
        type=str,
        required=True,
        help="Path to input parquet file"
    )
    parser.add_argument(
        "--output_file",
        type=str,
        default=None,
        help="Path to output parquet file (default: overwrite input file)"
    )
    parser.add_argument(
        "--keys",
        type=str,
        nargs="+",
        default=["data_source", "prompt", "reward_model", "extra_info"],
        help="Column names to keep (default: data_source prompt reward_model extra_info)"
    )
    args = parser.parse_args()
    
    output_path = args.output_file if args.output_file else args.input_file
    
    filter_parquet_file(args.input_file, output_path, args.keys)


if __name__ == "__main__":
    main()

