#!/bin/bash
# ERPNext API script to record REAL supplier payment structure for Homeira Amirkhani
# This reflects the actual situation where customers paid directly to Homeira's personal account
# and business payments are made from an imaginary business Chase account

BASE_URL="http://172.18.0.4:8001/api/resource"
API_KEY="54e8d25835474d3"
API_SECRET="f07c5b09a89a8e3"

AUTH_HEADER="Authorization: token ${API_KEY}:${API_SECRET}"
CONTENT_TYPE="Content-Type: application/json"

echo "=========================================="
echo "ERPNext REAL Supplier Payment Setup"
echo "Recording actual payment structure for Homeira Amirkhani"
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
    fi
    
    if [[ $response == *"error"* ]] || [[ $response == *"Error"* ]]; then
        echo "❌ Error: $response"
        return 1
    else
        echo "✅ Success: $response"
        return 0
    fi
}

# Function to check if record exists
check_exists() {
    local doctype="$1"
    local name="$2"
    
    response=$(curl -s -X GET \
        -H "$AUTH_HEADER" \
        "$BASE_URL/$doctype/$name")
    
    if [[ $response == *"does not exist"* ]] || [[ $response == *"Not Found"* ]]; then
        return 1  # Does not exist
    else
        return 0  # Exists
    fi
}

echo ""
echo "🔍 Step 1: Creating Business Chase Account..."

# Create a business Chase account for proper accounting
if check_exists "Account" "Business Chase - DS"; then
    echo "✅ Business Chase account already exists"
else
    echo "📝 Creating Business Chase account..."
    
    chase_account_data='{
        "account_name": "Business Chase - DS",
        "parent_account": "Bank Accounts - DS",
        "company": "DeepSpring",
        "account_type": "Bank",
        "is_group": 0
    }'
    
    make_api_call "POST" "Account" "$chase_account_data" "Creating Business Chase account"
fi

echo ""
echo "🔍 Step 2: Checking if supplier exists..."

# Check if supplier already exists
if check_exists "Supplier" "Homeira Amirkhani"; then
    echo "✅ Supplier 'Homeira Amirkhani' already exists"
else
    echo "📝 Creating supplier 'Homeira Amirkhani'..."
    
    supplier_data='{
        "supplier_name": "Homeira Amirkhani",
        "supplier_type": "Individual",
        "supplier_group": "All Supplier Groups",
        "company": "DeepSpring",
        "is_transporter": 0,
        "disabled": 0
    }'
    
    make_api_call "POST" "Supplier" "$supplier_data" "Creating supplier Homeira Amirkhani"
fi

echo ""
echo "🔍 Step 3: Checking required accounts and items..."

# Check if required accounts exist
required_accounts=("Contractors - DS" "Creditors - DS" "Business Chase - DS")
for account in "${required_accounts[@]}"; do
    if check_exists "Account" "$account"; then
        echo "✅ Account '$account' exists"
    else
        echo "❌ Account '$account' does not exist - please run setup_accounts.sh first"
        exit 1
    fi
done

# Check if Contractor Services item exists
if check_exists "Item" "Contractor Services"; then
    echo "✅ Item 'Contractor Services' exists"
else
    echo "❌ Item 'Contractor Services' does not exist - please run setup_stock_items.sh first"
    exit 1
fi

echo ""
echo "📋 Step 4: Creating Purchase Invoices for actual payments..."

# Create purchase invoices based on the REAL payment structure
# These represent the actual contractor services provided by Homeira

purchase_invoices=(
    '{"supplier": "Homeira Amirkhani", "posting_date": "2024-08-28", "due_date": "2024-08-30", "items": [{"item_code": "Contractor Services", "qty": 1, "rate": 6845, "expense_account": "Contractors - DS"}], "total": 6845, "grand_total": 6845, "outstanding_amount": 0}'
    '{"supplier": "Homeira Amirkhani", "posting_date": "2024-08-29", "due_date": "2024-08-31", "items": [{"item_code": "Contractor Services", "qty": 1, "rate": 19985, "expense_account": "Contractors - DS"}], "total": 19985, "grand_total": 19985, "outstanding_amount": 0}'
    '{"supplier": "Homeira Amirkhani", "posting_date": "2024-10-25", "due_date": "2024-10-27", "items": [{"item_code": "Contractor Services", "qty": 1, "rate": 20000, "expense_account": "Contractors - DS"}], "total": 20000, "grand_total": 20000, "outstanding_amount": 0}'
)

invoice_names=()
for i in "${!purchase_invoices[@]}"; do
    invoice_num=$((i + 1))
    echo "📄 Creating Purchase Invoice #$invoice_num..."
    
    # Add required fields for Purchase Invoice
    invoice_data=$(echo "${purchase_invoices[$i]}" | jq '. + {
        "doctype": "Purchase Invoice",
        "company": "DeepSpring",
        "currency": "USD",
        "buying_price_list": "Standard Buying",
        "price_list_currency": "USD",
        "plc_conversion_rate": 1,
        "conversion_rate": 1,
        "apply_tds": 0,
        "ignore_pricing_rule": 0,
        "update_stock": 0,
        "is_paid": 1,
        "status": "Paid"
    }')
    
    response=$(curl -s -X POST \
        -H "$AUTH_HEADER" \
        -H "$CONTENT_TYPE" \
        -d "$invoice_data" \
        "$BASE_URL/Purchase Invoice")
    
    if [[ $response == *"error"* ]] || [[ $response == *"Error"* ]]; then
        echo "❌ Error creating invoice #$invoice_num: $response"
    else
        # Extract invoice name from response
        invoice_name=$(echo "$response" | jq -r '.data.name // empty')
        if [ -n "$invoice_name" ]; then
            invoice_names+=("$invoice_name")
            echo "✅ Created Purchase Invoice: $invoice_name"
        else
            echo "✅ Purchase Invoice #$invoice_num created successfully"
        fi
    fi
