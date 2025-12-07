# 🚀 Phase VI: Advanced PL/SQL Components

> **A comprehensive guide to database procedures, functions, packages, and analytics for the Citizen Permit Management System**

---

## 🎯 Component Overview

Phase VI implements enterprise-grade PL/SQL components that encapsulate business logic, enhance performance, and provide powerful analytics capabilities.

### **Core Components**

| Component Type | Count | Purpose |
|----------------|-------|---------|
| **Stored Procedures** | 7 | Business logic encapsulation |
| **Functions** | 10 | Reusable calculations & validations |
| **Packages** | 2 | Grouped functionality modules |
| **Window Functions** | 7 | Advanced analytical queries |

---

## 🔧 Stored Procedures

### **Procedure Catalog**

#### 1️⃣ **`sp_register_citizen`**
**Purpose:** Register new citizens with validation  
**Features:**
- ✅ Age validation (18+ requirement)
- ✅ Duplicate detection (National ID, Email)
- ✅ Automatic sequence generation

#### 2️⃣ **`sp_submit_application`**
**Purpose:** Submit permit applications  
**Features:**
- ✅ Automatic application numbering
- ✅ Dynamic fee calculation
- ✅ Initial status assignment

#### 3️⃣ **`sp_update_application_status`**
**Purpose:** Manage application workflow  
**Features:**
- ✅ Status validation
- ✅ Audit trail creation
- ✅ Business rule enforcement

#### 4️⃣ **`sp_process_payment`**
**Purpose:** Handle payment transactions  
**Features:**
- ✅ Amount validation
- ✅ Change calculation
- ✅ Transaction logging

#### 5️⃣ **`sp_add_review_step`**
**Purpose:** Add review stages  
**Features:**
- ✅ Step sequencing
- ✅ Status synchronization
- ✅ Timeline tracking

#### 6️⃣ **`sp_complete_review_step`**
**Purpose:** Complete review processes  
**Features:**
- ✅ Processing time calculation
- ✅ Workflow advancement
- ✅ Performance metrics

#### 7️⃣ **`sp_bulk_update_status`**
**Purpose:** Batch status operations  
**Features:**
- ✅ Cursor-based processing
- ✅ Transaction management
- ✅ Bulk optimization

---

## 📊 Functions Library

### **Function Reference**

| Function | Returns | Description |
|----------|---------|-------------|
| `fn_calculate_processing_time` | `NUMBER` | Days between submission and completion |
| `fn_get_citizen_name` | `VARCHAR2` | Formatted full name |
| `fn_calculate_revenue` | `NUMBER` | Revenue for specified period |
| `fn_validate_eligibility` | `VARCHAR2` | Permit eligibility check |
| `fn_calculate_ipei` | `NUMBER` | Integrated Performance Efficiency Index |
| `fn_get_app_status_summary` | `VARCHAR2` | Application status summary |
| `fn_count_pending_reviews` | `NUMBER` | Count of pending reviews |
| `fn_calculate_renewal_fee` | `NUMBER` | Renewal fee calculation |
| `fn_get_permit_details` | `VARCHAR2` | Formatted permit information |
| `fn_calculate_citizen_age` | `NUMBER` | Age calculation from birth date |

---

## 📦 Package Architecture

### **Package 1: Application Management** (`pkg_application_mgmt`)

**Purpose:** Centralized application lifecycle management

**Procedures:**
- `submit_application` - New application submission
- `update_status` - Status transition management
- `cancel_application` - Application cancellation

**Functions:**
- `get_application_count` - Total application metrics
- `get_pending_count` - Pending applications count
- `calculate_approval_rate` - Success rate calculation

---

### **Package 2: Analytics** (`pkg_analytics`)

**Purpose:** Business intelligence and reporting

**Components:**
- `get_monthly_revenue` - Pipelined function for revenue analysis
- `get_department_performance` - Performance scoring
- `get_top_permit_types` - REF CURSOR for top permits

---

## 📈 Analytics & Window Functions

### **Advanced SQL Demonstrations**

| Example | Function | Use Case |
|---------|----------|----------|
| **Example 1** | `ROW_NUMBER()` | Rank applications per citizen |
| **Example 2** | `RANK()`, `DENSE_RANK()` | Revenue-based permit ranking |
| **Example 3** | `LAG()`, `LEAD()` | Processing time comparisons |
| **Example 4** | `PARTITION BY` | Department-level statistics |
| **Example 5** | Moving Average | 3-month revenue trends |
| **Example 6** | `NTILE()` | Citizen categorization |
| **Example 7** | `FIRST_VALUE()`, `LAST_VALUE()` | Processing benchmarks |

---

## 🧪 Testing Strategy

### **Test Categories**

```
✅ Unit Tests         → Individual component validation
✅ Integration Tests  → Package functionality verification
✅ Analytics Tests    → Window functions and reporting
✅ Error Tests        → Exception handling validation
```

### **Test Data Generation**
- Timestamp-based unique values
- Dynamic ID selection
- Realistic business scenarios
- Edge case coverage

---

## 📸 Screenshot Requirements

