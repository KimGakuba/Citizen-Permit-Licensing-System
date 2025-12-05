-- Use explicit IDs for department (10-21)
INSERT ALL
  INTO department VALUES (10, 'Business Registration Department', 'BRD', 'Handles business licensing and registration', 'Jean Paul Mugabo', 'brd@gov.rw', 'Y')
  INTO department VALUES (11, 'Construction and Urban Planning', 'CUP', 'Oversees construction permits and urban development', 'Marie Claire Uwase', 'cup@gov.rw', 'Y')
  INTO department VALUES (12, 'Health and Safety Department', 'HSD', 'Reviews health-related licenses and permits', 'Dr. Patrick Niyonzima', 'hsd@gov.rw', 'Y')
  INTO department VALUES (13, 'Environmental Protection Agency', 'EPA', 'Evaluates environmental impact and compliance', 'Grace Mukamana', 'epa@gov.rw', 'Y')
  INTO department VALUES (14, 'Transport Regulation Authority', 'TRA', 'Regulates transport and logistics operations', 'David Habimana', 'tra@gov.rw', 'Y')
  INTO department VALUES (15, 'Trade and Commerce Department', 'TCD', 'Manages import/export licenses and trade', 'Christine Ingabire', 'tcd@gov.rw', 'Y')
  INTO department VALUES (16, 'Mining and Natural Resources', 'MNR', 'Oversees mining licenses and resource extraction', 'Emmanuel Bizimana', 'mnr@gov.rw', 'Y')
  INTO department VALUES (17, 'Public Security Services', 'PSS', 'Reviews security-related licenses', 'Sarah Mukamazimpaka', 'pss@gov.rw', 'Y')
  INTO department VALUES (18, 'Communications Regulatory', 'CRA', 'Regulates telecommunications and media', 'Joseph Hakizimana', 'cra@gov.rw', 'Y')
  INTO department VALUES (19, 'Tourism Development Board', 'TDB', 'Manages tourism licenses and development', 'Claudine Nyirahabimana', 'tdb@gov.rw', 'Y')
  INTO department VALUES (20, 'Education Standards Authority', 'ESA', 'Reviews educational facility licenses', 'Eric Maniraguha', 'esa@gov.rw', 'Y')
  INTO department VALUES (21, 'Financial Services Department', 'FSD', 'Reviews financial compliance and payments', 'Jacqueline Umutoni', 'fsd@gov.rw', 'Y')
SELECT * FROM dual;

PROMPT 12 DEPARTMENT records inserted
COMMIT;



-- Drop and recreate sequence starting from 22
DROP SEQUENCE seq_department_id;
CREATE SEQUENCE seq_department_id START WITH 22 INCREMENT BY 1 NOCACHE NOCYCLE;



-- Check department count
SELECT COUNT(*) AS total_departments FROM department;

-- Check ID range
SELECT MIN(department_id) AS min_id, MAX(department_id) AS max_id FROM department;

-- List all departments
SELECT department_id, department_name, department_code FROM department ORDER BY department_id;





-- Add Department of Citizenship and Immigration (ID 22)
INSERT INTO department VALUES (
  22,
  'Department of Citizenship and Immigration',
  'DCI',
  'Handles citizenship applications, naturalization, and immigration services',
  'Dr. Samuel Nzabonimana',
  'dci@gov.rw',
  'Y'
);
COMMIT;

-- Update sequence for future inserts
DROP SEQUENCE seq_department_id;
CREATE SEQUENCE seq_department_id START WITH 23 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Verification
SELECT department_id, department_name, department_code, description 
FROM department 
WHERE department_name LIKE '%Citizenship%' OR department_name LIKE '%Immigration%';




-- Optional: Additional government departments
INSERT ALL
  INTO department VALUES (23, 'Passport and Identity Services', 'PIS', 'Issues national passports and identity documents', 'Angelique Mukamana', 'pis@gov.rw', 'Y')
  INTO department VALUES (24, 'Border Control Agency', 'BCA', 'Manages border security and customs', 'Major Frank Habimana', 'bca@gov.rw', 'Y')
  INTO department VALUES (25, 'Refugee Affairs Department', 'RAD', 'Handles refugee registration and assistance', 'Marie Uwimana', 'rad@gov.rw', 'Y')
SELECT * FROM dual;
COMMIT;

-- Update sequence again if adding more
DROP SEQUENCE seq_department_id;
CREATE SEQUENCE seq_department_id START WITH 26 INCREMENT BY 1 NOCACHE NOCYCLE;



-- Check total departments
SELECT COUNT(*) AS total_departments FROM department;

-- List all departments sorted
SELECT department_id, department_code, department_name, head_officer
FROM department
ORDER BY department_id;

-- See which departments handle which permit types (if you have this mapping)
-- You might want to create a DEPARTMENT_PERMIT_TYPE mapping table in the future

-- Check the new department
SELECT * FROM department WHERE department_id = 26;



-- Optional: Ministry-level department
INSERT INTO department VALUES (
  26,
  'Ministry of Interior',
  'MOI',
  'Oversees all internal affairs including citizenship, immigration, and security',
  'Hon. Jean de Dieu Uwihanganye',
  'moi@gov.rw',
  'Y'
);
COMMIT;