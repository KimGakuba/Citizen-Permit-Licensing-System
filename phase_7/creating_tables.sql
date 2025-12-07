CONNECT gakuba/Kim@localhost:1521/thu_27670_kim_permit_db;
SET SERVEROUTPUT ON;

PROMPT ============================================================================
PROMPT PHASE VII: TRIGGERS, AUDITING, AND BUSINESS RULES
PROMPT ============================================================================

-- ============================================================================
-- STEP 1: HOLIDAY MANAGEMENT TABLE
-- ============================================================================

PROMPT Creating HOLIDAYS table...

CREATE TABLE HOLIDAYS (
    holiday_id NUMBER(10) PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    holiday_name VARCHAR2(100) NOT NULL,
    holiday_type VARCHAR2(50) DEFAULT 'PUBLIC',
    created_date DATE DEFAULT SYSDATE
);

PROMPT HOLIDAYS table created successfully.

-- Insert upcoming month holidays (December 2025 - January 2026)
PROMPT Inserting sample holidays...

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, holiday_type) 
VALUES (1, TO_DATE('2025-12-25', 'YYYY-MM-DD'), 'Christmas Day', 'PUBLIC');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, holiday_type) 
VALUES (2, TO_DATE('2025-12-26', 'YYYY-MM-DD'), 'Boxing Day', 'PUBLIC');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, holiday_type) 
VALUES (3, TO_DATE('2026-01-01', 'YYYY-MM-DD'), 'New Year Day', 'PUBLIC');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, holiday_type) 
VALUES (4, TO_DATE('2026-02-03', 'YYYY-MM-DD'), 'Heroes Day', 'PUBLIC');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, holiday_type) 
VALUES (5, TO_DATE('2026-05-01', 'YYYY-MM-DD'), 'Labour Day', 'PUBLIC');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, holiday_type) 
VALUES (6, TO_DATE('2026-07-01', 'YYYY-MM-DD'), 'Indepedence Day', 'PUBLIC');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, holiday_type) 
VALUES (7, TO_DATE('2026-07-04', 'YYYY-MM-DD'), 'Liberation Day', 'PUBLIC');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, holiday_type) 
VALUES (8, TO_DATE('2026-08-01', 'YYYY-MM-DD'), 'Umuganura Day', 'PUBLIC');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, holiday_type) 
VALUES (9, TO_DATE('2026-08-15', 'YYYY-MM-DD'), 'Assumption Day', 'PUBLIC');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, holiday_type) 
VALUES (10, TO_DATE('2026-04-07', 'YYYY-MM-DD'), 'Genocide against Tutsi Memorial Day', 'PUBLIC');

COMMIT;





-- ============================================================================
-- STEP 2: AUDIT LOG TABLE
-- ============================================================================

PROMPT Creating AUDIT_LOG table...

CREATE TABLE AUDIT_LOG (
    audit_id NUMBER(10) PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation_type VARCHAR2(10) NOT NULL CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    operation_date DATE DEFAULT SYSDATE,
    operation_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50) DEFAULT USER,
    status VARCHAR2(20) NOT NULL CHECK (status IN ('ALLOWED', 'DENIED')),
    denial_reason VARCHAR2(200),
    record_id NUMBER(10),
    old_values CLOB,
    new_values CLOB
);

PROMPT AUDIT_LOG table created successfully.

-- Create sequence for audit_id
CREATE SEQUENCE audit_log_seq START WITH 1 INCREMENT BY 1;