### **Mandatory Captures**
```SQL
-- ============================================================================
-- PHASE VI: PL/SQL PROCEDURES
-- Student: NGABONZIZA Kim Gakuba (27670)
-- ============================================================================

CONNECT gakuba/Kim@localhost:1521/thu_27670_kim_permit_db;
SET SERVEROUTPUT ON;

-- ============================================================================
-- PROCEDURE 1: Register New Citizen
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_register_citizen (
    p_first_name        IN  VARCHAR2,
    p_last_name         IN  VARCHAR2,
    p_date_of_birth     IN  DATE,
    p_national_id       IN  VARCHAR2,
    p_email             IN  VARCHAR2,
    p_phone             IN  VARCHAR2,
    p_address           IN  VARCHAR2,
    p_residency_status  IN  VARCHAR2,
    p_citizen_id        OUT NUMBER
) AS
    v_age NUMBER;
    v_exists NUMBER;
    e_invalid_age EXCEPTION;
    e_duplicate_id EXCEPTION;
    e_duplicate_email EXCEPTION;
BEGIN
    v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, p_date_of_birth) / 12);
    IF v_age < 18 THEN RAISE e_invalid_age; END IF;
    
    SELECT COUNT(*) INTO v_exists FROM citizen WHERE national_id = p_national_id;
    IF v_exists > 0 THEN RAISE e_duplicate_id; END IF;
    
    SELECT COUNT(*) INTO v_exists FROM citizen WHERE email = p_email;
    IF v_exists > 0 THEN RAISE e_duplicate_email; END IF;
    
    INSERT INTO citizen (
        citizen_id, first_name, last_name, date_of_birth,
        national_id, email, phone, address,
        residency_status, registration_date, status
    ) VALUES (
        seq_citizen_id.NEXTVAL, p_first_name, p_last_name, p_date_of_birth,
        p_national_id, p_email, p_phone, p_address,
        p_residency_status, SYSDATE, 'Active'
    ) RETURNING citizen_id INTO p_citizen_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Citizen registered successfully. ID: ' || p_citizen_id);
EXCEPTION
    WHEN e_invalid_age THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20001, 'Citizen must be 18 years or older. Current age: ' || v_age);
    WHEN e_duplicate_id THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20002, 'National ID already exists: ' || p_national_id);
    WHEN e_duplicate_email THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20003, 'Email already exists: ' || p_email);
    WHEN OTHERS THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20099, 'Error registering citizen: ' || SQLERRM);
END sp_register_citizen;
/

-- ============================================================================
-- PROCEDURE 2: Submit New Application
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_submit_application (
    p_citizen_id        IN  NUMBER,
    p_permit_type_id    IN  NUMBER,
    p_priority_level    IN  VARCHAR2 DEFAULT 'Normal',
    p_notes             IN  VARCHAR2 DEFAULT NULL,
    p_application_id    OUT NUMBER
) AS
    v_app_number VARCHAR2(30);
    v_processing_fee NUMBER;
    v_estimated_days NUMBER;
    v_completion_date DATE;
    v_citizen_exists NUMBER;
    v_permit_exists NUMBER;
    v_next_seq_val NUMBER;
    e_invalid_citizen EXCEPTION;
    e_invalid_permit EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_citizen_exists FROM citizen WHERE citizen_id = p_citizen_id AND status = 'Active';
    IF v_citizen_exists = 0 THEN RAISE e_invalid_citizen; END IF;
    
    SELECT COUNT(*) INTO v_permit_exists FROM permit_type WHERE permit_type_id = p_permit_type_id AND is_active = 'Y';
    IF v_permit_exists = 0 THEN RAISE e_invalid_permit; END IF;
    
    SELECT processing_fee, estimated_days INTO v_processing_fee, v_estimated_days
    FROM permit_type WHERE permit_type_id = p_permit_type_id;
    
    v_completion_date := SYSDATE + v_estimated_days;
    SELECT seq_application_id.NEXTVAL INTO v_next_seq_val FROM DUAL;
    
    v_app_number := 'APP-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || LPAD(v_next_seq_val, 6, '0');
    
    INSERT INTO application (
        application_id, citizen_id, permit_type_id, application_number,
        submission_date, status, priority_level, payment_status,
        payment_amount, notes, last_updated, estimated_completion
    ) VALUES (
        v_next_seq_val, p_citizen_id, p_permit_type_id, v_app_number,
        SYSDATE, 'Submitted', p_priority_level, 'Pending',
        v_processing_fee, p_notes, SYSDATE, v_completion_date
    ) RETURNING application_id INTO p_application_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Application submitted successfully.');
    DBMS_OUTPUT.PUT_LINE('Application ID: ' || p_application_id);
    DBMS_OUTPUT.PUT_LINE('Application Number: ' || v_app_number);
    DBMS_OUTPUT.PUT_LINE('Fee: ' || v_processing_fee);
    DBMS_OUTPUT.PUT_LINE('Estimated Completion: ' || TO_CHAR(v_completion_date, 'YYYY-MM-DD'));
EXCEPTION
    WHEN e_invalid_citizen THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20004, 'Invalid or inactive citizen ID: ' || p_citizen_id);
    WHEN e_invalid_permit THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20005, 'Invalid or inactive permit type ID: ' || p_permit_type_id);
    WHEN OTHERS THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20099, 'Error submitting application: ' || SQLERRM);
END sp_submit_application;
/

-- ============================================================================
-- PROCEDURE 3: Update Application Status
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_update_application_status (
    p_application_id    IN NUMBER,
    p_new_status        IN VARCHAR2,
    p_comments          IN VARCHAR2 DEFAULT NULL,
    p_officer_id        IN NUMBER DEFAULT 1001
) AS
    v_current_status VARCHAR2(30);
    v_app_exists NUMBER;
    e_invalid_app EXCEPTION;
    e_invalid_status EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_app_exists FROM application WHERE application_id = p_application_id;
    IF v_app_exists = 0 THEN RAISE e_invalid_app; END IF;
    
    SELECT status INTO v_current_status FROM application WHERE application_id = p_application_id;
    
    IF p_new_status NOT IN ('Submitted', 'Under Review', 'Documentation Required', 
                            'Approved', 'Rejected', 'Cancelled', 'On Hold') THEN
        RAISE e_invalid_status;
    END IF;
    
    UPDATE application
    SET status = p_new_status,
        last_updated = SYSDATE,
        assigned_officer_id = p_officer_id,
        notes = CASE 
            WHEN p_comments IS NOT NULL THEN 
                COALESCE(notes, '') || CHR(10) || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ': ' || p_comments
            ELSE notes
        END
    WHERE application_id = p_application_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Application status updated successfully.');
    DBMS_OUTPUT.PUT_LINE('Application ID: ' || p_application_id);
    DBMS_OUTPUT.PUT_LINE('Previous Status: ' || v_current_status);
    DBMS_OUTPUT.PUT_LINE('New Status: ' || p_new_status);
    DBMS_OUTPUT.PUT_LINE('Updated by Officer: ' || p_officer_id);
EXCEPTION
    WHEN e_invalid_app THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20006, 'Application not found: ' || p_application_id);
    WHEN e_invalid_status THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20007, 'Invalid status: ' || p_new_status);
    WHEN OTHERS THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20099, 'Error updating application status: ' || SQLERRM);
END sp_update_application_status;
/

-- ============================================================================
-- PROCEDURE 4: Process Payment
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_process_payment (
    p_application_id    IN NUMBER,
    p_payment_amount    IN NUMBER,
    p_payment_method    IN VARCHAR2 DEFAULT 'Cash'
) AS
    v_required_fee NUMBER;
    v_current_status VARCHAR2(30);
    v_app_exists NUMBER;
    v_change NUMBER;
    e_invalid_app EXCEPTION;
    e_invalid_amount EXCEPTION;
    e_already_paid EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_app_exists FROM application WHERE application_id = p_application_id;
    IF v_app_exists = 0 THEN RAISE e_invalid_app; END IF;
    
    SELECT a.payment_amount, a.payment_status INTO v_required_fee, v_current_status
    FROM application a WHERE a.application_id = p_application_id;
    
    IF v_current_status = 'Paid' THEN RAISE e_already_paid; END IF;
    IF p_payment_amount < v_required_fee THEN RAISE e_invalid_amount; END IF;
    
    v_change := p_payment_amount - v_required_fee;
    
    UPDATE application
    SET payment_status = 'Paid',
        last_updated = SYSDATE,
        notes = COALESCE(notes, '') || CHR(10) || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || 
                ': Payment received - ' || p_payment_method || ' - Amount: ' || p_payment_amount
    WHERE application_id = p_application_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Payment processed successfully.');
    DBMS_OUTPUT.PUT_LINE('Application ID: ' || p_application_id);
    DBMS_OUTPUT.PUT_LINE('Amount Paid: ' || p_payment_amount);
    DBMS_OUTPUT.PUT_LINE('Payment Method: ' || p_payment_method);
    DBMS_OUTPUT.PUT_LINE('Required Fee: ' || v_required_fee);
    DBMS_OUTPUT.PUT_LINE('Change: ' || v_change);
EXCEPTION
    WHEN e_invalid_app THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20008, 'Application not found: ' || p_application_id);
    WHEN e_invalid_amount THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20009, 'Insufficient payment. Required: ' || v_required_fee || ', Received: ' || p_payment_amount);
    WHEN e_already_paid THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20010, 'Application already paid');
    WHEN OTHERS THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20099, 'Error processing payment: ' || SQLERRM);
END sp_process_payment;
/

-- ============================================================================
-- PROCEDURE 5: Add Review Step
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_add_review_step (
    p_application_id    IN NUMBER,
    p_department_id     IN NUMBER,
    p_reviewer_name     IN VARCHAR2,
    p_comments          IN VARCHAR2 DEFAULT NULL
) AS
    v_step_number NUMBER;
    v_app_exists NUMBER;
    v_dept_exists NUMBER;
    e_invalid_app EXCEPTION;
    e_invalid_dept EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_app_exists FROM application WHERE application_id = p_application_id;
    IF v_app_exists = 0 THEN RAISE e_invalid_app; END IF;
    
    SELECT COUNT(*) INTO v_dept_exists FROM department WHERE department_id = p_department_id AND is_active = 'Y';
    IF v_dept_exists = 0 THEN RAISE e_invalid_dept; END IF;
    
    SELECT NVL(MAX(step_number), 0) + 1 INTO v_step_number
    FROM review_step WHERE application_id = p_application_id;
    
    INSERT INTO review_step (
        step_id, application_id, department_id, step_number,
        review_date, step_status, reviewer_name, comments
    ) VALUES (
        seq_review_step_id.NEXTVAL, p_application_id, p_department_id, v_step_number,
        SYSDATE, 'In Progress', p_reviewer_name, p_comments
    );
    
    UPDATE application
    SET status = 'Under Review',
        last_updated = SYSDATE
    WHERE application_id = p_application_id
    AND status NOT IN ('Under Review', 'Approved', 'Rejected');
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Review step added successfully.');
    DBMS_OUTPUT.PUT_LINE('Application ID: ' || p_application_id);
    DBMS_OUTPUT.PUT_LINE('Step Number: ' || v_step_number);
    DBMS_OUTPUT.PUT_LINE('Department ID: ' || p_department_id);
    DBMS_OUTPUT.PUT_LINE('Reviewer: ' || p_reviewer_name);
EXCEPTION
    WHEN e_invalid_app THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20011, 'Application not found: ' || p_application_id);
    WHEN e_invalid_dept THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20012, 'Invalid or inactive department: ' || p_department_id);
    WHEN OTHERS THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20099, 'Error adding review step: ' || SQLERRM);
END sp_add_review_step;
/

-- ============================================================================
-- PROCEDURE 6: Complete Review Step
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_complete_review_step (
    p_step_id       IN NUMBER,
    p_decision      IN VARCHAR2,
    p_comments      IN VARCHAR2 DEFAULT NULL
) AS
    v_step_exists NUMBER;
    v_review_date DATE;
    v_processing_time NUMBER;
    e_invalid_step EXCEPTION;
    e_invalid_decision EXCEPTION;
BEGIN
    SELECT COUNT(*), MAX(review_date) INTO v_step_exists, v_review_date
    FROM review_step WHERE step_id = p_step_id;
    
    IF v_step_exists = 0 THEN RAISE e_invalid_step; END IF;
    
    IF p_decision NOT IN ('Approved', 'Rejected', 'Revision Required') THEN
        RAISE e_invalid_decision;
    END IF;
    
    v_processing_time := ROUND((SYSDATE - v_review_date) * 24 * 60);
    
    UPDATE review_step
    SET step_status = 'Completed',
        decision = p_decision,
        completion_date = SYSDATE,
        processing_time = v_processing_time,
        comments = CASE 
            WHEN p_comments IS NOT NULL THEN 
                COALESCE(comments, '') || CHR(10) || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ': ' || p_comments
            ELSE comments
        END
    WHERE step_id = p_step_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Review step completed successfully.');
    DBMS_OUTPUT.PUT_LINE('Step ID: ' || p_step_id);
    DBMS_OUTPUT.PUT_LINE('Decision: ' || p_decision);
    DBMS_OUTPUT.PUT_LINE('Processing Time: ' || ROUND(v_processing_time/60, 2) || ' hours');
EXCEPTION
    WHEN e_invalid_step THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20013, 'Review step not found: ' || p_step_id);
    WHEN e_invalid_decision THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20014, 'Invalid decision: ' || p_decision || '. Must be: Approved, Rejected, or Revision Required');
    WHEN OTHERS THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20099, 'Error completing review step: ' || SQLERRM);
END sp_complete_review_step;
/

-- ============================================================================
-- PROCEDURE 7: Bulk Update Status
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_bulk_update_status (
    p_old_status        IN VARCHAR2,
    p_new_status        IN VARCHAR2,
    p_days_in_status    IN NUMBER DEFAULT 30,
    p_count_updated     OUT NUMBER
) AS
    CURSOR c_applications IS
        SELECT application_id, application_number
        FROM application
        WHERE status = p_old_status
        AND last_updated < SYSDATE - p_days_in_status;
    v_app_id NUMBER;
    v_app_num VARCHAR2(30);
BEGIN
    p_count_updated := 0;
    IF p_new_status NOT IN ('Submitted', 'Under Review', 'Documentation Required', 
                           'Approved', 'Rejected', 'Cancelled', 'On Hold') THEN
        RAISE_APPLICATION_ERROR(-20015, 'Invalid new status: ' || p_new_status);
    END IF;
    
    OPEN c_applications;
    LOOP
        FETCH c_applications INTO v_app_id, v_app_num;
        EXIT WHEN c_applications%NOTFOUND;
        
        UPDATE application
        SET status = p_new_status,
            last_updated = SYSDATE,
            notes = COALESCE(notes, '') || CHR(10) || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || 
                    ': Bulk status update from ' || p_old_status || ' to ' || p_new_status
        WHERE application_id = v_app_id;
        
        p_count_updated := p_count_updated + 1;
        DBMS_OUTPUT.PUT_LINE('Updated: ' || v_app_num || ' (ID: ' || v_app_id || ')');
    END LOOP;
    CLOSE c_applications;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Bulk update completed. Total updated: ' || p_count_updated);
EXCEPTION
    WHEN OTHERS THEN
        IF c_applications%ISOPEN THEN CLOSE c_applications; END IF;
        ROLLBACK; RAISE_APPLICATION_ERROR(-20099, 'Error in bulk update: ' || SQLERRM);
END sp_bulk_update_status;
/
```

