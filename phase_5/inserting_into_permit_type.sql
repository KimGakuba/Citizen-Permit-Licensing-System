SELECT COUNT(*) FROM permit_type;
SELECT MAX(permit_type_id) FROM permit_type;


INSERT ALL
  INTO permit_type VALUES (100, 'Business Operating License', 'Business', 'License to operate a commercial business establishment', 365, 50000, 15, 'Business Registration, Tax Clearance, ID Copy', 'Y', SYSDATE-100)
  INTO permit_type VALUES (101, 'Construction Permit', 'Construction', 'Permit for building construction or renovation', 730, 100000, 30, 'Site Plan, Building Plans, Land Title, Engineering Report', 'Y', SYSDATE-90)
  INTO permit_type VALUES (102, 'Food Handling License', 'Health', 'License for food service establishments', 365, 30000, 10, 'Health Certificate, Premises Inspection, Food Safety Training', 'Y', SYSDATE-80)
  INTO permit_type VALUES (103, 'Liquor License', 'Business', 'License to sell alcoholic beverages', 365, 200000, 20, 'Business License, Premises Plan, Police Clearance, Tax Clearance', 'Y', SYSDATE-70)
  INTO permit_type VALUES (104, 'Professional Practice License', 'Professional', 'License for professional service providers', 365, 75000, 15, 'Academic Certificates, Professional Registration, ID Copy', 'Y', SYSDATE-60)
  INTO permit_type VALUES (105, 'Transport Operator License', 'Transport', 'License for public transport operations', 730, 150000, 25, 'Vehicle Registration, Driver Licenses, Insurance, Safety Inspection', 'Y', SYSDATE-50)
  INTO permit_type VALUES (106, 'Environmental Permit', 'Environment', 'Permit for activities affecting environment', 1095, 300000, 45, 'Environmental Impact Assessment, Site Survey, Mitigation Plan', 'Y', SYSDATE-40)
  INTO permit_type VALUES (107, 'Event Permit', 'Events', 'Permit for public gatherings and events', 30, 20000, 5, 'Event Plan, Venue Approval, Security Plan, Insurance', 'Y', SYSDATE-30)
  INTO permit_type VALUES (108, 'Import License', 'Trade', 'License to import goods', 365, 100000, 15, 'Business Registration, Tax Clearance, Product Specifications', 'Y', SYSDATE-25)
  INTO permit_type VALUES (109, 'Export License', 'Trade', 'License to export goods', 365, 80000, 15, 'Business Registration, Tax Clearance, Quality Certificate', 'Y', SYSDATE-20)
  INTO permit_type VALUES (110, 'Pharmacy License', 'Health', 'License to operate a pharmacy', 730, 250000, 30, 'Pharmacist License, Premises Approval, Health Ministry Clearance', 'Y', SYSDATE-15)
  INTO permit_type VALUES (111, 'Mining License', 'Mining', 'License for mineral extraction', 1825, 500000, 60, 'Geological Survey, Environmental Impact, Land Rights, Safety Plan', 'Y', SYSDATE-10)
  INTO permit_type VALUES (112, 'Security Guard License', 'Security', 'License for private security services', 365, 60000, 12, 'Police Clearance, Training Certificate, Company Registration', 'Y', SYSDATE-5)
  INTO permit_type VALUES (113, 'Advertising Permit', 'Media', 'Permit for outdoor advertising', 180, 40000, 7, 'Advertisement Design, Location Approval, Tax Clearance', 'Y', SYSDATE-3)
  INTO permit_type VALUES (114, 'Telecommunications License', 'Technology', 'License for telecom service providers', 1825, 1000000, 90, 'Technical Plans, Financial Statements, Regulatory Compliance', 'Y', SYSDATE-2)
  INTO permit_type VALUES (115, 'Water Extraction Permit', 'Environment', 'Permit for water extraction activities', 365, 120000, 20, 'Hydrological Study, Environmental Assessment, Usage Plan', 'Y', SYSDATE-1)
  INTO permit_type VALUES (116, 'Tourism License', 'Tourism', 'License for tourism service providers', 730, 180000, 25, 'Business Plan, Safety Standards, Insurance, Facility Inspection', 'Y', SYSDATE)
  INTO permit_type VALUES (117, 'Waste Management License', 'Environment', 'License for waste disposal services', 1095, 350000, 40, 'Disposal Plan, Environmental Standards, Equipment Certification', 'Y', SYSDATE)
  INTO permit_type VALUES (118, 'Educational Institution License', 'Education', 'License to operate educational facility', 1095, 400000, 50, 'Curriculum Approval, Facility Standards, Staff Qualifications', 'Y', SYSDATE)
  INTO permit_type VALUES (119, 'Medical Facility License', 'Health', 'License to operate medical facility', 730, 500000, 45, 'Medical Staff Licenses, Equipment Standards, Health Ministry Approval', 'Y', SYSDATE)
SELECT * FROM dual;

PROMPT 20 PERMIT_TYPE records inserted
COMMIT;


-- Drop and recreate sequence
DROP SEQUENCE seq_permit_type_id;

-- Create sequence starting from max ID + 1
DECLARE
  v_max_id NUMBER;
BEGIN
  SELECT MAX(permit_type_id) INTO v_max_id FROM permit_type;
  EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_permit_type_id START WITH ' || (v_max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;
/



SELECT MAX(permit_type_id) FROM permit_type;


-- Check you have 20 records
SELECT COUNT(*) AS total_permit_types FROM permit_type;

