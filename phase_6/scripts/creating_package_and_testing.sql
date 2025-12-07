CONNECT gakuba/Kim@localhost:1521/thu_27670_kim_permit_db;

SET SERVEROUTPUT ON;

-- ============================================================================
-- PACKAGE 1: Application Management Package
-- Purpose: Group all application-related procedures and functions
-- ============================================================================

-- Package Specification
CREATE OR REPLACE PACKAGE pkg_application_mgmt AS
    -- Public procedures
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
    
    -- Public functions
    FUNCTION get_application_count (
        p_citizen_id IN NUMBER
    ) RETURN NUMBER;
    
    FUNCTION get_pending_count (
        p_permit_type_id IN NUMBER DEFAULT NULL
    ) RETURN NUMBER;
    
    FUNCTION calculate_approval_rate (
        p_permit_type_id IN NUMBER
    ) RETURN NUMBER;
    
END pkg_application_mgmt;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY pkg_application_mgmt AS
    
    -- Submit new application
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
        -- Get the next sequence value first
        SELECT seq_application_id.NEXTVAL INTO v_next_seq FROM DUAL;
        
        -- Get permit details
        SELECT processing_fee, estimated_days
        INTO v_fee, v_days
        FROM permit_type
        WHERE permit_type_id = p_permit_type_id;
        
        -- Generate application number
        v_app_number := 'APP-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || 
                        LPAD(v_next_seq, 6, '0');
        
        -- Insert application
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
    
    -- Update application status
    PROCEDURE update_status (
        p_application_id    IN NUMBER,
        p_new_status        IN VARCHAR2,
        p_comments          IN VARCHAR2 DEFAULT NULL,
        p_officer_id        IN NUMBER DEFAULT 1001
    ) AS
        v_old_status VARCHAR2(30);
    BEGIN
        -- Get current status
        SELECT status INTO v_old_status
        FROM application
        WHERE application_id = p_application_id;
        
        -- Update application
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
    
    -- Cancel application
    PROCEDURE cancel_application (
        p_application_id    IN NUMBER,
        p_reason            IN VARCHAR2
    ) AS
        v_app_number VARCHAR2(30);
    BEGIN
        -- Get application number for message
        SELECT application_number INTO v_app_number
        FROM application
        WHERE application_id = p_application_id;
        
        UPDATE application
        SET status = 'Cancelled',
            last_updated = SYSDATE,
            notes = COALESCE(notes, '') || CHR(10) || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') || 
                    ': Application cancelled. Reason: ' || p_reason
        WHERE application_id = p_application_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Application cancelled: ' || v_app_number);
    END cancel_application;
    
    -- Get application count for citizen
    FUNCTION get_application_count (
        p_citizen_id IN NUMBER
    ) RETURN NUMBER AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM application
        WHERE citizen_id = p_citizen_id;
        
        RETURN v_count;
    END get_application_count;
    
    -- Get pending application count
    FUNCTION get_pending_count (
        p_permit_type_id IN NUMBER DEFAULT NULL
    ) RETURN NUMBER AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM application
        WHERE status IN ('Submitted', 'Under Review', 'Documentation Required')
        AND (p_permit_type_id IS NULL OR permit_type_id = p_permit_type_id);
        
        RETURN v_count;
    END get_pending_count;
    
    -- Calculate approval rate
    FUNCTION calculate_approval_rate (
        p_permit_type_id IN NUMBER
    ) RETURN NUMBER AS
        v_total NUMBER;
        v_approved NUMBER;
        v_rate NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_total
        FROM application
        WHERE permit_type_id = p_permit_type_id
        AND status IN ('Approved', 'Rejected');
        
        IF v_total = 0 THEN
            RETURN 0;
        END IF;
        
        SELECT COUNT(*)
        INTO v_approved
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
-- Purpose: Provide analytical functions and reports
-- ============================================================================

-- Package Specification
CREATE OR REPLACE PACKAGE pkg_analytics AS
    -- Public types
    TYPE t_revenue_rec IS RECORD (
        month VARCHAR2(7),
        total_revenue NUMBER,
        application_count NUMBER
    );
    
    TYPE t_revenue_table IS TABLE OF t_revenue_rec;
    
    -- Public functions
    FUNCTION get_monthly_revenue (
        p_year IN NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)
    ) RETURN t_revenue_table PIPELINED;
    
    FUNCTION get_department_performance (
        p_department_id IN NUMBER
    ) RETURN NUMBER;
    
    FUNCTION get_top_permit_types (
        p_limit IN NUMBER DEFAULT 5
    ) RETURN SYS_REFCURSOR;
    
