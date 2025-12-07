-- ============================================================================
-- FUNCTION 4: Validate Application Eligibility (CORRECTED)
-- Purpose: Check if citizen is eligible to apply for permit type
-- Return: VARCHAR2 ('ELIGIBLE', 'NOT_ELIGIBLE', reason)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_validate_eligibility (
    p_citizen_id        IN NUMBER,
    p_permit_type_id    IN NUMBER
) RETURN VARCHAR2
AS
    v_citizen_status VARCHAR2(20);
    v_residency VARCHAR2(30);
    v_permit_active CHAR(1);
    v_pending_count NUMBER;
    v_age NUMBER;
    v_date_of_birth DATE;
    v_permit_name VARCHAR2(100);
    v_estimated_days NUMBER;
BEGIN
    -- Check citizen status and details
    SELECT status, residency_status, date_of_birth
    INTO v_citizen_status, v_residency, v_date_of_birth
    FROM citizen
    WHERE citizen_id = p_citizen_id;
    
    IF v_citizen_status != 'Active' THEN
        RETURN 'NOT_ELIGIBLE: Citizen status is ' || v_citizen_status;
    END IF;
    
    -- Calculate age
    v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, v_date_of_birth) / 12);
    
    -- Check permit type details - using columns that exist
    -- Let me assume your permit_type table has: permit_type_id, permit_name, is_active, estimated_days
    SELECT is_active, permit_name, estimated_days
    INTO v_permit_active, v_permit_name, v_estimated_days
    FROM permit_type
    WHERE permit_type_id = p_permit_type_id;
    
    IF v_permit_active != 'Y' THEN
        RETURN 'NOT_ELIGIBLE: Permit type "' || v_permit_name || '" is inactive';
    END IF;
    
    -- Basic eligibility checks
    -- 1. Age requirement (18+ for most permits)
    IF v_age < 18 THEN
        RETURN 'NOT_ELIGIBLE: Minimum age requirement is 18. Current age: ' || v_age;
    END IF;
    
    -- 2. Residency check for certain permit types based on name
    -- Example: Business permits might require specific residency
    IF UPPER(v_permit_name) LIKE '%BUSINESS%' 
       AND v_residency NOT IN ('Citizen', 'Permanent Resident') THEN
        RETURN 'NOT_ELIGIBLE: ' || v_permit_name || 
               ' requires Citizen or Permanent Resident status. Current: ' || v_residency;
    END IF;
    
    -- 3. Check for pending applications
    SELECT COUNT(*)
    INTO v_pending_count
    FROM application
    WHERE citizen_id = p_citizen_id
    AND permit_type_id = p_permit_type_id
    AND status IN ('Submitted', 'Under Review', 'Documentation Required');
    
    IF v_pending_count > 0 THEN
        RETURN 'NOT_ELIGIBLE: Has ' || v_pending_count || 
               ' pending application(s) for "' || v_permit_name || '"';
    END IF;
    
    -- 4. Check for existing valid license of same type
    SELECT COUNT(*)
    INTO v_pending_count
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
    WHEN NO_DATA_FOUND THEN
        RETURN 'NOT_ELIGIBLE: Citizen or Permit Type not found';
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END fn_validate_eligibility;
/

-- ============================================================================
-- FUNCTION 5: Calculate IPEI (Intelligent Permit Efficiency Index)
-- Purpose: Calculate efficiency index for a permit type
-- Formula: IPEI = (Estimated Days / Actual Average Days) × 100
-- Return: NUMBER (efficiency percentage)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_calculate_ipei (
    p_permit_type_id IN NUMBER
) RETURN NUMBER
AS
    v_estimated_days NUMBER;
    v_actual_avg_days NUMBER;
    v_ipei NUMBER;
BEGIN
    -- Get estimated processing days
    SELECT estimated_days
    INTO v_estimated_days
    FROM permit_type
    WHERE permit_type_id = p_permit_type_id;
    
    -- Calculate actual average processing days for completed applications
    SELECT AVG(TRUNC(last_updated - submission_date))
    INTO v_actual_avg_days
    FROM application
    WHERE permit_type_id = p_permit_type_id
    AND status IN ('Approved', 'Rejected');
    
    -- Calculate IPEI (lower is better - means faster than estimated)
    IF v_actual_avg_days IS NULL OR v_actual_avg_days = 0 THEN
        RETURN NULL;
    END IF;
    
    v_ipei := ROUND((v_estimated_days / v_actual_avg_days) * 100, 2);
    
    RETURN v_ipei;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN ZERO_DIVIDE THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN -1;
