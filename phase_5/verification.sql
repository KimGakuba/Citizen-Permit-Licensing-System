-- ============================================================================
-- DATA INSERTION COMPLETE - VERIFICATION
-- ============================================================================

PROMPT ============================================================================
PROMPT Verifying Data Insertion...
PROMPT ============================================================================

SET LINESIZE 100
SET PAGESIZE 50
COLUMN table_name FORMAT A20
COLUMN record_count FORMAT 999,999

SELECT 
    table_name,
    record_count
FROM (
    SELECT 'CITIZEN' AS table_name, COUNT(*) AS record_count FROM citizen
    UNION ALL
    SELECT 'PERMIT_TYPE', COUNT(*) FROM permit_type
    UNION ALL
    SELECT 'DEPARTMENT', COUNT(*) FROM department
    UNION ALL
    SELECT 'APPLICATION', COUNT(*) FROM application
    UNION ALL
    SELECT 'REVIEW_STEP', COUNT(*) FROM review_step
    UNION ALL
    SELECT 'ISSUED_LICENSE', COUNT(*) FROM issued_license
    UNION ALL
    SELECT 'DOCUMENT', COUNT(*) FROM document
)
ORDER BY table_name;

PROMPT 
PROMPT ============================================================================
PROMPT Additional Statistics:
PROMPT ============================================================================

SELECT 
    metric,
    value
FROM (
    SELECT 'Total Applications' AS metric, TO_CHAR(COUNT(*), '999,999') AS value FROM application
    UNION ALL
    SELECT 'Approved Applications', TO_CHAR(COUNT(*), '999,999') FROM application WHERE status = 'Approved'
    UNION ALL
    SELECT 'Applications in Review', TO_CHAR(COUNT(*), '999,999') FROM application WHERE status = 'Under Review'
    UNION ALL
    SELECT 'Applications with Documents', TO_CHAR(COUNT(DISTINCT application_id), '999,999') FROM document
    UNION ALL
    SELECT 'Applications with Review Steps', TO_CHAR(COUNT(DISTINCT application_id), '999,999') FROM review_step
    UNION ALL
    SELECT 'Applications with Licenses', TO_CHAR(COUNT(DISTINCT application_id), '999,999') FROM issued_license
)
ORDER BY metric;








-- Quick summary dashboard
SELECT 
    category,
    detail,
    count,
    percentage
FROM (
    -- Application Status
    SELECT 
        'Application Status' AS category,
        status AS detail,
        COUNT(*) AS count,
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM application), 2) AS percentage
    FROM application
    GROUP BY status
    
    UNION ALL
    
    -- Payment Status
    SELECT 
        'Payment Status',
        payment_status,
        COUNT(*),
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM application), 2)
    FROM application
    GROUP BY payment_status
    
    UNION ALL
    
    -- Priority Level
    SELECT 
        'Priority Level',
        priority_level,
        COUNT(*),
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM application), 2)
    FROM application
    GROUP BY priority_level
    
    UNION ALL
    
    -- License Status
    SELECT 
        'License Status',
        license_status,
        COUNT(*),
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM issued_license), 2)
    FROM issued_license
    GROUP BY license_status
)
ORDER BY 
    CASE category
        WHEN 'Application Status' THEN 1
        WHEN 'Payment Status' THEN 2
        WHEN 'Priority Level' THEN 3
        WHEN 'License Status' THEN 4
    END,
    count DESC;