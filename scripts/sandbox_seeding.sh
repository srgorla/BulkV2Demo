#!/bin/bash

# Generata Accounts and related records Sample Data in local environment first
python3 generate_test_accounts_with_relatedRecords.py

# Upsert Accounts with ExternalId starting CD
./trigger_bulk_v2_jobs.sh --target-org  dcdemo --object Account --operation upsert --external-id External_ID__c --file-pattern "test_accounts_%d.csv"

# Wait for a short time before checking again
sleep 30

# Insert Cases for Accounts with ExternalId starting CD
./trigger_bulk_v2_jobs.sh --target-org  dcdemo --object Case --operation insert --file-pattern "test_cases_%d.csv"

sleep 30
# Insert Opportunities for Accounts with ExternalId starting CD
./trigger_bulk_v2_jobs.sh --target-org  dcdemo --object Opportunity --operation insert --file-pattern "test_opportunities_%d.csv"