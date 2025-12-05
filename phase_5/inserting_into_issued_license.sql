-- ============================================================================
-- INSERT INTO ISSUED_LICENSE (For approved applications only)
-- ============================================================================

PROMPT Inserting ISSUED_LICENSE records...

-- Insert licenses for approved applications
DECLARE
  v_validity NUMBER;
  v_license_num VARCHAR2(50);
  v_issue_date DATE;
  v_expiry_date DATE;
  v_license_count NUMBER := 0;
  v_approval_count NUMBER;
BEGIN
  -- Check how many approved applications exist
  SELECT COUNT(*) INTO v_approval_count 
  FROM application 
  WHERE status = 'Approved';
  
  DBMS_OUTPUT.PUT_LINE('Found ' || v_approval_count || ' approved applications');
  
  FOR app IN (SELECT a.application_id, a.submission_date, p.validity_period, p.permit_name
              FROM application a
              JOIN permit_type p ON a.permit_type_id = p.permit_type_id
              WHERE a.status = 'Approved')
  LOOP
    v_validity := app.validity_period;
    v_issue_date := app.submission_date + 15; -- Issued 15 days after submission
    v_expiry_date := v_issue_date + v_validity;
    v_license_num := 'LIC-' || TO_CHAR(app.application_id, 'FM000000') || '-' || TO_CHAR(v_issue_date, 'YYYY');
    
    INSERT INTO issued_license VALUES (
      seq_license_id.NEXTVAL,
      app.application_id,
      v_license_num,
      v_issue_date,
      v_expiry_date,
      v_validity,
      'License Officer ' || MOD(app.application_id, 5),
      'SHA256:' || SUBSTR(DBMS_RANDOM.STRING('X', 64), 1, 64),
      'QR' || LPAD(app.application_id, 10, '0'),
      CASE WHEN v_expiry_date < SYSDATE THEN 'Expired' ELSE 'Active' END,
      CASE WHEN v_expiry_date < SYSDATE + 90 THEN 'Y' ELSE 'N' END
    );
    
    v_license_count := v_license_count + 1;
    
    IF MOD(v_license_count, 10) = 0 THEN
      COMMIT;
      DBMS_OUTPUT.PUT_LINE('Inserted ' || v_license_count || ' licenses...');
    END IF;
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('ISSUED_LICENSE records inserted successfully!');
  DBMS_OUTPUT.PUT_LINE('Total licenses created: ' || v_license_count);
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inserting licenses: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/











SELECT 
    license_status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM issued_license
GROUP BY license_status
ORDER BY count DESC;





-- 1. Total licenses count
SELECT COUNT(*) AS total_licenses FROM issued_license;

-- 2. License status breakdown
SELECT 
    license_status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM issued_license
GROUP BY license_status
ORDER BY count DESC;

-- 3. Sample of licenses created
SELECT 
    license_id,
    application_id,
    license_number,
    TO_CHAR(issue_date, 'YYYY-MM-DD') AS issue_date,
    TO_CHAR(expiration_date, 'YYYY-MM-DD') AS expiration_date,
    validity_days,
    license_status,
    renewal_eligible
FROM issued_license
WHERE ROWNUM <= 10
ORDER BY license_id;

-- 4. Check which applications got licenses
SELECT 
    a.application_id,
    a.application_number,
    a.status AS app_status,
    il.license_number,
    il.license_status,
    TO_CHAR(il.expiration_date, 'YYYY-MM-DD') AS license_expires
FROM application a
LEFT JOIN issued_license il ON a.application_id = il.application_id
WHERE a.status = 'Approved'
ORDER BY a.application_id;

-- 5. Licenses expiring soon (within 90 days)
SELECT 
    license_id,
    application_id,
    license_number,
    license_status,
    TO_CHAR(expiration_date, 'YYYY-MM-DD') AS expiration_date,
    expiration_date - SYSDATE AS days_until_expiry
FROM issued_license
WHERE expiration_date BETWEEN SYSDATE AND SYSDATE + 90
ORDER BY expiration_date;

-- 6. Comprehensive summary
SELECT 
    'Total Licenses' AS metric,
    COUNT(*) AS value
FROM issued_license
UNION ALL
SELECT 
    'Active Licenses',
    COUNT(CASE WHEN license_status = 'Active' THEN 1 END)
