#!/bin/bash
# Variables
token="${TF_CLOUD_TOKEN}"

# Check if the correct number of arguments are passed
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <organization_name>"
  exit 1
fi

# Assign command-line argument to organization_name variable
organization_name="$1"

# 1. List all organizations the user has access to
echo "Fetching organizations from Terraform Cloud..."

organizations=$(curl --silent \
  --header "Authorization: Bearer $token" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/organizations" | jq)

# 2. Extract the organization ID for the input organization name
organization_id=$(echo $organizations | jq -r --arg org_name "$organization_name" '.data[] | select(.attributes.name==$org_name) | .id')

if [ -z "$organization_id" ]; then
  echo "Organization '$organization_name' not found."
  echo "Attempting to create new organization: $organization_name"

  # 3. Prepare the payload to create the organization
  create_payload=$(cat <<EOF
{
  "data": {
    "attributes": {
      "name": "$organization_name",
      "email": "admin@example.com"
    },
    "type": "organizations"
  }
}
EOF
)

  # 4. Create the organization in Terraform Cloud
  create_response=$(curl --silent \
    --header "Authorization: Bearer $token" \
    --header "Content-Type: application/vnd.api+json" \
    --request POST \
    --data "$create_payload" \
    "https://app.terraform.io/api/v2/organizations")

  # 5. Check if the response contains an error
  errors=$(echo $create_response | jq '.errors')
  if [ "$errors" != "null" ]; then
    echo "Error creating organization: $(echo $create_response | jq -r '.errors[].detail')"
    exit 1
  fi

  # 6. Extract the new organization ID
  organization_id=$(echo $create_response | jq -r '.data.id')

  if [ -z "$organization_id" ]; then
    echo "Failed to create the organization."
    exit 1
  fi

  echo "Organization '$organization_name' created successfully with ID: $organization_id"
else
  echo "Found organization '$organization_name' with ID: $organization_id"
fi

# Export the organization ID to be captured in GitHub Actions
echo "ORGANIZATION_ID=$organization_id" >> $GITHUB_ENV
