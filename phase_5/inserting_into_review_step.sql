-- ============================================================================
-- INSERT INTO REVIEW_STEP (Target: 400+ records, multiple steps per application)
-- ============================================================================

PROMPT Inserting REVIEW_STEP records...

-- Generate review steps for applications
DECLARE
  v_step_status VARCHAR2(30);
  v_decision VARCHAR2(30);
  v_completion DATE;
  v_processing_time NUMBER;
  v_dept_id NUMBER;
BEGIN
  -- For each of first 150 applications, create 2-4 review steps
  FOR app IN (SELECT application_id, submission_date, status 
              FROM application 
              WHERE application_id <= (SELECT MIN(application_id) + 149 FROM application)) 
  LOOP
    -- Step 1: Financial Review
    v_dept_id := 21; -- FSD
    v_step_status := CASE WHEN app.status IN ('Approved', 'Under Review', 'Documentation Required') 
                     THEN 'Completed' ELSE 'In Progress' END;
    v_decision := CASE WHEN app.status = 'Rejected' THEN 'Rejected' 
                       WHEN v_step_status = 'Completed' THEN 'Approved' 
                       ELSE NULL END;
    v_completion := CASE WHEN v_step_status = 'Completed' THEN app.submission_date + 2 ELSE NULL END;
    v_processing_time := CASE WHEN v_step_status = 'Completed' THEN 2880 ELSE NULL END; -- 2 days in minutes

    INSERT INTO review_step VALUES (
      seq_review_step_id.NEXTVAL, app.application_id, v_dept_id, 1,
      app.submission_date, v_step_status, 'Financial Officer ' || MOD(app.application_id, 5),
      'Payment verification completed', v_decision, v_completion, v_processing_time
    );

    -- Step 2: Document Verification
    IF app.status NOT IN ('Rejected', 'Cancelled') THEN
      v_dept_id := 10 + MOD(app.application_id, 10); -- Vary departments
      v_step_status := CASE WHEN app.status IN ('Approved') THEN 'Completed'
                            WHEN app.status = 'Under Review' THEN 'In Progress'
                            WHEN app.status = 'Documentation Required' THEN 'Blocked'
                            ELSE 'Pending' END;
      v_decision := CASE WHEN app.status = 'Approved' THEN 'Approved'
                         WHEN app.status = 'Documentation Required' THEN 'Revision Required'
                         ELSE NULL END;
      v_completion := CASE WHEN v_step_status = 'Completed' THEN app.submission_date + 7 ELSE NULL END;
      v_processing_time := CASE WHEN v_step_status = 'Completed' THEN 7200 ELSE NULL END;

      INSERT INTO review_step VALUES (
        seq_review_step_id.NEXTVAL, app.application_id, v_dept_id, 2,
        app.submission_date + 2, v_step_status, 'Review Officer ' || MOD(app.application_id, 8),
        'Document verification and technical review', v_decision, v_completion, v_processing_time
      );
    END IF;

    -- Step 3: Technical/Department Review (only for approved or in-review)
    IF app.status IN ('Approved', 'Under Review') THEN
      v_dept_id := 10 + MOD(app.application_id, 11);
      v_step_status := CASE WHEN app.status = 'Approved' THEN 'Completed' ELSE 'In Progress' END;
      v_decision := CASE WHEN app.status = 'Approved' THEN 'Approved' ELSE NULL END;
      v_completion := CASE WHEN v_step_status = 'Completed' THEN app.submission_date + 12 ELSE NULL END;
      v_processing_time := CASE WHEN v_step_status = 'Completed' THEN 7200 ELSE NULL END;

      INSERT INTO review_step VALUES (
        seq_review_step_id.NEXTVAL, app.application_id, v_dept_id, 3,
        app.submission_date + 7, v_step_status, 'Senior Officer ' || MOD(app.application_id, 6),
        'Technical compliance verification', v_decision, v_completion, v_processing_time
      );
    END IF;

    IF MOD(app.application_id, 50) = 0 THEN
      COMMIT;
    END IF;
  END LOOP;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('REVIEW_STEP records inserted successfully!');
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in main block: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/

-- ============================================================================
-- Add 20 more REVIEW_STEP records for specified departments
-- ============================================================================
PROMPT Adding 20 additional REVIEW_STEP records for specified departments...

DECLARE
  TYPE dept_rec IS RECORD (
    dept_id NUMBER,
    dept_code VARCHAR2(10),
    dept_name VARCHAR2(100),
    dept_head VARCHAR2(100)
  );
  
  TYPE dept_array IS TABLE OF dept_rec;
  
  v_depts dept_array;
  v_counter NUMBER := 0;
  v_step_status VARCHAR2(30);
  v_decision VARCHAR2(30);
  v_completion DATE;
  v_processing_time NUMBER;
  v_dept_id NUMBER;
  v_step_num NUMBER;
  v_start_date DATE;
  v_description VARCHAR2(200);