**OUTPUT**

![ALL PROCEDURES CREATION](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_6/screenshots/procedures_creation.png)

---
```SQL
-- ============================================================================
-- PHASE VI: PL/SQL FUNCTIONS
-- ============================================================================

-- FUNCTION 1: Calculate Application Processing Time
CREATE OR REPLACE FUNCTION fn_calculate_processing_time (
    p_application_id IN NUMBER
) RETURN NUMBER AS
    v_submission_date DATE;
    v_completion_date DATE;
    v_processing_days NUMBER;
BEGIN
    SELECT submission_date, 
           CASE WHEN status IN ('Approved', 'Rejected', 'Cancelled') THEN last_updated ELSE NULL END
    INTO v_submission_date, v_completion_date
    FROM application WHERE application_id = p_application_id;
    
    IF v_completion_date IS NULL THEN RETURN NULL; END IF;
    v_processing_days := ROUND(v_completion_date - v_submission_date);
    RETURN v_processing_days;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
    WHEN OTHERS THEN RETURN -1;
END fn_calculate_processing_time;
/

-- FUNCTION 2: Get Citizen Full Name
CREATE OR REPLACE FUNCTION fn_get_citizen_name (
    p_citizen_id IN NUMBER
) RETURN VARCHAR2 AS
    v_first_name VARCHAR2(100);
    v_last_name VARCHAR2(100);
BEGIN
    SELECT first_name, last_name INTO v_first_name, v_last_name
    FROM citizen WHERE citizen_id = p_citizen_id;
    RETURN TRIM(v_first_name || ' ' || v_last_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'Unknown Citizen';
    WHEN OTHERS THEN RETURN 'Error: ' || SQLERRM;
END fn_get_citizen_name;
/

-- FUNCTION 3: Calculate Total Revenue
CREATE OR REPLACE FUNCTION fn_calculate_revenue (
    p_start_date        IN DATE DEFAULT NULL,
    p_end_date          IN DATE DEFAULT NULL,
    p_permit_type_id    IN NUMBER DEFAULT NULL
) RETURN NUMBER AS
    v_total_revenue NUMBER;
BEGIN
    SELECT NVL(SUM(payment_amount), 0) INTO v_total_revenue
    FROM application
    WHERE payment_status = 'Paid'
    AND (p_start_date IS NULL OR submission_date >= p_start_date)
    AND (p_end_date IS NULL OR submission_date <= p_end_date)
    AND (p_permit_type_id IS NULL OR permit_type_id = p_permit_type_id);
    RETURN v_total_revenue;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END fn_calculate_revenue;
/

-- FUNCTION 4: Validate Application Eligibility
CREATE OR REPLACE FUNCTION fn_validate_eligibility (
    p_citizen_id        IN NUMBER,
    p_permit_type_id    IN NUMBER
) RETURN VARCHAR2 AS
    v_citizen_status VARCHAR2(20);
    v_residency VARCHAR2(30);
    v_permit_active CHAR(1);
    v_pending_count NUMBER;
    v_age NUMBER;
    v_date_of_birth DATE;
    v_permit_name VARCHAR2(100);
BEGIN
    SELECT status, residency_status, date_of_birth
    INTO v_citizen_status, v_residency, v_date_of_birth
    FROM citizen WHERE citizen_id = p_citizen_id;
    
    IF v_citizen_status != 'Active' THEN
        RETURN 'NOT_ELIGIBLE: Citizen status is ' || v_citizen_status;
    END IF;
    
    v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, v_date_of_birth) / 12);
    
    SELECT is_active, permit_name INTO v_permit_active, v_permit_name
    FROM permit_type WHERE permit_type_id = p_permit_type_id;
    
    IF v_permit_active != 'Y' THEN
        RETURN 'NOT_ELIGIBLE: Permit type "' || v_permit_name || '" is inactive';
    END IF;
    
    IF v_age < 18 THEN
        RETURN 'NOT_ELIGIBLE: Minimum age requirement is 18. Current age: ' || v_age;
    END IF;
    
    IF UPPER(v_permit_name) LIKE '%BUSINESS%' 
       AND v_residency NOT IN ('Citizen', 'Permanent Resident') THEN
        RETURN 'NOT_ELIGIBLE: ' || v_permit_name || 
               ' requires Citizen or Permanent Resident status. Current: ' || v_residency;
    END IF;
    
    SELECT COUNT(*) INTO v_pending_count
    FROM application
    WHERE citizen_id = p_citizen_id
    AND permit_type_id = p_permit_type_id
    AND status IN ('Submitted', 'Under Review', 'Documentation Required');
    
    IF v_pending_count > 0 THEN
        RETURN 'NOT_ELIGIBLE: Has ' || v_pending_count || 
               ' pending application(s) for "' || v_permit_name || '"';
    END IF;
    
    SELECT COUNT(*) INTO v_pending_count
    FROM issued_license il
    JOIN application a ON il.application_id = a.application_id
    WHERE a.citizen_id = p_citizen_id
    AND a.permit_type_id = p_permit_type_id
    AND il.license_status = 'Active'
    AND il.expiration_date > SYSDATE;
    
    IF v_pending_count > 0 THEN
        RETURN 'NOT_ELIGIBLE: Already has an active "' || v_permit_name || '" license';
    END IF;
    
    RETURN 'ELIGIBLE';
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'NOT_ELIGIBLE: Citizen or Permit Type not found';
    WHEN OTHERS THEN RETURN 'ERROR: ' || SQLERRM;
END fn_validate_eligibility;
/

-- FUNCTION 5: Calculate IPEI
CREATE OR REPLACE FUNCTION fn_calculate_ipei (
    p_permit_type_id IN NUMBER
) RETURN NUMBER AS
    v_estimated_days NUMBER;
    v_actual_avg_days NUMBER;
    v_ipei NUMBER;
BEGIN
    SELECT estimated_days INTO v_estimated_days
    FROM permit_type WHERE permit_type_id = p_permit_type_id;
    
    SELECT AVG(TRUNC(last_updated - submission_date)) INTO v_actual_avg_days
    FROM application
    WHERE permit_type_id = p_permit_type_id
    AND status IN ('Approved', 'Rejected');
    
    IF v_actual_avg_days IS NULL OR v_actual_avg_days = 0 THEN RETURN NULL; END IF;
    
    v_ipei := ROUND((v_estimated_days / v_actual_avg_days) * 100, 2);
    RETURN v_ipei;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
    WHEN ZERO_DIVIDE THEN RETURN NULL;
    WHEN OTHERS THEN RETURN -1;
END fn_calculate_ipei;
/

-- FUNCTION 6: Get Application Status Summary
CREATE OR REPLACE FUNCTION fn_get_app_status_summary (
    p_application_id IN NUMBER
) RETURN VARCHAR2 AS
    v_app_number VARCHAR2(30);
    v_status VARCHAR2(30);
    v_payment_status VARCHAR2(20);
    v_submission_date DATE;
    v_completion_date DATE;
    v_days_elapsed NUMBER;
    v_summary VARCHAR2(500);
BEGIN
    SELECT application_number, status, payment_status,
           submission_date, last_updated, TRUNC(SYSDATE - submission_date)
    INTO v_app_number, v_status, v_payment_status,
         v_submission_date, v_completion_date, v_days_elapsed
    FROM application WHERE application_id = p_application_id;
    
    v_summary := 'Application: ' || v_app_number || CHR(10) ||
                 'Status: ' || v_status || CHR(10) ||
                 'Payment: ' || v_payment_status || CHR(10) ||
                 'Submitted: ' || TO_CHAR(v_submission_date, 'DD-MON-YYYY') || CHR(10) ||
                 'Days Elapsed: ' || v_days_elapsed;
    
    IF v_status IN ('Approved', 'Rejected', 'Cancelled') THEN
        v_summary := v_summary || CHR(10) || 'Completed: ' || TO_CHAR(v_completion_date, 'DD-MON-YYYY');
    END IF;
    
    RETURN v_summary;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'Application not found';
    WHEN OTHERS THEN RETURN 'Error retrieving summary: ' || SQLERRM;
END fn_get_app_status_summary;
/

-- FUNCTION 7: Count Pending Reviews
CREATE OR REPLACE FUNCTION fn_count_pending_reviews (
    p_department_id IN NUMBER
) RETURN NUMBER AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM review_step
    WHERE department_id = p_department_id
    AND step_status IN ('In Progress', 'Pending', 'Awaiting Review');
    RETURN v_count;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END fn_count_pending_reviews;
/

-- FUNCTION 8: Calculate License Renewal Fee
CREATE OR REPLACE FUNCTION fn_calculate_renewal_fee (
    p_license_id IN NUMBER
) RETURN NUMBER AS
    v_original_fee NUMBER;
    v_expiry_date DATE;
    v_license_status VARCHAR2(20);
    v_renewal_fee NUMBER;
    v_days_until_expiry NUMBER;
    v_discount NUMBER := 0;
BEGIN
    SELECT pt.processing_fee, l.expiration_date, l.license_status
    INTO v_original_fee, v_expiry_date, v_license_status
    FROM issued_license l
    JOIN application a ON l.application_id = a.application_id
    JOIN permit_type pt ON a.permit_type_id = pt.permit_type_id
    WHERE l.license_id = p_license_id;
    
    v_days_until_expiry := v_expiry_date - SYSDATE;
    v_renewal_fee := v_original_fee * 0.8;
    
    IF v_days_until_expiry > 30 THEN v_discount := 0.10; END IF;
    IF v_days_until_expiry < 0 THEN
        v_discount := -0.20;
        IF v_days_until_expiry < -90 THEN v_discount := -0.50; END IF;
    END IF;
    
    v_renewal_fee := v_renewal_fee * (1 - v_discount);
    IF v_renewal_fee < (v_original_fee * 0.5) THEN v_renewal_fee := v_original_fee * 0.5; END IF;
    
    RETURN ROUND(v_renewal_fee, 2);
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
    WHEN OTHERS THEN RETURN 0;
END fn_calculate_renewal_fee;
/

-- ADDITIONAL FUNCTION: Get Permit Details
CREATE OR REPLACE FUNCTION fn_get_permit_details (
    p_permit_type_id IN NUMBER
) RETURN VARCHAR2 AS
    v_permit_name VARCHAR2(100);
    v_processing_fee NUMBER;
    v_estimated_days NUMBER;
    v_is_active CHAR(1);
    v_details VARCHAR2(500);
BEGIN
    SELECT permit_name, processing_fee, estimated_days, is_active
    INTO v_permit_name, v_processing_fee, v_estimated_days, v_is_active
    FROM permit_type WHERE permit_type_id = p_permit_type_id;
    
    v_details := 'Permit: ' || v_permit_name || CHR(10) ||
                 'Fee: ' || TO_CHAR(v_processing_fee, 'FM999,999,990') || ' RWF' || CHR(10) ||
                 'Estimated Processing: ' || v_estimated_days || ' days' || CHR(10) ||
                 'Status: ' || CASE v_is_active WHEN 'Y' THEN 'Active' ELSE 'Inactive' END;
    RETURN v_details;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'Permit type not found';
    WHEN OTHERS THEN RETURN 'Error retrieving permit details';
END fn_get_permit_details;
/

-- ADDITIONAL FUNCTION: Calculate Citizen Age
CREATE OR REPLACE FUNCTION fn_calculate_citizen_age (
    p_citizen_id IN NUMBER
) RETURN NUMBER AS
    v_date_of_birth DATE;
    v_age NUMBER;
BEGIN
    SELECT date_of_birth INTO v_date_of_birth FROM citizen WHERE citizen_id = p_citizen_id;
    v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, v_date_of_birth) / 12);
    RETURN v_age;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
    WHEN OTHERS THEN RETURN -1;
END fn_calculate_citizen_age;
/
```

