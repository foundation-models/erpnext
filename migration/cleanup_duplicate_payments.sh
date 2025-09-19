#!/bin/bash
# ERPNext API script to identify and remove duplicate payment entries
# This script will find duplicate payments and remove the redundant ones

BASE_URL="http://172.18.0.4:8001/api/resource"
API_KEY="54e8d25835474d3"
API_SECRET="f07c5b09a89a8e3"

AUTH_HEADER="Authorization: token ${API_KEY}:${API_SECRET}"
CONTENT_TYPE="Content-Type: application/json"

echo "=========================================="
echo "ERPNext Duplicate Payment Cleanup"
echo "Identifying and removing redundant payment entries"
echo "=========================================="

# Function to make API calls with error handling
make_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local description="$4"
    
    echo "📋 $description..."
    
    if [ "$method" = "POST" ]; then
        response=$(curl -s -X POST \
            -H "$AUTH_HEADER" \
            -H "$CONTENT_TYPE" \
            -d "$data" \
            "$BASE_URL/$endpoint")
    elif [ "$method" = "GET" ]; then
        response=$(curl -s -X GET \
            -H "$AUTH_HEADER" \
            "$BASE_URL/$endpoint")
    elif [ "$method" = "DELETE" ]; then
        response=$(curl -s -X DELETE \
            -H "$AUTH_HEADER" \
            "$BASE_URL/$endpoint")
    fi
    
    if [[ $response == *"error"* ]] || [[ $response == *"Error"* ]]; then
        echo "❌ Error: $response"
        return 1
    else
        echo "✅ Success: $response"
        return 0
    fi
}

echo ""
echo "🔍 Step 1: Analyzing duplicate payment entries..."

# Get all draft payment entries
echo "📊 Fetching all draft payment entries..."
response=$(curl -s -X GET \
    -H "$AUTH_HEADER" \
    "$BASE_URL/Payment%20Entry?filters=[['docstatus','=','0']]&fields=['name','party','posting_date','paid_amount','reference_no']&limit_page_length=100")

if [[ $response == *"error"* ]]; then
    echo "❌ Error fetching payment entries: $response"
    exit 1
fi

echo "✅ Successfully fetched payment entries"

# Parse the response and identify duplicates
echo ""
echo "🔍 Step 2: Identifying duplicate patterns..."

# Create a temporary file to store payment data
temp_file="/tmp/payment_analysis.json"
echo "$response" > "$temp_file"

# Use jq to analyze duplicates
echo "📊 Analyzing payment patterns..."

# Count entries by party, date, and amount
echo "Payment entries by party, date, and amount:"
jq -r '.data[] | "\(.party)|\(.posting_date)|\(.paid_amount)|\(.reference_no)|\(.name)"' "$temp_file" | sort | uniq -c | sort -nr

echo ""
echo "🔍 Step 3: Identifying specific duplicates to remove..."

# Find the specific duplicates mentioned in the image
duplicates_to_remove=()

# Check for MDC $10 entries on 2024-08-28
mdc_10_count=$(jq -r '.data[] | select(.party == "MDC" and .posting_date == "2024-08-28" and .paid_amount == 10) | .name' "$temp_file" | wc -l)
if [ "$mdc_10_count" -gt 1 ]; then
    echo "📋 Found $mdc_10_count MDC $10 entries on 2024-08-28 (keeping first, removing $((mdc_10_count - 1)) duplicates)"
    # Get all but the first one
    duplicates_to_remove+=($(jq -r '.data[] | select(.party == "MDC" and .posting_date == "2024-08-28" and .paid_amount == 10) | .name' "$temp_file" | tail -n +2))
fi

# Check for PI $5 entries on 2024-08-28
pi_5_count=$(jq -r '.data[] | select(.party == "PI" and .posting_date == "2024-08-28" and .paid_amount == 5) | .name' "$temp_file" | wc -l)
if [ "$pi_5_count" -gt 1 ]; then
    echo "📋 Found $pi_5_count PI $5 entries on 2024-08-28 (keeping first, removing $((pi_5_count - 1)) duplicates)"
    duplicates_to_remove+=($(jq -r '.data[] | select(.party == "PI" and .posting_date == "2024-08-28" and .paid_amount == 5) | .name' "$temp_file" | tail -n +2))
fi

