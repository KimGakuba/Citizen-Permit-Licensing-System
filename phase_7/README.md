# Phase VII: Advanced Programming & Auditing

**Project:** Citizen Permit and Licensing System  
**Student:** NGABONZIZA Kim Gakuba (27670)  
**Database:** `thu_27670_kim_permit_db`  
**Phase Completion Date:** December 7, 2025

---

## Overview

Phase VII implements comprehensive database security through **triggers**, **auditing mechanisms**, and **business rule enforcement**. The system ensures that critical database operations (INSERT, UPDATE, DELETE) are restricted during weekdays and public holidays, while maintaining a complete audit trail of all operation attempts.

---

## Business Rule Implementation

### Critical Restriction Rule

**Employees CANNOT perform INSERT/UPDATE/DELETE operations:**
- ❌ On **weekdays** (Monday - Friday)
- ❌ On **public holidays** (Rwanda national holidays)
- ✅ Only on **weekends** (Saturday - Sunday)

This restriction applies to the following tables:
- `CITIZEN` - Core citizen information
- `APPLICATION` - Permit/license applications

---

## Architecture Components

### 1. Holiday Management System

**Table:** `HOLIDAYS`

Stores Rwanda's public holidays for enforcement of operational restrictions.

```sql
CREATE TABLE HOLIDAYS (
    holiday_id NUMBER(10) PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    holiday_name VARCHAR2(100) NOT NULL,
    holiday_type VARCHAR2(50) DEFAULT 'PUBLIC',
    created_date DATE DEFAULT SYSDATE
);
```

**Configured Holidays:**
- Christmas Day (Dec 25, 2025)
- Boxing Day (Dec 26, 2025)
- New Year Day (Jan 1, 2026)
- Heroes Day (Feb 3, 2026)
- Labour Day (May 1, 2026)
- Independence Day (Jul 1, 2026)
- Liberation Day (Jul 4, 2026)
- Umuganura Day (Aug 1, 2026)
- Assumption Day (Aug 15, 2026)
- Genocide Memorial Day (Apr 7, 2026)

---

### 2. Audit Logging System

**Table:** `AUDIT_LOG`

Captures every operation attempt with comprehensive details for compliance and security monitoring.

```sql
CREATE TABLE AUDIT_LOG (
    audit_id NUMBER(10) PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation_type VARCHAR2(10) NOT NULL,
    operation_date DATE DEFAULT SYSDATE,
    operation_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50) DEFAULT USER,
    status VARCHAR2(20) NOT NULL,
    denial_reason VARCHAR2(200),
    record_id NUMBER(10),
    old_values CLOB,
    new_values CLOB
);
```

**Key Features:**
- Automatic timestamp recording
- Username capture
- Status tracking (ALLOWED/DENIED)
- Old and new values for change tracking
- Denial reason documentation

---

### 3. Core Functions & Procedures

#### Function: `check_operation_allowed()`

**Purpose:** Validates whether database operations can proceed based on current day/date.

**Returns:** 
- `'ALLOWED'` - Operation can proceed (weekend)
- `'DENIED: Operations not allowed on weekdays (MON)'` - Weekday block
- `'DENIED: Operations not allowed on public holidays'` - Holiday block

**Logic:**
1. Checks if current day is Monday-Friday → DENY
2. Checks if current date matches any holiday → DENY
3. Otherwise (weekend) → ALLOW

#### Procedure: `log_audit_entry()`

**Purpose:** Records all operation attempts in the audit log.

**Parameters:**
- `p_table_name` - Table being modified
- `p_operation` - INSERT/UPDATE/DELETE
- `p_status` - ALLOWED/DENIED
- `p_denial_reason` - Reason if denied
- `p_record_id` - Record identifier
- `p_old_values` - Previous values
- `p_new_values` - New values

---

### 4. Trigger Implementation

#### Simple Triggers (CITIZEN Table)

**Three row-level BEFORE triggers:**

1. **`trg_citizen_before_insert`**
   - Fires: Before INSERT on CITIZEN
   - Action: Validates operation timing
   - Logs: All attempts (allowed/denied)
   - Blocks: Weekday and holiday inserts

