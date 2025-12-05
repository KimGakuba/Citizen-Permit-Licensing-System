CREATE TABLE citizen (
  citizen_id          NUMBER(10)      NOT NULL,
  first_name          VARCHAR2(50)    NOT NULL,
  last_name           VARCHAR2(50)    NOT NULL,
  date_of_birth       DATE            NOT NULL,
  national_id         VARCHAR2(20)    NOT NULL,
  email               VARCHAR2(100)   NOT NULL,
  phone               VARCHAR2(20)    NOT NULL,
  address             VARCHAR2(200)   NOT NULL,
  residency_status    VARCHAR2(30)    NOT NULL,
  registration_date   DATE            DEFAULT SYSDATE NOT NULL,
  status              VARCHAR2(20)    DEFAULT 'Active' NOT NULL,
  -- Constraints
  CONSTRAINT pk_citizen PRIMARY KEY (citizen_id) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT uk_citizen_national_id UNIQUE (national_id) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT uk_citizen_email UNIQUE (email) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT chk_citizen_residency CHECK (residency_status IN ('Citizen', 'Resident', 'Foreigner')),
  CONSTRAINT chk_citizen_status CHECK (status IN ('Active', 'Inactive', 'Suspended'))
  -- Note: Date validation will be handled by application logic or trigger
) TABLESPACE PERMIT_DATA;


CREATE INDEX idx_citizen_lastname ON citizen(last_name) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_citizen_status ON citizen(status) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_citizen_residency ON citizen(residency_status) TABLESPACE PERMIT_IDX;




CREATE TABLE permit_type (
  permit_type_id      NUMBER(10)      NOT NULL,
  permit_name         VARCHAR2(100)   NOT NULL,
  category            VARCHAR2(50)    NOT NULL,
  description         VARCHAR2(500)   NOT NULL,
  validity_period     NUMBER(5)       NOT NULL,
  processing_fee      NUMBER(10,2)    NOT NULL,
  estimated_days      NUMBER(5)       NOT NULL,
  required_docs       VARCHAR2(500)   NOT NULL,
  is_active           CHAR(1)         DEFAULT 'Y' NOT NULL,
  created_date        DATE            DEFAULT SYSDATE NOT NULL,
  -- Constraints
  CONSTRAINT pk_permit_type PRIMARY KEY (permit_type_id) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT uk_permit_name UNIQUE (permit_name) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT chk_permit_validity CHECK (validity_period > 0),
  CONSTRAINT chk_permit_fee CHECK (processing_fee >= 0),
  CONSTRAINT chk_permit_days CHECK (estimated_days > 0),
  CONSTRAINT chk_permit_active CHECK (is_active IN ('Y', 'N'))
) TABLESPACE PERMIT_DATA;


CREATE INDEX idx_permit_category ON permit_type(category) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_permit_active ON permit_type(is_active) TABLESPACE PERMIT_IDX;


CREATE TABLE department (
  department_id       NUMBER(10)      NOT NULL,
  department_name     VARCHAR2(100)   NOT NULL,
  department_code     VARCHAR2(20)    NOT NULL,
  description         VARCHAR2(500)   NOT NULL,
  head_officer        VARCHAR2(100)   NOT NULL,
  contact_email       VARCHAR2(100)   NOT NULL,
  is_active           CHAR(1)         DEFAULT 'Y' NOT NULL,
  -- Constraints
  CONSTRAINT pk_department PRIMARY KEY (department_id) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT uk_dept_name UNIQUE (department_name) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT uk_dept_code UNIQUE (department_code) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT chk_dept_active CHECK (is_active IN ('Y', 'N'))
) TABLESPACE PERMIT_DATA;

CREATE INDEX idx_dept_active ON department(is_active) TABLESPACE PERMIT_IDX;



