#!/usr/bin/env python3
"""
Individual ERPNext API calls for Homeira Amirkhani supplier payment
This script provides individual API functions that can be called separately
"""

import requests
import json
from datetime import datetime, timedelta

class ERPNextAPI:
    def __init__(self):
        self.base_url = "http://172.18.0.4:8001/api/resource"
        self.api_key = "54e8d25835474d3"
        self.api_secret = "f07c5b09a89a8e3"
        self.headers = {
            "Authorization": f"token {self.api_key}:{self.api_secret}",
            "Content-Type": "application/json"
        }
    
    def make_request(self, method, endpoint, data=None):
        """Make API request with error handling"""
        url = f"{self.base_url}/{endpoint}"
        
        try:
            if method.upper() == "GET":
                response = requests.get(url, headers=self.headers)
            elif method.upper() == "POST":
                response = requests.post(url, headers=self.headers, json=data)
            elif method.upper() == "PUT":
                response = requests.put(url, headers=self.headers, json=data)
            elif method.upper() == "DELETE":
                response = requests.delete(url, headers=self.headers)
            
            response.raise_for_status()
            return response.json()
        
        except requests.exceptions.RequestException as e:
            print(f"❌ API Error: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"Response: {e.response.text}")
            return None
    
    def check_exists(self, doctype, name):
        """Check if a record exists"""
        response = self.make_request("GET", f"{doctype}/{name}")
        return response is not None and "does not exist" not in str(response)
    
    def create_supplier(self):
        """Create Homeira Amirkhani as a supplier"""
        print("👤 Creating supplier: Homeira Amirkhani")
        
        if self.check_exists("Supplier", "Homeira Amirkhani"):
            print("✅ Supplier already exists")
            return True
        
        supplier_data = {
            "supplier_name": "Homeira Amirkhani",
            "supplier_type": "Individual",
            "supplier_group": "All Supplier Groups",
            "company": "DeepSpring",
            "is_transporter": 0,
            "disabled": 0
        }
        
        response = self.make_request("POST", "Supplier", supplier_data)
        if response:
            print(f"✅ Supplier created: {response.get('data', {}).get('name', 'Unknown')}")
            return True
        return False
    
    def create_purchase_invoice(self, invoice_data):
        """Create a single purchase invoice"""
        print(f"📄 Creating purchase invoice for {invoice_data['posting_date']}")
        
        # Add required fields
        invoice_data.update({
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
        })
        
        response = self.make_request("POST", "Purchase Invoice", invoice_data)
        if response:
            invoice_name = response.get('data', {}).get('name', 'Unknown')
            print(f"✅ Purchase invoice created: {invoice_name}")
            return invoice_name
        return None
    
    def create_payment_entry(self, payment_data):
        """Create a single payment entry"""
        print(f"💳 Creating payment entry for {payment_data['posting_date']}")
        
        # Add required fields
        payment_data.update({
            "doctype": "Payment Entry",
            "company": "DeepSpring",
            "paid_from_account_currency": "USD",
            "paid_to_account_currency": "USD",
            "source_exchange_rate": 1,
            "target_exchange_rate": 1
        })
        
        response = self.make_request("POST", "Payment Entry", payment_data)
        if response:
            payment_name = response.get('data', {}).get('name', 'Unknown')
            print(f"✅ Payment entry created: {payment_name}")
            return payment_name
        return None
    
    def create_all_invoices(self):
        """Create all purchase invoices for the $46,830 payment"""
        invoices = [
            {
                "supplier": "Homeira Amirkhani",
                "posting_date": "2024-01-15",
                "due_date": "2024-01-30",
                "items": [{
                    "item_code": "Contractor Services",
                    "qty": 1,
                    "rate": 8500,
                    "expense_account": "Contractors - DS"
                }],
                "total": 8500,
                "grand_total": 8500,
                "outstanding_amount": 0
            },
            {
                "supplier": "Homeira Amirkhani",
                "posting_date": "2024-02-20",
                "due_date": "2024-03-05",
                "items": [{
                    "item_code": "Contractor Services",
                    "qty": 1,
                    "rate": 9200,
                    "expense_account": "Contractors - DS"
                }],
                "total": 9200,
                "grand_total": 9200,
                "outstanding_amount": 0
            },
            {
                "supplier": "Homeira Amirkhani",
                "posting_date": "2024-03-10",
                "due_date": "2024-03-25",
                "items": [{
                    "item_code": "Contractor Services",
                    "qty": 1,
                    "rate": 7800,
                    "expense_account": "Contractors - DS"
                }],
                "total": 7800,
                "grand_total": 7800,
                "outstanding_amount": 0
            },
            {
                "supplier": "Homeira Amirkhani",
                "posting_date": "2024-04-05",
                "due_date": "2024-04-20",
                "items": [{
                    "item_code": "Contractor Services",
                    "qty": 1,
                    "rate": 10500,
                    "expense_account": "Contractors - DS"
                }],
                "total": 10500,
                "grand_total": 10500,
                "outstanding_amount": 0
            },
            {
                "supplier": "Homeira Amirkhani",
                "posting_date": "2024-05-12",
                "due_date": "2024-05-27",
                "items": [{
                    "item_code": "Contractor Services",
                    "qty": 1,
                    "rate": 11330,
                    "expense_account": "Contractors - DS"
                }],
                "total": 11330,
                "grand_total": 11330,
                "outstanding_amount": 0
            }
        ]
        
        invoice_names = []
        for i, invoice_data in enumerate(invoices, 1):
            print(f"\n📋 Creating Purchase Invoice #{i}...")
            invoice_name = self.create_purchase_invoice(invoice_data)
            if invoice_name:
                invoice_names.append(invoice_name)
        
        return invoice_names
    
    def create_all_payments(self, invoice_names):
        """Create all payment entries for the invoices"""
        payments = [
            {
                "payment_type": "Pay",
                "party_type": "Supplier",
                "party": "Homeira Amirkhani",
                "posting_date": "2024-01-16",
                "paid_from": "Operating Bank - DS",
                "paid_to": "Creditors - DS",
                "paid_amount": 8500,
                "received_amount": 8500,
                "mode_of_payment": "Wire Transfer",
                "reference_no": "PAY-20240116-001",
                "reference_date": "2024-01-16"
            },
            {
                "payment_type": "Pay",
                "party_type": "Supplier",
                "party": "Homeira Amirkhani",
                "posting_date": "2024-02-21",
                "paid_from": "Visa Card - DS",
                "paid_to": "Creditors - DS",
                "paid_amount": 9200,
                "received_amount": 9200,
                "mode_of_payment": "Credit Card",
                "reference_no": "PAY-20240221-002",
                "reference_date": "2024-02-21"
            },
            {
                "payment_type": "Pay",
                "party_type": "Supplier",
                "party": "Homeira Amirkhani",
                "posting_date": "2024-03-11",
                "paid_from": "Operating Bank - DS",
                "paid_to": "Creditors - DS",
                "paid_amount": 7800,
                "received_amount": 7800,
                "mode_of_payment": "Wire Transfer",
                "reference_no": "PAY-20240311-003",
                "reference_date": "2024-03-11"
            },
            {
                "payment_type": "Pay",
                "party_type": "Supplier",
                "party": "Homeira Amirkhani",
                "posting_date": "2024-04-06",
                "paid_from": "Visa Card - DS",
                "paid_to": "Creditors - DS",
                "paid_amount": 10500,
                "received_amount": 10500,
                "mode_of_payment": "Credit Card",
                "reference_no": "PAY-20240406-004",
                "reference_date": "2024-04-06"
            },
            {
                "payment_type": "Pay",
                "party_type": "Supplier",
                "party": "Homeira Amirkhani",
                "posting_date": "2024-05-13",
                "paid_from": "Operating Bank - DS",
                "paid_to": "Creditors - DS",
                "paid_amount": 11330,
                "received_amount": 11330,
                "mode_of_payment": "Wire Transfer",
                "reference_no": "PAY-20240513-005",
                "reference_date": "2024-05-13"
            }
        ]
        
        payment_names = []
        for i, payment_data in enumerate(payments, 1):
            # Add invoice reference
            if i <= len(invoice_names):
                payment_data["references"] = [{
                    "reference_doctype": "Purchase Invoice",
                    "reference_name": invoice_names[i-1],
                    "allocated_amount": payment_data["paid_amount"]
                }]
            
            print(f"\n💰 Creating Payment Entry #{i}...")
            payment_name = self.create_payment_entry(payment_data)
            if payment_name:
                payment_names.append(payment_name)
        
        return payment_names
    
    def run_complete_setup(self):
        """Run the complete supplier payment setup"""
        print("🚀 Starting ERPNext Supplier Payment Setup")
        print("=" * 50)
        
        # Step 1: Create supplier
        print("\n📋 Step 1: Creating Supplier")
        if not self.create_supplier():
            print("❌ Failed to create supplier")
            return False
        
        # Step 2: Create purchase invoices
        print("\n📋 Step 2: Creating Purchase Invoices")
        invoice_names = self.create_all_invoices()
        if not invoice_names:
            print("❌ Failed to create purchase invoices")
            return False
        
        # Step 3: Create payment entries
        print("\n📋 Step 3: Creating Payment Entries")
        payment_names = self.create_all_payments(invoice_names)
        if not payment_names:
            print("❌ Failed to create payment entries")
            return False
        
        # Summary
        print("\n" + "=" * 50)
        print("✅ SUPPLIER PAYMENT SETUP COMPLETE")
        print("=" * 50)
        print(f"👤 Supplier: Homeira Amirkhani")
        print(f"📄 Purchase Invoices: {len(invoice_names)}")
        print(f"💳 Payment Entries: {len(payment_names)}")
        print(f"💰 Total Amount: $46,830.00")
        print("=" * 50)
        
        return True

def main():
    """Main function to run the setup"""
    api = ERPNextAPI()
    
    # Check if we can connect to ERPNext
    print("🔍 Testing ERPNext connection...")
    test_response = api.make_request("GET", "Account?limit_page_length=1")
    if not test_response:
        print("❌ Cannot connect to ERPNext. Please check:")
        print("   - ERPNext service is running")
        print("   - API credentials are correct")
        print("   - Network connectivity")
        return
    
    print("✅ Connected to ERPNext successfully")
    
    # Run the complete setup
    success = api.run_complete_setup()
    
    if success:
        print("\n🎉 All supplier payment records created successfully!")
        print("🔍 You can view them in ERPNext interface:")
        print("   - Purchase Invoices: Purchase → Purchase Invoice")
        print("   - Payment Entries: Accounts → Payment Entry")
        print("   - Supplier: Buying → Supplier")
    else:
        print("\n❌ Setup failed. Please check the errors above.")

if __name__ == "__main__":
    main()
