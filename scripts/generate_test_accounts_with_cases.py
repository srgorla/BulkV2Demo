import csv
import random
import pandas as pd
import faker
import os
import sys

# Initialize the Faker generator
fake = faker.Faker()

# Define the number of test accounts and cases
num_accounts = 100
cases_per_account = 5

# Define the CSV file header for accounts
account_header = ["Name", "BillingStreet", "BillingCity", "BillingState", "BillingPostalCode", "BillingCountry", "External_ID__c"]

# Directory to save the CSV files (one level up and in the data folder)
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.abspath(os.path.join(current_dir, os.pardir))
output_dir = os.path.join(parent_dir, 'data')
os.makedirs(output_dir, exist_ok=True)

# Generate test accounts
test_accounts = []

for _ in range(num_accounts):
    name = fake.company()
    street = fake.street_address()
    city = fake.city()
    state = fake.state_abbr()
    postal_code = fake.zipcode()
    country = "US"  # Assuming all test accounts are in the US
    external_id = f"CD{random.randint(100000, 999999)}"
    
    test_accounts.append([name, street, city, state, postal_code, country, external_id])

# Save the test accounts to a CSV file in the parent directory's data folder
account_filename = os.path.join(output_dir, 'test_accounts_1.csv')
with open(account_filename, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(account_header)
    writer.writerows(test_accounts)

print(f"{num_accounts} test accounts have been generated and saved to '{account_filename}'.")

# Load the generated test accounts
accounts_df = pd.read_csv(account_filename)

# Define the CSV file header for cases
case_header = ["Subject", "Description", "Status", "Priority", "Origin", "Reason", "Type", "Account.External_ID__c"]

# Predefined sample data for cases
subjects = ["Electrical circuit malfunctioning", "System update required", "Network connectivity issue", "Software installation problem", "Hardware failure"]
statuses = ["New", "Working", "Closed", "Escalated"]
priorities = ["Low", "Medium", "High"]
origins = ["Phone", "Email", "Web", "Chat"]
reasons = ["Performance", "Software", "Hardware", "Connectivity"]
types = ["Electrical", "Software", "Hardware", "Network"]

# Generate test cases
test_cases = []

for _, account in accounts_df.iterrows():
    for _ in range(cases_per_account):
        subject = random.choice(subjects)
        description = fake.sentence()
        status = random.choice(statuses)
        priority = random.choice(priorities)
        origin = random.choice(origins)
        reason = random.choice(reasons)
        case_type = random.choice(types)
        external_id = account["External_ID__c"]
        
        test_cases.append([subject, description, status, priority, origin, reason, case_type, external_id])

# Save the test cases to a CSV file in the parent directory's data folder
case_filename = os.path.join(output_dir, 'test_cases_1.csv')
with open(case_filename, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(case_header)
    writer.writerows(test_cases)

print(f"{len(test_cases)} cases for each of the {num_accounts} test accounts have been generated and saved to '{case_filename}'.")