END pkg_analytics;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY pkg_analytics AS
    
    -- Get monthly revenue (pipelined function)
    FUNCTION get_monthly_revenue (
        p_year IN NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)
    ) RETURN t_revenue_table PIPELINED AS
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
    
    -- Get department performance score
    FUNCTION get_department_performance (
        p_department_id IN NUMBER
    ) RETURN NUMBER AS
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
        
        IF v_total_reviews = 0 THEN
            RETURN 0;
        END IF;
        
        -- Score based on completion rate (70%) and speed (30%)
        v_score := ((v_completed / v_total_reviews) * 70) + 
                   (CASE 
                        WHEN v_avg_time = 0 THEN 30
                        WHEN v_avg_time < 1000 THEN 25  -- Fast (< 1000 minutes)
                        WHEN v_avg_time < 5000 THEN 20  -- Moderate
                        WHEN v_avg_time < 10000 THEN 10 -- Slow
                        ELSE 5                         -- Very slow
                    END);
        
        RETURN ROUND(LEAST(v_score, 100), 2); -- Cap at 100
    END get_department_performance;
    
    -- Get top permit types by application count (FIXED - removed category column)
    FUNCTION get_top_permit_types (
        p_limit IN NUMBER DEFAULT 5
    ) RETURN SYS_REFCURSOR AS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT 
                pt.permit_name,
                pt.permit_type_id,
                COUNT(a.application_id) AS application_count,
                SUM(CASE WHEN a.status = 'Approved' THEN 1 ELSE 0 END) AS approved_count,
                ROUND(AVG(a.payment_amount), 2) AS avg_fee,
                MIN(a.submission_date) AS first_application,
                MAX(a.submission_date) AS last_application
            FROM permit_type pt
            LEFT JOIN application a ON pt.permit_type_id = a.permit_type_id
            WHERE pt.is_active = 'Y'
            GROUP BY pt.permit_name, pt.permit_type_id
            ORDER BY application_count DESC NULLS LAST
            FETCH FIRST p_limit ROWS ONLY;
        
        RETURN v_cursor;
    END get_top_permit_types;
    
END pkg_analytics;
/









-- ============================================================================
-- WINDOW FUNCTIONS EXAMPLES (UPDATED)
-- Purpose: Demonstrate use of analytical window functions
-- ============================================================================

PROMPT ============================================================================
PROMPT Window Functions Examples
PROMPT ============================================================================

-- Example 1: ROW_NUMBER() - Rank applications by submission date per citizen
PROMPT
PROMPT 1. Application Ranking by Citizen (ROW_NUMBER):
SELECT 
    c.first_name || ' ' || c.last_name AS citizen_name,
    a.application_number,
    a.status,
    a.submission_date,
    ROW_NUMBER() OVER (
        PARTITION BY c.citizen_id 
        ORDER BY a.submission_date DESC
    ) AS recent_app_rank
FROM application a
JOIN citizen c ON a.citizen_id = c.citizen_id
WHERE c.status = 'Active'
AND ROWNUM <= 15
ORDER BY c.citizen_id, a.submission_date DESC;

-- Example 2: RANK() and DENSE_RANK() - Rank permits by application count
PROMPT
PROMPT 2. Permit Types Ranked by Application Count:
SELECT 
    pt.permit_name,
    COUNT(a.application_id) AS total_applications,
    RANK() OVER (ORDER BY COUNT(a.application_id) DESC) AS rank_by_count,
    DENSE_RANK() OVER (ORDER BY COUNT(a.application_id) DESC) AS dense_rank_by_count,
    SUM(COUNT(a.application_id)) OVER () AS total_all_applications
FROM permit_type pt
LEFT JOIN application a ON pt.permit_type_id = a.permit_type_id
WHERE pt.is_active = 'Y'
GROUP BY pt.permit_name
ORDER BY total_applications DESC;

