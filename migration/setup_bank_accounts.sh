#!/bin/bash
# ERPNext API setup for DeepSpring Bank & Credit Card accounts

BASE_URL="http://erpnext.localhost:8000/api/resource"
API_KEY="54e8d25835474d3"
API_SECRET="f07c5b09a89a8e3"

AUTH_HEADER="Authorization: token ${API_KEY}:${API_SECRET}"
CONTENT_TYPE="Content-Type: application/json"

# ---------------------------------------------------
# 1. Create Banks
# ---------------------------------------------------
create_bank() {
  local bank_name="$1"

  echo "Creating Bank: $bank_name ..."
  curl -s -X POST \
    -H "$AUTH_HEADER" \
    -H "$CONTENT_TYPE" \
    -d "{
      \"bank_name\": \"$bank_name\"
    }" \
    "$BASE_URL/Bank"
}

# Check if banks already exist before creating
echo "Checking if banks already exist..."

# Create DeepSpring Bank only if it doesn't exist
if curl -s -H "$AUTH_HEADER" "$BASE_URL/Bank/DeepSpring%20Bank" | grep -q "DoesNotExistError"; then
  create_bank "DeepSpring Bank"
else
  echo "DeepSpring Bank already exists, skipping..."
fi

# Create Visa Bank only if it doesn't exist
if curl -s -H "$AUTH_HEADER" "$BASE_URL/Bank/Visa%20Bank" | grep -q "DoesNotExistError"; then
  create_bank "Visa Bank"
else
  echo "Visa Bank already exists, skipping..."
fi

# ---------------------------------------------------
# 2. Create GL Accounts
# ---------------------------------------------------
create_gl_account() {
  local name="$1"
  local parent="$2"
  local type="$3"

  echo "Creating GL Account: $name under $parent ..."
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
    "$BASE_URL/Account"
}

# Check if accounts already exist before creating
echo "Checking if GL accounts already exist..."

# Create Operating Bank account only if it doesn't exist
if curl -s -H "$AUTH_HEADER" "$BASE_URL/Account/Operating%20Bank%20-%20DS" | grep -q "DoesNotExistError"; then
  create_gl_account "Operating Bank" "Bank Accounts - DS" "Bank"
else
  echo "Operating Bank - DS account already exists, skipping..."
fi

# Create Visa Card account only if it doesn't exist  
if curl -s -H "$AUTH_HEADER" "$BASE_URL/Account/Visa%20Card%20-%20DS" | grep -q "DoesNotExistError"; then
  create_gl_account "Visa Card" "Current Liabilities - DS" "Current Liability"
else
  echo "Visa Card - DS account already exists, skipping..."
fi

# ---------------------------------------------------
# 3. Create Bank Account records
# ---------------------------------------------------
create_bank_account() {
  local bank_name="$1"
  local account_name="$2"
  local bank="$3"

  echo "Creating Bank Account record: $bank_name ..."
  curl -s -X POST \
    -H "$AUTH_HEADER" \
    -H "$CONTENT_TYPE" \
    -d "{
      \"account_name\": \"$bank_name\",
      \"company\": \"DeepSpring\",
      \"account\": \"$account_name\",
      \"bank\": \"$bank\"
    }" \
    "$BASE_URL/Bank%20Account"
}

# Check if Bank Account records already exist before creating
echo "Checking if Bank Account records already exist..."

# Create Operating Bank Account record only if it doesn't exist
if curl -s -H "$AUTH_HEADER" "$BASE_URL/Bank%20Account/Operating%20Bank%20-%20DS" | grep -q "DoesNotExistError"; then
  create_bank_account "Operating Bank - DS" "Operating Bank - DS" "DeepSpring Bank"
else
  echo "Operating Bank - DS Bank Account record already exists, skipping..."
fi

# Create Visa Card Account record only if it doesn't exist
if curl -s -H "$AUTH_HEADER" "$BASE_URL/Bank%20Account/Visa%20Card%20-%20DS" | grep -q "DoesNotExistError"; then
  create_bank_account "Visa Card - DS" "Visa Card - DS" "Visa Bank"
else
  echo "Visa Card - DS Bank Account record already exists, skipping..."
fi