END fn_calculate_ipei;
/

-- ============================================================================
-- FUNCTION 6: Get Application Status Summary
-- Purpose: Return formatted status summary for an application
-- Return: VARCHAR2 (formatted summary)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_get_app_status_summary (
    p_application_id IN NUMBER
) RETURN VARCHAR2
AS
    v_app_number VARCHAR2(30);
    v_status VARCHAR2(30);
    v_payment_status VARCHAR2(20);
    v_submission_date DATE;
    v_completion_date DATE;
    v_days_elapsed NUMBER;
    v_summary VARCHAR2(500);
BEGIN
    SELECT 
        application_number,
        status,
        payment_status,
        submission_date,
        last_updated,
        TRUNC(SYSDATE - submission_date)
    INTO 
        v_app_number,
        v_status,
        v_payment_status,
        v_submission_date,
        v_completion_date,
        v_days_elapsed
    FROM application
    WHERE application_id = p_application_id;
    
    v_summary := 'Application: ' || v_app_number || CHR(10) ||
                 'Status: ' || v_status || CHR(10) ||
                 'Payment: ' || v_payment_status || CHR(10) ||
                 'Submitted: ' || TO_CHAR(v_submission_date, 'DD-MON-YYYY') || CHR(10) ||
                 'Days Elapsed: ' || v_days_elapsed;
    
    IF v_status IN ('Approved', 'Rejected', 'Cancelled') THEN
        v_summary := v_summary || CHR(10) ||
                    'Completed: ' || TO_CHAR(v_completion_date, 'DD-MON-YYYY');
    END IF;
    
    RETURN v_summary;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Application not found';
    WHEN OTHERS THEN
        RETURN 'Error retrieving summary: ' || SQLERRM;
END fn_get_app_status_summary;
/

-- ============================================================================
-- FUNCTION 7: Count Pending Reviews by Department
-- Purpose: Count pending review steps for a department
-- Return: NUMBER
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_count_pending_reviews (
    p_department_id IN NUMBER
) RETURN NUMBER
AS
    v_count NUMBER;
BEGIN
    -- Count steps that are in progress or pending
    SELECT COUNT(*)
    INTO v_count
    FROM review_step
    WHERE department_id = p_department_id
    AND step_status IN ('In Progress', 'Pending', 'Awaiting Review');
    
    RETURN v_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_count_pending_reviews;
/

-- ============================================================================
-- FUNCTION 8: Calculate License Renewal Fee
-- Purpose: Calculate renewal fee with discount based on license status
-- Return: NUMBER (renewal fee amount)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_calculate_renewal_fee (
    p_license_id IN NUMBER
) RETURN NUMBER
AS
    v_original_fee NUMBER;
    v_expiry_date DATE;
    v_license_status VARCHAR2(20);
    v_renewal_fee NUMBER;
    v_days_until_expiry NUMBER;
    v_discount NUMBER := 0;
BEGIN
    -- Get license details
    SELECT 
        pt.processing_fee,
        l.expiration_date,
        l.license_status
    INTO 
        v_original_fee,
        v_expiry_date,
        v_license_status
    FROM issued_license l
    JOIN application a ON l.application_id = a.application_id
    JOIN permit_type pt ON a.permit_type_id = pt.permit_type_id
    WHERE l.license_id = p_license_id;
    
    -- Calculate days until expiry
    v_days_until_expiry := v_expiry_date - SYSDATE;
    
    -- Calculate base renewal fee (80% of original)
    v_renewal_fee := v_original_fee * 0.8;
    
    -- Apply early renewal discount (if renewing 30+ days before expiry)
    IF v_days_until_expiry > 30 THEN
        v_discount := 0.10; -- 10% discount for early renewal
    END IF;
    
    -- Apply penalty for expired licenses
    IF v_days_until_expiry < 0 THEN
        v_discount := -0.20; -- 20% penalty for late renewal
        
        -- Additional penalty for long expired (> 90 days)
        IF v_days_until_expiry < -90 THEN
            v_discount := -0.50; -- 50% penalty for very late renewal
        END IF;
    END IF;
    
    v_renewal_fee := v_renewal_fee * (1 - v_discount);
    
    -- Ensure minimum fee (at least 50% of original)
    IF v_renewal_fee < (v_original_fee * 0.5) THEN
        v_renewal_fee := v_original_fee * 0.5;
    END IF;
    
    RETURN ROUND(v_renewal_fee, 2);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN 0;