BEGIN
  -- Initialize department array
  v_depts := dept_array(
    dept_rec(22, 'DCI', 'Department of Citizenship and Immigration', 'Dr. Samuel Nzabonimana'),
    dept_rec(23, 'PIS', 'Passport and Identity Services', 'Angelique Mukamana'),
    dept_rec(24, 'BCA', 'Border Control Agency', 'Major Frank Habimana'),
    dept_rec(25, 'RAD', 'Refugee Affairs Department', 'Marie Uwimana'),
    dept_rec(26, 'MOI', 'Ministry of Interior', 'Minister of Interior')
  );

  -- Get some approved applications for additional review steps
  FOR app_rec IN (
    SELECT application_id, submission_date 
    FROM application 
    WHERE status = 'Approved' 
    ORDER BY application_id DESC 
    FETCH FIRST 20 ROWS ONLY
  ) LOOP
    v_counter := v_counter + 1;
    
    -- Cycle through the 5 departments (22-26)
    v_dept_id := v_depts(MOD(v_counter - 1, 5) + 1).dept_id;
    
    -- Determine step number (4 or 5 for these additional steps)
    v_step_num := CASE WHEN MOD(v_counter, 2) = 0 THEN 4 ELSE 5 END;
    
    -- Calculate start date (after previous steps)
    v_start_date := app_rec.submission_date + 15 + MOD(v_counter, 5);
    
    -- Determine status (Completed for most, In Progress for some)
    v_step_status := CASE WHEN MOD(v_counter, 3) = 0 THEN 'In Progress' ELSE 'Completed' END;
    
    -- Set decision and completion dates
    v_decision := CASE WHEN v_step_status = 'Completed' THEN 'Approved' ELSE NULL END;
    v_completion := CASE WHEN v_step_status = 'Completed' THEN v_start_date + 5 ELSE NULL END;
    v_processing_time := CASE WHEN v_step_status = 'Completed' THEN 3600 ELSE 1440 END; -- 2.5 days or 1 day
    
    -- Create review description based on department
    CASE v_dept_id
      WHEN 22 THEN -- DCI
        v_description := 'Citizenship verification and background check completed by ' || v_depts(1).dept_head;
      WHEN 23 THEN -- PIS
        v_description := 'Passport and identity document verification by ' || v_depts(2).dept_head;
      WHEN 24 THEN -- BCA
        v_description := 'Border security clearance and travel history review by ' || v_depts(3).dept_head;
      WHEN 25 THEN -- RAD
        v_description := 'Refugee status verification and humanitarian assessment by ' || v_depts(4).dept_head;
      WHEN 26 THEN -- MOI
        v_description := 'Final ministerial approval and documentation by ' || v_depts(5).dept_head;
    END CASE;
    
    -- Insert the additional review step
    INSERT INTO review_step VALUES (
      seq_review_step_id.NEXTVAL,
      app_rec.application_id,
      v_dept_id,
      v_step_num,
      v_start_date,
      v_step_status,
      v_depts(MOD(v_counter - 1, 5) + 1).dept_head,
      v_description,
      v_decision,
      v_completion,
      v_processing_time
    );
    
    -- Display progress
    IF MOD(v_counter, 5) = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Added ' || v_counter || ' additional review steps...');
      COMMIT;
    END IF;
  END LOOP;
  
  -- Final commit and summary
  COMMIT;
  
  -- Display summary
  DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== ADDITIONAL REVIEW STEPS SUMMARY ===');
  DBMS_OUTPUT.PUT_LINE('Total additional review steps added: ' || v_counter);
  
  FOR i IN 1..v_depts.COUNT LOOP
    DECLARE
      v_dept_count NUMBER;
    BEGIN
      SELECT COUNT(*) INTO v_dept_count
      FROM review_step
      WHERE department_id = v_depts(i).dept_id
        AND step_number >= 4; -- Only count our additional steps (steps 4+)
      
      DBMS_OUTPUT.PUT_LINE(v_depts(i).dept_code || ' (' || v_depts(i).dept_name || '): ' || 
                          v_dept_count || ' review steps');
    END;
  END LOOP;
  
  -- Overall count
  DECLARE
    v_total_review_steps NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_total_review_steps FROM review_step;
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Total REVIEW_STEP records in table: ' || v_total_review_steps);
  END;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error adding additional review steps: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/





SELECT COUNT(*) AS "Total Review Steps" FROM review_step;


-- Check all columns in review_step table
DESC review_step;




-- See all columns and sample data
SELECT * FROM review_step 
WHERE department_id BETWEEN 22 AND 26
AND ROWNUM <= 5;




-- Simple count to verify data exists
SELECT 
    department_id,
    COUNT(*) AS step_count
FROM review_step
WHERE department_id BETWEEN 22 AND 26
GROUP BY department_id
ORDER BY department_id;



-- See everything for departments 22-26
SELECT 
    r.*,
    a.application_number,
    a.status as app_status
FROM review_step r
JOIN application a ON r.application_id = a.application_id
WHERE r.department_id BETWEEN 22 AND 26
ORDER BY r.department_id, r.step_id;