CREATE TABLE application (
  application_id          NUMBER(10)      NOT NULL,
  citizen_id              NUMBER(10)      NOT NULL,
  permit_type_id          NUMBER(10)      NOT NULL,
  application_number      VARCHAR2(30)    NOT NULL,
  submission_date         DATE            DEFAULT SYSDATE NOT NULL,
  status                  VARCHAR2(30)    DEFAULT 'Submitted' NOT NULL,
  priority_level          VARCHAR2(20)    DEFAULT 'Normal' NOT NULL,
  payment_status          VARCHAR2(20)    DEFAULT 'Pending' NOT NULL,
  payment_amount          NUMBER(10,2)    DEFAULT 0,
  notes                   VARCHAR2(1000),
  last_updated            DATE            DEFAULT SYSDATE NOT NULL,
  assigned_officer_id     NUMBER(10),
  estimated_completion    DATE,
  -- Constraints
  CONSTRAINT pk_application PRIMARY KEY (application_id) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT uk_app_number UNIQUE (application_number) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT fk_app_citizen FOREIGN KEY (citizen_id) 
    REFERENCES citizen(citizen_id) ON DELETE CASCADE,
  CONSTRAINT fk_app_permit_type FOREIGN KEY (permit_type_id) 
    REFERENCES permit_type(permit_type_id),  -- REMOVED: ON DELETE RESTRICT
  CONSTRAINT chk_app_status CHECK (status IN 
    ('Submitted', 'Under Review', 'Documentation Required', 
     'Approved', 'Rejected', 'Cancelled', 'On Hold')),
  CONSTRAINT chk_app_priority CHECK (priority_level IN 
    ('Low', 'Normal', 'High', 'Urgent')),
  CONSTRAINT chk_app_payment_status CHECK (payment_status IN 
    ('Pending', 'Paid', 'Waived', 'Refunded')),
  CONSTRAINT chk_app_payment_amount CHECK (payment_amount >= 0)
) TABLESPACE PERMIT_DATA;


CREATE INDEX idx_app_citizen ON application(citizen_id) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_app_permit_type ON application(permit_type_id) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_app_status ON application(status) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_app_submission_date ON application(submission_date) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_app_payment_status ON application(payment_status) TABLESPACE PERMIT_IDX;



CREATE TABLE review_step (
  step_id             NUMBER(10)      NOT NULL,
  application_id      NUMBER(10)      NOT NULL,
  department_id       NUMBER(10)      NOT NULL,
  step_number         NUMBER(3)       NOT NULL,
  review_date         DATE            DEFAULT SYSDATE NOT NULL,
  step_status         VARCHAR2(30)    DEFAULT 'Pending' NOT NULL,
  reviewer_name       VARCHAR2(100),
  comments            VARCHAR2(2000),
  decision            VARCHAR2(30),
  completion_date     DATE,
  processing_time     NUMBER(10),
  CONSTRAINT pk_review_step PRIMARY KEY (step_id) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT fk_step_application FOREIGN KEY (application_id) 
    REFERENCES application(application_id) ON DELETE CASCADE,
  CONSTRAINT fk_step_department FOREIGN KEY (department_id) 
    REFERENCES department(department_id),
  CONSTRAINT chk_step_number CHECK (step_number > 0),
  CONSTRAINT chk_step_status CHECK (step_status IN 
    ('Pending', 'In Progress', 'Completed', 'Blocked', 'Escalated')),
  CONSTRAINT chk_step_decision CHECK (decision IN 
    ('Approved', 'Rejected', 'Revision Required', NULL)),
  CONSTRAINT chk_step_processing_time CHECK (processing_time >= 0 OR processing_time IS NULL)
) TABLESPACE PERMIT_DATA;



CREATE TABLE issued_license (
  license_id          NUMBER(10)      NOT NULL,
  application_id      NUMBER(10)      NOT NULL,
  license_number      VARCHAR2(50)    NOT NULL,
  issue_date          DATE            DEFAULT SYSDATE NOT NULL,
  expiration_date     DATE            NOT NULL,
  validity_days       NUMBER(10)      NOT NULL,
  issued_by           VARCHAR2(100)   NOT NULL,
  digital_signature   VARCHAR2(500),
  qr_code             VARCHAR2(200),
  license_status      VARCHAR2(20)    DEFAULT 'Active' NOT NULL,
  renewal_eligible    CHAR(1)         DEFAULT 'Y' NOT NULL,
  CONSTRAINT pk_issued_license PRIMARY KEY (license_id) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT uk_license_number UNIQUE (license_number) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT uk_license_app UNIQUE (application_id) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT fk_license_app FOREIGN KEY (application_id) 
    REFERENCES application(application_id) ON DELETE CASCADE,
  CONSTRAINT chk_license_status CHECK (license_status IN 
    ('Active', 'Expired', 'Revoked', 'Suspended')),
  CONSTRAINT chk_license_renewal CHECK (renewal_eligible IN ('Y', 'N')),
  CONSTRAINT chk_license_validity CHECK (validity_days > 0),
  CONSTRAINT chk_license_expiry CHECK (expiration_date > issue_date)
) TABLESPACE PERMIT_DATA;


