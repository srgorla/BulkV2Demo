#!/bin/bash


# Source the utility script
. utils.sh

# Function to display usage
usage() {
    echo "Usage: $0 --target-org <TARGET_ORG_ALIAS> --object <OBJECT_NAME> --operation <OPERATION_NAME> [--external-id <EXTERNAL_ID>] [--file-pattern <FILE_PATTERN>]"
    echo "   or: $0 -t <TARGET_ORG_ALIAS> -o <OBJECT_NAME> -p <OPERATION_NAME> [-e <EXTERNAL_ID>] [-f <FILE_PATTERN>]"
    exit 1
}

# Default values
FILE_PATTERN="OutputResult%d.csv"

# Parse named parameters
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --target-org|-t)
            TARGET_ORG_ALIAS="$2"
            shift 2
            ;;
        --object|-o)
            OBJECT_NAME="$2"
            shift 2
            ;;
        --operation|-p)
            OPERATION_NAME="$2"
            shift 2
            ;;
        --external-id|-e)
            EXTERNAL_ID="$2"
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
if [ -z "$TARGET_ORG_ALIAS" ] || [ -z "$OBJECT_NAME" ] || [ -z "$OPERATION_NAME" ]; then
    echo "Error: Missing required parameters."
    usage
fi


echo "TARGET_ORG_ALIAS : " $TARGET_ORG_ALIAS 

# Validate arguments for upsert operation
if [ "$OPERATION_NAME" == "upsert" ]; then
    if [ -z "$EXTERNAL_ID" ]; then
        echo "Error: When the operation is 'upsert', the EXTERNAL_ID parameter is required."
        echo "Usage: $0 <TARGET_ORG_ALIAS> <OBJECT_NAME> <OPERATION_NAME>  <EXTERNAL_ID>"
        exit 1
    fi
else
    if [ "$#" -eq 4 ]; then
        echo "Error: EXTERNAL_ID parameter is only valid for 'upsert' operation."
        echo "Usage: $0 <TARGET_ORG_ALIAS> <OBJECT_NAME> <OPERATION_NAME>  [EXTERNAL_ID]"
        exit 1
    fi
fi

# Retrieve the access token and instance URL dynamically for the target org
TARGET_ORG_INFO=$(sf org display --target-org $TARGET_ORG_ALIAS --json | jq -r '.result')
TARGET_ACCESS_TOKEN=$(echo $TARGET_ORG_INFO | jq -r '.accessToken')
TARGET_INSTANCE_URL=$(echo $TARGET_ORG_INFO | jq -r '.instanceUrl')

# Debugging: Print the retrieved access token and instance URL (you can comment this out later)
echo "Retrieved Access Token for target org: $TARGET_ACCESS_TOKEN"
echo "Retrieved Instance URL for target org: $TARGET_INSTANCE_URL"

# Check if TARGET_ACCESS_TOKEN or TARGET_INSTANCE_URL is empty
if [ -z "$TARGET_ACCESS_TOKEN" ] || [ -z "$TARGET_INSTANCE_URL" ]; then
    echo "Failed to retrieve the access token or instance URL for the target org."
    exit 1
fi

# Define the authorization header for the target org
TARGET_AUTH_HEADER="Authorization: Bearer $TARGET_ACCESS_TOKEN"


# Initialize file counter
file_counter=1

while true; do
    file=$(printf "../data/$FILE_PATTERN" "$file_counter")
    if [ -f "$file" ]; then
        echo "Processing $file..."
        # Create a job for the target org
        TARGET_JOB_ID=$(create_job "$OBJECT_NAME" "$OPERATION_NAME" "$EXTERNAL_ID")

        # Check if TARGET_JOB_ID is empty
        if [ -z "$TARGET_JOB_ID" ]; then
            echo "Failed to create the job for the target org."
            exit 1
        fi

        echo "Created Job for the target org with ID: $TARGET_JOB_ID"

        # Upload the CSV file to the target org
        UPLOAD_RESPONSE=$(upload_data "$TARGET_JOB_ID" "$file")

        # Check if the upload was successful
        if [ "$UPLOAD_RESPONSE" -ne 201 ]; then
            echo "Failed to upload $file. HTTP response code: $UPLOAD_RESPONSE"
            exit 1
        fi

        echo "Upload of $file completed successfully."

        # Close the job for the target org
        CLOSE_JOB_RESPONSE=$(close_job "$TARGET_JOB_ID")

        # Check if closing the job was successful
        if [ "$CLOSE_JOB_RESPONSE" -ne 200 ]; then
            echo "Failed to close the job $TARGET_JOB_ID. HTTP response code: $CLOSE_JOB_RESPONSE"
            exit 1
        fi

        echo "Job $TARGET_JOB_ID closed successfully."
    else
        # Break if no file is found with the current counter value
        if [ $file_counter -eq 1 ]; then
            echo "No files found to process with pattern $FILE_PATTERN."
            exit 1
        else
            break
        fi
    fi
    file_counter=$((file_counter + 1))
done

echo "Bulk v2 job(s) are submitted to the target org."