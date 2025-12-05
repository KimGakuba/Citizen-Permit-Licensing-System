-- 30 Additional Applications for new departments (DCI, PIS, BCA, RAD, MOI)
-- Using explicit IDs starting from 10500
INSERT ALL
  -- Department of Citizenship and Immigration (DCI) - Citizenship Applications
  INTO application VALUES (10500, 1100, 130, 'APP-2024-CIT-001', DATE '2024-06-01', 'Under Review', 'High', 'Paid', 100000, 'Citizenship by naturalization - stage 1', SYSDATE-60, 1001, DATE '2024-11-01')
  INTO application VALUES (10501, 1105, 130, 'APP-2024-CIT-002', DATE '2024-06-05', 'Documentation Required', 'Normal', 'Paid', 100000, 'Missing language test certificate', SYSDATE-56, 1002, DATE '2024-12-05')
  INTO application VALUES (10502, 1110, 130, 'APP-2024-CIT-003', DATE '2024-06-10', 'Approved', 'Urgent', 'Paid', 100000, 'Expedited processing - diplomatic spouse', SYSDATE-51, 1003, DATE '2024-08-10')
  INTO application VALUES (10503, 1115, 130, 'APP-2024-CIT-004', DATE '2024-06-15', 'Under Review', 'Normal', 'Paid', 100000, 'Standard citizenship application', SYSDATE-46, 1004, DATE '2024-12-15')
  INTO application VALUES (10504, 1120, 130, 'APP-2024-CIT-005', DATE '2024-06-20', 'Rejected', 'Normal', 'Paid', 100000, 'Failed background check', SYSDATE-41, NULL, NULL)
  
  -- Passport and Identity Services (PIS) - Passport Applications
  INTO application VALUES (10505, 1125, 131, 'APP-2024-PAS-001', DATE '2024-06-25', 'Approved', 'Normal', 'Paid', 50000, 'First time passport application', SYSDATE-36, 1005, DATE '2024-07-25')
  INTO application VALUES (10506, 1130, 131, 'APP-2024-PAS-002', DATE '2024-06-28', 'Under Review', 'High', 'Paid', 50000, 'Lost passport replacement - urgent travel', SYSDATE-33, 1006, DATE '2024-07-15')
  INTO application VALUES (10507, 1135, 131, 'APP-2024-PAS-003', DATE '2024-07-01', 'Approved', 'Normal', 'Paid', 50000, 'Passport renewal - standard', SYSDATE-30, 1007, DATE '2024-07-20')
  INTO application VALUES (10508, 1140, 131, 'APP-2024-PAS-004', DATE '2024-07-05', 'Submitted', 'Normal', 'Pending', 50000, 'Child passport application', SYSDATE-26, NULL, DATE '2024-08-05')
  INTO application VALUES (10509, 1145, 131, 'APP-2024-PAS-005', DATE '2024-07-10', 'Under Review', 'Normal', 'Paid', 50000, 'Damaged passport replacement', SYSDATE-21, 1008, DATE '2024-08-10')
  
  -- Border Control Agency (BCA) - Border/Visas
  INTO application VALUES (10510, 1150, 132, 'APP-2024-VIS-001', DATE '2024-07-15', 'Approved', 'Normal', 'Paid', 30000, 'Tourist visa extension', SYSDATE-16, 1009, DATE '2024-07-25')
  INTO application VALUES (10511, 1155, 132, 'APP-2024-VIS-002', DATE '2024-07-18', 'Under Review', 'High', 'Paid', 30000, 'Business visa - investment case', SYSDATE-13, 1010, DATE '2024-08-18')
  INTO application VALUES (10512, 1160, 133, 'APP-2024-STU-001', DATE '2024-07-20', 'Approved', 'Normal', 'Paid', 25000, 'Student visa - university admission', SYSDATE-11, 1001, DATE '2024-08-10')
  INTO application VALUES (10513, 1165, 132, 'APP-2024-VIS-003', DATE '2024-07-22', 'Rejected', 'Normal', 'Paid', 30000, 'Insufficient financial proof', SYSDATE-9, NULL, NULL)
  INTO application VALUES (10514, 1170, 132, 'APP-2024-VIS-004', DATE '2024-07-25', 'Under Review', 'Urgent', 'Paid', 30000, 'Medical visa - emergency treatment', SYSDATE-6, 1002, DATE '2024-08-01')
  
  -- Refugee Affairs Department (RAD)
  INTO application VALUES (10515, 1175, 134, 'APP-2024-REF-001', DATE '2024-07-28', 'Approved', 'High', 'Paid', 0, 'Refugee status application - conflict zone', SYSDATE-3, 1003, DATE '2024-08-10')
  INTO application VALUES (10516, 1180, 134, 'APP-2024-REF-002', DATE '2024-08-01', 'Under Review', 'Normal', 'Paid', 0, 'Asylum application - political persecution', SYSDATE, 1004, DATE '2024-10-01')
  INTO application VALUES (10517, 1185, 134, 'APP-2024-REF-003', DATE '2024-08-03', 'Documentation Required', 'Normal', 'Paid', 0, 'Missing UNHCR documentation', SYSDATE, 1005, DATE '2024-11-03')
  INTO application VALUES (10518, 1190, 134, 'APP-2024-REF-004', DATE '2024-08-05', 'Approved', 'Urgent', 'Paid', 0, 'Family reunification - urgent humanitarian', SYSDATE, 1006, DATE '2024-09-05')
  INTO application VALUES (10519, 1195, 134, 'APP-2024-REF-005', DATE '2024-08-08', 'Under Review', 'Normal', 'Paid', 0, 'Refugee resettlement application', SYSDATE, 1007, DATE '2024-11-08')
  
  -- Ministry of Interior (MOI) - Special Cases
  INTO application VALUES (10520, 1199, 130, 'APP-2024-MOI-001', DATE '2024-08-10', 'Under Review', 'High', 'Paid', 100000, 'Special citizenship - exceptional contributions', SYSDATE, 1008, DATE '2024-12-10')
  INTO application VALUES (10521, 1101, 131, 'APP-2024-MOI-002', DATE '2024-08-12', 'Approved', 'Urgent', 'Paid', 50000, 'Diplomatic passport - government official', SYSDATE, 1009, DATE '2024-08-20')
  INTO application VALUES (10522, 1106, 132, 'APP-2024-MOI-003', DATE '2024-08-15', 'Under Review', 'High', 'Paid', 30000, 'Special work visa - critical infrastructure', SYSDATE, 1010, DATE '2024-09-15')
  INTO application VALUES (10523, 1111, 133, 'APP-2024-MOI-004', DATE '2024-08-18', 'Approved', 'Normal', 'Paid', 25000, 'Government scholarship student visa', SYSDATE, 1001, DATE '2024-09-10')
  INTO application VALUES (10524, 1116, 134, 'APP-2024-MOI-005', DATE '2024-08-20', 'Under Review', 'High', 'Paid', 0, 'High-profile refugee case - ministry review', SYSDATE, 1002, DATE '2024-10-20')
  
  -- Mixed applications for comprehensive testing
  INTO application VALUES (10525, 1121, 130, 'APP-2024-CIT-006', DATE '2024-08-22', 'Submitted', 'Normal', 'Paid', 100000, 'Marriage-based citizenship application', SYSDATE, 1003, DATE '2025-02-22')
  INTO application VALUES (10526, 1126, 131, 'APP-2024-PAS-006', DATE '2024-08-25', 'Under Review', 'Normal', 'Paid', 50000, 'Name change passport update', SYSDATE, 1004, DATE '2024-09-25')
  INTO application VALUES (10527, 1131, 132, 'APP-2024-VIS-005', DATE '2024-08-28', 'Approved', 'Normal', 'Paid', 30000, 'Artist visa - cultural exchange', SYSDATE, 1005, DATE '2024-09-15')
  INTO application VALUES (10528, 1136, 133, 'APP-2024-STU-002', DATE '2024-09-01', 'Under Review', 'Normal', 'Paid', 25000, 'PhD student visa - research grant', SYSDATE, 1006, DATE '2024-09-25')
  INTO application VALUES (10529, 1141, 134, 'APP-2024-REF-006', DATE '2024-09-03', 'Approved', 'Normal', 'Paid', 0, 'Refugee travel document application', SYSDATE, 1007, DATE '2024-09-20')
