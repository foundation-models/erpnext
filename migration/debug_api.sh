#!/bin/bash
# Debug script to test ERPNext API connectivity

BASE_URL="http://172.18.0.4:8001/api/resource"
API_KEY="54e8d25835474d3"
API_SECRET="f07c5b09a89a8e3"

AUTH_HEADER="Authorization: token ${API_KEY}:${API_SECRET}"
CONTENT_TYPE="Content-Type: application/json"

echo "🔍 Testing ERPNext API connectivity..."
echo "Base URL: $BASE_URL"
echo "Auth Header: $AUTH_HEADER"
echo ""

echo "📋 Test 1: Check if we can access the API..."
response=$(curl -s -X GET \
    -H "$AUTH_HEADER" \
    "$BASE_URL/Supplier?fields=[\"name\",\"supplier_name\"]&limit_page_length=1")

echo "Response: $response"
echo ""

echo "📋 Test 2: Try to create a simple test record..."
test_data='{
    "doctype": "Supplier",
    "supplier_name": "Test Supplier API",
    "supplier_type": "Individual",
    "supplier_group": "All Supplier Groups",
    "company": "DeepSpring"
}'

response=$(curl -s -X POST \
    -H "$AUTH_HEADER" \
    -H "$CONTENT_TYPE" \
    -d "$test_data" \
    "$BASE_URL/Supplier")

echo "Create Response: $response"
echo ""

echo "📋 Test 3: Check if test record was created..."
response=$(curl -s -X GET \
    -H "$AUTH_HEADER" \
    "$BASE_URL/Supplier/Test Supplier API")

echo "Get Response: $response"
echo ""

echo "📋 Test 4: Check existing suppliers..."
response=$(curl -s -X GET \
    -H "$AUTH_HEADER" \
    "$BASE_URL/Supplier?fields=[\"name\",\"supplier_name\"]&limit_page_length=10")

echo "All Suppliers: $response"
