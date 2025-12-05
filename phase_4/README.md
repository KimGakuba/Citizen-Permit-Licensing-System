# Phase IV: Database Creation - Setup Guide

**Student:** NGABONZIZA Kim Gakuba  
**ID:** 27670  
**Project:** Citizen Permit and Licensing System  
**Database Name:** thu_27670_kim_permit_db

---

## 📋 Database Configuration Summary

| Component | Value |
|-----------|-------|
| **PDB Name** | thu_27670_kim_permit_db |
| **Admin Username** | gakuba |
| **Admin Password** | Kim |
| **Data Tablespace** | permit_data (200MB, Auto-extend to 1GB) |
| **Index Tablespace** | permit_idx (100MB, Auto-extend to 500MB) |
| **Temp Tablespace** | permit_temp (50MB, Auto-extend to 200MB) |
| **Sequences** | 7 sequences created (starting from safe values) |

---

## 🚀 Quick Start Instructions

### Step 1: Connect to Oracle as SYSDBA

```bash
# Using SQL*Plus
sqlplus sys/oracle@localhost:1521/XEPDB1 as sysdba

# OR using SQL Developer
# Host: localhost
# Port: 1521
# SID/Service: XEPDB1
# Username: sys
# Password: oracle
# Role: SYSDBA
```

### Step 2: Run the Database Creation Script

```sql
CREATE PLUGGABLE DATABASE thu_27670_kim_permit_db
  ADMIN USER gakuba IDENTIFIED BY Kim
  ROLES = (DBA)
  DEFAULT TABLESPACE users
  DATAFILE 'C:\APP\KIM\PRODUCT\21C\ORADATA\XE\thu_27670_kim_permit_db\users01.dbf'
  SIZE 250M AUTOEXTEND ON
  FILE_NAME_CONVERT = (
    'C:\APP\KIM\PRODUCT\21C\ORADATA\XE\PDBSEED\',
    'C:\APP\KIM\PRODUCT\21C\ORADATA\XE\thu_27670_kim_permit_db\'
  );
```
![](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_4/creating%20pdb.png)

### Step 3: Verify PDB Creation

```sql
-- Check if PDB is created and open
SELECT name, open_mode FROM v$pdbs WHERE name = 'THU_27670_KIM_PERMIT_DB';

-- Expected output:
-- NAME                     OPEN_MODE
-- ----------------------  ----------
-- thu_27670_KIM_PERMIT_DB  READ WRITE
```
![](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_4/openning%20pdb.png)

### Step 4: Connect as Admin User

```sql
-- Disconnect from SYSDBA
DISCONNECT;

-- Connect as admin user
CONNECT gakuba/Kim@localhost:1521/thu_27670_kim_permit_db

-- Verify connection
SELECT sys_context('USERENV', 'CON_NAME') AS pdb_name,
       sys_context('USERENV', 'CURRENT_USER') AS current_user
FROM dual;
```

### Step 5: Verify Tablespaces

```sql
SELECT tablespace_name,status,content, extent_management FROM dba__tablespaces;
```
![](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_4/View%20All%20Tablespaces%20in%20Your%20PDB.png)

### Step 6: Verify Sequences

```sql
-- List all sequences
SELECT sequence_name, last_number, increment_by
FROM user_sequences
ORDER BY sequence_name;

-- Expected: 8 sequences
```
![](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_4/creating_sequence.png)

---

![](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_4/view_sequences.png)

---

---

## 🔐 Connection Strings Reference

### SQL*Plus Connection Strings

```bash
# As SYSDBA (for administration)
sqlplus sys/oracle@localhost:1521/wed_27670_kim_permit_db as sysdba

# As Admin User (for development)
sqlplus gakuba/kim@localhost:1521/thu_27670_kim_permit_db

# Quick connect as admin
sqlplus gakuba/kim@thu_27670_kim_permit_db
```

### SQL Developer Connection

```
Connection Name: thu_27670_kim_permit_db
Username: gakuba
Password: Kim
Hostname: localhost
Port: 1521
Service name: thu_27670_kim_permit_db
```

### JDBC Connection String

```java
String url = "jdbc:oracle:thin:@localhost:1521/thu_27670_kim_permit_db";
String user = "gakuba";
String password = "Kim";
```

### Python cx_Oracle Connection

```python
import cx_Oracle

dsn = cx_Oracle.makedsn("localhost", 1521, service_name="thu_27670_kim_permit_db")
connection = cx_Oracle.connect(user="gakuba", password="Kim", dsn=dsn)
```

---

---

## 🎯 Memory Configuration (Documentation)

These parameters are typically set at the CDB level:

```sql
-- System Global Area (SGA) - Shared memory
ALTER SYSTEM SET sga_target = 1G SCOPE=SPFILE;

-- Program Global Area (PGA) - Private memory per session
ALTER SYSTEM SET pga_aggregate_target = 500M SCOPE=SPFILE;

-- Database block size (cannot be changed after creation)
-- Default: 8KB (optimal for most applications)

-- Maximum processes
ALTER SYSTEM SET processes = 300 SCOPE=SPFILE;

-- Sessions
ALTER SYSTEM SET sessions = 472 SCOPE=SPFILE;
```

**Note:** These settings require database restart and should be done by a DBA.

---

## 📸 Required Screenshots

I took the following screenshots showing my project name visible:

1. **PDB Creation Success**
   ```sql
   SHOW PDBS;
   ```
   ![](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_4/openning%20pdb.png)

   ---

3. **Tablespace List**
   ```sql
   SELECT tablespace_name, block_size, status, extent_management,contents
   FROM dba_tablespaces;
   ```
![](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_4/View%20All%20Tablespaces%20in%20Your%20PDB.png)

---

3. **User Privileges**
   ```sql
   GRANT DBA TO gakuba;
   GRANT UNLIMITED TABLESPACE TO gakuba;
   ```
   ![](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_4/Grant%20additional%20privileges%20for%20admin%20user.png)

---

4. **Sequences Created**
   ```sql
   SELECT sequence_name, min_value, max_value, 
          increment_by, last_number, cache_size
   FROM user_sequences
   ORDER BY sequence_name;
   ```
   ---

5. **Successful Admin Connection**
   ```sql
   SELECT sys_context('USERENV', 'CON_NAME') AS pdb_name,
          sys_context('USERENV', 'CURRENT_USER') AS current_user,
          sys_context('USERENV', 'SESSION_USER') AS session_user,
          TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') AS connection_time
   FROM dual;
   ```
   ![](https://github.com/KimGakuba/Citizen-Permit-Licensing-System/blob/main/phase_4/connect%20to%20your%20PDB%20in%20SQL%20Developer.png)

---

## 🎓 Learning Objectives Achieved

After completing Phase IV, you have:

✅ Created an Oracle Pluggable Database (PDB)  
✅ Configured multiple tablespaces for data organization  
✅ Set up admin user with appropriate privileges  
✅ Created sequences for primary key generation  
✅ Configured autoextend and storage parameters  
✅ Prepared database for production-ready implementation  
✅ Documented all configuration decisions  
✅ Established connection methods and troubleshooting procedures

---

## ⏭️ Next Steps: Phase V

You are now ready to:
1. Create all 7 tables (CITIZEN, PERMIT_TYPE, APPLICATION, etc.)
2. Implement constraints (PK, FK, CHECK, UNIQUE)
3. Create indexes for performance optimization
4. Insert 100-500+ realistic test data rows
5. Validate data integrity

---


**Status:** ✅ Phase IV Complete - Ready for Phase V  
**Last Updated:** December 2025  
**Prepared By:** NGABONZIZA Kim Gakuba (27670)
