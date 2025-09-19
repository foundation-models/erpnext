#!/bin/bash
# ERPNext API setup for DeepSpring Cost Centers

BASE_URL="http://172.18.0.4:8001/api/resource/Cost%20Center"
API_KEY="54e8d25835474d3"
API_SECRET="f07c5b09a89a8e3"

AUTH_HEADER="Authorization: token ${API_KEY}:${API_SECRET}"
CONTENT_TYPE="Content-Type: application/json"

create_cost_center() {
  local name="$1"
  echo "Creating Cost Center: $name ..."
  
  response=$(curl -s -X POST \
    -H "$AUTH_HEADER" \
    -H "$CONTENT_TYPE" \
    -d "{
      \"cost_center_name\": \"$name\",
      \"is_group\": 0,
      \"company\": \"DeepSpring\",
      \"parent_cost_center\": \"DeepSpring - DS\"
    }" \
    "$BASE_URL")
  
  # Check if the response contains an error
  if echo "$response" | grep -q '"exception"'; then
    echo "❌ Failed to create $name"
    echo "$response" | jq -r '.exception' 2>/dev/null || echo "$response"
  else
    echo "✅ Successfully created $name"
    echo "$response" | jq -r '.data.name' 2>/dev/null || echo "Created successfully"
  fi
  echo ""
}

# ---------------------------------------------------
# Create the cost centers
# ---------------------------------------------------
echo "🚀 Starting Cost Center Creation for DeepSpring..."
echo "Parent Cost Center: DeepSpring - DS"
echo "Company: DeepSpring"
echo "=========================================="
echo ""
create_cost_center "DS-Admin"
create_cost_center "Client-MDC"
create_cost_center "Client-PI"
create_cost_center "DS-R&D"