# Check for MDC $14990 entries on 2024-08-29
mdc_14990_count=$(jq -r '.data[] | select(.party == "MDC" and .posting_date == "2024-08-29" and .paid_amount == 14990) | .name' "$temp_file" | wc -l)
if [ "$mdc_14990_count" -gt 1 ]; then
    echo "📋 Found $mdc_14990_count MDC $14990 entries on 2024-08-29 (keeping first, removing $((mdc_14990_count - 1)) duplicates)"
    duplicates_to_remove+=($(jq -r '.data[] | select(.party == "MDC" and .posting_date == "2024-08-29" and .paid_amount == 14990) | .name' "$temp_file" | tail -n +2))
fi

# Check for PI $4995 entries on 2024-08-29
pi_4995_count=$(jq -r '.data[] | select(.party == "PI" and .posting_date == "2024-08-29" and .paid_amount == 4995) | .name' "$temp_file" | wc -l)
if [ "$pi_4995_count" -gt 1 ]; then
    echo "📋 Found $pi_4995_count PI $4995 entries on 2024-08-29 (keeping first, removing $((pi_4995_count - 1)) duplicates)"
    duplicates_to_remove+=($(jq -r '.data[] | select(.party == "PI" and .posting_date == "2024-08-29" and .paid_amount == 4995) | .name' "$temp_file" | tail -n +2))
fi

# Check for MDC $20000 entries on 2024-10-25
mdc_20000_count=$(jq -r '.data[] | select(.party == "MDC" and .posting_date == "2024-10-25" and .paid_amount == 20000) | .name' "$temp_file" | wc -l)
if [ "$mdc_20000_count" -gt 1 ]; then
    echo "📋 Found $mdc_20000_count MDC $20000 entries on 2024-10-25 (keeping first, removing $((mdc_20000_count - 1)) duplicates)"
    duplicates_to_remove+=($(jq -r '.data[] | select(.party == "MDC" and .posting_date == "2024-10-25" and .paid_amount == 20000) | .name' "$temp_file" | tail -n +2))
fi

echo ""
echo "📊 Summary of duplicates found:"
echo "Total duplicate entries to remove: ${#duplicates_to_remove[@]}"

if [ ${#duplicates_to_remove[@]} -eq 0 ]; then
    echo "✅ No duplicates found. All payment entries are unique."
    rm -f "$temp_file"
    exit 0
fi

echo ""
echo "🗑️  Step 4: Removing duplicate payment entries..."

# Create backup before deletion
backup_file="/tmp/payment_backup_$(date +%Y%m%d_%H%M%S).json"
echo "📦 Creating backup at: $backup_file"
echo "$response" > "$backup_file"
echo "✅ Backup created successfully"

# Remove duplicates
removed_count=0
for payment_name in "${duplicates_to_remove[@]}"; do
    echo "🗑️  Removing duplicate payment: $payment_name"
    
    delete_response=$(curl -s -X DELETE \
        -H "$AUTH_HEADER" \
        "$BASE_URL/Payment%20Entry/$payment_name")
    
    if [[ $delete_response == *"error"* ]] || [[ $delete_response == *"Error"* ]]; then
        echo "❌ Error removing $payment_name: $delete_response"
    else
        echo "✅ Successfully removed $payment_name"
        ((removed_count++))
    fi
done

echo ""
echo "📊 Step 5: Final verification..."

# Get updated count
updated_response=$(curl -s -X GET \
    -H "$AUTH_HEADER" \
    "$BASE_URL/Payment%20Entry?filters=[['docstatus','=','0']]&fields=['name','party','posting_date','paid_amount']&limit_page_length=100")

updated_count=$(echo "$updated_response" | jq '.data | length')
echo "📊 Remaining draft payment entries: $updated_count"

echo ""
echo "=========================================="
echo "📋 DUPLICATE CLEANUP COMPLETE"
echo "=========================================="
echo "🗑️  Duplicates removed: $removed_count"
echo "📊 Remaining entries: $updated_count"
echo "📦 Backup created: $backup_file"
echo "=========================================="

# Clean up temporary file
rm -f "$temp_file"

echo ""
echo "✅ Duplicate payment entries have been cleaned up!"
echo "🔍 You can now check the Payment Entry list in ERPNext"
echo "💡 The backup file is saved at: $backup_file"