SELECT * FROM dual;
COMMIT;



INSERT ALL
  INTO application VALUES (1, 1000, 100, 'APP-2024-000001', DATE '2024-01-15', 'Approved', 'Normal', 'Paid', 50000, NULL, DATE '2024-01-15', 1001, DATE '2024-02-15')
  INTO application VALUES (2, 1001, 101, 'APP-2024-000002', DATE '2024-01-18', 'Under Review', 'High', 'Paid', 100000, 'Pending site inspection', DATE '2024-01-18', 1002, DATE '2024-03-18')
  INTO application VALUES (3, 1002, 102, 'APP-2024-000003', DATE '2024-01-20', 'Approved', 'Normal', 'Paid', 30000, NULL, DATE '2024-01-20', 1003, DATE '2024-02-10')
  INTO application VALUES (4, 1003, 103, 'APP-2024-000004', DATE '2024-01-22', 'Under Review', 'Urgent', 'Paid', 200000, 'Police clearance pending', DATE '2024-01-22', 1004, DATE '2024-02-22')
  INTO application VALUES (5, 1004, 104, 'APP-2024-000005', DATE '2024-01-25', 'Approved', 'Normal', 'Paid', 75000, NULL, DATE '2024-01-25', 1005, DATE '2024-02-25')
  INTO application VALUES (6, 1005, 105, 'APP-2024-000006', DATE '2024-01-28', 'Documentation Required', 'High', 'Paid', 150000, 'Missing insurance documents', DATE '2024-01-28', 1006, DATE '2024-03-10')
  INTO application VALUES (7, 1006, 106, 'APP-2024-000007', DATE '2024-02-01', 'Under Review', 'Normal', 'Paid', 300000, 'Environmental assessment in progress', DATE '2024-02-01', 1007, DATE '2024-04-01')
  INTO application VALUES (8, 1007, 107, 'APP-2024-000008', DATE '2024-02-03', 'Approved', 'Low', 'Paid', 20000, NULL, DATE '2024-02-03', 1008, DATE '2024-02-13')
  INTO application VALUES (9, 1008, 108, 'APP-2024-000009', DATE '2024-02-05', 'Approved', 'Normal', 'Paid', 100000, NULL, DATE '2024-02-05', 1009, DATE '2024-02-25')
  INTO application VALUES (10, 1009, 109, 'APP-2024-000010', DATE '2024-02-07', 'Under Review', 'Normal', 'Paid', 80000, NULL, DATE '2024-02-07', 1010, DATE '2024-02-27')
  INTO application VALUES (11, 1010, 110, 'APP-2024-000011', DATE '2024-02-10', 'Approved', 'High', 'Paid', 250000, NULL, DATE '2024-02-10', 1001, DATE '2024-03-20')
  INTO application VALUES (12, 1011, 111, 'APP-2024-000012', DATE '2024-02-12', 'Under Review', 'Normal', 'Paid', 500000, 'Geological survey pending', DATE '2024-02-12', 1002, DATE '2024-05-12')
  INTO application VALUES (13, 1012, 112, 'APP-2024-000013', DATE '2024-02-15', 'Approved', 'Normal', 'Paid', 60000, NULL, DATE '2024-02-15', 1003, DATE '2024-03-05')
  INTO application VALUES (14, 1013, 113, 'APP-2024-000014', DATE '2024-02-17', 'Approved', 'Low', 'Paid', 40000, NULL, DATE '2024-02-17', 1004, DATE '2024-02-27')
  INTO application VALUES (15, 1014, 114, 'APP-2024-000015', DATE '2024-02-20', 'Under Review', 'Urgent', 'Paid', 1000000, 'Technical review in progress', DATE '2024-02-20', 1005, DATE '2024-06-20')
  INTO application VALUES (16, 1015, 115, 'APP-2024-000016', DATE '2024-02-22', 'Approved', 'Normal', 'Paid', 120000, NULL, DATE '2024-02-22', 1006, DATE '2024-03-22')
  INTO application VALUES (17, 1016, 116, 'APP-2024-000017', DATE '2024-02-25', 'Under Review', 'High', 'Paid', 180000, NULL, DATE '2024-02-25', 1007, DATE '2024-04-05')
  INTO application VALUES (18, 1017, 117, 'APP-2024-000018', DATE '2024-02-28', 'Approved', 'Normal', 'Paid', 350000, NULL, DATE '2024-02-28', 1008, DATE '2024-04-28')
  INTO application VALUES (19, 1018, 118, 'APP-2024-000019', DATE '2024-03-01', 'Under Review', 'Normal', 'Paid', 400000, 'Curriculum review pending', DATE '2024-03-01', 1009, DATE '2024-05-15')
  INTO application VALUES (20, 1019, 119, 'APP-2024-000020', DATE '2024-03-03', 'Approved', 'High', 'Paid', 500000, NULL, DATE '2024-03-03', 1010, DATE '2024-04-20')
  INTO application VALUES (21, 1020, 100, 'APP-2024-000021', DATE '2024-03-05', 'Rejected', 'Normal', 'Paid', 50000, 'Incomplete documentation', DATE '2024-03-05', 1001, NULL)
  INTO application VALUES (22, 1021, 101, 'APP-2024-000022', DATE '2024-03-07', 'Approved', 'Normal', 'Paid', 100000, NULL, DATE '2024-03-07', 1002, DATE '2024-04-07')
  INTO application VALUES (23, 1022, 102, 'APP-2024-000023', DATE '2024-03-10', 'Under Review', 'Low', 'Paid', 30000, NULL, DATE '2024-03-10', 1003, DATE '2024-03-25')
  INTO application VALUES (24, 1023, 103, 'APP-2024-000024', DATE '2024-03-12', 'Approved', 'Urgent', 'Paid', 200000, NULL, DATE '2024-03-12', 1004, DATE '2024-04-12')
  INTO application VALUES (25, 1024, 104, 'APP-2024-000025', DATE '2024-03-15', 'Under Review', 'Normal', 'Paid', 75000, NULL, DATE '2024-03-15', 1005, DATE '2024-04-01')
  INTO application VALUES (26, 1025, 105, 'APP-2024-000026', DATE '2024-03-17', 'Approved', 'Normal', 'Paid', 150000, NULL, DATE '2024-03-17', 1006, DATE '2024-04-17')
  INTO application VALUES (27, 1026, 106, 'APP-2024-000027', DATE '2024-03-20', 'Cancelled', 'Normal', 'Refunded', 300000, 'Applicant request', DATE '2024-03-20', NULL, NULL)
  INTO application VALUES (28, 1027, 107, 'APP-2024-000028', DATE '2024-03-22', 'Approved', 'Low', 'Paid', 20000, NULL, DATE '2024-03-22', 1008, DATE '2024-04-05')
  INTO application VALUES (29, 1028, 108, 'APP-2024-000029', DATE '2024-03-25', 'Under Review', 'Normal', 'Paid', 100000, NULL, DATE '2024-03-25', 1009, DATE '2024-04-15')
  INTO application VALUES (30, 1029, 109, 'APP-2024-000030', DATE '2024-03-27', 'Approved', 'Normal', 'Paid', 80000, NULL, DATE '2024-03-27', 1010, DATE '2024-04-17')
  INTO application VALUES (31, 1030, 110, 'APP-2024-000031', DATE '2024-03-30', 'Under Review', 'High', 'Paid', 250000, NULL, DATE '2024-03-30', 1001, DATE '2024-05-10')
  INTO application VALUES (32, 1031, 111, 'APP-2024-000032', DATE '2024-04-01', 'Documentation Required', 'Normal', 'Paid', 500000, 'Additional environmental docs needed', DATE '2024-04-01', 1002, DATE '2024-06-15')
  INTO application VALUES (33, 1032, 112, 'APP-2024-000033', DATE '2024-04-03', 'Approved', 'Normal', 'Paid', 60000, NULL, DATE '2024-04-03', 1003, DATE '2024-04-18')
  INTO application VALUES (34, 1033, 113, 'APP-2024-000034', DATE '2024-04-05', 'Approved', 'Low', 'Paid', 40000, NULL, DATE '2024-04-05', 1004, DATE '2024-04-15')
  INTO application VALUES (35, 1034, 114, 'APP-2024-000035', DATE '2024-04-07', 'Under Review', 'Urgent', 'Paid', 1000000, NULL, DATE '2024-04-07', 1005, DATE '2024-07-07')
  INTO application VALUES (36, 1035, 115, 'APP-2024-000036', DATE '2024-04-10', 'Approved', 'Normal', 'Paid', 120000, NULL, DATE '2024-04-10', 1006, DATE '2024-05-10')
  INTO application VALUES (37, 1036, 116, 'APP-2024-000037', DATE '2024-04-12', 'Under Review', 'High', 'Paid', 180000, NULL, DATE '2024-04-12', 1007, DATE '2024-05-20')
  INTO application VALUES (38, 1037, 117, 'APP-2024-000038', DATE '2024-04-15', 'Submitted', 'Normal', 'Paid', 350000, NULL, DATE '2024-04-15', 1008, DATE '2024-06-15')
  INTO application VALUES (39, 1038, 118, 'APP-2024-000039', DATE '2024-04-17', 'Submitted', 'Normal', 'Pending', 400000, 'Payment verification needed', DATE '2024-04-17', NULL, DATE '2024-06-30')
  INTO application VALUES (40, 1039, 119, 'APP-2024-000040', DATE '2024-04-20', 'Submitted', 'High', 'Pending', 500000, NULL, DATE '2024-04-20', NULL, DATE '2024-06-10')
  INTO application VALUES (41, 1040, 100, 'APP-2024-000041', DATE '2024-04-22', 'Submitted', 'Normal', 'Paid', 50000, NULL, DATE '2024-04-22', 1001, DATE '2024-05-12')
  INTO application VALUES (42, 1041, 101, 'APP-2024-000042', DATE '2024-04-25', 'Submitted', 'Normal', 'Paid', 100000, NULL, DATE '2024-04-25', 1002, DATE '2024-05-28')
  INTO application VALUES (43, 1042, 102, 'APP-2024-000043', DATE '2024-04-27', 'Submitted', 'Low', 'Paid', 30000, NULL, DATE '2024-04-27', 1003, DATE '2024-05-12')
  INTO application VALUES (44, 1043, 103, 'APP-2024-000044', DATE '2024-04-30', 'Submitted', 'Urgent', 'Paid', 200000, NULL, DATE '2024-04-30', 1004, DATE '2024-05-25')
  INTO application VALUES (45, 1044, 104, 'APP-2024-000045', DATE '2024-05-02', 'Submitted', 'Normal', 'Paid', 75000, NULL, DATE '2024-05-02', 1005, DATE '2024-05-20')
  INTO application VALUES (46, 1045, 105, 'APP-2024-000046', DATE '2024-05-05', 'Submitted', 'Normal', 'Paid', 150000, NULL, DATE '2024-05-05', 1006, DATE '2024-06-05')
  INTO application VALUES (47, 1046, 106, 'APP-2024-000047', DATE '2024-05-07', 'Submitted', 'Normal', 'Pending', 300000, NULL, DATE '2024-05-07', NULL, DATE '2024-06-20')
  INTO application VALUES (48, 1047, 107, 'APP-2024-000048', DATE '2024-05-10', 'Submitted', 'Low', 'Paid', 20000, NULL, DATE '2024-05-10', 1008, DATE '2024-05-20')
  INTO application VALUES (49, 1048, 108, 'APP-2024-000049', DATE '2024-05-12', 'Submitted', 'Normal', 'Paid', 100000, NULL, DATE '2024-05-12', 1009, DATE '2024-05-30')
  INTO application VALUES (50, 1049, 109, 'APP-2024-000050', DATE '2024-05-15', 'Submitted', 'Normal', 'Paid', 80000, NULL, DATE '2024-05-15', 1010, DATE '2024-06-05')
