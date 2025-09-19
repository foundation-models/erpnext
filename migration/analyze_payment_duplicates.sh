#!/bin/bash
# ERPNext API script to analyze payment entry duplicates in detail
# This script will provide a comprehensive analysis of the payment entries

BASE_URL="http://erpnext.localhost:8000/api/resource"
API_KEY="54e8d25835474d3"
API_SECRET="f07c5b09a89a8e3"

AUTH_HEADER="Authorization: token ${API_KEY}:${API_SECRET}"
CONTENT_TYPE="Content-Type: application/json"

echo "=========================================="
echo "ERPNext Payment Entry Analysis"
echo "Comprehensive analysis of payment entries"
echo "=========================================="

echo ""
echo "🔍 Step 1: Fetching all payment entries..."

# Get all payment entries (both draft and submitted)
response=$(curl -s -X GET \
    -H "$AUTH_HEADER" \
    "$BASE_URL/Payment%20Entry?fields=['name','party','posting_date','paid_amount','reference_no','docstatus','payment_type']&limit_page_length=100")

if [[ $response == *"error"* ]]; then
    echo "❌ Error fetching payment entries: $response"
    exit 1
fi

echo "✅ Successfully fetched payment entries"

# Save to temporary file for analysis
temp_file="/tmp/payment_analysis.json"
echo "$response" > "$temp_file"

echo ""
echo "📊 Step 2: Basic Statistics..."

total_count=$(echo "$response" | jq '.data | length')
draft_count=$(echo "$response" | jq '.data | map(select(.docstatus == 0)) | length')
submitted_count=$(echo "$response" | jq '.data | map(select(.docstatus == 1)) | length')

echo "📈 Total payment entries: $total_count"
echo "📋 Draft entries: $draft_count"
echo "✅ Submitted entries: $submitted_count"

echo ""
echo "📊 Step 3: Payment entries by party..."

echo "MDC payments:"
echo "$response" | jq -r '.data[] | select(.party == "MDC") | "  \(.name) | \(.posting_date) | $\(.paid_amount) | \(.reference_no) | Status: \(if .docstatus == 0 then "Draft" else "Submitted" end)"'

echo ""
echo "PI payments:"
echo "$response" | jq -r '.data[] | select(.party == "PI") | "  \(.name) | \(.posting_date) | $\(.paid_amount) | \(.reference_no) | Status: \(if .docstatus == 0 then "Draft" else "Submitted" end)"'

echo ""
echo "📊 Step 4: Looking for exact duplicates..."

# Find entries with same party, date, amount, and reference
echo "Entries with identical party, date, amount, and reference:"
echo "$response" | jq -r '.data[] | "\(.party)|\(.posting_date)|\(.paid_amount)|\(.reference_no)|\(.name)"' | sort | uniq -c | sort -nr | head -20

echo ""
echo "📊 Step 5: Specific date analysis (2024-08-28)..."

echo "All entries for 2024-08-28:"
echo "$response" | jq -r '.data[] | select(.posting_date == "2024-08-28") | "  \(.name) | \(.party) | $\(.paid_amount) | \(.reference_no) | Status: \(if .docstatus == 0 then "Draft" else "Submitted" end)"'

echo ""
echo "📊 Step 6: Specific date analysis (2024-08-29)..."

echo "All entries for 2024-08-29:"
echo "$response" | jq -r '.data[] | select(.posting_date == "2024-08-29") | "  \(.name) | \(.party) | $\(.paid_amount) | \(.reference_no) | Status: \(if .docstatus == 0 then "Draft" else "Submitted" end)"'

echo ""
echo "📊 Step 7: Specific date analysis (2024-10-25)..."

echo "All entries for 2024-10-25:"
echo "$response" | jq -r '.data[] | select(.posting_date == "2024-10-25") | "  \(.name) | \(.party) | $\(.paid_amount) | \(.reference_no) | Status: \(if .docstatus == 0 then "Draft" else "Submitted" end)"'

echo ""
echo "📊 Step 8: Payment type analysis..."

echo "Payment types:"
echo "$response" | jq -r '.data[] | .payment_type' | sort | uniq -c

echo ""
echo "📊 Step 9: Reference number analysis..."

echo "Reference numbers (showing duplicates):"
echo "$response" | jq -r '.data[] | .reference_no' | sort | uniq -c | sort -nr | head -10

echo ""
echo "=========================================="
echo "📋 ANALYSIS COMPLETE"
echo "=========================================="
echo "📊 Total entries analyzed: $total_count"
echo "📋 Draft entries: $draft_count"
echo "✅ Submitted entries: $submitted_count"
echo "=========================================="

# Clean up
rm -f "$temp_file"

echo ""
echo "💡 Based on this analysis, you can:"
echo "   1. Check if the 'duplicates' are actually different entries with same data"
echo "   2. Look for entries with same reference numbers"
echo "   3. Identify if the issue is in the UI display or actual data"
echo "   4. Consider if entries need to be submitted instead of left as drafts"
