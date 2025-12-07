-- ============================================================================
-- PHASE VI: PL/SQL PROCEDURES
-- Student: NGABONZIZA Kim Gakuba (27670)
-- Project: Citizen Permit and Licensing System
-- Database: thu_27670_kim_permit_db
-- ============================================================================

CONNECT gakuba/Kim@localhost:1521/thu_27670_kim_permit_db;

SET SERVEROUTPUT ON;

-- ============================================================================
-- PROCEDURE 1: Register New Citizen
-- Purpose: Insert a new citizen with validation
-- Parameters: IN (citizen details), OUT (generated citizen_id)
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
    -- Validate age (must be 18 or older)
    v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, p_date_of_birth) / 12);
    
    IF v_age < 18 THEN
        RAISE e_invalid_age;
    END IF;
    
    -- Check for duplicate national ID
    SELECT COUNT(*) INTO v_exists
    FROM citizen
    WHERE national_id = p_national_id;
    
    IF v_exists > 0 THEN
        RAISE e_duplicate_id;
    END IF;
    
    -- Check for duplicate email
    SELECT COUNT(*) INTO v_exists
    FROM citizen
    WHERE email = p_email;
    
    IF v_exists > 0 THEN
        RAISE e_duplicate_email;
    END IF;
    
    -- Insert new citizen
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
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Citizen must be 18 years or older. Current age: ' || v_age);
    WHEN e_duplicate_id THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'National ID already exists: ' || p_national_id);
    WHEN e_duplicate_email THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Email already exists: ' || p_email);
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error registering citizen: ' || SQLERRM);
END sp_register_citizen;
/







-- ============================================================================
-- PROCEDURE 2: Submit New Application
-- Purpose: Create a new permit application with automatic numbering
-- Parameters: IN (citizen_id, permit_type_id, notes), OUT (application_id)
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
    -- Validate citizen exists
    SELECT COUNT(*) INTO v_citizen_exists
    FROM citizen
    WHERE citizen_id = p_citizen_id AND status = 'Active';
    
    IF v_citizen_exists = 0 THEN
        RAISE e_invalid_citizen;
    END IF;
    
    -- Validate permit type exists and is active
    SELECT COUNT(*) INTO v_permit_exists
    FROM permit_type
    WHERE permit_type_id = p_permit_type_id AND is_active = 'Y';
    
    IF v_permit_exists = 0 THEN
        RAISE e_invalid_permit;
    END IF;
    
    -- Get permit details
    SELECT processing_fee, estimated_days
    INTO v_processing_fee, v_estimated_days
    FROM permit_type
    WHERE permit_type_id = p_permit_type_id;
    
    -- Calculate estimated completion date
    v_completion_date := SYSDATE + v_estimated_days;
    
    -- Get the next sequence value first
    SELECT seq_application_id.NEXTVAL INTO v_next_seq_val FROM DUAL;
    
    -- Generate application number (format: APP-YYYY-NNNNNN)
    v_app_number := 'APP-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || 
                    LPAD(v_next_seq_val, 6, '0');
    
    -- Insert application
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
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, 'Invalid or inactive citizen ID: ' || p_citizen_id);
    WHEN e_invalid_permit THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20005, 'Invalid or inactive permit type ID: ' || p_permit_type_id);
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error submitting application: ' || SQLERRM);
END sp_submit_application;
/








-- ============================================================================
-- PROCEDURE 3: Update Application Status
-- Purpose: Update application status with validation and audit trail
-- Parameters: IN (application_id, new_status, comments, officer_id)
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_update_application_status (
    p_application_id    IN NUMBER,
    p_new_status        IN VARCHAR2,
    p_comments          IN VARCHAR2 DEFAULT NULL,
    p_officer_id        IN NUMBER DEFAULT 1001  -- Default officer
) AS
    v_current_status VARCHAR2(30);
    v_app_exists NUMBER;
    e_invalid_app EXCEPTION;
    e_invalid_status EXCEPTION;
