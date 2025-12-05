# Phase V: Complete Implementation Summary

**Student:** NGABONZIZA Kim Gakuba  
**ID:** 27670  
**Project:** Citizen Permit and Licensing System  
**Database:** thu_27670_kim_permit_db  
**Date:** December 2025

---

## 📋 Executive Summary

Phase V successfully implemented a fully normalized database with 7 tables, comprehensive constraints, realistic test data, and complete validation. The system now contains **1,100+ records** across all tables, representing a fully operational permit and licensing management system.

---

## 🎯 What Was Accomplished

### Tables Created (7)
1. **CITIZEN** - 200 records (IDs: 1000-1199)
2. **PERMIT_TYPE** - 20 records (IDs: 100-119)
3. **DEPARTMENT** - 26 records (IDs: 10-35)
4. **APPLICATION** - 230 records (IDs: 1-230, 10500-10529)
5. **REVIEW_STEP** - 470+ records
6. **ISSUED_LICENSE** - 60+ records (approved applications only)
7. **DOCUMENT** - 300+ records (2-5 per application)

### Constraints Implemented
- ✅ 7 Primary Keys
- ✅ 8 Unique Constraints
- ✅ 6 Foreign Keys with CASCADE/RESTRICT
- ✅ 25+ CHECK Constraints
- ✅ Multiple DEFAULT values

### Indexes Created
- ✅ 20+ indexes across all tables
- ✅ Proper tablespace separation (PERMIT_DATA, PERMIT_IDX)
- ✅ Performance-optimized for queries

---

## 🚀 Quick Start Commands

### Step 1: Connect to Database
```sql
sqlplus gakuba/Kim@localhost:1521/thu_27670_kim_permit_db
```

### Step 2: Verify Current State
```sql
-- Check all tables
SELECT table_name, num_rows 
FROM user_tables 
ORDER BY table_name;

-- Count total records
SELECT 
    'CITIZEN' AS table_name, COUNT(*) AS records FROM citizen
UNION ALL SELECT 'PERMIT_TYPE', COUNT(*) FROM permit_type
UNION ALL SELECT 'DEPARTMENT', COUNT(*) FROM department
UNION ALL SELECT 'APPLICATION', COUNT(*) FROM application
UNION ALL SELECT 'REVIEW_STEP', COUNT(*) FROM review_step
UNION ALL SELECT 'ISSUED_LICENSE', COUNT(*) FROM issued_license
UNION ALL SELECT 'DOCUMENT', COUNT(*) FROM document;
```

**Expected Output:**
```
TABLE_NAME      RECORDS
--------------- -------
CITIZEN         200
PERMIT_TYPE     20
DEPARTMENT      26
APPLICATION     230
REVIEW_STEP     470+
ISSUED_LICENSE  60+
DOCUMENT        300+
```

---

## 📊 Data Summary

### Citizens (200 records)
- **IDs:** 1000-1199
- **Distribution:** 
  - Citizens: ~75%
  - Residents: ~15%
  - Foreigners: ~10%
- **Status:** 
  - Active: 196
  - Inactive: 2
  - Suspended: 2

### Permit Types (20 records)
- Business Operating License
- Construction Permit
- Food Handling License
- Professional Practice License
- Transport Operator License
- Environmental Permit
- Import/Export Licenses
- And 13 more...

### Departments (26 records)
**Original 12:**
- Business Registration (BRD)
- Construction & Urban Planning (CUP)
- Health & Safety (HSD)
- Environmental Protection (EPA)
- Transport Regulation (TRA)
- Trade & Commerce (TCD)
- Mining & Natural Resources (MNR)
- Public Security (PSS)
- Communications Regulatory (CRA)
- Tourism Development (TDB)
- Education Standards (ESA)
- Financial Services (FSD)

**Additional 5 (IDs 22-26):**
- Citizenship & Immigration (DCI)
- Passport & Identity Services (PIS)
- Border Control Agency (BCA)
- Refugee Affairs (RAD)
- Ministry of Interior (MOI)

### Applications (230 records)
**Status Distribution:**
- Approved: ~30% (60-70 records)
- Under Review: ~25% (50-60 records)
- Submitted: ~20% (40-50 records)
- Documentation Required: ~10%
- Rejected: ~10%
- Cancelled: ~5%

**Special Applications (10500-10529):**
- 30 specialized applications for new departments
- Citizenship applications
- Passport requests
- Visa applications
- Refugee cases

---

## 🔍 Key Verification Queries

### 1. Check All Tables and Constraints
```sql
-- Tables with record counts
SELECT 
    table_name,
    num_rows,
    tablespace_name,
    status
FROM user_tables
WHERE table_name IN (
    'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
    'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
)
ORDER BY table_name;
```