SELECT * FROM dual;








DECLARE
  v_app_num NUMBER := 51;
  v_citizen_id NUMBER;
  v_permit_id NUMBER;
  v_status VARCHAR2(30);
  v_priority VARCHAR2(20);
  v_payment_status VARCHAR2(20);
  v_submission_date DATE;
  v_processing_fee NUMBER;
  v_estimated_days NUMBER;
  v_application_date DATE;  -- Added this variable
BEGIN
  FOR i IN 1..150 LOOP
    v_app_num := 50 + i;
    v_citizen_id := 1000 + MOD(i - 1, 50);  -- Corrected to cycle properly from 1000-1049
    v_permit_id := 100 + MOD(i - 1, 20);    -- Corrected to cycle properly from 100-119

    -- Vary status distribution
    CASE MOD(i, 10)
      WHEN 0 THEN
        v_status := 'Approved';
        v_payment_status := 'Paid';
      WHEN 1 THEN
        v_status := 'Rejected';
        v_payment_status := 'Paid';
      WHEN 2 THEN
        v_status := 'Cancelled';
        v_payment_status := 'Refunded';
      WHEN 3 THEN
        v_status := 'Under Review';
        v_payment_status := 'Paid';
      WHEN 4 THEN
        v_status := 'Under Review';
        v_payment_status := 'Paid';
      WHEN 5 THEN
        v_status := 'Under Review';
        v_payment_status := 'Paid';
      WHEN 6 THEN
        v_status := 'Documentation Required';
        v_payment_status := 'Paid';
      WHEN 7 THEN
        v_status := 'Documentation Required';
        v_payment_status := 'Paid';
      ELSE
        v_status := 'Submitted';
        v_payment_status := CASE WHEN MOD(i, 5) = 0 THEN 'Pending' ELSE 'Paid' END;
    END CASE;

    -- Vary priority - using CASE for clarity
    CASE
      WHEN MOD(i, 15) = 0 THEN
        v_priority := 'Urgent';
      WHEN MOD(i, 7) = 0 THEN
        v_priority := 'High';
      WHEN MOD(i, 11) = 0 THEN
        v_priority := 'Low';
      ELSE
        v_priority := 'Normal';
    END CASE;

    -- Get permit type details once to avoid multiple queries
    BEGIN
      SELECT processing_fee, estimated_days 
      INTO v_processing_fee, v_estimated_days
      FROM permit_type 
      WHERE permit_type_id = v_permit_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Default values if permit type not found
        v_processing_fee := 50000;
        v_estimated_days := 30;
    END;

    -- Calculate application date (spread over last 150 days)
    v_application_date := TRUNC(SYSDATE) - (150 - i);

    -- Insert the application - Using correct column order from your original INSERT
    INSERT INTO application (
      application_id, 
      citizen_id, 
      permit_type_id, 
      application_number,
      submission_date,  -- Based on your original INSERT, this is the application date
      status, 
      priority_level, 
      payment_status,
      payment_amount, 
      notes,
      last_updated,  -- This is the timestamp column from your original INSERT
      assigned_officer_id, 
      estimated_completion
    ) VALUES (
      seq_application_id.NEXTVAL,
      v_citizen_id,
      v_permit_id,
      'APP-2024-' || LPAD(v_app_num, 6, '0'),
      v_application_date,  -- This is the application submission date
      v_status,
      v_priority,
      v_payment_status,
      v_processing_fee,
      NULL,  -- notes column
      SYSDATE,  -- last_updated (timestamp of when record was inserted)
      CASE 
        WHEN v_payment_status = 'Paid' AND v_status NOT IN ('Cancelled', 'Rejected') 
        THEN 1001 + MOD(i - 1, 10)  -- Officer IDs 1001-1010
        ELSE NULL 
      END,
      CASE 
        WHEN v_status NOT IN ('Rejected', 'Cancelled', 'Submitted') 
        THEN v_application_date + v_estimated_days
        ELSE NULL 
      END
    );

    -- Commit every 50 records
    IF MOD(i, 50) = 0 THEN
      COMMIT;
      DBMS_OUTPUT.PUT_LINE('Inserted ' || i || ' additional applications...');
    END IF;
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Total 200 APPLICATION records inserted successfully!');
END;
/


SELECT COUNT(*) AS total_applications 
FROM application;

SELECT 
    status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM application
GROUP BY status
ORDER BY count DESC;












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






SELECT 
    status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) || '%' AS percentage
FROM application
GROUP BY status
ORDER BY count DESC;