**OUTPUT**

![ALL FUNCTIONS CREATION](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_6/screenshots/functions_creation.png)

---
```SQL
-- ============================================================================
-- PACKAGE 1: Application Management Package
-- ============================================================================

-- Package Specification
CREATE OR REPLACE PACKAGE pkg_application_mgmt AS
    PROCEDURE submit_application (
        p_citizen_id        IN  NUMBER,
        p_permit_type_id    IN  NUMBER,
        p_priority_level    IN  VARCHAR2 DEFAULT 'Normal',
        p_notes             IN  VARCHAR2 DEFAULT NULL,
        p_application_id    OUT NUMBER
    );
    PROCEDURE update_status (
        p_application_id    IN NUMBER,
        p_new_status        IN VARCHAR2,
        p_comments          IN VARCHAR2 DEFAULT NULL,
        p_officer_id        IN NUMBER DEFAULT 1001
    );
    PROCEDURE cancel_application (
        p_application_id    IN NUMBER,
        p_reason            IN VARCHAR2
    );
    FUNCTION get_application_count (p_citizen_id IN NUMBER) RETURN NUMBER;
    FUNCTION get_pending_count (p_permit_type_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
    FUNCTION calculate_approval_rate (p_permit_type_id IN NUMBER) RETURN NUMBER;
END pkg_application_mgmt;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY pkg_application_mgmt AS
    PROCEDURE submit_application (
        p_citizen_id        IN  NUMBER,
        p_permit_type_id    IN  NUMBER,
        p_priority_level    IN  VARCHAR2 DEFAULT 'Normal',
        p_notes             IN  VARCHAR2 DEFAULT NULL,
        p_application_id    OUT NUMBER
    ) AS
        v_app_number VARCHAR2(30);
        v_fee NUMBER;
        v_days NUMBER;
        v_next_seq NUMBER;
    BEGIN
        SELECT seq_application_id.NEXTVAL INTO v_next_seq FROM DUAL;
        SELECT processing_fee, estimated_days INTO v_fee, v_days
        FROM permit_type WHERE permit_type_id = p_permit_type_id;
        
        v_app_number := 'APP-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || LPAD(v_next_seq, 6, '0');
        
        INSERT INTO application (
            application_id, citizen_id, permit_type_id, application_number,
            status, priority_level, payment_amount, payment_status,
            submission_date, last_updated, estimated_completion, notes
        ) VALUES (
            v_next_seq, p_citizen_id, p_permit_type_id, v_app_number,
            'Submitted', p_priority_level, v_fee, 'Pending',
            SYSDATE, SYSDATE, SYSDATE + v_days, p_notes
        ) RETURNING application_id INTO p_application_id;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Application submitted: ' || v_app_number);
    END submit_application;
    
    PROCEDURE update_status (
        p_application_id    IN NUMBER,
        p_new_status        IN VARCHAR2,
        p_comments          IN VARCHAR2 DEFAULT NULL,
        p_officer_id        IN NUMBER DEFAULT 1001
    ) AS
        v_old_status VARCHAR2(30);
    BEGIN
        SELECT status INTO v_old_status FROM application WHERE application_id = p_application_id;
        UPDATE application
        SET status = p_new_status,
            last_updated = SYSDATE,
            notes = COALESCE(notes, '') || CHR(10) || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') || 
                    ': Status changed from ' || v_old_status || ' to ' || p_new_status ||
                    CASE WHEN p_comments IS NOT NULL THEN '. Comments: ' || p_comments ELSE '' END
        WHERE application_id = p_application_id;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Status updated for application ' || p_application_id || 
                            ': ' || v_old_status || ' -> ' || p_new_status);
    END update_status;
    
    PROCEDURE cancel_application (
        p_application_id    IN NUMBER,
        p_reason            IN VARCHAR2
    ) AS
        v_app_number VARCHAR2(30);
    BEGIN
        SELECT application_number INTO v_app_number FROM application WHERE application_id = p_application_id;
        UPDATE application
        SET status = 'Cancelled',
            last_updated = SYSDATE,
            notes = COALESCE(notes, '') || CHR(10) || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') || 
                    ': Application cancelled. Reason: ' || p_reason
        WHERE application_id = p_application_id;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Application cancelled: ' || v_app_number);
    END cancel_application;
    
    FUNCTION get_application_count (p_citizen_id IN NUMBER) RETURN NUMBER AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM application WHERE citizen_id = p_citizen_id;
        RETURN v_count;
    END get_application_count;
    
    FUNCTION get_pending_count (p_permit_type_id IN NUMBER DEFAULT NULL) RETURN NUMBER AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM application
        WHERE status IN ('Submitted', 'Under Review', 'Documentation Required')
        AND (p_permit_type_id IS NULL OR permit_type_id = p_permit_type_id);
        
        RETURN v_count;
    END get_pending_count;
    
    FUNCTION calculate_approval_rate (p_permit_type_id IN NUMBER) RETURN NUMBER AS
        v_total NUMBER;
        v_approved NUMBER;
        v_rate NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total
        FROM application
        WHERE permit_type_id = p_permit_type_id
        AND status IN ('Approved', 'Rejected');
        
        IF v_total = 0 THEN RETURN 0; END IF;
        
        SELECT COUNT(*) INTO v_approved
        FROM application
        WHERE permit_type_id = p_permit_type_id
        AND status = 'Approved';
        
        v_rate := ROUND((v_approved / v_total) * 100, 2);
        RETURN v_rate;
    END calculate_approval_rate;
    
END pkg_application_mgmt;
/

-- ============================================================================
-- PACKAGE 2: Analytics Package
-- ============================================================================

-- Package Specification
CREATE OR REPLACE PACKAGE pkg_analytics AS
    TYPE t_revenue_rec IS RECORD (
        month VARCHAR2(7),
        total_revenue NUMBER,
        application_count NUMBER
    );
    TYPE t_revenue_table IS TABLE OF t_revenue_rec;
    
    FUNCTION get_monthly_revenue (p_year IN NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)) 
        RETURN t_revenue_table PIPELINED;
    FUNCTION get_department_performance (p_department_id IN NUMBER) RETURN NUMBER;
    FUNCTION get_top_permit_types (p_limit IN NUMBER DEFAULT 5) RETURN SYS_REFCURSOR;
END pkg_analytics;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY pkg_analytics AS
    FUNCTION get_monthly_revenue (p_year IN NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)) 
        RETURN t_revenue_table PIPELINED AS
        v_rec t_revenue_rec;
    BEGIN
        FOR rec IN (
            SELECT 
                TO_CHAR(submission_date, 'YYYY-MM') AS month,
                SUM(payment_amount) AS total_revenue,
                COUNT(*) AS application_count
            FROM application
            WHERE EXTRACT(YEAR FROM submission_date) = p_year
            AND payment_status = 'Paid'
            GROUP BY TO_CHAR(submission_date, 'YYYY-MM')
            ORDER BY month
        ) LOOP
            v_rec.month := rec.month;
            v_rec.total_revenue := rec.total_revenue;
            v_rec.application_count := rec.application_count;
            PIPE ROW(v_rec);
        END LOOP;
        RETURN;
    END get_monthly_revenue;
    
    FUNCTION get_department_performance (p_department_id IN NUMBER) RETURN NUMBER AS
        v_total_reviews NUMBER;
        v_completed NUMBER;
        v_avg_time NUMBER;
        v_score NUMBER;
    BEGIN
        SELECT 
            COUNT(*),
            SUM(CASE WHEN step_status = 'Completed' THEN 1 ELSE 0 END),
            AVG(CASE WHEN processing_time IS NOT NULL THEN processing_time ELSE 0 END)
        INTO v_total_reviews, v_completed, v_avg_time
        FROM review_step
        WHERE department_id = p_department_id;
        
        IF v_total_reviews = 0 THEN RETURN 0; END IF;
        
        v_score := ((v_completed / v_total_reviews) * 70) + 
                   (CASE 
                        WHEN v_avg_time = 0 THEN 30
                        WHEN v_avg_time < 1000 THEN 25
                        WHEN v_avg_time < 5000 THEN 20
                        WHEN v_avg_time < 10000 THEN 10
                        ELSE 5
                    END);
        
        RETURN ROUND(LEAST(v_score, 100), 2);
    END get_department_performance;
    
    FUNCTION get_top_permit_types (p_limit IN NUMBER DEFAULT 5) RETURN SYS_REFCURSOR AS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT 
                pt.permit_name,
                COUNT(a.application_id) AS application_count,
                SUM(CASE WHEN a.status = 'Approved' THEN 1 ELSE 0 END) AS approved_count,
                ROUND(AVG(a.payment_amount), 2) AS avg_fee,
                MIN(a.submission_date) AS first_application,
                MAX(a.submission_date) AS last_application
            FROM permit_type pt
            LEFT JOIN application a ON pt.permit_type_id = a.permit_type_id
            WHERE pt.is_active = 'Y'
            GROUP BY pt.permit_name
            ORDER BY application_count DESC NULLS LAST
            FETCH FIRST p_limit ROWS ONLY;
        
        RETURN v_cursor;
    END get_top_permit_types;
    
END pkg_analytics;
/
```

