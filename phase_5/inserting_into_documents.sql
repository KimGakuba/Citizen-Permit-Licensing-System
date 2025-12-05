-- ============================================================================
-- INSERT INTO DOCUMENT (Multiple documents per application)
-- ============================================================================

PROMPT Inserting DOCUMENT records...

-- Insert 2-5 documents per application (first 100 applications)
DECLARE
  TYPE doc_type_array IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
  v_doc_types doc_type_array;
  v_doc_count NUMBER;
  v_doc_type VARCHAR2(100);
  v_file_name VARCHAR2(200);
  v_file_size NUMBER;
  v_total_docs NUMBER := 0;
  v_app_count NUMBER := 0;
BEGIN
  -- Initialize document types
  v_doc_types(1) := 'National ID Copy';
  v_doc_types(2) := 'Business Registration';
  v_doc_types(3) := 'Tax Clearance Certificate';
  v_doc_types(4) := 'Proof of Address';
  v_doc_types(5) := 'Bank Statement';
  v_doc_types(6) := 'Site Plan';
  v_doc_types(7) := 'Insurance Certificate';
  v_doc_types(8) := 'Professional License';
  
  DBMS_OUTPUT.PUT_LINE('Starting document insertion for first 100 applications...');
  
  FOR app IN (SELECT application_id 
              FROM application 
              WHERE application_id <= (SELECT MIN(application_id) + 99 FROM application)
              ORDER BY application_id)
  LOOP
    v_app_count := v_app_count + 1;
    v_doc_count := 2 + MOD(app.application_id, 4); -- 2 to 5 documents per application
    
    FOR i IN 1..v_doc_count LOOP
      v_doc_type := v_doc_types(MOD(i-1, 8) + 1);
      v_file_name := REPLACE(LOWER(v_doc_type), ' ', '_') || '_' || app.application_id || '_' || i || '.pdf';
      v_file_size := 102400 + (MOD(app.application_id * i, 900) * 1024); -- 100KB to 1MB
      
      INSERT INTO document VALUES (
        seq_document_id.NEXTVAL,
        app.application_id,
        v_doc_type,
        v_file_name,
        'C:\APP\KIM\PERMIT_DOCUMENTS\' || TO_CHAR(SYSDATE, 'YYYY') || '\' || v_file_name,
        v_file_size,
        SYSDATE - (100 - MOD(app.application_id, 100)),
        CASE WHEN MOD(i, 5) = 0 THEN 'N' ELSE 'Y' END,
        CASE WHEN MOD(i, 5) = 0 THEN NULL ELSE 'Verifier ' || MOD(app.application_id, 5) END
      );
      
      v_total_docs := v_total_docs + 1;
    END LOOP;
    
    -- Progress update every 20 applications
    IF MOD(v_app_count, 20) = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Processed ' || v_app_count || ' applications, created ' || v_total_docs || ' documents...');
      COMMIT;
    END IF;
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('DOCUMENT records inserted successfully!');
  DBMS_OUTPUT.PUT_LINE('Total applications processed: ' || v_app_count);
  DBMS_OUTPUT.PUT_LINE('Total documents created: ' || v_total_docs);
  DBMS_OUTPUT.PUT_LINE('Average documents per application: ' || ROUND(v_total_docs / v_app_count, 2));
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inserting documents: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/




-- 1. Count total documents
SELECT COUNT(*) AS total_documents FROM document;

-- 2. Documents per application distribution
SELECT 
    docs_per_app,
    COUNT(*) AS application_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM (
    SELECT 
        application_id,
        COUNT(*) AS docs_per_app
    FROM document
    GROUP BY application_id
)
GROUP BY docs_per_app
ORDER BY docs_per_app;

-- 3. Document types distribution
SELECT 
    document_type,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM document
GROUP BY document_type
ORDER BY count DESC;

-- 4. Verification status
SELECT 
    verified,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM document
GROUP BY verified
ORDER BY verified;

-- 5. Sample of documents
SELECT 
    document_id,
    application_id,
    document_type,
    file_name,
    ROUND(file_size/1024, 2) AS file_size_kb,
    TO_CHAR(upload_date, 'YYYY-MM-DD') AS upload_date,
    verified,
    verified_by
FROM document
WHERE ROWNUM <= 10
ORDER BY document_id;

-- 6. Check documents by application
SELECT 
    a.application_id,
    a.application_number,
    COUNT(d.document_id) AS document_count
FROM application a
LEFT JOIN document d ON a.application_id = d.application_id
WHERE a.application_id <= (SELECT MIN(application_id) + 99 FROM application)
GROUP BY a.application_id, a.application_number
ORDER BY a.application_id;

-- 7. Comprehensive summary
SELECT 
    'Total Documents' AS metric,
    COUNT(*) AS value
FROM document
UNION ALL
SELECT 
    'Total Applications with Documents',
    COUNT(DISTINCT application_id)
FROM document
UNION ALL
SELECT 
    'Average Documents per Application',
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT application_id), 2)
FROM document
UNION ALL
SELECT 
    'Verified Documents',
    COUNT(CASE WHEN verified = 'Y' THEN 1 END)
FROM document
UNION ALL
SELECT 
    'Total File Size (MB)',
    ROUND(SUM(file_size)/1024/1024, 2)
FROM document
UNION ALL
SELECT 
    'Average File Size (KB)',
    ROUND(AVG(file_size)/1024, 2)
FROM document;





SELECT 
    COUNT(DISTINCT application_id) AS apps_with_docs,
    COUNT(*) AS total_documents,
    ROUND(AVG(cnt), 2) AS avg_docs_per_app
FROM (
    SELECT application_id, COUNT(*) AS cnt
    FROM document
    GROUP BY application_id
);








SELECT 
    'CITIZEN' AS table_name, COUNT(*) AS records FROM citizen
UNION ALL SELECT 'PERMIT_TYPE', COUNT(*) FROM permit_type
UNION ALL SELECT 'DEPARTMENT', COUNT(*) FROM department
UNION ALL SELECT 'APPLICATION', COUNT(*) FROM application
UNION ALL SELECT 'REVIEW_STEP', COUNT(*) FROM review_step
UNION ALL SELECT 'ISSUED_LICENSE', COUNT(*) FROM issued_license
UNION ALL SELECT 'DOCUMENT', COUNT(*) FROM document
ORDER BY table_name;