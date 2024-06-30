#!/bin/bash

# Retrieve Cases with Account ExternalId starting CD
./retrieveSFRecords.sh --target-org dcdemo --query "SELECT id FROM Case where  account.External_ID__c like 'CD%' " --file-pattern "CaseDelete%d.csv" -m 100000

# Retrieve opportunities with Account ExternalId starting CD
./retrieveSFRecords.sh --target-org dcdemo --query "SELECT id FROM opportunity where  account.External_ID__c like 'CD%' " --file-pattern "CaseDelete%d.csv" -m 100000

# Retrieve Accounts with ExternalId starting CD
./retrieveSFRecords.sh --target-org dcdemo --query "SELECT id FROM Account where  External_ID__c like 'CD%' " --file-pattern "AccountDelete%d.csv" -m 100000

# Delete Cases with Accounts ExternalId starting CD
./trigger_bulk_v2_jobs.sh --target-org dcdemo --object Case --operation hardDelete --file-pattern "CaseDelete%d.csv"

# Wait for a short time before checking again
sleep 30

# Delete Cases with Accounts ExternalId starting CD
./trigger_bulk_v2_jobs.sh --target-org dcdemo --object opportunity --operation hardDelete --file-pattern "OpportunityDelete%d.csv"

# Delete Account with ExternalId starting CD
./trigger_bulk_v2_jobs.sh --target-org dcdemo --object Account --operation hardDelete --file-pattern "AccountDelete%d.csv"