2. **`trg_citizen_before_update`**
   - Fires: Before UPDATE on CITIZEN
   - Action: Validates operation timing
   - Logs: Both old and new values
   - Blocks: Weekday and holiday updates

3. **`trg_citizen_before_delete`**
   - Fires: Before DELETE on CITIZEN
   - Action: Validates operation timing
   - Logs: Deleted record details
   - Blocks: Weekday and holiday deletions

#### Compound Trigger (APPLICATION Table)

**`trg_application_compound`** - Advanced multi-phase trigger

**Structure:**
```
COMPOUND TRIGGER
├── BEFORE STATEMENT
│   └── Check operation allowed once for entire statement
├── BEFORE EACH ROW
│   └── Collect operation details for each affected row
└── AFTER STATEMENT
    └── Batch log all successful operations
```

**Advantages:**
- **Performance:** Single validation check per statement
- **Efficiency:** Batch logging reduces overhead
- **Consistency:** All rows processed together
- **Atomicity:** Transaction-level control

---

## Testing Results

### Test Scenarios

#### Test 1: Restriction Function Validation
```sql
-- Check current day status
SELECT check_operation_allowed() FROM DUAL;
```
**Expected:** Shows current restriction status

#### Test 2: INSERT Operation (Weekday)
```sql
INSERT INTO CITIZEN VALUES (...);
```
**Expected:** ❌ DENIED with error -20001

#### Test 3: UPDATE Operation (Weekday)
```sql
UPDATE CITIZEN SET residency_status = 'TEMPORARY' WHERE citizen_id = 1000;
```
**Expected:** ❌ DENIED with error -20002

#### Test 4: DELETE Operation (Weekday)
```sql
DELETE FROM CITIZEN WHERE citizen_id = 9999;
```
**Expected:** ❌ DENIED with error -20003

#### Test 5: Weekend Operations
```sql
-- Run same operations on Saturday/Sunday
```
**Expected:** ✅ ALLOWED and logged

---

## Verification Queries

### Check Trigger Status
```sql
SELECT trigger_name, table_name, triggering_event, status
FROM USER_TRIGGERS
WHERE table_name IN ('CITIZEN', 'APPLICATION')
ORDER BY table_name, trigger_name;
```

### View Audit Log Entries
```sql
SELECT audit_id, table_name, operation_type, 
       TO_CHAR(operation_date, 'YYYY-MM-DD') as op_date,
       username, status, denial_reason
FROM AUDIT_LOG
ORDER BY audit_id DESC;
```

### Operations by Status
```sql
SELECT table_name, operation_type, status, COUNT(*) as count
FROM AUDIT_LOG
GROUP BY table_name, operation_type, status
ORDER BY table_name, operation_type;
```

### Denied Operations Only
```sql
SELECT audit_id, table_name, operation_type,
       TO_CHAR(operation_date, 'YYYY-MM-DD DY') as attempt_day,
       denial_reason, new_values
FROM AUDIT_LOG
WHERE status = 'DENIED'
ORDER BY operation_date DESC;
```

### Holiday Calendar
```sql
SELECT TO_CHAR(holiday_date, 'YYYY-MM-DD DY') as holiday,
       holiday_name, holiday_type
FROM HOLIDAYS
ORDER BY holiday_date;
```

---

## Screenshots Documentation

### Required Screenshots for Phase VII Submission

All screenshots must clearly show the **project name** (`thu_27670_kim_permit_db`) visible in the SQL Developer or Oracle session.

#### Screenshot 1: Holiday Table Creation (After STEP 1)
**File:** `screenshot_01_holidays_created.png`

**Should Display:**
- ✅ "HOLIDAYS table created successfully" message
- ✅ "10 rows inserted" confirmation
- ✅ Project/database name visible
- ✅ Timestamp of execution

**SQL Output Example:**
```
HOLIDAYS table created successfully.
Inserting sample holidays...
1 row created.
1 row created.
...
10 row created.
Commit complete.
```

**Verification Query to Screenshot:**
```sql
SELECT COUNT(*) as total_holidays FROM HOLIDAYS;
SELECT holiday_name, TO_CHAR(holiday_date, 'YYYY-MM-DD') FROM HOLIDAYS ORDER BY holiday_date;
```