-- Check ID range
SELECT MIN(permit_type_id) AS min_id, MAX(permit_type_id) AS max_id FROM permit_type;

-- List all permit types
SELECT permit_type_id, permit_name, category FROM permit_type ORDER BY permit_type_id;



-- Additional 10 Permit Types (IDs 120-129)
INSERT ALL
  INTO permit_type VALUES (120, 'Research Laboratory License', 'Science', 'License to operate scientific research laboratory', 1095, 600000, 60, 'Research Proposal, Safety Protocols, Equipment List, Staff Qualifications', 'Y', SYSDATE)
  INTO permit_type VALUES (121, 'Broadcasting License', 'Media', 'License for radio/TV broadcasting operations', 1825, 800000, 75, 'Technical Specifications, Programming Schedule, Regulatory Compliance', 'Y', SYSDATE)
  INTO permit_type VALUES (122, 'Data Center License', 'Technology', 'License to operate data processing center', 1825, 1200000, 90, 'Infrastructure Plan, Security Protocols, Disaster Recovery Plan', 'Y', SYSDATE)
  INTO permit_type VALUES (123, 'Renewable Energy License', 'Energy', 'License for renewable energy generation', 1825, 900000, 85, 'Environmental Impact, Technical Plans, Grid Connection Agreement', 'Y', SYSDATE)
  INTO permit_type VALUES (124, 'Warehouse License', 'Logistics', 'License for commercial storage facilities', 730, 300000, 30, 'Building Plans, Safety Standards, Fire Safety Certificate', 'Y', SYSDATE)
  INTO permit_type VALUES (125, 'Freight Forwarding License', 'Logistics', 'License for international freight services', 365, 400000, 25, 'Business Registration, Customs Clearance Certificate, Insurance', 'Y', SYSDATE)
  INTO permit_type VALUES (126, 'Financial Advisory License', 'Finance', 'License for financial consulting services', 365, 350000, 20, 'Professional Certifications, Compliance Record, Financial Statements', 'Y', SYSDATE)
  INTO permit_type VALUES (127, 'Real Estate Broker License', 'Real Estate', 'License for property brokerage services', 365, 250000, 15, 'Professional Training, Background Check, Insurance Bond', 'Y', SYSDATE)
  INTO permit_type VALUES (128, 'Agricultural Export License', 'Agriculture', 'License to export agricultural products', 365, 200000, 20, 'Farm Registration, Quality Standards, Phytosanitary Certificate', 'Y', SYSDATE)
  INTO permit_type VALUES (129, 'Cultural Heritage License', 'Culture', 'License for cultural heritage activities', 1095, 150000, 45, 'Heritage Assessment, Conservation Plan, Community Approval', 'Y', SYSDATE)
SELECT * FROM dual;
COMMIT;



-- Fix permit_type sequence
DROP SEQUENCE seq_permit_type_id;
CREATE SEQUENCE seq_permit_type_id START WITH 130 INCREMENT BY 1 NOCACHE NOCYCLE;



-- Add CITIZENSHIP permit type (ID 130)
INSERT INTO permit_type VALUES (
  130,
  'Citizenship Application',
  'Citizenship',
  'Application for citizenship and naturalization process',
  3650, -- 10 years validity
  100000,
  180, -- 6 months processing time
  'Birth Certificate, Background Check, Residency Proof, Language Test, Civic Knowledge Test',
  'Y',
  SYSDATE
);
COMMIT;




-- Update sequence for future inserts
DROP SEQUENCE seq_permit_type_id;
CREATE SEQUENCE seq_permit_type_id START WITH 131 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Verification
SELECT permit_type_id, permit_name, category, validity_period, processing_fee, estimated_days
FROM permit_type 
WHERE permit_name LIKE '%Citizenship%' 
ORDER BY permit_type_id;



-- Optional: Additional citizenship-related permit types
INSERT ALL
  INTO permit_type VALUES (131, 'Permanent Residency Permit', 'Immigration', 'Permanent residency status application', 1825, 75000, 120, 'Employment Proof, Background Check, Residency History, Health Certificate', 'Y', SYSDATE)
  INTO permit_type VALUES (132, 'Work Permit', 'Immigration', 'Authorization to work in the country', 365, 50000, 30, 'Job Offer, Employer Registration, Qualifications, Police Clearance', 'Y', SYSDATE)
  INTO permit_type VALUES (133, 'Student Visa', 'Education', 'Study permit for educational institutions', 365, 30000, 21, 'University Acceptance, Financial Proof, Accommodation Proof, Health Insurance', 'Y', SYSDATE)
  INTO permit_type VALUES (134, 'Diplomatic Visa', 'Government', 'Visa for diplomatic personnel', 1095, 0, 14, 'Diplomatic Note, Government Appointment, Official Documentation', 'Y', SYSDATE)
SELECT * FROM dual;
COMMIT;

-- Update sequence again if adding more
DROP SEQUENCE seq_permit_type_id;
CREATE SEQUENCE seq_permit_type_id START WITH 135 INCREMENT BY 1 NOCACHE NOCYCLE;




-- Check all permit types count
SELECT COUNT(*) AS total_permit_types FROM permit_type;

-- List all citizenship/immigration related permits
SELECT permit_type_id, permit_name, category, validity_period, processing_fee
FROM permit_type 
WHERE category IN ('Citizenship', 'Immigration', 'Education', 'Government')
ORDER BY permit_type_id;

-- Check ID range
SELECT MIN(permit_type_id) AS min_id, MAX(permit_type_id) AS max_id FROM permit_type;