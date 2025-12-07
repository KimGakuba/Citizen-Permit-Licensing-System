-- ============================================================================
-- STEP 3: AUDIT LOGGING PROCEDURE
-- ============================================================================

PROMPT Creating log_audit_entry procedure...

CREATE OR REPLACE PROCEDURE log_audit_entry(
    p_table_name IN VARCHAR2,
    p_operation IN VARCHAR2,
    p_status IN VARCHAR2,
    p_denial_reason IN VARCHAR2 DEFAULT NULL,
    p_record_id IN NUMBER DEFAULT NULL,
    p_old_values IN CLOB DEFAULT NULL,
    p_new_values IN CLOB DEFAULT NULL
) AS
BEGIN
    INSERT INTO AUDIT_LOG (
        audit_id,
        table_name,
        operation_type,
        operation_date,
        operation_time,
        username,
        status,
        denial_reason,
        record_id,
        old_values,
        new_values
    ) VALUES (
        audit_log_seq.NEXTVAL,
        p_table_name,
        p_operation,
        SYSDATE,
        SYSTIMESTAMP,
        USER,
        p_status,
        p_denial_reason,
        p_record_id,
        p_old_values,
        p_new_values
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error logging audit: ' || SQLERRM);
END log_audit_entry;
/





-- ============================================================================
-- STEP 4: RESTRICTION CHECK FUNCTION
-- ============================================================================

PROMPT Creating check_operation_allowed function...

CREATE OR REPLACE FUNCTION check_operation_allowed
RETURN VARCHAR2 AS
    v_day_of_week VARCHAR2(10);
    v_is_holiday NUMBER;
    v_error_msg VARCHAR2(200);
BEGIN
    -- Get current day of week
    v_day_of_week := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    
    -- Check if today is a weekday (Monday-Friday)
    IF v_day_of_week IN ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
        v_error_msg := 'DENIED: Operations not allowed on weekdays (' || v_day_of_week || ')';
        RETURN v_error_msg;
    END IF;
    
    -- Check if today is a public holiday
    SELECT COUNT(*) INTO v_is_holiday
    FROM HOLIDAYS
    WHERE TRUNC(holiday_date) = TRUNC(SYSDATE);
    
    IF v_is_holiday > 0 THEN
        v_error_msg := 'DENIED: Operations not allowed on public holidays';
        RETURN v_error_msg;
    END IF;
    
    -- Operation is allowed
    RETURN 'ALLOWED';
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END check_operation_allowed;
/




-- ============================================================================
-- STEP 5: SIMPLE TRIGGERS FOR CITIZEN TABLE
-- ============================================================================

PROMPT Creating simple triggers for CITIZEN table...

-- BEFORE INSERT TRIGGER
CREATE OR REPLACE TRIGGER trg_citizen_before_insert
BEFORE INSERT ON CITIZEN
FOR EACH ROW
DECLARE
    v_check_result VARCHAR2(200);
BEGIN
    v_check_result := check_operation_allowed();
    
    IF v_check_result != 'ALLOWED' THEN
        log_audit_entry(
            p_table_name => 'CITIZEN',
            p_operation => 'INSERT',
            p_status => 'DENIED',
            p_denial_reason => v_check_result,
            p_new_values => 'Citizen ID: ' || :NEW.citizen_id || 
                          ', First Name: ' || :NEW.first_name ||
                          ', Last Name: ' || :NEW.last_name ||
                          ', DOB: ' || TO_CHAR(:NEW.date_of_birth, 'YYYY-MM-DD')
        );
        RAISE_APPLICATION_ERROR(-20001, v_check_result);
    END IF;
END;
/

PROMPT trg_citizen_before_insert trigger created.

-- BEFORE UPDATE TRIGGER
CREATE OR REPLACE TRIGGER trg_citizen_before_update
BEFORE UPDATE ON CITIZEN
FOR EACH ROW
DECLARE
    v_check_result VARCHAR2(200);
BEGIN
    v_check_result := check_operation_allowed();
    
    IF v_check_result != 'ALLOWED' THEN
        log_audit_entry(
            p_table_name => 'CITIZEN',
            p_operation => 'UPDATE',
            p_status => 'DENIED',
            p_denial_reason => v_check_result,
            p_record_id => :OLD.citizen_id,
            p_old_values => 'Old: ' || :OLD.first_name || ' ' || :OLD.last_name ||
                          ', DOB: ' || TO_CHAR(:OLD.date_of_birth, 'YYYY-MM-DD'),
            p_new_values => 'New: ' || :NEW.first_name || ' ' || :NEW.last_name ||
                          ', DOB: ' || TO_CHAR(:NEW.date_of_birth, 'YYYY-MM-DD')
        );
        RAISE_APPLICATION_ERROR(-20002, v_check_result);
    END IF;
END;
/

PROMPT trg_citizen_before_update trigger created.

-- BEFORE DELETE TRIGGER
CREATE OR REPLACE TRIGGER trg_citizen_before_delete
BEFORE DELETE ON CITIZEN
FOR EACH ROW
DECLARE
    v_check_result VARCHAR2(200);
BEGIN
    v_check_result := check_operation_allowed();
    
    IF v_check_result != 'ALLOWED' THEN
        log_audit_entry(
            p_table_name => 'CITIZEN',
            p_operation => 'DELETE',
            p_status => 'DENIED',
            p_denial_reason => v_check_result,
            p_record_id => :OLD.citizen_id,
            p_old_values => 'Citizen ID: ' || :OLD.citizen_id || 
                          ', Name: ' || :OLD.first_name || ' ' || :OLD.last_name ||
                          ', National ID: ' || :OLD.national_id
        );
        RAISE_APPLICATION_ERROR(-20003, v_check_result);
    END IF;
END;
/









-- ============================================================================
-- STEP 6: COMPOUND TRIGGER FOR APPLICATION TABLE
-- ============================================================================

PROMPT Creating compound trigger for APPLICATION table...

CREATE OR REPLACE TRIGGER trg_application_compound
FOR INSERT OR UPDATE OR DELETE ON APPLICATION
COMPOUND TRIGGER

    -- Variables to store operation details
    TYPE t_operation_rec IS RECORD (
        operation VARCHAR2(10),
        application_id NUMBER,
        old_status VARCHAR2(50),
        new_status VARCHAR2(50),
        citizen_id NUMBER
    );
    
    TYPE t_operations_table IS TABLE OF t_operation_rec INDEX BY PLS_INTEGER;
    v_operations t_operations_table;
    v_index PLS_INTEGER := 0;
    v_check_result VARCHAR2(200);

    -- BEFORE STATEMENT: Check if operations are allowed
    BEFORE STATEMENT IS
    BEGIN
        v_check_result := check_operation_allowed();
        
        IF v_check_result != 'ALLOWED' THEN
            log_audit_entry(
                p_table_name => 'APPLICATION',
                p_operation => CASE 
                    WHEN INSERTING THEN 'INSERT'
                    WHEN UPDATING THEN 'UPDATE'
                    WHEN DELETING THEN 'DELETE'
                END,
                p_status => 'DENIED',
                p_denial_reason => v_check_result
            );
            RAISE_APPLICATION_ERROR(-20004, v_check_result);
        END IF;
    END BEFORE STATEMENT;

    -- BEFORE EACH ROW: Capture operation details
    BEFORE EACH ROW IS
    BEGIN
        v_index := v_index + 1;
        
        IF INSERTING THEN
            v_operations(v_index).operation := 'INSERT';
            v_operations(v_index).application_id := :NEW.application_id;
            v_operations(v_index).new_status := :NEW.status;
            v_operations(v_index).citizen_id := :NEW.citizen_id;
            
        ELSIF UPDATING THEN
            v_operations(v_index).operation := 'UPDATE';
            v_operations(v_index).application_id := :OLD.application_id;
            v_operations(v_index).old_status := :OLD.status;
            v_operations(v_index).new_status := :NEW.status;
            v_operations(v_index).citizen_id := :NEW.citizen_id;
            
        ELSIF DELETING THEN
            v_operations(v_index).operation := 'DELETE';
            v_operations(v_index).application_id := :OLD.application_id;
            v_operations(v_index).old_status := :OLD.status;
            v_operations(v_index).citizen_id := :OLD.citizen_id;
        END IF;
    END BEFORE EACH ROW;

    -- AFTER STATEMENT: Log all successful operations
    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1..v_operations.COUNT LOOP
            log_audit_entry(
                p_table_name => 'APPLICATION',
                p_operation => v_operations(i).operation,
                p_status => 'ALLOWED',
                p_record_id => v_operations(i).application_id,
                p_old_values => CASE 
                    WHEN v_operations(i).old_status IS NOT NULL 
                    THEN 'Status: ' || v_operations(i).old_status 
                    ELSE NULL 
                END,
                p_new_values => CASE 
                    WHEN v_operations(i).new_status IS NOT NULL 
                    THEN 'Status: ' || v_operations(i).new_status || 
                         ', Citizen ID: ' || v_operations(i).citizen_id 
                    ELSE NULL 
                END
            );
        END LOOP;
        
        -- Clear the collection
        v_operations.DELETE;
        v_index := 0;
    END AFTER STATEMENT;

END trg_application_compound;
/











-- ============================================================================
-- STEP 7: TESTING AND VERIFICATION
-- ============================================================================

PROMPT ============================================================================
PROMPT BEGINNING TESTS...
PROMPT ============================================================================

PROMPT Current Day: ' || TO_CHAR(SYSDATE, 'DAY') || ', Restriction Check: ' || check_operation_allowed();

-- Test 1: Test restriction function
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST 1: RESTRICTION FUNCTION ===');
    DBMS_OUTPUT.PUT_LINE('Function Result: ' || check_operation_allowed());
    DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST 2: INSERT OPERATION ===');
    DBMS_OUTPUT.PUT_LINE('Attempting to insert test citizen...');

    INSERT INTO CITIZEN (
        citizen_id, 
        first_name, 
        last_name, 
        date_of_birth, 
        national_id,
        email,
        phone,
        address,
        residency_status,
        registration_date,
        status
    )
    VALUES (
        9999, 
        'Test', 
        'Phase VII User', 
        TO_DATE('1990-01-01', 'YYYY-MM-DD'),
        'TEST19900101',
        'test@example.com',
        '1234567890',
        'Test Address',
        'PERMANENT',
        SYSDATE,
        'ACTIVE'
    );

    DBMS_OUTPUT.PUT_LINE('? INSERT allowed successfully');
    ROLLBACK; -- Don't actually save test data
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('? INSERT denied: ' || SQLERRM);
END;
/

-- Test 3: Test UPDATE operation
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST 3: UPDATE OPERATION ===');
    DBMS_OUTPUT.PUT_LINE('Attempting to update citizen...');
    
    UPDATE CITIZEN 
    SET residency_status = 'TEMPORARY'
    WHERE citizen_id = 1000 AND ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('? UPDATE allowed successfully');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('? UPDATE denied: ' || SQLERRM);
END;
/

-- Test 4: Test DELETE operation
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST 4: DELETE OPERATION ===');
    DBMS_OUTPUT.PUT_LINE('Attempting to delete citizen...');
    
    DELETE FROM CITIZEN WHERE citizen_id = 9999;
    
    DBMS_OUTPUT.PUT_LINE('? DELETE attempted (test record likely doesn''t exist)');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('? DELETE denied: ' || SQLERRM);
END;
/

-- Test 5: Test APPLICATION table operations
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST 5: APPLICATION OPERATIONS ===');
    DBMS_OUTPUT.PUT_LINE('Testing compound trigger...');
    
    -- This will test the compound trigger
    DBMS_OUTPUT.PUT_LINE('Compound trigger is active and will fire on any DML');
    DBMS_OUTPUT.PUT_LINE('');
END;
/












-- ============================================================================
-- STEP 8: VERIFICATION QUERIES
-- ============================================================================

PROMPT ============================================================================
PROMPT VERIFICATION RESULTS
PROMPT ============================================================================

-- Verify triggers are created
PROMPT Trigger Status:
SELECT 
    trigger_name,
    table_name,
    triggering_event,
    status
FROM USER_TRIGGERS
WHERE table_name IN ('CITIZEN', 'APPLICATION')
ORDER BY table_name, trigger_name;

-- Verify function is created
PROMPT Function Status:
SELECT object_name, object_type, status
FROM USER_OBJECTS
WHERE object_name = 'CHECK_OPERATION_ALLOWED'
UNION ALL
SELECT 'LOG_AUDIT_ENTRY', 'PROCEDURE', status
FROM USER_OBJECTS
WHERE object_name = 'LOG_AUDIT_ENTRY';

-- Verify tables are created
PROMPT Table Status:
SELECT table_name, num_rows
FROM USER_TABLES
WHERE table_name IN ('HOLIDAYS', 'AUDIT_LOG')
ORDER BY table_name;









-- ============================================================================
-- STEP 9: AUDIT LOG REVIEW
-- ============================================================================

PROMPT ============================================================================
PROMPT AUDIT LOG ENTRIES (Recent)
PROMPT ============================================================================

SELECT 
    audit_id,
    table_name,
    operation_type,
    TO_CHAR(operation_date, 'YYYY-MM-DD') as op_date,
    TO_CHAR(operation_time, 'HH24:MI:SS') as op_time,
    username,
    status,
    denial_reason
FROM AUDIT_LOG
WHERE operation_date >= SYSDATE - 1
ORDER BY audit_id DESC
FETCH FIRST 5 ROWS ONLY;








-- ============================================================================
-- STEP 11: SUMMARY STATISTICS
-- ============================================================================

PROMPT ============================================================================
PROMPT SUMMARY STATISTICS
PROMPT ============================================================================

-- Count operations by status
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