FROM issued_license
UNION ALL
SELECT 
    'Expired Licenses',
    COUNT(CASE WHEN license_status = 'Expired' THEN 1 END)
FROM issued_license
UNION ALL
SELECT 
    'Licenses Expiring Soon',
    COUNT(CASE WHEN expiration_date < SYSDATE + 90 THEN 1 END)
FROM issued_license
UNION ALL
SELECT 
    'Eligible for Renewal',
    COUNT(CASE WHEN renewal_eligible = 'Y' THEN 1 END)
FROM issued_license
UNION ALL
SELECT 
    'Average Validity (Days)',
    ROUND(AVG(validity_days), 0)
FROM issued_license;








-- ============================================================================
-- INSERT INTO ISSUED_LICENSE (For approved applications only)
-- ============================================================================

PROMPT Inserting ISSUED_LICENSE records...

-- Insert licenses for approved applications
DECLARE
  v_validity NUMBER;
  v_license_num VARCHAR2(50);
  v_issue_date DATE;
  v_expiration_date DATE;
  v_license_count NUMBER := 0;
  v_approval_count NUMBER;
  v_license_exists NUMBER;
BEGIN
  -- Check how many approved applications exist
  SELECT COUNT(*) INTO v_approval_count 
  FROM application 
  WHERE status = 'Approved';
  
  DBMS_OUTPUT.PUT_LINE('Found ' || v_approval_count || ' approved applications');
  
  FOR app IN (SELECT a.application_id, a.submission_date, p.validity_period, p.permit_name
              FROM application a
              JOIN permit_type p ON a.permit_type_id = p.permit_type_id
              WHERE a.status = 'Approved')
  LOOP
    -- Check if license already exists for this application
    SELECT COUNT(*) INTO v_license_exists
    FROM issued_license
    WHERE application_id = app.application_id;
    
    -- Only insert if license doesn't already exist
    IF v_license_exists = 0 THEN
      v_validity := app.validity_period;
      v_issue_date := app.submission_date + 15; -- Issued 15 days after submission
      v_expiration_date := v_issue_date + v_validity;
      
      -- Generate unique license number with timestamp to avoid duplicates
      v_license_num := 'LIC-' || 
                      TO_CHAR(app.application_id, 'FM000000') || '-' || 
                      TO_CHAR(v_issue_date, 'YYYYMMDD') || '-' ||
                      TO_CHAR(DBMS_RANDOM.VALUE(1000, 9999));
      
      INSERT INTO issued_license VALUES (
        seq_license_id.NEXTVAL,
        app.application_id,
        v_license_num,
        v_issue_date,
        v_expiration_date,
        v_validity,
        'License Officer ' || MOD(app.application_id, 5),
        'SHA256:' || SUBSTR(DBMS_RANDOM.STRING('X', 64), 1, 64),
        'QR' || LPAD(app.application_id, 10, '0'),
        CASE WHEN v_expiration_date < SYSDATE THEN 'Expired' ELSE 'Active' END,
        CASE WHEN v_expiration_date < SYSDATE + 90 THEN 'Y' ELSE 'N' END
      );
      
      v_license_count := v_license_count + 1;
      
      IF MOD(v_license_count, 10) = 0 THEN
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Inserted ' || v_license_count || ' licenses...');
      END IF;
    ELSE
      DBMS_OUTPUT.PUT_LINE('License already exists for application ' || app.application_id || ' - skipping');
    END IF;
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('ISSUED_LICENSE records inserted successfully!');
  DBMS_OUTPUT.PUT_LINE('Total new licenses created: ' || v_license_count);
  DBMS_OUTPUT.PUT_LINE('Total licenses already existed: ' || (v_approval_count - v_license_count));
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inserting licenses: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/


-- Check total licenses
SELECT COUNT(*) AS total_licenses FROM issued_license;

-- Check license numbers to ensure uniqueness
SELECT 
    license_number,
    COUNT(*) AS duplicate_count
FROM issued_license
GROUP BY license_number
HAVING COUNT(*) > 1;

-- View newly created licenses
SELECT 
    license_id,
    application_id,
    license_number,
    license_status,
    TO_CHAR(issue_date, 'YYYY-MM-DD') AS issue_date,
    TO_CHAR(expiration_date, 'YYYY-MM-DD') AS expiration_date
FROM issued_license
ORDER BY license_id DESC
FETCH FIRST 10 ROWS ONLY;