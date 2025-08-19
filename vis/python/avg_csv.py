#!/usr/bin/env python
import csv
import argparse
import sys

def average_column_in_range(file_path, column, start_line, end_line, has_header=True, b=False):
    """
    Calculate the average of a specified column for a given range of line numbers.
    Works with space-separated scientific notation values.
    """
    values = []

    with open(file_path, newline='', encoding='utf-8') as csvfile:
        if has_header:
            reader = csv.DictReader(csvfile, delimiter=" ")
            for line_num, row in enumerate(reader, start=2):  # header is line 1
                if start_line <= line_num <= end_line:
                    try:
                        values.append(float(row[column]))
                    except ValueError:
                        if not b:
                            print(f"Skipping non-numeric value at line {line_num}: {row[column]}")
        else:
            reader = csv.reader(csvfile, delimiter=" ", skipinitialspace=True)
            for line_num, row in enumerate(reader, start=1):
                if start_line <= line_num <= end_line:
                    try:
                        values.append(float(row[column]))
                    except (ValueError, IndexError):
                        if not b:
                            print(f"Skipping invalid or missing value at line {line_num}")

    if values:
        avg = sum(values) / len(values)
        if b:
            print(avg)
        else:
            print(f"Average of column '{column}' from lines {start_line} to {end_line}: {avg}")
        return avg
    else:
        print("No valid numeric data found in the specified range.")
        if b:
            sys.exit(1)
        return None


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Calculate the average of a space-separated column over a given line range.")
    parser.add_argument("file", help="Path to the space-separated data file")
    parser.add_argument("column", help="Column name (if header) or column index (if no header)", type=str)
    parser.add_argument("start", help="Start line number (1-based)", type=int)
    parser.add_argument("end", help="End line number (inclusive)", type=int)
    parser.add_argument("--no-header", action="store_true", help="Specify if the file does not have a header")
    parser.add_argument("-b", action="store_true", help="for use in a script")
    args = parser.parse_args()

    # Convert column to int if no header
    if args.no_header:
        try:
            args.column = int(args.column)
        except ValueError:
            print("Error: When using --no-header, column must be an integer index.")
            sys.exit(1)

    average_column_in_range(
        file_path=args.file,
        column=args.column,
        start_line=args.start,
        end_line=args.end,
        has_header=not args.no_header,
        b=args.b
    )