---

#### Screenshot 2: Audit Log Creation (After STEP 2)
**File:** `screenshot_02_audit_log_created.png`

**Should Display:**
- ✅ "AUDIT_LOG table created successfully" message
- ✅ "Sequence audit_log_seq created" confirmation
- ✅ Table structure visible (DESC AUDIT_LOG)

**SQL Output Example:**
```
AUDIT_LOG table created successfully.
Sequence created.
```

**Verification Query to Screenshot:**
```sql
DESC AUDIT_LOG;
SELECT sequence_name, last_number FROM USER_SEQUENCES WHERE sequence_name = 'AUDIT_LOG_SEQ';
```

---

#### Screenshot 3: Audit Procedure Creation (After STEP 3)
**File:** `screenshot_03_procedure_created.png`

**Should Display:**
- ✅ "Procedure log_audit_entry compiled" message
- ✅ No errors shown
- ✅ Procedure visible in object browser

**SQL Output Example:**
```
Creating log_audit_entry procedure...
Procedure created.
```

**Verification Query to Screenshot:**
```sql
SELECT object_name, object_type, status 
FROM USER_OBJECTS 
WHERE object_name = 'LOG_AUDIT_ENTRY';
```

---

#### Screenshot 4: Restriction Function Creation (After STEP 4)
**File:** `screenshot_04_function_created.png`

**Should Display:**
- ✅ "Function check_operation_allowed compiled" message
- ✅ Function test showing result
- ✅ Current day of week displayed

**SQL Output Example:**
```
Creating check_operation_allowed function...
Function created.
```

**Test Query to Screenshot:**
```sql
SELECT check_operation_allowed() as current_status FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'DAY, YYYY-MM-DD') as current_date_time FROM DUAL;
```

---

#### Screenshot 5: Simple Triggers Creation (After STEP 5)
**File:** `screenshot_05_simple_triggers_created.png`

**Should Display:**
- ✅ "trg_citizen_before_insert trigger created" message
- ✅ "trg_citizen_before_update trigger created" message
- ✅ "trg_citizen_before_delete trigger created" message
- ✅ Count showing 3 triggers created

**SQL Output Example:**
```
Creating simple triggers for CITIZEN table...
Trigger created.
trg_citizen_before_insert trigger created.
Trigger created.
trg_citizen_before_update trigger created.
Trigger created.
trg_citizen_before_delete trigger created.
```

**Verification Query to Screenshot:**
```sql
SELECT trigger_name, table_name, triggering_event, status
FROM USER_TRIGGERS
WHERE table_name = 'CITIZEN'
ORDER BY trigger_name;
```

---

#### Screenshot 6: Compound Trigger Creation (After STEP 6)
**File:** `screenshot_06_compound_trigger_created.png`

**Should Display:**
- ✅ "Compound trigger created successfully" message
- ✅ Total triggers count = 4 (3 simple + 1 compound)
- ✅ All triggers showing ENABLED status

**SQL Output Example:**
```
Creating compound trigger for APPLICATION table...
Trigger created.
```

**Verification Query to Screenshot:**
```sql
SELECT trigger_name, table_name, trigger_type, status
FROM USER_TRIGGERS
WHERE table_name IN ('CITIZEN', 'APPLICATION')
ORDER BY table_name, trigger_name;

-- Count total triggers
SELECT 'Total Triggers Created' as metric, COUNT(*) as count
FROM USER_TRIGGERS
WHERE table_name IN ('CITIZEN', 'APPLICATION');
```

---

#### Screenshot 7: Test 1 - Restriction Function (After TEST 1)
**File:** `screenshot_07_test1_restriction_function.png`

**Should Display:**
- ✅ Test header: "=== TEST 1: RESTRICTION FUNCTION ==="
- ✅ Function result output
- ✅ Current day shown (MON/TUE/WED/THU/FRI or SAT/SUN)

**Expected Output (Weekday):**
```
=== TEST 1: RESTRICTION FUNCTION ===
Function Result: DENIED: Operations not allowed on weekdays (THU)
```

**Expected Output (Weekend):**
```
=== TEST 1: RESTRICTION FUNCTION ===
Function Result: ALLOWED
```

