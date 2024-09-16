#!/bin/bash
set -x
# Variables
token="$1"
workspace_id="$2"
new_image_sha="$3"

# 1. List all variables in the workspace
echo "Fetching variables from Terraform Cloud workspace..."

variables=$(curl --silent \
  --header "Authorization: Bearer $token" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/workspaces/$workspace_id/vars" | jq)

# 2. Extract the variable ID for "image_sha"
variable_id=$(echo $variables | jq -r '.data[] | select(.attributes.key=="image_sha") | .id')

if [ -z "$variable_id" ]; then
  echo "Variable 'image_sha' not found in workspace."
  exit 1
else
  echo "Found 'image_sha' variable with ID: $variable_id"
fi

# 3. Prepare the payload to update the variable
update_payload=$(cat <<EOF
{
  "data": {
    "id": "$variable_id",
    "attributes": {
      "key": "image_sha",
      "value": "$new_image_sha",
      "category": "terraform",
      "hcl": false,
      "sensitive": false
    },
    "type": "vars"
  }
}
EOF
)

# 4. Update the variable in Terraform Cloud
echo "Updating 'image_sha' variable with new value: $new_image_sha"

curl --silent \
  --header "Authorization: Bearer $token" \
  --header "Content-Type: application/vnd.api+json" \
  --request PATCH \
  --data "$update_payload" \
  "https://app.terraform.io/api/v2/vars/$variable_id" | jq

echo "Variable 'image_sha' updated successfully."
