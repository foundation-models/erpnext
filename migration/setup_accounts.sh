#!/bin/bash
# ERPNext API cleanup and setup for DeepSpring (DS)

BASE_URL="http://172.18.0.4:8001/api/resource/Account"
API_KEY="54e8d25835474d3"
API_SECRET="f07c5b09a89a8e3"

AUTH_HEADER="Authorization: token ${API_KEY}:${API_SECRET}"
CONTENT_TYPE="Content-Type: application/json"

disable_account() {
  local acct="$1"
  echo "Disabling $acct ..."
  curl -s -X PUT \
    -H "$AUTH_HEADER" \
    -H "$CONTENT_TYPE" \
    -d '{"disabled":1}' \
    "$BASE_URL/${acct// /%20}"
}


# ---------------------------------------------------
# 1. Delete unwanted demo accounts
# ---------------------------------------------------
TO_DELETE=(
  "Administrative Expenses - DS"
  "Commission on Sales - DS"
  "Depreciation - DS"
  "Entertainment Expenses - DS"
  "Exchange Gain/Loss - DS"
  "Freight and Forwarding Charges - DS"
  "Gain/Loss on Asset Disposal - DS"
  "Impairment - DS"
  "Miscellaneous Expenses - DS"
  "Office Maintenance Expenses - DS"
  "Office Rent - DS"
  "Postal Expenses - DS"
  "Print and Stationery - DS"
  "Round Off - DS"
  "Salary - DS"
  "Sales Expenses - DS"
  "Telephone Expenses - DS"
  "Utility Expenses - DS"
  "Write Off - DS"
)

for acct in "${TO_DELETE[@]}"; do
  echo "Deleting $acct ..."
  resp=$(curl -s -X DELETE -H "$AUTH_HEADER" "$BASE_URL/${acct// /%20}")
  if [[ $resp == *"LinkExistsError"* ]]; then
    disable_account "$acct"
  fi
done


# ---------------------------------------------------
# 2. Create clean accounts
# ---------------------------------------------------
create_account() {
  local name="$1"
  local parent="$2"
  local type="$3"

  echo "Creating $name under $parent ..."
  curl -s -X POST \
    -H "$AUTH_HEADER" \
    -H "$CONTENT_TYPE" \
    -d "{
      \"account_name\": \"$name\",
      \"parent_account\": \"$parent\",
      \"company\": \"DeepSpring\",
      \"account_type\": \"$type\",
      \"is_group\": 0
    }" \
    "$BASE_URL"
}

# Direct Expenses
create_account "Contractors" "Direct Expenses - DS" "Expense Account"
create_account "Offshore Services" "Direct Expenses - DS" "Expense Account"
create_account "Travel" "Direct Expenses - DS" "Expense Account"

# Indirect Expenses
create_account "Computer Equipment" "Indirect Expenses - DS" "Expense Account"
create_account "Software Subscriptions" "Indirect Expenses - DS" "Expense Account"
create_account "Cloud Services" "Indirect Expenses - DS" "Expense Account"
create_account "Legal & Professional Fees" "Indirect Expenses - DS" "Expense Account"
create_account "Home Office Expense" "Indirect Expenses - DS" "Expense Account"
create_account "Office Supplies" "Indirect Expenses - DS" "Expense Account"
create_account "Meals & Entertainment" "Indirect Expenses - DS" "Expense Account"
create_account "Bank & Card Fees" "Indirect Expenses - DS" "Expense Account"
create_account "Marketing Expenses" "Indirect Expenses - DS" "Expense Account"