**OUTPUT**

![PACKAGES CREATION](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_6/screenshots/packages_creation.png)

---
```SQL
-- ============================================================================
-- TESTING FUNCTIONS
-- ============================================================================

PROMPT ============================================================================
PROMPT Testing Functions...
PROMPT ============================================================================

-- Test 4: Validate eligibility
DECLARE
    v_test_citizen_id NUMBER;
    v_test_permit_id NUMBER;
BEGIN
    SELECT MIN(citizen_id) INTO v_test_citizen_id FROM citizen;
    SELECT MIN(permit_type_id) INTO v_test_permit_id FROM permit_type;
    
    DBMS_OUTPUT.PUT_LINE('Test 4: Validate Eligibility');
    DBMS_OUTPUT.PUT_LINE('Citizen ID: ' || v_test_citizen_id);
    DBMS_OUTPUT.PUT_LINE('Permit Type ID: ' || v_test_permit_id);
    DBMS_OUTPUT.PUT_LINE('Result: ' || fn_validate_eligibility(v_test_citizen_id, v_test_permit_id));
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Test 5: Calculate IPEI
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 5: Calculate IPEI');
    FOR rec IN (SELECT permit_type_id, permit_name FROM permit_type WHERE ROWNUM <= 3) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('Permit: ' || rec.permit_name || ' | IPEI Score: ' || 
                            NVL(TO_CHAR(fn_calculate_ipei(rec.permit_type_id)), 'No data'));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Test 6: Get application summary
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 6: Application Summary');
    FOR rec IN (SELECT application_id, application_number FROM application WHERE ROWNUM <= 2) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('Application: ' || rec.application_number);
        DBMS_OUTPUT.PUT_LINE(fn_get_app_status_summary(rec.application_id));
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/

-- Test 7: Count pending reviews by department
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 7: Pending Reviews by Department');
    FOR rec IN (SELECT department_id, department_name FROM department WHERE is_active = 'Y' AND ROWNUM <= 3) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('Department: ' || rec.department_name || 
                            ' | Pending Reviews: ' || fn_count_pending_reviews(rec.department_id));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Test 8: Calculate renewal fee
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 8: License Renewal Fees');
    FOR rec IN (SELECT l.license_id, l.license_number, pt.permit_name
                FROM issued_license l
                JOIN application a ON l.application_id = a.application_id
                JOIN permit_type pt ON a.permit_type_id = pt.permit_type_id
                WHERE ROWNUM <= 2) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('License: ' || rec.license_number || ' (' || rec.permit_name || ')' ||
                            ' | Renewal Fee: ' || NVL(TO_CHAR(fn_calculate_renewal_fee(rec.license_id)), 'N/A'));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Test Additional Functions
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Additional Functions');
    
    -- Test Get Permit Details
    DECLARE
        v_permit_id NUMBER;
    BEGIN
        SELECT MIN(permit_type_id) INTO v_permit_id FROM permit_type;
        DBMS_OUTPUT.PUT_LINE('Permit Details:');
        DBMS_OUTPUT.PUT_LINE(fn_get_permit_details(v_permit_id));
        DBMS_OUTPUT.PUT_LINE('');
    END;
    
    -- Test Calculate Citizen Age
    DECLARE
        v_citizen_id NUMBER;
    BEGIN
        SELECT MIN(citizen_id) INTO v_citizen_id FROM citizen;
        DBMS_OUTPUT.PUT_LINE('Citizen Age: ' || fn_calculate_citizen_age(v_citizen_id) || ' years');
    END;
END;
/
```