### 2. Verify Constraints
```sql
-- Constraint summary by type
SELECT 
    CASE constraint_type
        WHEN 'P' THEN 'Primary Key'
        WHEN 'R' THEN 'Foreign Key'
        WHEN 'U' THEN 'Unique'
        WHEN 'C' THEN 'Check'
    END AS constraint_type,
    COUNT(*) AS count
FROM user_constraints
WHERE table_name IN (
    'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
    'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
)
GROUP BY constraint_type
ORDER BY count DESC;
```

### 3. Check Foreign Key Relationships
```sql
SELECT 
    a.table_name AS from_table,
    a.constraint_name,
    b.table_name AS to_table,
    a.delete_rule
FROM user_constraints a
JOIN user_constraints b ON a.r_constraint_name = b.constraint_name
WHERE a.constraint_type = 'R'
ORDER BY a.table_name;
```

### 4. Sample Data with JOIN
```sql
-- Applications with citizen and permit details
SELECT 
    a.application_number,
    c.first_name || ' ' || c.last_name AS applicant,
    p.permit_name,
    a.status,
    a.payment_amount,
    a.submission_date
FROM application a
JOIN citizen c ON a.citizen_id = c.citizen_id
JOIN permit_type p ON a.permit_type_id = p.permit_type_id
WHERE ROWNUM <= 10
ORDER BY a.submission_date DESC;
```

### 5. Application Status Distribution
```sql
SELECT 
    status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM application
GROUP BY status
ORDER BY count DESC;
```

### 6. Review Steps by Department
```sql
SELECT 
    d.department_code,
    d.department_name,
    COUNT(r.step_id) AS total_reviews,
    SUM(CASE WHEN r.step_status = 'Completed' THEN 1 ELSE 0 END) AS completed
FROM department d
LEFT JOIN review_step r ON d.department_id = r.department_id
GROUP BY d.department_code, d.department_name
ORDER BY total_reviews DESC;
```

### 7. Licenses Issued
```sql
-- Issued licenses with expiration tracking
SELECT 
    l.license_number,
    a.application_number,
    c.first_name || ' ' || c.last_name AS licensee,
    l.license_status,
    TO_CHAR(l.issue_date, 'YYYY-MM-DD') AS issued,
    TO_CHAR(l.expiration_date, 'YYYY-MM-DD') AS expires,
    CASE 
        WHEN l.expiration_date < SYSDATE THEN 'EXPIRED'
        WHEN l.expiration_date < SYSDATE + 90 THEN 'EXPIRING SOON'
        ELSE 'VALID'
    END AS status_indicator
FROM issued_license l
JOIN application a ON l.application_id = a.application_id
JOIN citizen c ON a.citizen_id = c.citizen_id
ORDER BY l.issue_date DESC
FETCH FIRST 10 ROWS ONLY;
```

### 8. Documents per Application
```sql
SELECT 
    COUNT(DISTINCT application_id) AS apps_with_docs,
    COUNT(*) AS total_documents,
    ROUND(AVG(cnt), 2) AS avg_docs_per_app
FROM (
    SELECT application_id, COUNT(*) AS cnt
    FROM document
    GROUP BY application_id
);
```

---

## 📸 Required Screenshots

### Screenshot 1: Database Connection
**Command:**
```sql
SELECT 
    sys_context('USERENV', 'CON_NAME') AS pdb_name,
    sys_context('USERENV', 'CURRENT_USER') AS current_user,
    sys_context('USERENV', 'DB_NAME') AS database_name
FROM dual;
```
**Purpose:** Show successful connection to correct PDB

---

### Screenshot 2: All Tables Created
**Command:**
```sql
SELECT 
    table_name,
    tablespace_name,
    num_rows
FROM user_tables
ORDER BY table_name;
```
**Purpose:** Verify all 7 tables exist

---

### Screenshot 3: Record Counts
**Command:**
```sql
SELECT 
    'CITIZEN' AS table_name, COUNT(*) AS records FROM citizen
UNION ALL SELECT 'PERMIT_TYPE', COUNT(*) FROM permit_type
UNION ALL SELECT 'DEPARTMENT', COUNT(*) FROM department
UNION ALL SELECT 'APPLICATION', COUNT(*) FROM application
UNION ALL SELECT 'REVIEW_STEP', COUNT(*) FROM review_step
UNION ALL SELECT 'ISSUED_LICENSE', COUNT(*) FROM issued_license
UNION ALL SELECT 'DOCUMENT', COUNT(*) FROM document
ORDER BY table_name;
```
**Purpose:** Show data volume in each table

---