-- Example 3: LAG() and LEAD() - Compare processing time with adjacent applications
PROMPT
PROMPT 3. Application Processing Time Trends:
SELECT 
    application_number,
    permit_type_id,
    submission_date,
    last_updated,
    TRUNC(last_updated - submission_date) AS processing_days,
    LAG(TRUNC(last_updated - submission_date)) OVER (
        PARTITION BY permit_type_id 
        ORDER BY submission_date
    ) AS prev_permit_processing_days,
    LEAD(TRUNC(last_updated - submission_date)) OVER (
        PARTITION BY permit_type_id 
        ORDER BY submission_date
    ) AS next_permit_processing_days
FROM application
WHERE status IN ('Approved', 'Rejected')
AND ROWNUM <= 12
ORDER BY permit_type_id, submission_date;

-- Example 4: PARTITION BY with aggregation - Department review analysis
PROMPT
PROMPT 4. Department Review Analysis:
SELECT 
    d.department_name,
    rs.step_status,
    COUNT(*) AS status_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY d.department_name), 2) AS department_percentage,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS overall_percentage
FROM review_step rs
JOIN department d ON rs.department_id = d.department_id
WHERE d.is_active = 'Y'
GROUP BY d.department_name, rs.step_status
ORDER BY d.department_name, COUNT(*) DESC;