---

#### Screenshot 8: Test 2 - INSERT Operation (After TEST 2)
**File:** `screenshot_08_test2_insert_denied.png`

**Should Display:**
- ✅ Test header: "=== TEST 2: INSERT OPERATION ==="
- ✅ Error message with code (ORA-20001)
- ✅ "DENIED: Operations not allowed on weekdays" message
- ✅ Audit log entry created

**Expected Output (Weekday - DENIED):**
```
=== TEST 2: INSERT OPERATION ===
Attempting to insert test citizen...
✗ INSERT denied: ORA-20001: DENIED: Operations not allowed on weekdays (THU)
```

**Expected Output (Weekend - ALLOWED):**
```
=== TEST 2: INSERT OPERATION ===
Attempting to insert test citizen...
✓ INSERT allowed successfully
```

**Audit Log Query to Screenshot:**
```sql
SELECT audit_id, table_name, operation_type, status, denial_reason
FROM AUDIT_LOG
WHERE table_name = 'CITIZEN' AND operation_type = 'INSERT'
ORDER BY audit_id DESC
FETCH FIRST 1 ROWS ONLY;
```

---

#### Screenshot 9: Test 3 - UPDATE Operation (After TEST 3)
**File:** `screenshot_09_test3_update_denied.png`

**Should Display:**
- ✅ Test header: "=== TEST 3: UPDATE OPERATION ==="
- ✅ Error message with code (ORA-20002)
- ✅ Audit entry showing DENIED status

**Expected Output:**
```
=== TEST 3: UPDATE OPERATION ===
Attempting to update citizen...
✗ UPDATE denied: ORA-20002: DENIED: Operations not allowed on weekdays (THU)
```

---

#### Screenshot 10: Test 4 - DELETE Operation (After TEST 4)
**File:** `screenshot_10_test4_delete_denied.png`

**Should Display:**
- ✅ Test header: "=== TEST 4: DELETE OPERATION ==="
- ✅ Error message with code (ORA-20003)
- ✅ Audit entry logged

**Expected Output:**
```
=== TEST 4: DELETE OPERATION ===
Attempting to delete citizen...
✗ DELETE denied: ORA-20003: DENIED: Operations not allowed on weekdays (THU)
```

---

#### Screenshot 11: Test 5 - Compound Trigger Test (After TEST 5)
**File:** `screenshot_11_test5_compound_trigger.png`

**Should Display:**
- ✅ Test header: "=== TEST 5: APPLICATION OPERATIONS ==="
- ✅ Compound trigger behavior confirmation
- ✅ Message about trigger being active

**Expected Output:**
```
=== TEST 5: APPLICATION OPERATIONS ===
Testing compound trigger...
Compound trigger is active and will fire on any DML
```

**Additional Test Query:**
```sql
-- Attempt operation on APPLICATION table
INSERT INTO APPLICATION (application_id, citizen_id, permit_type_id, submission_date, status)
VALUES (9999, 1000, 1, SYSDATE, 'SUBMITTED');
```

---

#### Screenshot 12: All Test Results Summary
**File:** `screenshot_12_all_tests_summary.png`

**Should Display:**
- ✅ Summary of all 5 tests
- ✅ Pass/Fail status for each
- ✅ Current day of week
- ✅ Total audit entries created

**Summary Query to Screenshot:**
```sql
-- Test Results Summary
SELECT 
    'Test 1: Restriction Function' as test_name,
    check_operation_allowed() as result
FROM DUAL
UNION ALL
SELECT 
    'Test 2-5: Operations Count' as test_name,
    TO_CHAR(COUNT(*)) || ' audit entries' as result
FROM AUDIT_LOG;

-- Show recent audit entries
SELECT 
    audit_id,
    table_name,
    operation_type,
    status,
    SUBSTR(denial_reason, 1, 50) as reason
FROM AUDIT_LOG
ORDER BY audit_id DESC
FETCH FIRST 10 ROWS ONLY;
```

---

#### Screenshot 13: Verification - Trigger Status (After VERIFICATION RESULTS)
**File:** `screenshot_13_trigger_status.png`

