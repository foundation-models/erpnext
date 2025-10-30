#!/bin/bash
# Import Customer Payments into ERPNext (DeepSpring)
# All payments go into Operating Bank - DS - Chase

BASE_URL="http://172.18.0.4:8001/api/resource/Payment%20Entry"
AUTH="Authorization: token 54e8d25835474d3:f07c5b09a89a8e3"
CT="Content-Type: application/json"

post_payment() {
  local customer="$1"
  local date="$2"
  local amount="$3"
  local ref="$4"

  echo "Posting payment $ref for $customer $amount on $date ..."
  curl -s -X POST "$BASE_URL" \
    -H "$AUTH" \
    -H "$CT" \
    -d "{
      \"payment_type\": \"Receive\",
      \"party_type\": \"Customer\",
      \"party\": \"$customer\",
      \"posting_date\": \"$date\",
      \"paid_from\": \"Debtors - DS\",
      \"paid_to\": \"Operating Bank - DS\",
      \"paid_amount\": $amount,
      \"received_amount\": $amount,
      \"mode_of_payment\": \"Wire Transfer\",
      \"reference_no\": \"$ref\",
      \"reference_date\": \"$date\"
    }"
}

# ----------------------
# Customer Payments List
# ----------------------

post_payment "MDC" "2024-08-28" 10 "CHASE-20240828-1"
post_payment "PI" "2024-08-28" 5 "CHASE-20240828-2"
post_payment "MDC" "2024-08-29" 14990 "CHASE-20240829-1"
post_payment "PI" "2024-08-29" 4995 "CHASE-20240829-2"
post_payment "MDC" "2024-10-25" 20000 "CHASE-20241025-1"
post_payment "PI" "2025-03-03" 10000 "CHASE-20250303-1"
post_payment "MDC" "2025-03-03" 10000 "CHASE-20250303-2"
post_payment "PI" "2025-03-20" 10000 "CHASE-20250320-1"
post_payment "MDC" "2025-03-20" 10000 "CHASE-20250320-2"
post_payment "PI" "2025-03-24" 5000 "CHASE-20250324-1"
post_payment "MDC" "2025-03-24" 5000 "CHASE-20250324-2"
post_payment "PI" "2025-03-26" 10000 "CHASE-20250326-1"
post_payment "MDC" "2025-03-26" 5000 "CHASE-20250326-2"
post_payment "PI" "2025-03-28" 5000 "CHASE-20250328-1"
post_payment "MDC" "2025-03-28" 5000 "CHASE-20250328-2"
post_payment "PI" "2025-07-22" 20000 "CHASE-20250722-1"
post_payment "MDC" "2025-07-29" 20000 "CHASE-20250729-1"
post_payment "PI" "2025-07-30" 27500 "CHASE-20250730-1"
post_payment "MDC" "2025-07-30" 27500 "CHASE-20250730-2"
post_payment "MDC" "2025-08-15" 25000 "CHASE-20250815-1"
post_payment "PI" "2025-09-16" 12500 "CHASE-20250916-1"
post_payment "MDC" "2025-09-16" 12500 "CHASE-20250916-2"
post_payment "PI" "2025-09-17" 2450 "CHASE-20250917-1"
post_payment "MDC" "2025-09-17" 2450 "CHASE-20250917-2"

# October 2025 - Axos Business Payments
post_payment "PI" "2025-10-16" 12500 "AXOS-20251016-1"
post_payment "MDC" "2025-10-16" 12500 "AXOS-20251016-2"
post_payment "PI" "2025-10-16" 2700 "AXOS-20251016-3"
post_payment "MDC" "2025-10-16" 2700 "AXOS-20251016-4"
