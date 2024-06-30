import csv
import random
import faker
import os
import sys

# Initialize the Faker generator
fake = faker.Faker()

# Check if the number of arguments provided is correct
if len(sys.argv) < 2:
    print("Usage: python script_name.py num_accounts")
    sys.exit(1)

# Extract the number of test accounts from command line argument
try:
    num_accounts = int(sys.argv[1])
except ValueError:
    print("Error: num_accounts must be an integer")
    sys.exit(1)

# Define the CSV file header
header = ["Name", "BillingStreet", "BillingCity", "BillingState", "BillingPostalCode", "BillingCountry", "External_ID__c"]

# Directory to save the CSV files (one level up and in the data folder)
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.abspath(os.path.join(current_dir, os.pardir))
output_dir = os.path.join(parent_dir, 'data')
os.makedirs(output_dir, exist_ok=True)

# Generate unique test accounts
def generate_test_accounts(num, start_id):
    accounts = []
    for i in range(num):
        name = fake.company()
        street = fake.street_address()
        city = fake.city()
        state = fake.state_abbr()
        postal_code = fake.zipcode()
        country = "US"  # Assuming all test accounts are in the US
        external_id = f"A{str(start_id + i).zfill(9)}"  # Ensure ID is at least 10 characters long with prefix 'A'
        accounts.append([name, street, city, state, postal_code, country, external_id])
    return accounts

# Split the accounts into chunks of 100,000 and write to separate CSV files
chunk_size = 100000
start_id = 800000000
for i in range(0, num_accounts, chunk_size):
    chunk_accounts = generate_test_accounts(min(chunk_size, num_accounts - i), start_id + i)
    filename = os.path.join(output_dir, f'sample_accounts_{i//chunk_size + 1}.csv')
    with open(filename, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(header)
        writer.writerows(chunk_accounts)
    print(f"{len(chunk_accounts)} test accounts have been generated and saved to '{filename}'.")

print("All test accounts have been generated and saved.")