**Should Display:**
- ✅ All 4 triggers listed
- ✅ Status = ENABLED for all
- ✅ Correct table names (CITIZEN, APPLICATION)
- ✅ Triggering events shown

**Verification Query:**
```sql
-- Trigger Status
SELECT 
    trigger_name,
    table_name,
    triggering_event,
    trigger_type,
    status
FROM USER_TRIGGERS
WHERE table_name IN ('CITIZEN', 'APPLICATION')
ORDER BY table_name, trigger_name;
```

**Expected Results:**
```
TRIGGER_NAME                    TABLE_NAME    TRIGGERING_EVENT    STATUS
------------------------------- ------------- ------------------- -------
TRG_CITIZEN_BEFORE_INSERT       CITIZEN       INSERT              ENABLED
TRG_CITIZEN_BEFORE_UPDATE       CITIZEN       UPDATE              ENABLED
TRG_CITIZEN_BEFORE_DELETE       CITIZEN       DELETE              ENABLED
TRG_APPLICATION_COMPOUND        APPLICATION   INSERT OR UPDATE    ENABLED
                                              OR DELETE
```

---

#### Screenshot 14: Verification - Function & Procedure Status
**File:** `screenshot_14_function_procedure_status.png`

**Should Display:**
- ✅ check_operation_allowed (FUNCTION) = VALID
- ✅ log_audit_entry (PROCEDURE) = VALID
- ✅ Object type and status columns

**Verification Query:**
```sql
-- Function and Procedure Status
SELECT 
    object_name,
    object_type,
    status,
    TO_CHAR(created, 'YYYY-MM-DD HH24:MI:SS') as created_date
FROM USER_OBJECTS
WHERE object_name IN ('CHECK_OPERATION_ALLOWED', 'LOG_AUDIT_ENTRY')
ORDER BY object_type, object_name;
```

---

#### Screenshot 15: Verification - Table Status
**File:** `screenshot_15_table_status.png`

**Should Display:**
- ✅ HOLIDAYS table with row count
- ✅ AUDIT_LOG table with row count
- ✅ Both tables showing VALID status

**Verification Query:**
```sql
-- Table Status
SELECT 
    table_name,
    num_rows,
    TO_CHAR(last_analyzed, 'YYYY-MM-DD') as last_analyzed
FROM USER_TABLES
WHERE table_name IN ('HOLIDAYS', 'AUDIT_LOG')
ORDER BY table_name;

-- Show actual counts
SELECT 'HOLIDAYS' as table_name, COUNT(*) as actual_count FROM HOLIDAYS
UNION ALL
SELECT 'AUDIT_LOG', COUNT(*) FROM AUDIT_LOG;
```

---

#### Screenshot 16: Audit Log Entries View
**File:** `screenshot_16_audit_log_entries.png`

**Should Display:**
- ✅ Recent audit log entries (last 10-15 rows)
- ✅ Mix of ALLOWED and DENIED operations
- ✅ Different operation types (INSERT, UPDATE, DELETE)
- ✅ Timestamps and usernames visible

**Display Query:**
```sql
-- Recent Audit Log Entries
SELECT 
    audit_id,
    table_name,
    operation_type,
    TO_CHAR(operation_date, 'YYYY-MM-DD') as op_date,
    TO_CHAR(operation_time, 'HH24:MI:SS') as op_time,
    username,
    status,
    SUBSTR(denial_reason, 1, 40) as reason
FROM AUDIT_LOG
ORDER BY audit_id DESC
FETCH FIRST 15 ROWS ONLY;
```

---

#### Screenshot 17: Operations Summary Statistics
**File:** `screenshot_17_operations_summary.png`

**Should Display:**
- ✅ Total audit entries count
- ✅ Allowed operations count
- ✅ Denied operations count
- ✅ Breakdown by table and operation type