CREATE TABLE document (
  document_id         NUMBER(10)      NOT NULL,
  application_id      NUMBER(10)      NOT NULL,
  document_type       VARCHAR2(100)   NOT NULL,
  file_name           VARCHAR2(200)   NOT NULL,
  file_path           VARCHAR2(500)   NOT NULL,
  file_size           NUMBER(15)      NOT NULL,
  upload_date         DATE            DEFAULT SYSDATE NOT NULL,
  verified            CHAR(1)         DEFAULT 'N' NOT NULL,
  verified_by         VARCHAR2(100),
  CONSTRAINT pk_document PRIMARY KEY (document_id) USING INDEX TABLESPACE PERMIT_IDX,
  CONSTRAINT fk_doc_application FOREIGN KEY (application_id) 
    REFERENCES application(application_id) ON DELETE CASCADE,
  CONSTRAINT chk_doc_verified CHECK (verified IN ('Y', 'N')),
  CONSTRAINT chk_doc_file_size CHECK (file_size > 0)
) TABLESPACE PERMIT_DATA;



CREATE INDEX idx_step_application ON review_step(application_id) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_step_department ON review_step(department_id) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_step_status ON review_step(step_status) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_step_review_date ON review_step(review_date) TABLESPACE PERMIT_IDX;


--CREATE INDEX idx_license_app ON issued_license(application_id) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_license_status ON issued_license(license_status) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_license_expiry ON issued_license(expiration_date) TABLESPACE PERMIT_IDX;


CREATE INDEX idx_doc_application ON document(application_id) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_doc_type ON document(document_type) TABLESPACE PERMIT_IDX;
CREATE INDEX idx_doc_verified ON document(verified) TABLESPACE PERMIT_IDX;

-- VERIFICATION: List all tables created
SELECT table_name, tablespace_name, num_rows, status
FROM user_tables
WHERE table_name IN (
  'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
  'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
)
ORDER BY table_name;


-- Count tables
SELECT COUNT(*) AS total_tables 
FROM user_tables 
WHERE table_name IN (
  'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
  'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
);

-- VERIFICATION: List all indexes created
SELECT index_name, table_name, tablespace_name, uniqueness, status
FROM user_indexes
WHERE table_name IN (
  'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
  'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
)
ORDER BY table_name, index_name;



-- Count indexes
SELECT COUNT(*) AS total_indexes 
FROM user_indexes 
WHERE table_name IN (
  'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
  'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
);

-- VERIFICATION: List all constraints
SELECT 
  constraint_name,
  table_name,
  constraint_type,
  CASE constraint_type
    WHEN 'P' THEN 'Primary Key'
    WHEN 'U' THEN 'Unique'
    WHEN 'R' THEN 'Foreign Key'
    WHEN 'C' THEN 'Check'
  END AS constraint_description,
  status
FROM user_constraints
WHERE table_name IN (
  'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
  'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
)
ORDER BY table_name, constraint_type;


-- Count constraints by type
SELECT 
  CASE constraint_type
    WHEN 'P' THEN 'Primary Key'
    WHEN 'U' THEN 'Unique'
    WHEN 'R' THEN 'Foreign Key'
    WHEN 'C' THEN 'Check'
  END AS constraint_type,
  COUNT(*) AS count
FROM user_constraints
WHERE table_name IN (
  'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
  'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
)
GROUP BY constraint_type
ORDER BY constraint_type;


-- VERIFICATION: Show table relationships (Foreign Keys)
SELECT 
  a.constraint_name,
  a.table_name AS from_table,
  b.table_name AS to_table,
  a.status
FROM user_constraints a
JOIN user_constraints b ON a.r_constraint_name = b.constraint_name
WHERE a.constraint_type = 'R'
AND a.table_name IN (
  'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
  'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
)
ORDER BY a.table_name;


-- VERIFICATION: Check tablespace usage
SELECT 
  t.table_name,
  t.tablespace_name AS table_tablespace,
  i.index_name,
  i.tablespace_name AS index_tablespace
FROM user_tables t
LEFT JOIN user_indexes i ON t.table_name = i.table_name
WHERE t.table_name IN (
  'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
  'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
)
ORDER BY t.table_name, i.index_name;