BEGIN
    -- Validate application exists
    SELECT COUNT(*) INTO v_app_exists
    FROM application
    WHERE application_id = p_application_id;
    
    IF v_app_exists = 0 THEN
        RAISE e_invalid_app;
    END IF;
    
    -- Get current status
    SELECT status INTO v_current_status
    FROM application
    WHERE application_id = p_application_id;
    
    -- Validate status transition
    IF p_new_status NOT IN ('Submitted', 'Under Review', 'Documentation Required', 
                            'Approved', 'Rejected', 'Cancelled', 'On Hold') THEN
        RAISE e_invalid_status;
    END IF;
    
    -- Update application
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
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20006, 'Application not found: ' || p_application_id);
    WHEN e_invalid_status THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20007, 'Invalid status: ' || p_new_status);
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error updating application status: ' || SQLERRM);
END sp_update_application_status;
/








-- ============================================================================
-- PROCEDURE 4: Process Payment
-- Purpose: Record payment for an application
-- Parameters: IN (application_id, payment_amount, payment_method)
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
    -- Validate application exists
    SELECT COUNT(*) INTO v_app_exists
    FROM application
    WHERE application_id = p_application_id;
    
    IF v_app_exists = 0 THEN
        RAISE e_invalid_app;
    END IF;
    
    -- Get required fee and current payment status
    SELECT a.payment_amount, a.payment_status
    INTO v_required_fee, v_current_status
    FROM application a
    WHERE a.application_id = p_application_id;
    
    -- Check if already paid
    IF v_current_status = 'Paid' THEN
        RAISE e_already_paid;
    END IF;
    
    -- Validate payment amount
    IF p_payment_amount < v_required_fee THEN
        RAISE e_invalid_amount;
    END IF;
    
    -- Calculate change
    v_change := p_payment_amount - v_required_fee;
    
    -- Update application payment status
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
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20008, 'Application not found: ' || p_application_id);
    WHEN e_invalid_amount THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20009, 'Insufficient payment. Required: ' || v_required_fee || ', Received: ' || p_payment_amount);
    WHEN e_already_paid THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20010, 'Application already paid');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error processing payment: ' || SQLERRM);
END sp_process_payment;
/









-- ============================================================================
-- PROCEDURE 5: Add Review Step
-- Purpose: Create a new review step for an application
-- Parameters: IN (application_id, department_id, reviewer_name, comments)
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
    -- Validate application exists
    SELECT COUNT(*) INTO v_app_exists
    FROM application
    WHERE application_id = p_application_id;
    
    IF v_app_exists = 0 THEN
        RAISE e_invalid_app;
    END IF;
    
    -- Validate department exists
    SELECT COUNT(*) INTO v_dept_exists
    FROM department
    WHERE department_id = p_department_id AND is_active = 'Y';
    
    IF v_dept_exists = 0 THEN
        RAISE e_invalid_dept;
    END IF;
    
    -- Get next step number
    SELECT NVL(MAX(step_number), 0) + 1
    INTO v_step_number
    FROM review_step
    WHERE application_id = p_application_id;
    
    -- Insert review step
    INSERT INTO review_step (
        step_id, application_id, department_id, step_number,
        review_date, step_status, reviewer_name, comments
    ) VALUES (
        seq_review_step_id.NEXTVAL, p_application_id, p_department_id, v_step_number,
        SYSDATE, 'In Progress', p_reviewer_name, p_comments
    );
    
    -- Update application status to 'Under Review' only if not already
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
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'Application not found: ' || p_application_id);
    WHEN e_invalid_dept THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20012, 'Invalid or inactive department: ' || p_department_id);
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error adding review step: ' || SQLERRM);
END sp_add_review_step;
/








-- ============================================================================
-- PROCEDURE 6: Complete Review Step
-- Purpose: Mark a review step as completed with decision
-- Parameters: IN (step_id, decision, comments)
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_complete_review_step (
    p_step_id       IN NUMBER,
    p_decision      IN VARCHAR2,
    p_comments      IN VARCHAR2 DEFAULT NULL
) AS
    v_step_exists NUMBER;
    v_review_date DATE;
    v_processing_time NUMBER;
    v_application_id NUMBER;
    e_invalid_step EXCEPTION;
    e_invalid_decision EXCEPTION;