**Summary Query:**
```sql
-- Summary Statistics
SELECT 
    'Total Audit Entries' as metric,
    COUNT(*) as value
FROM AUDIT_LOG
UNION ALL
SELECT 
    'Allowed Operations',
    COUNT(*)
FROM AUDIT_LOG
WHERE status = 'ALLOWED'
UNION ALL
SELECT 
    'Denied Operations',
    COUNT(*)
FROM AUDIT_LOG
WHERE status = 'DENIED'
UNION ALL
SELECT 
    'Total Triggers',
    COUNT(*)
FROM USER_TRIGGERS
WHERE table_name IN ('CITIZEN', 'APPLICATION');

-- Operations by Table
SELECT 
    table_name,
    operation_type,
    status,
    COUNT(*) as count
FROM AUDIT_LOG
GROUP BY table_name, operation_type, status
ORDER BY table_name, operation_type, status;
```

---

### Screenshot Organization for GitHub

```
screenshots/
├── phase7_implementation/
│   ├── 01_holidays_created.png
│   ├── 02_audit_log_created.png
│   ├── 03_procedure_created.png
│   ├── 04_function_created.png
│   ├── 05_simple_triggers_created.png
│   └── 06_compound_trigger_created.png
│
├── phase7_testing/
│   ├── 07_test1_restriction_function.png
│   ├── 08_test2_insert_denied.png
│   ├── 09_test3_update_denied.png
│   ├── 10_test4_delete_denied.png
│   ├── 11_test5_compound_trigger.png
│   └── 12_all_tests_summary.png
│
└── phase7_verification/
    ├── 13_trigger_status.png
    ├── 14_function_procedure_status.png
    ├── 15_table_status.png
    ├── 16_audit_log_entries.png
    └── 17_operations_summary.png
```

---

### Screenshot Checklist

Before submitting, verify each screenshot includes:

- [ ] **Project Name Visible** - `thu_27670_kim_permit_db` shown clearly
- [ ] **Timestamp** - Date/time of execution visible
- [ ] **SQL Developer Window** - Full window with query and results
- [ ] **Clear Text** - Readable font size (zoom if needed)
- [ ] **No Sensitive Info** - No passwords or personal data visible
- [ ] **Complete Output** - All relevant messages captured
- [ ] **Proper Naming** - Files named according to convention
- [ ] **High Quality** - PNG format, good resolution

---

### Tips for Taking Screenshots

1. **Use SQL Developer's Output Panel:** Show both query and results
2. **Enable SERVEROUTPUT:** `SET SERVEROUTPUT ON;` before tests
3. **Clear Previous Output:** Start with clean output window
4. **Zoom for Clarity:** Ensure text is readable (120-150% zoom)
5. **Capture Full Window:** Include SQL Developer title bar with connection name
6. **Use Snipping Tool:** Windows Snipping Tool or Mac Screenshot (Cmd+Shift+4)
7. **Label Each Test:** Add comments in SQL showing test number

---

## File Structure

```
phase7_triggers_auditing/
├── 01_holiday_table.sql          # Holiday management setup
├── 02_audit_log_table.sql        # Audit logging infrastructure
├── 03_audit_procedure.sql        # Audit logging procedure
├── 04_restriction_function.sql   # Operation validation function
├── 05_citizen_triggers.sql       # Simple triggers for CITIZEN
├── 06_application_trigger.sql    # Compound trigger for APPLICATION
├── 07_test_scenarios.sql         # Comprehensive testing suite
├── 08_verification_queries.sql   # Validation and monitoring queries
├── README.md                     # This documentation
└── screenshots/                  # All Phase VII screenshots
    ├── phase7_implementation/    # Setup screenshots (1-6)
    ├── phase7_testing/           # Test screenshots (7-12)
    └── phase7_verification/      # Verification screenshots (13-17)
```

---

## Security Features

### Access Control
- ✅ Time-based operation restrictions
- ✅ Holiday-aware blocking
- ✅ User tracking (USERNAME column)
- ✅ Automatic timestamp recording

### Audit Trail
- ✅ Complete operation history
- ✅ Before/after value tracking
- ✅ Denial reason documentation
- ✅ Non-repudiation (COMMIT in audit)

### Error Handling
- ✅ Custom error codes (-20001 to -20004)
- ✅ Descriptive error messages
- ✅ Graceful exception management
- ✅ Fallback error logging

---

## Performance Considerations

### Optimization Strategies
1. **Compound Trigger:** Reduces trigger overhead on APPLICATION table
2. **Indexed Columns:** `holiday_date` indexed for fast lookup
3. **TRUNC Functions:** Efficient date comparisons
4. **Autonomous Transactions:** Audit logs persist even on rollback

