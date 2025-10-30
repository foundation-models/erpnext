# Payment Submission Error Fix

## Problem
When submitting a Payment Entry to take it out of draft status, the following error occurred:

```
Server Error
MySQLdb.OperationalError: (1054, "Unknown column 'tabBudget.customer' in 'SELECT'")
Possible source of error: erpnext (app)
```

## Root Cause
The error was caused by a mismatch between the Accounting Dimension configuration and the Budget DocType schema:

1. **Accounting Dimension Configuration**: An Accounting Dimension named "Customer" was created with fieldname `customer`
2. **Missing Custom Field**: The corresponding custom field was never properly created in the Budget DocType
3. **Fieldname Mismatch**: When the custom field was eventually created during migration, Frappe automatically prefixed it with `custom_` (creating `custom_customer` column in the database), but the Accounting Dimension record still referenced the unprefixed fieldname `customer`

## How It Happened
When submitting a Payment Entry:
- ERPNext's budget validation system (`budget_controller.py`) is triggered
- It queries all Accounting Dimensions to build budget checks
- For each dimension, it tries to SELECT that field from the `tabBudget` table
- The query tried to access `tabBudget.customer`, but the actual column name was `tabBudget.custom_customer`
- This caused the MySQL "Unknown column" error

## Solution Applied
The fix involved three steps:

### 1. Created the Missing Custom Field
```sql
INSERT INTO `tabCustom Field` (
    `name`, `dt`, `label`, `fieldname`, `fieldtype`, 
    `options`, `insert_after`, `depends_on`, `allow_on_submit`
) VALUES (
    'Budget-customer', 'Budget', 'Customer', 'customer', 'Link',
    'Customer', 'cost_center', 'eval:doc.budget_against = "Customer"', 0
);
```

### 2. Ran Database Migration
```bash
bench --site erpnext.localhost migrate
```
This created the `custom_customer` column in the `tabBudget` table.

### 3. Fixed the Fieldname Mismatch
Updated both records to use the consistent `custom_customer` fieldname:
```sql
-- Update Custom Field
UPDATE `tabCustom Field` 
SET fieldname = 'custom_customer', name = 'Budget-custom_customer'
WHERE dt = 'Budget' AND fieldname = 'customer';

-- Update Accounting Dimension
UPDATE `tabAccounting Dimension` 
SET fieldname = 'custom_customer'
WHERE name = 'Customer' AND fieldname = 'customer';
```

### 4. Cleared Cache
```bash
bench --site erpnext.localhost clear-cache
```

## Verification
After the fix:
- ✅ Accounting Dimension "Customer" has fieldname: `custom_customer`
- ✅ Custom Field in Budget DocType has fieldname: `custom_customer`
- ✅ Database column exists: `tabBudget.custom_customer`
- ✅ Payment Entry submissions should now work without errors

## Prevention
This issue typically occurs when:
- Accounting Dimensions are created but custom fields fail to generate properly
- Direct database manipulation is done without following Frappe's naming conventions
- System migrations are interrupted or fail partway through

**Best Practice**: Always use Frappe's built-in tools to create Accounting Dimensions rather than manual database operations. If custom fields don't generate automatically, use the "Create Dimensions" button in the Accounting Dimension form.

## Testing
To test that the fix works:
1. Create or open a Payment Entry in draft status
2. Fill in the required fields
3. Click "Submit"
4. The payment should submit successfully without the "Unknown column 'tabBudget.customer'" error

## Date Fixed
October 30, 2025


