#!/bin/bash
# Variables
token="${TF_CLOUD_TOKEN}"
organization="${ORGANIZATION_NAME}"

# Check if the correct number of arguments are passed
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <workspace_name>"
  exit 1
fi

# Assign command-line argument to workspace_name variable
workspace_name="$1"

# 1. List all workspaces in the organization
echo "Fetching workspaces from Terraform Cloud organization: $organization"

workspaces=$(curl --silent \
  --header "Authorization: Bearer $token" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/organizations/$organization/workspaces" | jq)

# 2. Extract the workspace ID for the input workspace name
workspace_id=$(echo $workspaces | jq -r --arg ws_name "$workspace_name" '.data[] | select(.attributes.name==$ws_name) | .id')

if [ -z "$workspace_id" ]; then
  echo "Workspace '$workspace_name' not found in organization $organization."
  echo "Creating new workspace: $workspace_name"

  # 3. Prepare the payload to create the workspace
  create_payload=$(cat <<EOF
{
  "data": {
    "attributes": {
      "name": "$workspace_name"
    },
    "type": "workspaces"
  }
}
EOF
)

  # 4. Create the workspace in Terraform Cloud
  create_response=$(curl --silent \
    --header "Authorization: Bearer $token" \
    --header "Content-Type: application/vnd.api+json" \
    --request POST \
    --data "$create_payload" \
    "https://app.terraform.io/api/v2/organizations/$organization/workspaces" | jq)

  # 5. Extract the new workspace ID
  workspace_id=$(echo $create_response | jq -r '.data.id')

  if [ -z "$workspace_id" ]; then
    echo "Failed to create the workspace."
    exit 1
  fi

  echo "Workspace '$workspace_name' created successfully with ID: $workspace_id"
else
  echo "Found workspace '$workspace_name' with ID: $workspace_id"
fi

# Export the workspace ID to be captured in GitHub Actions
echo "WORKSPACE_ID=$workspace_id" >> $GITHUB_ENV