**OUTPUT**

![ FUNCTION TESTING](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_6/screenshots/functions_testing.png)

---
```SQL
-- ============================================================================
-- TESTING PACKAGES
-- ============================================================================

PROMPT ============================================================================
PROMPT Testing Packages...
PROMPT ============================================================================

-- Test Application Management Package
DECLARE
    v_app_id NUMBER;
    v_count NUMBER;
    v_rate NUMBER;
    v_citizen_id NUMBER;
    v_permit_id NUMBER;
BEGIN
    -- Get test data
    SELECT MIN(citizen_id) INTO v_citizen_id FROM citizen WHERE status = 'Active';
    SELECT MIN(permit_type_id) INTO v_permit_id FROM permit_type WHERE is_active = 'Y';
    
    DBMS_OUTPUT.PUT_LINE('Testing Application Management Package');
    DBMS_OUTPUT.PUT_LINE('Citizen ID: ' || v_citizen_id || ', Permit Type ID: ' || v_permit_id);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    
    -- Test 1: Submit application
    pkg_application_mgmt.submit_application(
        p_citizen_id => v_citizen_id,
        p_permit_type_id => v_permit_id,
        p_priority_level => 'Normal',
        p_notes => 'Test from package',
        p_application_id => v_app_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ Application submitted. ID: ' || v_app_id);
    
    -- Test 2: Get application count
    v_count := pkg_application_mgmt.get_application_count(v_citizen_id);
    DBMS_OUTPUT.PUT_LINE('✓ Total applications for citizen: ' || v_count);
    
    -- Test 3: Get pending count
    v_count := pkg_application_mgmt.get_pending_count(v_permit_id);
    DBMS_OUTPUT.PUT_LINE('✓ Pending applications for permit type: ' || v_count);
    
    -- Test 4: Update status
    pkg_application_mgmt.update_status(
        p_application_id => v_app_id,
        p_new_status => 'Under Review',
        p_comments => 'Initial review started',
        p_officer_id => 1001
    );
    DBMS_OUTPUT.PUT_LINE('✓ Status updated to Under Review');
    
    -- Test 5: Approval rate
    v_rate := pkg_application_mgmt.calculate_approval_rate(v_permit_id);
    DBMS_OUTPUT.PUT_LINE('✓ Approval rate for permit type: ' || v_rate || '%');
    
    -- Test 6: Cancel application
    pkg_application_mgmt.cancel_application(
        p_application_id => v_app_id,
        p_reason => 'Testing package functionality'
    );
    DBMS_OUTPUT.PUT_LINE('✓ Application cancelled');
    
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('✅ Application Management Package tests completed.');
END;
/
```

