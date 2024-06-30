import pandas as pd
import glob
import os
import csv

# Define the directory containing the CSV files
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.abspath(os.path.join(current_dir, os.pardir))
input_dir = os.path.join(parent_dir, 'data')
output_file = os.path.join(input_dir, 'sample_accounts_consolidated_1.csv')

# Use glob to find all CSV files matching the pattern
csv_files = glob.glob(os.path.join(input_dir, 'sample_accounts_*.csv'))

# Initialize an empty list to store dataframes
dataframes = []

# Iterate through the list of CSV files and read them into dataframes
for file in csv_files:
    df = pd.read_csv(file)
    dataframes.append(df)

# Concatenate all dataframes into a single dataframe
consolidated_df = pd.concat(dataframes, ignore_index=True)

# Save the consolidated dataframe to a new CSV file with CRLF line endings
with open(output_file, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file, lineterminator='\r\n', quoting=csv.QUOTE_MINIMAL)
    writer.writerow(consolidated_df.columns)
    writer.writerows(consolidated_df.values)

print(f"All CSV files have been consolidated into '{output_file}'.")
