#!/bin/bash
# Auto-generated script to post expenses into ERPNext
BASE_URL="http://172.18.0.4:8001/api/resource/Purchase%20Invoice"
AUTH="Authorization: token 54e8d25835474d3:f07c5b09a89a8e3"
CT="Content-Type: application/json"

post_expense() {
  local date="$1"
  local desc="$2"
  local notes="$3"
  local amount="$4"
  local account="$5"
  local ref="$6"

  echo "Posting expense $ref ($amount) on $date ..."
  curl -s -X POST "$BASE_URL" \
    -H "$AUTH" \
    -H "$CT" \
    -d "{
      \"doctype\": \"Purchase Invoice\",
      \"supplier\": \"Credit Card - Wells Fargo\",
      \"posting_date\": \"$date\",
      \"bill_no\": \"$ref\",
      \"items\": [
        {
          \"item_name\": \"Expense\",
          \"description\": \"$desc\",
          \"qty\": 1,
          \"rate\": $amount,
          \"expense_account\": \"$account\",
          \"cost_center\": \"DS-Admin - DS\"
        }
      ],
      \"mode_of_payment\": \"Credit Card\",
      \"remarks\": \"$notes\"
    }"
}

post_expense "2025-09-01" "AGODA.COM ROYALE CHU INTERNET DF" "Hotel Reservation" 368.17 "Travel - DS" "WF-20250901-1"
post_expense "2025-09-19" "AGODA.COM TJAMPUHAN INTERNET DF" "Hotel Reservation" 107.49 "Travel - DS" "WF-20250919-2"
post_expense "2025-09-18" "AGODA.COM TJAMPUHAN INTERNET DF" "Hotel Reservation" 94.49 "Travel - DS" "WF-20250918-3"
post_expense "2025-09-13" "AIRPAZ (USD) KUALA LUMPUR MY" "Hotel Reservation" 139.89 "Travel - DS" "WF-20250913-4"
post_expense "2025-07-04" "ALADDIN GOURMET MARKET SAN MATEO CA" "Restaurant / meal — check business purpose." 14.17 "Meals & Entertainment - DS" "WF-20250704-5"
post_expense "2025-06-13" "ALADDIN GOURMET MARKET SAN MATEO CA" "Restaurant / meal — check business purpose." 52.86 "Meals & Entertainment - DS" "WF-20250613-6"
post_expense "2025-05-25" "ALADDIN GOURMET MARKET SAN MATEO CA" "Restaurant / meal — check business purpose." 34.37 "Meals & Entertainment - DS" "WF-20250525-7"
post_expense "2025-08-09" "CURSOR USAGE JUL NEW YORK NY" "Software / subscription." 12.39 "Software Subscriptions - DS" "WF-20250809-8"
post_expense "2025-07-06" "CURSOR USAGE JUN NEW YORK NY" "Software / subscription." 88.83 "Software Subscriptions - DS" "WF-20250706-9"
post_expense "2025-06-08" "CURSOR USAGE MAY NEW YORK NY" "Software / subscription." 32.43 "Software Subscriptions - DS" "WF-20250608-10"
post_expense "2025-07-17" "CURSOR USAGE MID JUL NEW YORK NY" "Software / subscription." 80.72 "Software Subscriptions - DS" "WF-20250717-11"
post_expense "2025-07-12" "CURSOR USAGE MID JUL NEW YORK NY" "Software / subscription." 60.08 "Software Subscriptions - DS" "WF-20250712-12"
post_expense "2025-07-03" "CURSOR, AI POWERED IDE NEW YORK NY" "Software / subscription." 20.0 "Software Subscriptions - DS" "WF-20250703-13"
post_expense "2025-06-03" "CURSOR, AI POWERED IDE NEW YORK NY" "Software / subscription." 20.0 "Software Subscriptions - DS" "WF-20250603-14"
post_expense "2025-08-11" "FOODA CNP CHICAGO IL" "Restaurant / meal — check business purpose." 0.25 "Meals & Entertainment - DS" "WF-20250811-15"
post_expense "2025-07-29" "FOODA CNP CHICAGO IL" "Restaurant / meal — check business purpose." 17.95 "Meals & Entertainment - DS" "WF-20250729-16"
post_expense "2025-07-28" "FOODA CNP CHICAGO IL" "Restaurant / meal — check business purpose." 2.6 "Meals & Entertainment - DS" "WF-20250728-17"
post_expense "2025-09-14" "HOTEL AT BOOKING.COM AMSTERDAM NL" "Likely hotel / lodging — probably business-eligible if travel-related." 41.37 "Travel - DS" "WF-20250914-18"
post_expense "2025-06-09" "MICROSOFT-G096077173 MSBILL.INFO WA" "Software / subscription — verify if company-paid." 5.53 "Software Subscriptions - DS" "WF-20250609-19"
post_expense "2025-07-09" "MICROSOFT-G100635162 MSBILL.INFO WA" "Software / subscription — verify if company-paid." 105.56 "Software Subscriptions - DS" "WF-20250709-20"
post_expense "2025-08-09" "MICROSOFT-G106352200 MSBILL.INFO WA" "Software / subscription — verify if company-paid." 29.11 "Software Subscriptions - DS" "WF-20250809-21"
post_expense "2025-07-11" "REAL PRODUCE INTERNATI PALO ALTO CA" "Restaurant / meal — check business purpose." 27.32 "Meals & Entertainment - DS" "WF-20250711-22"
post_expense "2025-07-03" "REAL PRODUCE INTERNATI PALO ALTO CA" "Restaurant / meal — check business purpose." 25.71 "Meals & Entertainment - DS" "WF-20250703-23"
post_expense "2025-06-20" "REAL PRODUCE INTERNATI PALO ALTO CA" "Restaurant / meal — check business purpose." 3.27 "Meals & Entertainment - DS" "WF-20250620-24"
post_expense "2025-06-16" "REAL PRODUCE INTERNATI PALO ALTO CA" "Restaurant / meal — check business purpose." 20.26 "Meals & Entertainment - DS" "WF-20250616-25"
post_expense "2025-06-12" "REAL PRODUCE INTERNATI PALO ALTO CA" "Restaurant / meal — check business purpose." 4.56 "Meals & Entertainment - DS" "WF-20250612-26"
post_expense "2025-05-30" "REAL PRODUCE INTERNATI PALO ALTO CA" "Restaurant / meal — check business purpose." 22.32 "Meals & Entertainment - DS" "WF-20250530-27"
post_expense "2025-07-31" "USPS PO 0558030193 PALO ALTO CA" "office_supplies" 13.2 "Office Supplies - DS" "WF-20250731-28"
post_expense "2025-06-23" "USPS PO 0558030193 PALO ALTO CA" "office_supplies" 12.15 "Office Supplies - DS" "WF-20250623-29"
post_expense "2025-09-17" "WEB*NETWORKSOLUTIONS JACKSONVILLE FL" "Software / subscription" 3.0 "Software Subscriptions - DS" "WF-20250917-30"
post_expense "2025-08-20" "WEB*NETWORKSOLUTIONS JACKSONVILLE FL" "Software / subscription" 3.0 "Software Subscriptions - DS" "WF-20250820-31"
post_expense "2025-07-23" "WEB*NETWORKSOLUTIONS JACKSONVILLE FL" "Software / subscription" 3.0 "Software Subscriptions - DS" "WF-20250723-32"
post_expense "2025-06-26" "WEB*NETWORKSOLUTIONS JACKSONVILLE FL" "Software / subscription" 3.0 "Software Subscriptions - DS" "WF-20250626-33"
post_expense "2025-05-28" "WEB*NETWORKSOLUTIONS JACKSONVILLE FL" "Software / subscription" 3.0 "Software Subscriptions - DS" "WF-20250528-34"