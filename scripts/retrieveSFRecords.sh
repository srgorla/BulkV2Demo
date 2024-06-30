#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 --target-org <TARGET_ORG_ALIAS> --query <SOQL_QUERY>  [--max_records <MAX_RECORDS>] [--file-pattern <FILE_PATTERN>]"
    echo " or: $0 -t <TARGET_ORG_ALIAS> -q <SOQL_QUERY>  [--max_records <MAX_RECORDS>] [--file-pattern <FILE_PATTERN>]"
    exit 1
}

# Default values
MAX_RECORDS=2500000
FILE_PATTERN="OutputResult%d.csv"

# Parse named parameters
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --target-org|-t)
            TARGET_ORG_ALIAS="$2"
            shift 2
            ;;
        --query|-q)
            QUERY="$2"
            shift 2
            ;;
        --max-records|-m)
            MAX_RECORDS="$2"
            shift 2
            ;;
        --file-pattern|-f)
            FILE_PATTERN="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter passed: $1"
            usage
            ;;
    esac
done

# Check required parameters
if [ -z "$TARGET_ORG_ALIAS" ] || [ -z "$QUERY" ] ; then
    echo "Error: Missing required parameters."
    usage
fi

# Remove files that match the pattern
PATTERN_TO_DELETE=$(echo $FILE_PATTERN | sed 's/%d/*/')
rm -f $PATTERN_TO_DELETE

# Set initial variables
TEMP_FILE='temp_results.csv'
HEADERS_FILE='response_headers.txt'
JOB_STATUS='temp_job_status.json'

# Retrieve the access token and instance URL dynamically
ORG_INFO=$(sf org display --target-org $TARGET_ORG_ALIAS --json | jq -r '.result')
TARGET_ACCESS_TOKEN=$(echo $ORG_INFO | jq -r '.accessToken')
TARGET_INSTANCE_URL=$(echo $ORG_INFO | jq -r '.instanceUrl')

# Debugging: Print the retrieved access token and instance URL (you can comment this out later)
echo "Retrieved Access Token: $TARGET_ACCESS_TOKEN"
echo "Retrieved Instance URL: $TARGET_INSTANCE_URL"

# Check if TARGET_ACCESS_TOKEN or TARGET_INSTANCE_URL is empty
if [ -z "$TARGET_ACCESS_TOKEN" ] || [ -z "$TARGET_INSTANCE_URL" ]; then
    echo "Failed to retrieve the access token or instance URL."
    exit 1
fi

# Define the authorization header
AUTH_HEADER="Authorization: Bearer $TARGET_ACCESS_TOKEN"

# Create the job
CREATE_JOB_RESPONSE=$(curl -s -L "$TARGET_INSTANCE_URL/services/data/v60.0/jobs/query" \
-H "Content-Type: application/json" \
-H "$AUTH_HEADER" \
-d '{
  "operation" : "query",
  "query" : "'"$QUERY"'",
  "contentType" : "CSV",
  "columnDelimiter" : "COMMA",
  "lineEnding" : "CRLF"
}')

# Extract the job ID from the response
JOB_ID=$(echo $CREATE_JOB_RESPONSE | jq -r '.id')

# Check if JOB_ID is empty
if [ -z "$JOB_ID" ]; then
    echo "Failed to create the job."
    exit 1
fi

echo "Created Job with ID: $JOB_ID"

# Check the job status until it is completed
while true; do
    # Check the job status
    curl -s -L "$TARGET_INSTANCE_URL/services/data/v60.0/jobs/query/$JOB_ID" \
    -H "$AUTH_HEADER" -o $JOB_STATUS

    # Extract the job status from the response
    JOB_STATE=$(jq -r '.state' $JOB_STATUS)

    echo "Current Job State: $JOB_STATE"

    # Check if the job is completed
    if [ "$JOB_STATE" == "JobComplete" ]; then
        break
    elif [ "$JOB_STATE" == "Failed" ]; then
        echo "Job failed."
        exit 1
    fi

    # Wait for a short time before checking again
    sleep 5
done

# Base URL for retrieving results
BASE_URL="$TARGET_INSTANCE_URL/services/data/v60.0/jobs/query/$JOB_ID/results"

# Initialize locator as empty and file counter
locator=""
file_counter=1

# Loop to fetch all records using the locator
while true; do
    if [ -z "$locator" ]; then
        # Initial request without locator
        url="$BASE_URL?maxRecords=$MAX_RECORDS"
    else
        # Subsequent requests with locator
        url="$BASE_URL?locator=$locator&maxRecords=$MAX_RECORDS"
    fi

    # Make the curl request and save headers to a file
    curl -L -D $HEADERS_FILE "$url" -H "$AUTH_HEADER" -o $TEMP_FILE

    # Check if the request succeeded
    if [ $? -ne 0 ]; then
        echo "Failed to fetch data from Salesforce."
        exit 1
    fi

    # Extract the locator from response headers
    locator=$(grep -Fi 'Sforce-Locator:' $HEADERS_FILE | awk '{print $2}' | tr -d '\r')

    # Output file for the current chunk
    output_file=$(printf "$FILE_PATTERN" "$file_counter")

    # Check if the temp file has data
    if [ -s $TEMP_FILE ]; then
    # Ensure the target directory exists
    TARGET_DIR="../data"
    mkdir -p $TARGET_DIR

    # Move the file to the target directory
    mv $TEMP_FILE $TARGET_DIR/$output_file

    echo "File moved to $TARGET_DIR/$output_file"

    else
        echo "No data to save for this request. Skipping file."
    fi

    # Increment the file counter
    file_counter=$((file_counter + 1))

    # Check if there are no more records to fetch or locator is invalid
    if [ -z "$locator" ] || [ "$locator" == "null" ]; then
        break
    fi

    # Optionally, sleep for a short time to avoid hitting rate limits
    sleep 1
done

# Clean up temporary files
rm -f $HEADERS_FILE $JOB_STATUS

echo "All records have been successfully retrieved and saved to result files."