-- Example 5: Moving average - 3-month moving average of revenue
PROMPT
PROMPT 5. 3-Month Moving Average of Monthly Revenue:
SELECT 
    month_year,
    monthly_revenue,
    ROUND(AVG(monthly_revenue) OVER (
        ORDER BY month_year 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3months,
    SUM(monthly_revenue) OVER (
        ORDER BY month_year
    ) AS cumulative_revenue
FROM (
    SELECT 
        TO_CHAR(submission_date, 'YYYY-MM') AS month_year,
        SUM(payment_amount) AS monthly_revenue
    FROM application
    WHERE payment_status = 'Paid'
    GROUP BY TO_CHAR(submission_date, 'YYYY-MM')
)
ORDER BY month_year;

-- Example 6: NTILE() - Divide citizens into groups by application count
PROMPT
PROMPT 6. Citizen Groups by Application Frequency:
SELECT 
    c.first_name || ' ' || c.last_name AS citizen_name,
    COUNT(a.application_id) AS application_count,
    NTILE(4) OVER (ORDER BY COUNT(a.application_id) DESC) AS frequency_group,
    CASE NTILE(4) OVER (ORDER BY COUNT(a.application_id) DESC)
        WHEN 1 THEN 'Frequent Applicant'
        WHEN 2 THEN 'Regular Applicant'
        WHEN 3 THEN 'Occasional Applicant'
        WHEN 4 THEN 'Rare Applicant'
    END AS frequency_category
FROM citizen c
LEFT JOIN application a ON c.citizen_id = a.citizen_id
WHERE c.status = 'Active'
GROUP BY c.citizen_id, c.first_name, c.last_name
HAVING COUNT(a.application_id) > 0
ORDER BY application_count DESC;

-- Example 7: FIRST_VALUE and LAST_VALUE - Compare with best/worst processing times
PROMPT
PROMPT 7. Processing Time Benchmarks:
SELECT 
    pt.permit_name,
    a.application_number,
    TRUNC(a.last_updated - a.submission_date) AS processing_days,
    FIRST_VALUE(TRUNC(a.last_updated - a.submission_date)) OVER (
        PARTITION BY a.permit_type_id 
        ORDER BY (a.last_updated - a.submission_date)
    ) AS fastest_in_category,
    LAST_VALUE(TRUNC(a.last_updated - a.submission_date)) OVER (
        PARTITION BY a.permit_type_id 
        ORDER BY (a.last_updated - a.submission_date)
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS slowest_in_category
FROM application a
JOIN permit_type pt ON a.permit_type_id = pt.permit_type_id
WHERE a.status = 'Approved'
AND ROWNUM <= 10
ORDER BY pt.permit_name, processing_days;








-- ============================================================================
-- TESTING PACKAGES (UPDATED)
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
    
    DBMS_OUTPUT.PUT_LINE('Testing with Citizen ID: ' || v_citizen_id || ', Permit Type ID: ' || v_permit_id);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    
    -- Test submit application
    pkg_application_mgmt.submit_application(
        p_citizen_id => v_citizen_id,
        p_permit_type_id => v_permit_id,
        p_priority_level => 'Normal',
        p_notes => 'Test from package',
        p_application_id => v_app_id
    );
    DBMS_OUTPUT.PUT_LINE('Submitted Application ID: ' || v_app_id);
    
    -- Test get application count
    v_count := pkg_application_mgmt.get_application_count(v_citizen_id);
    DBMS_OUTPUT.PUT_LINE('Total applications for citizen: ' || v_count);
    
    -- Test get pending count
    v_count := pkg_application_mgmt.get_pending_count(v_permit_id);
    DBMS_OUTPUT.PUT_LINE('Pending applications for permit type: ' || v_count);
    
    -- Test update status
    pkg_application_mgmt.update_status(
        p_application_id => v_app_id,
        p_new_status => 'Under Review',
        p_comments => 'Initial review started',
        p_officer_id => 1001
    );
    
    -- Test approval rate
    v_rate := pkg_application_mgmt.calculate_approval_rate(v_permit_id);
    DBMS_OUTPUT.PUT_LINE('Approval rate for permit type: ' || v_rate || '%');
    
    -- Test cancel application
    pkg_application_mgmt.cancel_application(
        p_application_id => v_app_id,
        p_reason => 'Testing package functionality'
    );
    
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Application Management Package tests completed.');
END;
/







-- Test Analytics Package
PROMPT
PROMPT Testing Analytics Package:
PROMPT ------------------------------------------------------

-- Test monthly revenue
DECLARE
    v_year NUMBER := EXTRACT(YEAR FROM SYSDATE);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Monthly Revenue for ' || v_year || ':');
    FOR rec IN (SELECT * FROM TABLE(pkg_analytics.get_monthly_revenue(v_year))) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || rec.month || ': ' || 
                            TO_CHAR(rec.total_revenue, 'FM999,999,990') || 
                            ' RWF (' || rec.application_count || ' apps)');
    END LOOP;
END;
/

-- Test department performance
BEGIN
    DBMS_OUTPUT.PUT_LINE('Department Performance Scores:');
    FOR rec IN (
        SELECT d.department_id, d.department_name,
               pkg_analytics.get_department_performance(d.department_id) AS score
        FROM department d
        WHERE d.is_active = 'Y'
        AND ROWNUM <= 5
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || rec.department_name || ': ' || rec.score || '/100');
    END LOOP;
END;
/
-- Test top permit types
DECLARE
    v_cursor SYS_REFCURSOR;
    v_permit_name VARCHAR2(100);
    v_permit_type_id NUMBER;  -- ADDED THIS VARIABLE
    v_app_count NUMBER;
    v_approved_count NUMBER;
    v_avg_fee NUMBER;
    v_first_app DATE;
    v_last_app DATE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Top 5 Permit Types:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    
    v_cursor := pkg_analytics.get_top_permit_types(5);
    
    LOOP
        FETCH v_cursor INTO v_permit_name, v_permit_type_id, v_app_count, v_approved_count, v_avg_fee, v_first_app, v_last_app;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Permit: ' || v_permit_name || ' (ID: ' || v_permit_type_id || ')');
        DBMS_OUTPUT.PUT_LINE('  Total Applications: ' || NVL(v_app_count, 0));
        
        IF v_app_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('  Approved: ' || NVL(v_approved_count, 0) || 
                                ' (' || ROUND(NVL(v_approved_count, 0) * 100.0 / v_app_count, 1) || '%)');
            DBMS_OUTPUT.PUT_LINE('  Average Fee: ' || TO_CHAR(NVL(v_avg_fee, 0), 'FM999,999,990') || ' RWF');
            DBMS_OUTPUT.PUT_LINE('  First Application: ' || TO_CHAR(v_first_app, 'DD-MON-YYYY'));
            DBMS_OUTPUT.PUT_LINE('  Last Application: ' || TO_CHAR(v_last_app, 'DD-MON-YYYY'));
        ELSE
            DBMS_OUTPUT.PUT_LINE('  No applications yet');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    IF v_cursor%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No permit types found with applications.');
    END IF;
    
    CLOSE v_cursor;
END;
/