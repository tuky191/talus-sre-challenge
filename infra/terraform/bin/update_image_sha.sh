#!/bin/bash
# Variables
token="${TF_CLOUD_TOKEN}"
workspace_id="${TERRAFORM_WORKSPACE_ID}"
new_backend_image_id="${backend_image}"

# 1. List all variables in the workspace
echo "Fetching variables from Terraform Cloud workspace..."

variables=$(curl --silent \
  --header "Authorization: Bearer $token" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/workspaces/$workspace_id/vars" | jq)

# 2. Extract the variable ID for "backend_image"
variable_id=$(echo $variables | jq -r '.data[] | select(.attributes.key=="backend_image") | .id')

if [ -z "$variable_id" ]; then
  echo "Variable 'backend_image' not found in workspace."
  echo "Creating 'backend_image' variable with value: $new_backend_image_id"

  # 3. Prepare the payload to create the variable
  create_payload=$(cat <<EOF
{
  "data": {
    "attributes": {
      "key": "backend_image",
      "value": "$new_backend_image_id",
      "category": "terraform",
      "hcl": false,
      "sensitive": false
    },
    "type": "vars"
  }
}
EOF
)

  # 4. Create the variable in Terraform Cloud
  curl --silent \
    --header "Authorization: Bearer $token" \
    --header "Content-Type: application/vnd.api+json" \
    --request POST \
    --data "$create_payload" \
    "https://app.terraform.io/api/v2/workspaces/$workspace_id/vars" | jq

  echo "Variable 'backend_image' created successfully."
else
  echo "Found 'backend_image' variable with ID: $variable_id"

  # 5. Prepare the payload to update the variable
  update_payload=$(cat <<EOF
{
  "data": {
    "id": "$variable_id",
    "attributes": {
      "key": "backend_image",
      "value": "$new_backend_image_id",
      "category": "terraform",
      "hcl": false,
      "sensitive": false
    },
    "type": "vars"
  }
}
EOF
)

  # 6. Update the variable in Terraform Cloud
  echo "Updating 'backend_image' variable with new value: $new_backend_image_id"

  curl --silent \
    --header "Authorization: Bearer $token" \
    --header "Content-Type: application/vnd.api+json" \
    --request PATCH \
    --data "$update_payload" \
    "https://app.terraform.io/api/v2/vars/$variable_id" | jq

  echo "Variable 'backend_image' updated successfully."
fi