END fn_calculate_renewal_fee;
/

-- ============================================================================
-- ADDITIONAL FUNCTION: Get Permit Type Details
-- Purpose: Get formatted information about a permit type
-- Return: VARCHAR2
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_get_permit_details (
    p_permit_type_id IN NUMBER
) RETURN VARCHAR2
AS
    v_permit_name VARCHAR2(100);
    v_processing_fee NUMBER;
    v_estimated_days NUMBER;
    v_is_active CHAR(1);
    v_details VARCHAR2(500);
BEGIN
    SELECT permit_name, processing_fee, estimated_days, is_active
    INTO v_permit_name, v_processing_fee, v_estimated_days, v_is_active
    FROM permit_type
    WHERE permit_type_id = p_permit_type_id;
    
    v_details := 'Permit: ' || v_permit_name || CHR(10) ||
                 'Fee: ' || TO_CHAR(v_processing_fee, 'FM999,999,990') || ' RWF' || CHR(10) ||
                 'Estimated Processing: ' || v_estimated_days || ' days' || CHR(10) ||
                 'Status: ' || CASE v_is_active 
                                 WHEN 'Y' THEN 'Active' 
                                 ELSE 'Inactive' 
                               END;
    
    RETURN v_details;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Permit type not found';
    WHEN OTHERS THEN
        RETURN 'Error retrieving permit details';
END fn_get_permit_details;
/

-- ============================================================================
-- ADDITIONAL FUNCTION: Calculate Citizen Age
-- Purpose: Calculate exact age of a citizen
-- Return: NUMBER (age in years)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_calculate_citizen_age (
    p_citizen_id IN NUMBER
) RETURN NUMBER
AS
    v_date_of_birth DATE;
    v_age NUMBER;
BEGIN
    SELECT date_of_birth
    INTO v_date_of_birth
    FROM citizen
    WHERE citizen_id = p_citizen_id;
    
    v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, v_date_of_birth) / 12);
    
    RETURN v_age;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN -1;
END fn_calculate_citizen_age;
/

-- ============================================================================
-- VERIFICATION: Test all functions
-- ============================================================================

PROMPT ============================================================================
PROMPT Testing Functions...
PROMPT ============================================================================

-- Test 4: Validate eligibility - test with various citizens
DECLARE
    v_test_citizen_id NUMBER;
    v_test_permit_id NUMBER;
BEGIN
    -- Get a test citizen and permit
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
    FOR rec IN (SELECT permit_type_id, permit_name 
                FROM permit_type 
                WHERE ROWNUM <= 3) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('Permit: ' || rec.permit_name || 
                            ' | IPEI Score: ' || 
                            NVL(TO_CHAR(fn_calculate_ipei(rec.permit_type_id)), 'No data'));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Test 6: Get application summary
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 6: Application Summary');
    FOR rec IN (SELECT application_id, application_number 
                FROM application 
                WHERE ROWNUM <= 2) 
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
    FOR rec IN (SELECT department_id, department_name 
                FROM department 
                WHERE is_active = 'Y' 
                AND ROWNUM <= 3) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('Department: ' || rec.department_name || 
                            ' | Pending Reviews: ' || 
                            fn_count_pending_reviews(rec.department_id));
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
        DBMS_OUTPUT.PUT_LINE('License: ' || rec.license_number || 
                            ' (' || rec.permit_name || ')' ||
                            ' | Renewal Fee: ' || 
                            NVL(TO_CHAR(fn_calculate_renewal_fee(rec.license_id)), 'N/A'));
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
        DBMS_OUTPUT.PUT_LINE('Citizen Age: ' || 
                            fn_calculate_citizen_age(v_citizen_id) || ' years');
    END;
END;
/

PROMPT ============================================================================
PROMPT All functions created and tested successfully!
PROMPT ============================================================================