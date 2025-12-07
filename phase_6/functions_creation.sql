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