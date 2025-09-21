# Manual ERPNext Entry Instructions for Homeira Amirkhani Supplier Payment

## Overview
This document provides step-by-step manual instructions for recording the $46,830 payment to Homeira Amirkhani in ERPNext, as an alternative to the automated script.

## Prerequisites
- ERPNext system is running and accessible
- User has appropriate permissions for Purchase Invoice and Payment Entry creation
- Required accounts and items are already set up (run setup scripts if needed)

## Step 1: Create Supplier

### Navigate to Supplier Creation
1. Go to **Buying** → **Supplier** → **New**
2. Fill in the following details:

| Field | Value |
|-------|-------|
| **Supplier Name** | Homeira Amirkhani |
| **Supplier Type** | Individual |
| **Supplier Group** | All Supplier Groups |
| **Company** | DeepSpring |
| **Is Transporter** | No |
| **Disabled** | No |

3. Click **Save**

## Step 2: Create Purchase Invoices

Create multiple purchase invoices to split the $46,830 across different dates during 2024:

### Purchase Invoice #1 (January 2024)
1. Go to **Purchase** → **Purchase Invoice** → **New**
2. Fill in the details:

| Field | Value |
|-------|-------|
| **Supplier** | Homeira Amirkhani |
| **Posting Date** | 2024-01-15 |
| **Due Date** | 2024-01-30 |
| **Company** | DeepSpring |
| **Currency** | USD |

3. In the **Items** table, add one row:
   - **Item Code**: Contractor Services
   - **Qty**: 1
   - **Rate**: 8,500.00
   - **Expense Account**: Contractors - DS

4. Click **Save** and note the invoice number (e.g., PINV-2024-00001)

### Purchase Invoice #2 (February 2024)
1. Create new Purchase Invoice
2. Use the same structure with:
   - **Posting Date**: 2024-02-20
   - **Due Date**: 2024-03-05
   - **Rate**: 9,200.00

### Purchase Invoice #3 (March 2024)
1. Create new Purchase Invoice
2. Use the same structure with:
   - **Posting Date**: 2024-03-10
   - **Due Date**: 2024-03-25
   - **Rate**: 7,800.00

### Purchase Invoice #4 (April 2024)
1. Create new Purchase Invoice
2. Use the same structure with:
   - **Posting Date**: 2024-04-05
   - **Due Date**: 2024-04-20
   - **Rate**: 10,500.00

### Purchase Invoice #5 (May 2024)
1. Create new Purchase Invoice
2. Use the same structure with:
   - **Posting Date**: 2024-05-12
   - **Due Date**: 2024-05-27
   - **Rate**: 11,330.00

**Total Amount**: $46,830.00

## Step 3: Create Payment Entries

For each purchase invoice, create a corresponding payment entry:

### Payment Entry #1 (Bank Transfer)
1. Go to **Accounts** → **Payment Entry** → **New**
2. Fill in the details:

| Field | Value |
|-------|-------|
| **Payment Type** | Pay |
| **Party Type** | Supplier |
| **Party** | Homeira Amirkhani |
| **Company** | DeepSpring |
| **Posting Date** | 2024-01-16 |
| **Paid From** | Operating Bank - DS |
| **Paid To** | Creditors - DS |
| **Paid Amount** | 8,500.00 |
| **Mode of Payment** | Wire Transfer |
| **Reference No** | PAY-20240116-001 |
| **Reference Date** | 2024-01-16 |

3. In the **References** table, add one row:
   - **Reference Doctype**: Purchase Invoice
   - **Reference Name**: [Invoice number from Step 2.1]
   - **Allocated Amount**: 8,500.00

4. Click **Save**

### Payment Entry #2 (Credit Card)
1. Create new Payment Entry
2. Use the same structure with:
   - **Posting Date**: 2024-02-21
   - **Paid From**: Visa Card - DS
   - **Paid Amount**: 9,200.00
   - **Mode of Payment**: Credit Card
   - **Reference No**: PAY-20240221-002
   - **Allocated Amount**: 9,200.00

### Payment Entry #3 (Bank Transfer)
1. Create new Payment Entry
2. Use the same structure with:
   - **Posting Date**: 2024-03-11
   - **Paid From**: Operating Bank - DS
   - **Paid Amount**: 7,800.00
   - **Mode of Payment**: Wire Transfer
   - **Reference No**: PAY-20240311-003
   - **Allocated Amount**: 7,800.00

### Payment Entry #4 (Credit Card)
1. Create new Payment Entry
2. Use the same structure with:
   - **Posting Date**: 2024-04-06
   - **Paid From**: Visa Card - DS
   - **Paid Amount**: 10,500.00
   - **Mode of Payment**: Credit Card
   - **Reference No**: PAY-20240406-004
   - **Allocated Amount**: 10,500.00

### Payment Entry #5 (Bank Transfer)
1. Create new Payment Entry
2. Use the same structure with:
   - **Posting Date**: 2024-05-13
   - **Paid From**: Operating Bank - DS
   - **Paid Amount**: 11,330.00
   - **Mode of Payment**: Wire Transfer
   - **Reference No**: PAY-20240513-005
   - **Allocated Amount**: 11,330.00

## Step 4: Verification

After completing all entries, verify the following:

1. **Supplier Balance**: Go to **Buying** → **Supplier** → Homeira Amirkhani
   - Outstanding amount should be $0.00
   - All invoices should show as "Paid"

2. **Account Balances**: Go to **Accounts** → **Chart of Accounts**
   - **Contractors - DS**: Should show total expenses of $46,830.00
   - **Creditors - DS**: Should show net zero balance
   - **Operating Bank - DS**: Should show total payments of $27,630.00
   - **Visa Card - DS**: Should show total payments of $19,200.00

3. **Payment Entries**: Go to **Accounts** → **Payment Entry**
   - All 5 payment entries should be created and submitted
   - Each should reference the corresponding purchase invoice

## Summary

| Component | Count | Total Amount |
|-----------|-------|--------------|
| **Purchase Invoices** | 5 | $46,830.00 |
| **Payment Entries** | 5 | $46,830.00 |
| **Bank Transfers** | 3 | $27,630.00 |
| **Credit Card Payments** | 2 | $19,200.00 |

This setup provides proper expense tracking with:
- ✅ Supplier management
- ✅ Invoice documentation
- ✅ Payment tracking
- ✅ Account reconciliation
- ✅ Audit trail

## Troubleshooting

If you encounter issues:

1. **Missing Accounts**: Run `setup_accounts.sh` first
2. **Missing Items**: Run `setup_stock_items.sh` first
3. **Permission Errors**: Ensure user has "Purchase User" and "Accounts User" roles
4. **Validation Errors**: Check that all required fields are filled and dates are valid

For automated setup, use the `setup_supplier_payment.sh` script instead of manual entry.

