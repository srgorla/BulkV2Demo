#!/bin/bash

# Function to create a job in the target org
create_job() {
    local object_name=$1
    local operation_name=$2
    local external_id=${3:-}
    # Create job configuration JSON
    local job_config='{
      "operation" : "'"$operation_name"'",
      "object" : "'"$object_name"'",
      "contentType" : "CSV",
      "columnDelimiter" : "COMMA",
      "lineEnding" : "CRLF"
    }'

    # If the operation is upsert, add the externalIdFieldName
    if [[ "$operation_name" == "upsert" && -n "$external_id" ]]; then
        job_config=$(echo "$job_config" | jq --arg external_id "$external_id" '. + {externalIdFieldName: $external_id}')
    fi

    local job_response=$(curl -s -L "$TARGET_INSTANCE_URL/services/data/v60.0/jobs/ingest" \
    -H "Content-Type: application/json" \
    -H "$TARGET_AUTH_HEADER" \
    -d "$job_config")
    echo "$job_response" | jq -r '.id'
}

# Function to upload data to a job in the target org
upload_data() {
    local job_id=$1
    local data_file=$2
    local upload_response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -L "$TARGET_INSTANCE_URL/services/data/v60.0/jobs/ingest/$job_id/batches" \
    -H "Content-Type: text/csv" \
    -H "$TARGET_AUTH_HEADER" \
    --data-binary @"$data_file")
    
    # Add a sleep after each upload
    sleep 1

    echo "$upload_response"
}

# Function to close a job in the target org
close_job() {
    local job_id=$1
    local close_response=$(curl -s -o /dev/null -w "%{http_code}" -X PATCH -L "$TARGET_INSTANCE_URL/services/data/v60.0/jobs/ingest/$job_id" \
    -H "Content-Type: application/json" \
    -H "$TARGET_AUTH_HEADER" \
    -d '{
      "state" : "UploadComplete"
    }')
    echo "$close_response"
}
