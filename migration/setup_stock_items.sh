#!/bin/bash
# ERPNext API setup for DeepSpring Stock Items

BASE_URL="http://172.18.0.4:8001/api/resource"
API_KEY="54e8d25835474d3"
API_SECRET="f07c5b09a89a8e3"

AUTH_HEADER="Authorization: token ${API_KEY}:${API_SECRET}"
CONTENT_TYPE="Content-Type: application/json"

# ---------------------------------------------------
# 1. Create Item Group if it doesn't exist
# ---------------------------------------------------
create_item_group() {
  local group_name="$1"
  local parent_group="$2"

  echo "Creating Item Group: $group_name ..."
  curl -s -X POST \
    -H "$AUTH_HEADER" \
    -H "$CONTENT_TYPE" \
    -d "{
      \"item_group_name\": \"$group_name\",
      \"parent_item_group\": \"$parent_group\",
      \"is_group\": 0
    }" \
    "$BASE_URL/Item%20Group"
}

# Check if Item Groups already exist before creating
echo "Checking if Item Groups already exist..."

# Create Services group only if it doesn't exist
if curl -s -H "$AUTH_HEADER" "$BASE_URL/Item%20Group/Services" | grep -q "DoesNotExistError"; then
  create_item_group "Services" "All Item Groups"
else
  echo "Services Item Group already exists, skipping..."
fi

# Create Expense Items group only if it doesn't exist
if curl -s -H "$AUTH_HEADER" "$BASE_URL/Item%20Group/Expense%20Items" | grep -q "DoesNotExistError"; then
  create_item_group "Expense Items" "All Item Groups"
else
  echo "Expense Items Item Group already exists, skipping..."
fi

# ---------------------------------------------------
# 2. Create Stock Items
# ---------------------------------------------------
create_stock_item() {
  local item_name="$1"
  local item_group="$2"
  local expense_account="$3"
  local maintain_stock="$4"

  echo "Creating Stock Item: $item_name ..."
  curl -s -X POST \
    -H "$AUTH_HEADER" \
    -H "$CONTENT_TYPE" \
    -d "{
      \"item_code\": \"$item_name\",
      \"item_name\": \"$item_name\",
      \"item_group\": \"$item_group\",
      \"is_stock_item\": $maintain_stock,
      \"is_sales_item\": 1,
      \"is_purchase_item\": 1,
      \"valuation_rate\": 0,
      \"standard_rate\": 0,
      \"item_defaults\": [
        {
          \"company\": \"DeepSpring\",
          \"default_expense_account\": \"$expense_account\"
        }
      ]
    }" \
    "$BASE_URL/Item"
}

# Check if Stock Items already exist before creating
echo "Checking if Stock Items already exist..."

# Create expense items (Maintain Stock: No)
expense_items=(
  "Contractor Services:Expense Items:Contractors - DS"
  "Offshore Services:Expense Items:Offshore Services - DS"
  "Travel:Expense Items:Travel - DS"
  "Computer Equipment:Expense Items:Computer Equipment - DS"
  "Software Subscription:Expense Items:Software Subscriptions - DS"
  "Cloud Services:Expense Items:Cloud Services - DS"
  "Legal Services:Expense Items:Legal & Professional Fees - DS"
  "Home Office:Expense Items:Home Office Expense - DS"
  "Office Supplies:Expense Items:Office Supplies - DS"
  "Meals & Entertainment:Expense Items:Meals & Entertainment - DS"
  "Bank/Card Fees:Expense Items:Bank & Card Fees - DS"
)

for item_data in "${expense_items[@]}"; do
  IFS=':' read -r item_name item_group expense_account <<< "$item_data"
  
  # Check if item already exists
  if curl -s -H "$AUTH_HEADER" "$BASE_URL/Item/${item_name// /%20}" | grep -q "DoesNotExistError"; then
    create_stock_item "$item_name" "$item_group" "$expense_account" "0"
  else
    echo "$item_name already exists, skipping..."
  fi
done

# ---------------------------------------------------
# 3. Create Revenue Item for Sales
# ---------------------------------------------------
# Create Consulting Services item for sales to MDC/PI
echo "Creating revenue item for sales..."

if curl -s -H "$AUTH_HEADER" "$BASE_URL/Item/Consulting%20Services" | grep -q "DoesNotExistError"; then
  echo "Creating Stock Item: Consulting Services ..."
  curl -s -X POST \
    -H "$AUTH_HEADER" \
    -H "$CONTENT_TYPE" \
    -d "{
      \"item_code\": \"Consulting Services\",
      \"item_name\": \"Consulting Services\",
      \"item_group\": \"Services\",
      \"is_stock_item\": 0,
      \"is_sales_item\": 1,
      \"is_purchase_item\": 0,
      \"valuation_rate\": 0,
      \"standard_rate\": 0,
      \"item_defaults\": [
        {
          \"company\": \"DeepSpring\",
          \"default_income_account\": \"Income - DS\"
        }
      ]
    }" \
    "$BASE_URL/Item"
else
  echo "Consulting Services already exists, skipping..."
fi

echo "Stock items setup completed!"