BEGIN
    -- Validate step exists and get review date
    SELECT COUNT(*), MAX(review_date)
    INTO v_step_exists, v_review_date
    FROM review_step
    WHERE step_id = p_step_id;
    
    IF v_step_exists = 0 THEN
        RAISE e_invalid_step;
    END IF;
    
    -- Validate decision
    IF p_decision NOT IN ('Approved', 'Rejected', 'Revision Required') THEN
        RAISE e_invalid_decision;
    END IF;
    
    -- Calculate processing time in minutes
    v_processing_time := ROUND((SYSDATE - v_review_date) * 24 * 60);
    
    -- Update review step
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
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20013, 'Review step not found: ' || p_step_id);
    WHEN e_invalid_decision THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20014, 'Invalid decision: ' || p_decision || '. Must be: Approved, Rejected, or Revision Required');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error completing review step: ' || SQLERRM);
END sp_complete_review_step;
/


















-- ============================================================================
-- PROCEDURE 7: Bulk Update Status (with cursor)
-- Purpose: Update status for multiple applications matching criteria
-- Parameters: IN (old_status, new_status), OUT (count_updated)
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
    
    -- Validate status values
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
        IF c_applications%ISOPEN THEN
            CLOSE c_applications;
        END IF;
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error in bulk update: ' || SQLERRM);
END sp_bulk_update_status;
/








-- Test 1: Register new citizen
DECLARE
    v_citizen_id NUMBER;
    v_timestamp VARCHAR2(30);
BEGIN
    -- Generate unique values using timestamp
    v_timestamp := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    
    sp_register_citizen(
        p_first_name => 'Test_' || v_timestamp,
        p_last_name => 'Procedure',
        p_date_of_birth => DATE '1990-01-01',
        p_national_id => 'NID' || v_timestamp,
        p_email => 'test.procedure.' || v_timestamp || '@test.com',
        p_phone => '+25078' || SUBSTR(v_timestamp, -6),
        p_address => 'Test Address, Kigali',
        p_residency_status => 'Citizen',
        p_citizen_id => v_citizen_id
    );
    DBMS_OUTPUT.PUT_LINE('Test 1 PASSED: Citizen ID = ' || v_citizen_id);
END;
/








-- Test 2: Submit application using the last created citizen
DECLARE
    v_app_id NUMBER;
    v_citizen_id NUMBER;
BEGIN
    -- Get the last citizen ID created
    SELECT MAX(citizen_id) INTO v_citizen_id FROM citizen 
    WHERE first_name LIKE 'Test_%' AND last_name = 'Procedure';
    
    sp_submit_application(
        p_citizen_id => v_citizen_id,
        p_permit_type_id => 100,
        p_priority_level => 'Normal',
        p_notes => 'Test application from procedure',
        p_application_id => v_app_id
    );
    DBMS_OUTPUT.PUT_LINE('Test 2 PASSED: Application ID = ' || v_app_id);
END;
/














-- Test 3: Update application status
DECLARE
    v_app_id NUMBER;
BEGIN
    -- Get the last application ID from our test citizen
    SELECT MAX(a.application_id)
    INTO v_app_id
    FROM application a
    WHERE a.citizen_id = (
        SELECT MAX(citizen_id) FROM citizen 
        WHERE first_name LIKE 'Test_%' AND last_name = 'Procedure'
    );
    
    sp_update_application_status(
        p_application_id => v_app_id,
        p_new_status => 'Under Review',
        p_comments => 'Testing status update procedure',
        p_officer_id => 1001
    );
    DBMS_OUTPUT.PUT_LINE('Test 3 PASSED: Application status updated for ID: ' || v_app_id);
END;
/











-- Test 4: Process payment
DECLARE
    v_app_id NUMBER;
