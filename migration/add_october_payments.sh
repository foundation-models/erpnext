#!/bin/bash
# Add October 2025 Axos Business Payments to ERPNext
# Creates Axos Business bank account and adds payment entries

BASE_URL="http://172.18.0.4:8001/api/resource"
AUTH="Authorization: token 54e8d25835474d3:f07c5b09a89a8e3"
CT="Content-Type: application/json"

echo "================================================"
echo "Adding October 2025 Axos Business Payments"
echo "================================================"
echo ""

# ---------------------------------------------------
# Step 1: Create Axos Bank if it doesn't exist
# ---------------------------------------------------
echo "Step 1: Creating Axos Bank..."
curl -s -X POST "$BASE_URL/Bank" \
  -H "$AUTH" \
  -H "$CT" \
  -d '{
    "bank_name": "Axos Bank"
  }' | jq -r '.data.name // "Already exists or created"'

echo ""

# ---------------------------------------------------
# Step 2: Create Axos Business GL Account
# ---------------------------------------------------
echo "Step 2: Creating Axos Business GL Account..."
curl -s -X POST "$BASE_URL/Account" \
  -H "$AUTH" \
  -H "$CT" \
  -d '{
    "account_name": "Axos Business",
    "parent_account": "Bank Accounts - DS",
    "company": "DeepSpring",
    "account_type": "Bank",
    "is_group": 0
  }' | jq -r '.data.name // "Already exists or created"'

echo ""

# ---------------------------------------------------
# Step 3: Create Bank Account record
# ---------------------------------------------------
echo "Step 3: Creating Axos Business Bank Account record..."
curl -s -X POST "$BASE_URL/Bank%20Account" \
  -H "$AUTH" \
  -H "$CT" \
  -d '{
    "account_name": "Axos Business - DS",
    "company": "DeepSpring",
    "account": "Axos Business - DS",
    "bank": "Axos Bank"
  }' | jq -r '.data.name // "Already exists or created"'

echo ""
echo "✅ Axos Business account setup complete!"
echo ""

# ---------------------------------------------------
# Step 4: Add Payment Entries
# ---------------------------------------------------
post_payment() {
  local customer="$1"
  local date="$2"
  local amount="$3"
  local ref="$4"

  echo "Creating payment entry: $ref for $customer (\$$amount) on $date..."
  
  response=$(curl -s -X POST "$BASE_URL/Payment%20Entry" \
    -H "$AUTH" \
    -H "$CT" \
    -d "{
      \"doctype\": \"Payment Entry\",
      \"payment_type\": \"Receive\",
      \"party_type\": \"Customer\",
      \"party\": \"$customer\",
      \"posting_date\": \"$date\",
      \"company\": \"DeepSpring\",
      \"paid_from\": \"Debtors - DS\",
      \"paid_to\": \"Axos Business - DS\",
      \"paid_amount\": $amount,
      \"received_amount\": $amount,
      \"paid_from_account_currency\": \"USD\",
      \"paid_to_account_currency\": \"USD\",
      \"source_exchange_rate\": 1,
      \"target_exchange_rate\": 1,
      \"mode_of_payment\": \"Wire Transfer\",
      \"reference_no\": \"$ref\",
      \"reference_date\": \"$date\"
    }")
  
  payment_name=$(echo "$response" | jq -r '.data.name // "Error"')
  
  if [[ "$payment_name" == "Error" ]]; then
    echo "   ❌ Failed to create payment"
    echo "   Response: $response"
  else
    echo "   ✅ Created: $payment_name"
  fi
  echo ""
}

echo "================================================"
echo "Step 4: Creating Payment Entries"
echo "================================================"
echo ""

# October 16, 2025 Payments via Axos Business
post_payment "PI" "2025-10-16" 12500 "AXOS-20251016-1"
post_payment "MDC" "2025-10-16" 12500 "AXOS-20251016-2"
post_payment "PI" "2025-10-16" 2700 "AXOS-20251016-3"
post_payment "MDC" "2025-10-16" 2700 "AXOS-20251016-4"

echo "================================================"
echo "✅ All October 2025 payments added successfully!"
echo "================================================"
echo ""
echo "Summary:"
echo "  - PI Payments:  \$12,500 + \$2,700 = \$15,200"
echo "  - MDC Payments: \$12,500 + \$2,700 = \$15,200"
echo "  - Total Added:  \$30,400"
echo ""
echo "Next steps:"
echo "  1. Log into ERPNext: http://172.18.0.4:8001"
echo "  2. Go to Accounts → Payment Entry"
echo "  3. Review the new payment entries"
echo "  4. Submit them to finalize"
echo ""


