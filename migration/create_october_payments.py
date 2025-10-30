#!/usr/bin/env python3
"""
Create October 2025 Axos Business payment entries directly in ERPNext
Run this inside the ERPNext container using: bench --site erpnext.localhost console < this_file.py
"""

import frappe
from frappe.utils import nowdate

frappe.connect(site='erpnext.localhost')
frappe.set_user('Administrator')

print("Creating October 2025 Axos Business Payments...")
print("=" * 60)

# Define the payments
payments = [
    {"customer": "PI", "date": "2025-10-16", "amount": 12500, "ref": "AXOS-20251016-1"},
    {"customer": "MDC", "date": "2025-10-16", "amount": 12500, "ref": "AXOS-20251016-2"},
    {"customer": "PI", "date": "2025-10-16", "amount": 2700, "ref": "AXOS-20251016-3"},
    {"customer": "MDC", "date": "2025-10-16", "amount": 2700, "ref": "AXOS-20251016-4"},
]

# First, ensure Axos Business bank account exists
print("\nStep 1: Checking/Creating Axos Business account...")

try:
    # Check if Axos Bank exists, if not create it
    if not frappe.db.exists("Bank", "Axos Bank"):
        bank = frappe.get_doc({
            "doctype": "Bank",
            "bank_name": "Axos Bank"
        })
        bank.insert(ignore_permissions=True)
        print("✅ Created Axos Bank")
    else:
        print("✅ Axos Bank already exists")
except Exception as e:
    print(f"Note: Axos Bank - {str(e)}")

try:
    # Check if Axos Business GL account exists
    if not frappe.db.exists("Account", "Axos Business - DS"):
        account = frappe.get_doc({
            "doctype": "Account",
            "account_name": "Axos Business",
            "parent_account": "Bank Accounts - DS",
            "company": "DeepSpring",
            "account_type": "Bank",
            "is_group": 0
        })
        account.insert(ignore_permissions=True)
        print("✅ Created Axos Business - DS GL Account")
    else:
        print("✅ Axos Business - DS GL Account already exists")
except Exception as e:
    print(f"Note: Axos Business GL Account - {str(e)}")

try:
    # Check if Bank Account record exists
    if not frappe.db.exists("Bank Account", {"account": "Axos Business - DS"}):
        bank_account = frappe.get_doc({
            "doctype": "Bank Account",
            "account_name": "Axos Business - DS",
            "account": "Axos Business - DS",
            "bank": "Axos Bank",
            "company": "DeepSpring",
            "is_default": 0
        })
        bank_account.insert(ignore_permissions=True)
        print("✅ Created Bank Account record")
    else:
        print("✅ Bank Account record already exists")
except Exception as e:
    print(f"Note: Bank Account - {str(e)}")

print("\nStep 2: Creating Payment Entries...")
print("-" * 60)

# Create payment entries
created_count = 0
for payment_data in payments:
    try:
        # Check if payment already exists
        if frappe.db.exists("Payment Entry", {"reference_no": payment_data["ref"]}):
            print(f"⚠️  Payment {payment_data['ref']} already exists, skipping")
            continue
        
        # Create payment entry
        payment = frappe.get_doc({
            "doctype": "Payment Entry",
            "payment_type": "Receive",
            "party_type": "Customer",
            "party": payment_data["customer"],
            "posting_date": payment_data["date"],
            "company": "DeepSpring",
            "paid_from": "Debtors - DS",
            "paid_to": "Axos Business - DS",
            "paid_amount": payment_data["amount"],
            "received_amount": payment_data["amount"],
            "paid_from_account_currency": "USD",
            "paid_to_account_currency": "USD",
            "source_exchange_rate": 1,
            "target_exchange_rate": 1,
            "mode_of_payment": "Wire Transfer",
            "reference_no": payment_data["ref"],
            "reference_date": payment_data["date"]
        })
        
        payment.insert(ignore_permissions=True)
        created_count += 1
        
        print(f"✅ Created {payment.name}: {payment_data['customer']} - ${payment_data['amount']:,} ({payment_data['ref']})")
        
    except Exception as e:
        print(f"❌ Failed to create payment {payment_data['ref']}: {str(e)}")

frappe.db.commit()

print("-" * 60)
print(f"\n🎉 Summary: Successfully created {created_count} out of {len(payments)} payments")
print("\nNext steps:")
print("  1. Review the payments in ERPNext UI")
print("  2. Submit them to finalize")
print("\n" + "=" * 60)