BEGIN
    -- Get the application ID from our test
    SELECT MAX(a.application_id)
    INTO v_app_id
    FROM application a
    WHERE a.citizen_id = (
        SELECT MAX(citizen_id) FROM citizen 
        WHERE first_name LIKE 'Test_%' AND last_name = 'Procedure'
    );
    
    -- Check current payment status
    DECLARE
        v_payment_status VARCHAR2(20);
    BEGIN
        SELECT payment_status INTO v_payment_status
        FROM application
        WHERE application_id = v_app_id;
        
        DBMS_OUTPUT.PUT_LINE('Current payment status for app ' || v_app_id || ': ' || v_payment_status);
        
        IF v_payment_status != 'Paid' THEN
            sp_process_payment(
                p_application_id => v_app_id,
                p_payment_amount => 50000,
                p_payment_method => 'Bank Transfer'
            );
            DBMS_OUTPUT.PUT_LINE('Test 4 PASSED: Payment processed for Application ID: ' || v_app_id);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Test 4 SKIPPED: Application already paid');
        END IF;
    END;
END;
/










-- Test 4 Alternative: Always test payment with fresh application
DECLARE
    v_app_id NUMBER;
    v_citizen_id NUMBER;
    v_timestamp VARCHAR2(30);
BEGIN
    -- Create a fresh citizen for payment test
    v_timestamp := TO_CHAR(SYSDATE, 'HH24MISS');
    
    sp_register_citizen(
        p_first_name => 'Payment_' || v_timestamp,
        p_last_name => 'Test',
        p_date_of_birth => DATE '1992-01-01',
        p_national_id => 'PAY' || v_timestamp,
        p_email => 'payment.test' || v_timestamp || '@test.com',
        p_phone => '+25078' || SUBSTR(v_timestamp, -5),
        p_address => 'Payment Test Street',
        p_residency_status => 'Citizen',
        p_citizen_id => v_citizen_id
    );
    
    -- Submit application with this citizen
    sp_submit_application(
        p_citizen_id => v_citizen_id,
        p_permit_type_id => 100,
        p_priority_level => 'Normal',
        p_notes => 'Test application for payment procedure',
        p_application_id => v_app_id
    );
    
    -- Process payment
    sp_process_payment(
        p_application_id => v_app_id,
        p_payment_amount => 50000,
        p_payment_method => 'Credit Card'
    );
    
    DBMS_OUTPUT.PUT_LINE('Test 4 PASSED: Payment processed for Application ID: ' || v_app_id);
END;
/






-- Test 5: Add review step
DECLARE
    v_app_id NUMBER;
BEGIN
    -- Get the application ID from our test citizen
    SELECT MAX(a.application_id)
    INTO v_app_id
    FROM application a
    WHERE a.citizen_id = (
        SELECT MAX(citizen_id) FROM citizen 
        WHERE first_name LIKE 'Test_%' AND last_name = 'Procedure'
    );
    
    sp_add_review_step(
        p_application_id => v_app_id,
        p_department_id => 10,
        p_reviewer_name => 'John Reviewer',
        p_comments => 'Initial review step'
    );
    DBMS_OUTPUT.PUT_LINE('Test 5 PASSED: Review step added for Application ID: ' || v_app_id);
END;
/





-- Test 6: Bulk update
DECLARE
    v_count_updated NUMBER;
    v_test_app_id NUMBER;
BEGIN
    -- Get our test application
    SELECT MAX(a.application_id)
    INTO v_test_app_id
    FROM application a
    WHERE a.citizen_id = (
        SELECT MAX(citizen_id) FROM citizen 
        WHERE first_name LIKE 'Test_%' AND last_name = 'Procedure'
    );
    
    -- Update our test application to 'Submitted' status with old date
    UPDATE application 
    SET status = 'Submitted', 
        last_updated = SYSDATE - 2,
        notes = COALESCE(notes, '') || CHR(10) || 'Updated for bulk test'
    WHERE application_id = v_test_app_id;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Test 6: Setting up application ' || v_test_app_id || ' for bulk update test');
    
    -- Now run the bulk update
    sp_bulk_update_status(
        p_old_status => 'Submitted',
        p_new_status => 'On Hold',
        p_days_in_status => 1,
        p_count_updated => v_count_updated
    );
    
    DBMS_OUTPUT.PUT_LINE('Test 6 PASSED: Bulk update executed. Records updated: ' || v_count_updated);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Test 6 SKIPPED: No test application found for bulk update');
END;
/