### Monitoring Metrics
```sql
-- Operation volume by day
SELECT TO_CHAR(operation_date, 'YYYY-MM-DD DY') as day,
       COUNT(*) as total_operations,
       SUM(CASE WHEN status = 'DENIED' THEN 1 ELSE 0 END) as denied
FROM AUDIT_LOG
GROUP BY TO_CHAR(operation_date, 'YYYY-MM-DD DY')
ORDER BY operation_date DESC;
```

---

## Maintenance Procedures

### Adding New Holidays
```sql
INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (11, TO_DATE('2026-12-25', 'YYYY-MM-DD'), 'Christmas Day 2026', 'PUBLIC');
COMMIT;
```

### Clearing Old Audit Logs (Archive Strategy)
```sql
-- Archive logs older than 1 year
DELETE FROM AUDIT_LOG 
WHERE operation_date < ADD_MONTHS(SYSDATE, -12);
COMMIT;
```

### Disabling Triggers (Emergency Only)
```sql
-- Disable all triggers on CITIZEN
ALTER TRIGGER trg_citizen_before_insert DISABLE;
ALTER TRIGGER trg_citizen_before_update DISABLE;
ALTER TRIGGER trg_citizen_before_delete DISABLE;

-- Re-enable after maintenance
ALTER TRIGGER trg_citizen_before_insert ENABLE;
ALTER TRIGGER trg_citizen_before_update ENABLE;
ALTER TRIGGER trg_citizen_before_delete ENABLE;
```

---

## Compliance & Reporting

### Audit Summary Report
```sql
SELECT 
    'Total Operations' as metric,
    COUNT(*) as value
FROM AUDIT_LOG
UNION ALL
SELECT 'Allowed Operations', COUNT(*) FROM AUDIT_LOG WHERE status = 'ALLOWED'
UNION ALL
SELECT 'Denied Operations', COUNT(*) FROM AUDIT_LOG WHERE status = 'DENIED'
UNION ALL
SELECT 'Unique Users', COUNT(DISTINCT username) FROM AUDIT_LOG;
```

### Violation Tracking
```sql
-- Users attempting unauthorized operations
SELECT username, 
       COUNT(*) as violation_attempts,
       MAX(operation_date) as last_attempt
FROM AUDIT_LOG
WHERE status = 'DENIED'
GROUP BY username
ORDER BY violation_attempts DESC;
```

---

## Known Limitations

1. **Time Zone:** Uses server time (SYSDATE) - ensure server timezone is correct
2. **Holiday Updates:** Requires manual insertion of new holidays annually
3. **Autonomous Transactions:** Audit logs cannot be rolled back (by design)
4. **Performance:** High-volume operations may experience slight delay due to validation

---

## Future Enhancements

- [ ] Email notifications for denied operations
- [ ] Role-based operation permissions (weekend admins)
- [ ] Automated holiday calendar import
- [ ] Real-time audit dashboard
- [ ] Machine learning for anomaly detection

---

## References

- **Project Document:** `PLSQL_Capstone_Project_Enhanced_BI.pdf`
- **Project Description:** `Citizen_Permit_and_Licensing_System_description_27670.pdf`
- **Phase VII Requirements:** Section 7, Pages 6-7
- **Oracle Documentation:** PL/SQL Triggers and Auditing Best Practices

---

## Contact & Support

**Student:** NGABONZIZA Kim Gakuba  
**ID:** 27670  
**Lecturer:** Eric Maniraguha (eric.maniraguha@auca.ac.rw)  
**Institution:** Adventist University of Central Africa (AUCA)

---

## Conclusion

Phase VII successfully implements a **robust auditing and security framework** that:
- ✅ Enforces business rules automatically
- ✅ Maintains complete audit trails
- ✅ Protects data integrity
- ✅ Ensures compliance with operational policies
- ✅ Provides visibility into all database operations

**All triggers tested and verified functional. Ready for production deployment.**

---

*"Whatever you do, work at it with all your heart, as working for the Lord, not for human masters." — Colossians 3:23 (NIV)* 