done

echo ""
echo "💰 Step 5: Creating Payment Entries (Business to Personal Transfers)..."

# Create payment entries showing transfers from business Chase to Homeira's personal account
# This represents the business paying Homeira for her contractor services

payment_entries=(
    '{"payment_type": "Pay", "party_type": "Supplier", "party": "Homeira Amirkhani", "posting_date": "2024-08-28", "paid_from": "Business Chase - DS", "paid_to": "Creditors - DS", "paid_amount": 6845, "received_amount": 6845, "mode_of_payment": "Wire Transfer", "reference_no": "BIZ-PAY-20240828-1", "reference_date": "2024-08-28"}'
    '{"payment_type": "Pay", "party_type": "Supplier", "party": "Homeira Amirkhani", "posting_date": "2024-08-29", "paid_from": "Business Chase - DS", "paid_to": "Creditors - DS", "paid_amount": 19985, "received_amount": 19985, "mode_of_payment": "Wire Transfer", "reference_no": "BIZ-PAY-20240829-1", "reference_date": "2024-08-29"}'
    '{"payment_type": "Pay", "party_type": "Supplier", "party": "Homeira Amirkhani", "posting_date": "2024-10-25", "paid_from": "Business Chase - DS", "paid_to": "Creditors - DS", "paid_amount": 20000, "received_amount": 20000, "mode_of_payment": "Wire Transfer", "reference_no": "BIZ-PAY-20241025-1", "reference_date": "2024-10-25"}'
)

payment_names=()
for i in "${!payment_entries[@]}"; do
    payment_num=$((i + 1))
    echo "💳 Creating Payment Entry #$payment_num..."
    
    # Add invoice reference if available
    payment_data=$(echo "${payment_entries[$i]}" | jq '. + {
        "doctype": "Payment Entry",
        "company": "DeepSpring",
        "paid_from_account_currency": "USD",
        "paid_to_account_currency": "USD",
        "source_exchange_rate": 1,
        "target_exchange_rate": 1
    }')
    
    # Add invoice reference if we have a corresponding invoice
    if [ $i -lt ${#invoice_names[@]} ]; then
        invoice_name="${invoice_names[$i]}"
        payment_data=$(echo "$payment_data" | jq '. + {
            "references": [{
                "reference_doctype": "Purchase Invoice",
                "reference_name": "'$invoice_name'",
                "allocated_amount": .paid_amount
            }]
        }')
    fi
    
    response=$(curl -s -X POST \
        -H "$AUTH_HEADER" \
        -H "$CONTENT_TYPE" \
        -d "$payment_data" \
        "$BASE_URL/Payment Entry")
    
    if [[ $response == *"error"* ]] || [[ $response == *"Error"* ]]; then
        echo "❌ Error creating payment #$payment_num: $response"
    else
        payment_name=$(echo "$response" | jq -r '.data.name // empty')
        if [ -n "$payment_name" ]; then
            echo "✅ Created Payment Entry: $payment_name"
            payment_names+=("$payment_name")
        else
            echo "✅ Payment Entry #$payment_num created successfully"
        fi
    fi
done

echo ""
echo "📊 Step 6: Summary Report..."

# Calculate total amounts
total_invoiced=0
for invoice in "${purchase_invoices[@]}"; do
    amount=$(echo "$invoice" | jq -r '.grand_total')
    total_invoiced=$((total_invoiced + amount))
done

echo "=========================================="
echo "📋 REAL SUPPLIER PAYMENT SETUP COMPLETE"
echo "=========================================="
echo "👤 Supplier: Homeira Amirkhani (Personal Account)"
echo "🏦 Business Account: Business Chase - DS"
echo "📄 Purchase Invoices Created: ${#purchase_invoices[@]}"
echo "💳 Payment Entries Created: ${#payment_names[@]}"
echo "💰 Total Amount: \$$total_invoiced"
echo "🔄 Payment Type: Business to Personal Transfers"
echo "📅 Date Range: 2024-08-28 to 2024-12-31"
echo ""
echo "📋 ACCOUNTING STRUCTURE:"
echo "   • Customer payments → Operating Bank - DS (existing)"
echo "   • Business payments → Business Chase - DS → Homeira (new)"
echo "   • This reflects real flow: Customers → Homeira's personal account"
echo "   • Business pays Homeira from imaginary business Chase account"
echo "=========================================="

echo ""
echo "✅ Real supplier payment structure has been created in ERPNext!"
echo "🔍 You can now view these records in the ERPNext interface:"
echo "   - Purchase Invoices: Purchase → Purchase Invoice"
echo "   - Payment Entries: Accounts → Payment Entry"
echo "   - Supplier: Buying → Supplier"
echo "   - Business Chase Account: Accounts → Chart of Accounts"
echo ""
echo "💡 NOTE: This setup reflects the real situation where:"
echo "   1. Customers (MDC/PI) paid directly to Homeira's personal Chase account"
echo "   2. Business records payments to Homeira from an imaginary business Chase account"
echo "   3. This provides proper expense tracking while reflecting actual cash flow"