**OUTPUT**

![PACKAGE TESTING](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_6/screenshots/package_testing.png)

---
```SQL
-- Test Analytics Package
PROMPT
PROMPT Testing Analytics Package:
PROMPT ------------------------------------------------------

-- Test 1: Monthly revenue
DECLARE
    v_year NUMBER := EXTRACT(YEAR FROM SYSDATE);
    v_counter NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('1. Monthly Revenue for ' || v_year || ':');
    FOR rec IN (SELECT * FROM TABLE(pkg_analytics.get_monthly_revenue(v_year))) 
    LOOP
        v_counter := v_counter + 1;
        IF v_counter <= 6 THEN
            DBMS_OUTPUT.PUT_LINE('   ' || rec.month || ': ' || 
                                TO_CHAR(rec.total_revenue, 'FM999,999,990') || 
                                ' RWF (' || rec.application_count || ' apps)');
        END IF;
    END LOOP;
    
    IF v_counter = 0 THEN
        DBMS_OUTPUT.PUT_LINE('   No revenue data available');
    END IF;
END;
/

-- Test 2: Department performance
BEGIN
    DBMS_OUTPUT.PUT_LINE('2. Department Performance Scores:');
    FOR rec IN (
        SELECT d.department_id, d.department_name,
               pkg_analytics.get_department_performance(d.department_id) AS score
        FROM department d
        WHERE d.is_active = 'Y'
        AND ROWNUM <= 5
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('   ' || rec.department_name || ': ' || rec.score || '/100');
    END LOOP;
END;
/
```

**OUTPUT**

![ANALYLITIC TESTING](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_6/screenshots/analytics_package_testing.png)

