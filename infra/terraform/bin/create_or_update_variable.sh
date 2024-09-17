#!/bin/bash

# Check if the correct number of arguments are passed
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <variable_name> <variable_value> <is_sensitive>"
  exit 1
fi

# Assign command-line arguments to variables
variable_name="$1"
variable_value="$2"
is_sensitive="$3"

# Variables for the API
token="${TF_CLOUD_TOKEN}"
organization="${ORGANIZATION_NAME}"
workspace_name="${WORKSPACE_NAME}"

# 1. Fetch the workspace ID using the workspace name
workspace_id=$(curl --silent \
  --header "Authorization: Bearer $token" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/organizations/$organization/workspaces/$workspace_name" | jq -r '.data.id')

if [ -z "$workspace_id" ]; then
  echo "Workspace '$workspace_name' not found."
  exit 1
fi

# 2. List all variables in the workspace
echo "Fetching variables from Terraform Cloud workspace: $workspace_name"

variables=$(curl --silent \
  --header "Authorization: Bearer $token" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/workspaces/$workspace_id/vars" | jq)

# 3. Extract the variable ID for the input variable name
variable_id=$(echo $variables | jq -r --arg var_name "$variable_name" '.data[] | select(.attributes.key==$var_name) | .id')

# 4. Determine if the variable is sensitive
sensitive_flag=false
if [ "$is_sensitive" == "true" ]; then
  sensitive_flag=true
fi

if [ -z "$variable_id" ]; then
  echo "Variable '$variable_name' not found. Creating new variable."

  # 5. Prepare the payload to create the variable
  create_payload=$(cat <<EOF
{
  "data": {
    "attributes": {
      "key": "$variable_name",
      "value": "$variable_value",
      "category": "terraform",
      "hcl": false,
      "sensitive": $sensitive_flag
    },
    "type": "vars"
  }
}
EOF
)

  # 6. Create the variable in Terraform Cloud
  curl --silent \
    --header "Authorization: Bearer $token" \
    --header "Content-Type: application/vnd.api+json" \
    --request POST \
    --data "$create_payload" \
    "https://app.terraform.io/api/v2/workspaces/$workspace_id/vars" | jq

  echo "Variable '$variable_name' created successfully."
else
  echo "Found variable '$variable_name' with ID: $variable_id. Updating the value."

  # 7. Prepare the payload to update the variable
  update_payload=$(cat <<EOF
{
  "data": {
    "id": "$variable_id",
    "attributes": {
      "key": "$variable_name",
      "value": "$variable_value",
      "category": "terraform",
      "hcl": false,
      "sensitive": $sensitive_flag
    },
    "type": "vars"
  }
}
EOF
)

  # 8. Update the variable in Terraform Cloud
  curl --silent \
    --header "Authorization: Bearer $token" \
    --header "Content-Type: application/vnd.api+json" \
    --request PATCH \
    --data "$update_payload" \
    "https://app.terraform.io/api/v2/vars/$variable_id" | jq

  echo "Variable '$variable_name' updated successfully."
fi
