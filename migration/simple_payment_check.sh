#!/bin/bash
# Simple script to check payment entries in ERPNext

BASE_URL="http://172.18.0.4:8001/api/resource"
API_KEY="54e8d25835474d3"
API_SECRET="f07c5b09a89a8e3"

AUTH_HEADER="Authorization: token ${API_KEY}:${API_SECRET}"

echo "=========================================="
echo "Simple Payment Entry Check"
echo "=========================================="

echo ""
echo "🔍 Testing API connection..."
response=$(curl -s -X GET -H "$AUTH_HEADER" "$BASE_URL/Payment%20Entry?limit_page_length=5")

echo "Raw response:"
echo "$response"

echo ""
echo "🔍 Checking if response contains data..."
if [[ $response == *"data"* ]]; then
    echo "✅ Response contains 'data' field"
    
    # Try to extract data count
    data_count=$(echo "$response" | jq -r '.data | length' 2>/dev/null)
    if [ "$data_count" != "null" ] && [ "$data_count" != "" ]; then
        echo "📊 Data count: $data_count"
        
        if [ "$data_count" -gt 0 ]; then
            echo "📋 First few entries:"
            echo "$response" | jq -r '.data[] | "\(.name) | \(.party) | \(.posting_date) | \(.paid_amount)"' 2>/dev/null
        else
            echo "📋 No payment entries found"
        fi
    else
        echo "❌ Could not parse data count"
    fi
else
    echo "❌ Response does not contain 'data' field"
fi

echo ""
echo "🔍 Testing with different endpoint..."
response2=$(curl -s -X GET -H "$AUTH_HEADER" "$BASE_URL/Payment%20Entry")

echo "Raw response 2:"
echo "$response2"

echo ""
echo "🔍 Checking account entries for comparison..."
account_response=$(curl -s -X GET -H "$AUTH_HEADER" "$BASE_URL/Account?limit_page_length=3")
echo "Account response:"
echo "$account_response"