---
```SQL
-- ============================================================================
-- WINDOW FUNCTIONS EXAMPLES
-- ============================================================================

PROMPT ============================================================================
PROMPT Window Functions Examples
PROMPT ============================================================================

-- Example 1: ROW_NUMBER() - Rank applications by submission date per citizen
PROMPT 1. Application Ranking by Citizen (ROW_NUMBER):
SELECT 
    c.first_name || ' ' || c.last_name AS citizen_name,
    a.application_number,
    a.status,
    a.submission_date,
    ROW_NUMBER() OVER (PARTITION BY c.citizen_id ORDER BY a.submission_date DESC) AS recent_app_rank
FROM application a
JOIN citizen c ON a.citizen_id = c.citizen_id
WHERE c.status = 'Active'
AND ROWNUM <= 5
ORDER BY c.citizen_id, a.submission_date DESC;

-- Example 2: RANK() and DENSE_RANK() - Rank permits by application count
PROMPT 
PROMPT 2. Permit Types Ranked by Application Count:
SELECT 
    pt.permit_name,
    COUNT(a.application_id) AS total_applications,
    RANK() OVER (ORDER BY COUNT(a.application_id) DESC) AS rank_by_count,
    DENSE_RANK() OVER (ORDER BY COUNT(a.application_id) DESC) AS dense_rank_by_count
FROM permit_type pt
LEFT JOIN application a ON pt.permit_type_id = a.permit_type_id
WHERE pt.is_active = 'Y'
GROUP BY pt.permit_name
HAVING COUNT(a.application_id) > 0
ORDER BY total_applications DESC
FETCH FIRST 5 ROWS ONLY;

-- Example 3: LAG() and LEAD() - Compare processing time with adjacent applications
PROMPT 
PROMPT 3. Application Processing Time Trends:
SELECT 
    application_number,
    submission_date,
    last_updated,
    TRUNC(last_updated - submission_date) AS processing_days,
    LAG(TRUNC(last_updated - submission_date)) OVER (ORDER BY submission_date) AS prev_processing_days,
    LEAD(TRUNC(last_updated - submission_date)) OVER (ORDER BY submission_date) AS next_processing_days
FROM application
WHERE status IN ('Approved', 'Rejected')
AND ROWNUM <= 5
ORDER BY submission_date;

-- Example 4: PARTITION BY with aggregation - Department review analysis
PROMPT 
PROMPT 4. Department Review Analysis:
SELECT 
    d.department_name,
    rs.step_status,
    COUNT(*) AS status_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY d.department_name), 2) AS department_percentage
FROM review_step rs
JOIN department d ON rs.department_id = d.department_id
WHERE d.is_active = 'Y'
AND ROWNUM <= 10
GROUP BY d.department_name, rs.step_status
ORDER BY d.department_name, COUNT(*) DESC;

-- Example 5: Moving average - 3-month moving average of revenue
PROMPT 
PROMPT 5. 3-Month Moving Average of Monthly Revenue:
SELECT 
    month_year,
    monthly_revenue,
    ROUND(AVG(monthly_revenue) OVER (ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3months
FROM (
    SELECT 
        TO_CHAR(submission_date, 'YYYY-MM') AS month_year,
        SUM(payment_amount) AS monthly_revenue
    FROM application
    WHERE payment_status = 'Paid'
    AND submission_date >= ADD_MONTHS(SYSDATE, -6)
    GROUP BY TO_CHAR(submission_date, 'YYYY-MM')
)
ORDER BY month_year;
```

**OUTPUT**

![WINDOW FUNCTION TESTING](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_6/screenshots/window_functions_testing.png)

---
```SQL
PROMPT ============================================================================
PROMPT ✅ All Phase VI components created and tested successfully!
PROMPT ============================================================================
PROMPT 
PROMPT Summary:
PROMPT - 7 Stored Procedures created
PROMPT - 10 Functions created  
PROMPT - 2 Packages created
PROMPT - 5 Window Function examples demonstrated
PROMPT - All components successfully tested
PROMPT ============================================================================
```

**OUTPUT**

![SUCCESS MESSAGE](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_6/screenshots/success_message.png)

---

### **Optional Captures**
- 9️⃣ Error handling demonstrations
- 🔟 Final success message

---

## 🚀 Execution Guide

### **Prerequisites**

```sql
-- Connect to database
CONNECT gakuba/Kim@localhost:1521/thu_27670_kim_permit_db;
SET SERVEROUTPUT ON;
```

### **Execution Options**

**Option 1: Complete File**
```sql
@phase6_plsql_complete.sql
```

**Option 2: Section by Section**
```sql
-- 1. Procedures (Lines 1-300)
-- 2. Functions (Lines 300-600)
-- 3. Packages (Lines 600-800)
-- 4. Window Functions (Lines 800-900)
-- 5. Testing (Lines 900-end)
```

### **Verification Commands**

```sql
-- Check all objects
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY')
ORDER BY object_type, object_name;

-- Test function
SELECT fn_get_citizen_name(1000) FROM dual;

-- Test package
SELECT pkg_analytics.get_department_performance(10) FROM dual;
```

---

## 🔍 Troubleshooting

### **Common Issues & Solutions**

#### ⚠️ **Issue 1: Sequence Reference Error**
**Problem:** `CURRVAL` used before `NEXTVAL`  
**Solution:**
```sql
SELECT seq_name.NEXTVAL INTO variable FROM DUAL;
```

#### ⚠️ **Issue 2: Missing Columns**
**Problem:** Reference to non-existent columns  
**Solution:**
```sql
DESCRIBE table_name;
```

#### ⚠️ **Issue 3: Package Compilation Errors**
**Problem:** Specification/body mismatch  
**Solution:**
```sql
DROP PACKAGE package_name;
-- Then recreate
```

#### ⚠️ **Issue 4: Testing Data Issues**
**Problem:** Tests fail due to missing data  
**Solution:**
```sql
-- Use dynamic ID selection
SELECT MIN(citizen_id) INTO v_citizen_id FROM citizens;
```

---

## ⚡ Performance Considerations

### **Optimizations Implemented**

- 🔹 **Bulk Operations** - Reduced commit frequency
- 🔹 **Index Usage** - Optimized WHERE clauses
- 🔹 **Cursor Management** - Explicit closure
- 🔹 **Transaction Control** - Appropriate commit/rollback

### **Memory Management**
- Appropriately sized variables
- Proper cursor closure
- Exception-driven cleanup

---

## 🎯 Learning Outcomes

### **Technical Skills Demonstrated**

✅ Advanced PL/SQL programming  
✅ Package design patterns  
✅ Window function mastery  
✅ Error handling strategies  
✅ Testing methodologies  
✅ Performance optimization

### **Business Logic Implemented**

✅ Citizen registration system  
✅ Permit application workflow  
✅ Payment processing  
✅ Review/approval process  
✅ Analytics and reporting  
✅ Bulk administrative operations

---

## ✅ Submission Checklist

- [ ] All procedures created and tested
- [ ] All functions created and tested
- [ ] Packages created and tested
- [ ] Window functions demonstrated
- [ ] Screenshots captured at specified locations
- [ ] Error handling demonstrated
- [ ] Code properly commented
- [ ] README.md completed

---

<div align="center">

**🎓 Phase VI Complete**

*Enterprise-grade PL/SQL implementation for the Citizen Permit Management System*

---

**Version:** 1.0 | **Last Updated:** December 2025

</div>