### Screenshot 4: Constraints Summary
**Command:**
```sql
SELECT 
    CASE constraint_type
        WHEN 'P' THEN 'Primary Key'
        WHEN 'R' THEN 'Foreign Key'
        WHEN 'U' THEN 'Unique'
        WHEN 'C' THEN 'Check'
    END AS constraint_type,
    COUNT(*) AS count
FROM user_constraints
WHERE table_name IN (
    'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
    'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
)
GROUP BY constraint_type
ORDER BY count DESC;
```
**Purpose:** Show all constraint types implemented

---

### Screenshot 5: Sample Data with JOIN
**Command:**
```sql
SELECT 
    a.application_number,
    c.first_name || ' ' || c.last_name AS applicant,
    p.permit_name,
    a.status,
    TO_CHAR(a.payment_amount, '999,999.99') AS amount
FROM application a
JOIN citizen c ON a.citizen_id = c.citizen_id
JOIN permit_type p ON a.permit_type_id = p.permit_type_id
WHERE ROWNUM <= 10
ORDER BY a.application_id;
```
**Purpose:** Demonstrate multi-table relationships

---

### Screenshot 6: Application Status Distribution
**Command:**
```sql
SELECT 
    status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) || '%' AS percentage
FROM application
GROUP BY status
ORDER BY count DESC;
```
**Purpose:** Show realistic data distribution

---

### Screenshot 7: Review Process Tracking
**Command:**
```sql
SELECT 
    d.department_code,
    d.department_name,
    COUNT(r.step_id) AS reviews
FROM department d
LEFT JOIN review_step r ON d.department_id = r.department_id
GROUP BY d.department_code, d.department_name
ORDER BY reviews DESC
FETCH FIRST 10 ROWS ONLY;
```
**Purpose:** Show workflow tracking across departments

---

### Screenshot 8: Indexes Created
**Command:**
```sql
SELECT 
    index_name,
    table_name,
    tablespace_name,
    uniqueness
FROM user_indexes
WHERE table_name IN (
    'CITIZEN', 'PERMIT_TYPE', 'DEPARTMENT', 'APPLICATION',
    'REVIEW_STEP', 'ISSUED_LICENSE', 'DOCUMENT'
)
ORDER BY table_name, index_name;
```
**Purpose:** Verify performance optimization

---

## 🎨 Data Characteristics

### Realistic Rwandan Context
- ✅ Actual Kigali locations (Kimihurura, Remera, Nyamirambo, etc.)
- ✅ Rwandan names (Mugabo, Uwase, Niyonzima, Mukamana)
- ✅ Valid phone numbers (+250788...)
- ✅ Proper residency classifications
- ✅ Government department structure

### Data Quality
- ✅ No duplicate emails or national IDs
- ✅ Valid date ranges (DOB before SYSDATE)
- ✅ Proper foreign key relationships
- ✅ Realistic status distributions
- ✅ Edge cases included (Inactive/Suspended citizens)

### Business Logic
- ✅ Only approved applications have licenses
- ✅ Review steps track workflow progression
- ✅ Multiple documents per application
- ✅ Payment tracking (Paid/Pending/Refunded)
- ✅ Priority levels (Urgent/High/Normal/Low)

---

## 🔧 Important Sequences

All sequences are properly configured:

```sql
-- Check current sequence values
SELECT 
    sequence_name,
    last_number AS current_value,
    increment_by,
    cache_size
FROM user_sequences
ORDER BY sequence_name;
```

**Sequences:**
1. `seq_citizen_id` - Current: 1200
2. `seq_permit_type_id` - Current: 120
3. `seq_department_id` - Current: 36
4. `seq_application_id` - Current: 10530+
5. `seq_review_step_id` - Current: varies
6. `seq_license_id` - Current: varies
7. `seq_document_id` - Current: varies

---

## 📈 Database Statistics

### Storage Summary
```sql
SELECT 
    'Total Tables' AS metric, 
    TO_CHAR(COUNT(*)) AS value 
FROM user_tables
UNION ALL
SELECT 'Total Indexes', TO_CHAR(COUNT(*)) FROM user_indexes
UNION ALL
SELECT 'Total Constraints', TO_CHAR(COUNT(*)) FROM user_constraints
UNION ALL
SELECT 'Total Sequences', TO_CHAR(COUNT(*)) FROM user_sequences
UNION ALL
SELECT 'Total Records', TO_CHAR(
    (SELECT COUNT(*) FROM citizen) +
    (SELECT COUNT(*) FROM permit_type) +
    (SELECT COUNT(*) FROM department) +
    (SELECT COUNT(*) FROM application) +
    (SELECT COUNT(*) FROM review_step) +
    (SELECT COUNT(*) FROM issued_license) +
    (SELECT COUNT(*) FROM document)
) FROM dual;
```

---

## ✅ Validation Checklist

Before proceeding to Phase VI, ensure:

- [x] All 7 tables created
- [x] 200 citizens inserted (IDs 1000-1199)
- [x] 20 permit types inserted
- [x] 26 departments inserted (including 5 new ones)
- [x] 230 applications inserted
- [x] 470+ review steps inserted
- [x] 60+ licenses issued (approved apps only)
- [x] 300+ documents uploaded
- [x] All foreign keys working
- [x] All constraints validated
- [x] All indexes created
- [x] Sequences properly configured
- [x] Screenshots taken
- [x] All committed to GitHub

---

## 🐛 Common Issues & Solutions

### Issue 1: Constraint Violations
**Problem:** Foreign key errors when inserting data

**Solution:**
```sql
-- Check if parent records exist
SELECT COUNT(*) FROM citizen WHERE citizen_id = 1000;
SELECT COUNT(*) FROM permit_type WHERE permit_type_id = 100;
```

### Issue 2: Sequence Out of Sync
**Problem:** Duplicate key errors

**Solution:**
```sql
-- Reset sequence to max ID + 1
DECLARE
  v_max_id NUMBER;
BEGIN
  SELECT MAX(citizen_id) INTO v_max_id FROM citizen;
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_citizen_id';
  EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_citizen_id START WITH ' || 
                    (v_max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;
/
```

### Issue 3: No Licenses for Approved Apps
**Problem:** Approved applications don't have licenses

**Solution:**
```sql
-- Check approved apps without licenses
SELECT a.application_id, a.application_number, a.status
FROM application a
LEFT JOIN issued_license l ON a.application_id = l.application_id
WHERE a.status = 'Approved' AND l.license_id IS NULL;

-- Re-run license insertion block if needed
```

---

## 📂 GitHub Structure

```
phase-5/
├── README.md                           (This file)
├── 01_create_tables.sql               (Table creation DDL)
├── 02_create_sequences.sql            (Sequence creation)
├── 03_insert_citizens.sql             (200 citizen records)
├── 04_insert_permit_types.sql         (20 permit types)
├── 05_insert_departments.sql          (26 departments)
├── 06_insert_applications.sql         (230 applications)
├── 07_insert_review_steps.sql         (470+ review steps)
├── 08_insert_licenses.sql             (60+ licenses)
├── 09_insert_documents.sql            (300+ documents)
├── 10_validation_queries.sql          (All verification queries)
├── screenshots/
│   ├── 01_connection.png
│   ├── 02_tables_created.png
│   ├── 03_record_counts.png
│   ├── 04_constraints.png
│   ├── 05_sample_join.png
│   ├── 06_status_distribution.png
│   ├── 07_review_process.png
│   └── 08_indexes.png
└── data_summary.md                    (Data distribution details)
```

---

## 🎓 Learning Outcomes Achieved

✅ **Database Design:** Normalized to 3NF with proper relationships  
✅ **Data Integrity:** Foreign keys, check constraints, unique constraints  
✅ **Performance:** Strategic indexing on frequently queried columns  
✅ **Realistic Data:** 1100+ records representing actual use cases  
✅ **SQL Proficiency:** Complex queries with JOINs, aggregations, subqueries  
✅ **Data Quality:** No orphan records, valid references throughout  
✅ **Business Logic:** Status tracking, workflow management, audit trails  

---

## ⏭️ Next Phase: Phase VI

**You are now ready for:**
- PL/SQL Procedures (3-5 minimum)
- PL/SQL Functions (3-5 minimum)
- Cursors and Bulk Operations
- Window Functions (ROW_NUMBER, RANK, LAG, LEAD)
- Package Development
- Exception Handling
- Transaction Management

---

## 📞 Support

**Lecturer:** Eric Maniraguha  
**Email:** eric.maniraguha@auca.ac.rw

---

**Status:** ✅ Phase V Complete  
**Total Records:** 1,100+  
**Tables:** 7 (fully normalized)  
**Data Quality:** Production-ready  
**Ready For:** Phase VI - PL/SQL Development  

**Prepared By:** NGABONZIZA Kim Gakuba (27670)  
**Completion Date:** December 2025

---

## 🌟 Project Highlights

> "This database represents a fully functional government permit management system with realistic Rwandan context, comprehensive data validation, and production-ready quality. All 230 applications tracked through complete workflows with proper audit trails."

**Key Metrics:**
- 200 unique citizens with diverse profiles
- 26 government departments (including specialized immigration/citizenship departments)
- 230 applications spanning 6 months
- 470+ review steps showing workflow progression
- 60+ issued licenses with proper validation
- 300+ supporting documents

**Innovation:** Special departments (DCI, PIS, BCA, RAD, MOI) added to support citizenship, passport, visa, and refugee applications, making this a comprehensive government services database.

---

*"Whatever you do, work at it with all your heart, as working for the Lord, not for human masters." — Colossians 3:23*
