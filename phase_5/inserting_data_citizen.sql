-- First, find the next available ID
SELECT COALESCE(MAX(citizen_id), 1000) + 1 AS next_id FROM citizen;

-- Then use this corrected INSERT ALL with explicit IDs
INSERT ALL
  INTO citizen VALUES (1000, 'Jean', 'Mugabo', DATE '1985-03-15', 'NID1198503150001', 'jean.mugabo@email.com', '+250788123001', 'KG 5 Ave, Kigali', 'Citizen', SYSDATE-1000, 'Active')
  INTO citizen VALUES (1001, 'Marie', 'Uwase', DATE '1990-07-22', 'NID1199007220002', 'marie.uwase@email.com', '+250788123002', 'KG 10 St, Kigali', 'Citizen', SYSDATE-950, 'Active')
  INTO citizen VALUES (1002, 'Patrick', 'Niyonzima', DATE '1988-11-10', 'NID1198811100003', 'patrick.n@email.com', '+250788123003', 'KN 3 Rd, Kigali', 'Citizen', SYSDATE-900, 'Active')
  INTO citizen VALUES (1003, 'Grace', 'Mukamana', DATE '1992-05-18', 'NID1199205180004', 'grace.m@email.com', '+250788123004', 'KK 15 Ave, Kigali', 'Resident', SYSDATE-850, 'Active')
  INTO citizen VALUES (1004, 'David', 'Habimana', DATE '1987-09-25', 'NID1198709250005', 'david.h@email.com', '+250788123005', 'KG 20 St, Kigali', 'Citizen', SYSDATE-800, 'Active')
  INTO citizen VALUES (1005, 'Christine', 'Ingabire', DATE '1995-01-30', 'NID1199501300006', 'christine.i@email.com', '+250788123006', 'KN 7 Rd, Kigali', 'Citizen', SYSDATE-750, 'Active')
  INTO citizen VALUES (1006, 'Emmanuel', 'Bizimana', DATE '1983-12-05', 'NID1198312050007', 'emmanuel.b@email.com', '+250788123007', 'KK 25 Ave, Kigali', 'Citizen', SYSDATE-700, 'Active')
  INTO citizen VALUES (1007, 'Sarah', 'Mukamazimpaka', DATE '1991-08-14', 'NID1199108140008', 'sarah.m@email.com', '+250788123008', 'KG 30 St, Kigali', 'Resident', SYSDATE-650, 'Active')
  INTO citizen VALUES (1008, 'Joseph', 'Hakizimana', DATE '1989-04-20', 'NID1198904200009', 'joseph.h@email.com', '+250788123009', 'KN 12 Rd, Kigali', 'Citizen', SYSDATE-600, 'Active')
  INTO citizen VALUES (1009, 'Claudine', 'Nyirahabimana', DATE '1993-10-08', 'NID1199310080010', 'claudine.n@email.com', '+250788123010', 'KK 35 Ave, Kigali', 'Citizen', SYSDATE-550, 'Active')
  INTO citizen VALUES (1010, 'Eric', 'Maniraguha', DATE '1986-06-12', 'NID1198606120011', 'eric.m@email.com', '+250788123011', 'KG 40 St, Kigali', 'Citizen', SYSDATE-500, 'Active')
  INTO citizen VALUES (1011, 'Jacqueline', 'Umutoni', DATE '1994-02-28', 'NID1199402280012', 'jacqueline.u@email.com', '+250788123012', 'KN 18 Rd, Kigali', 'Resident', SYSDATE-450, 'Active')
  INTO citizen VALUES (1012, 'Felix', 'Ndagijimana', DATE '1984-11-16', 'NID1198411160013', 'felix.n@email.com', '+250788123013', 'KK 45 Ave, Kigali', 'Citizen', SYSDATE-400, 'Active')
  INTO citizen VALUES (1013, 'Diane', 'Uwamahoro', DATE '1996-07-03', 'NID1199607030014', 'diane.u@email.com', '+250788123014', 'KG 50 St, Kigali', 'Citizen', SYSDATE-350, 'Active')
  INTO citizen VALUES (1014, 'Samuel', 'Gasana', DATE '1982-03-21', 'NID1198203210015', 'samuel.g@email.com', '+250788123015', 'KN 23 Rd, Kigali', 'Citizen', SYSDATE-300, 'Active')
  INTO citizen VALUES (1015, 'Angelique', 'Murekatete', DATE '1991-12-09', 'NID1199112090016', 'angelique.m@email.com', '+250788123016', 'KK 55 Ave, Kigali', 'Foreigner', SYSDATE-250, 'Active')
  INTO citizen VALUES (1016, 'Robert', 'Uwizeyimana', DATE '1988-05-27', 'NID1198805270017', 'robert.u@email.com', '+250788123017', 'KG 60 St, Kigali', 'Citizen', SYSDATE-200, 'Active')
  INTO citizen VALUES (1017, 'Beatrice', 'Mukandayisenga', DATE '1993-09-13', 'NID1199309130018', 'beatrice.m@email.com', '+250788123018', 'KN 28 Rd, Kigali', 'Citizen', SYSDATE-150, 'Active')
  INTO citizen VALUES (1018, 'Richard', 'Niyitegeka', DATE '1987-01-05', 'NID1198701050019', 'richard.n@email.com', '+250788123019', 'KK 65 Ave, Kigali', 'Resident', SYSDATE-100, 'Active')
  INTO citizen VALUES (1019, 'Esperance', 'Mukashyaka', DATE '1990-08-19', 'NID1199008190020', 'esperance.m@email.com', '+250788123020', 'KG 70 St, Kigali', 'Citizen', SYSDATE-50, 'Active')
  INTO citizen VALUES (1020, 'James', 'Kamanzi', DATE '1985-04-11', 'NID1198504110021', 'james.k@email.com', '+250788123021', 'Nyarugenge, Kigali', 'Citizen', SYSDATE-45, 'Active')
  INTO citizen VALUES (1021, 'Alice', 'Mukarutabana', DATE '1992-10-24', 'NID1199210240022', 'alice.m@email.com', '+250788123022', 'Kicukiro, Kigali', 'Citizen', SYSDATE-40, 'Active')
  INTO citizen VALUES (1022, 'Peter', 'Ntare', DATE '1989-06-07', 'NID1198906070023', 'peter.n@email.com', '+250788123023', 'Gasabo, Kigali', 'Resident', SYSDATE-35, 'Active')
  INTO citizen VALUES (1023, 'Louise', 'Mukamwiza', DATE '1994-03-15', 'NID1199403150024', 'louise.m@email.com', '+250788123024', 'Remera, Kigali', 'Citizen', SYSDATE-30, 'Active')
  INTO citizen VALUES (1024, 'Vincent', 'Harerimana', DATE '1986-11-28', 'NID1198611280025', 'vincent.h@email.com', '+250788123025', 'Kimihurura, Kigali', 'Citizen', SYSDATE-25, 'Active')
  INTO citizen VALUES (1025, 'Agnes', 'Nyiransabimana', DATE '1991-07-02', 'NID1199107020026', 'agnes.n@email.com', '+250788123026', 'Gikondo, Kigali', 'Citizen', SYSDATE-20, 'Active')
  INTO citizen VALUES (1026, 'Martin', 'Nsengimana', DATE '1983-02-18', 'NID1198302180027', 'martin.n@email.com', '+250788123027', 'Nyamirambo, Kigali', 'Foreigner', SYSDATE-15, 'Active')
  INTO citizen VALUES (1027, 'Florence', 'Uwimana', DATE '1995-09-30', 'NID1199509300028', 'florence.u@email.com', '+250788123028', 'Kacyiru, Kigali', 'Citizen', SYSDATE-10, 'Active')
  INTO citizen VALUES (1028, 'Paul', 'Mutabazi', DATE '1988-05-12', 'NID1198805120029', 'paul.m@email.com', '+250788123029', 'Kimironko, Kigali', 'Citizen', SYSDATE-5, 'Active')
  INTO citizen VALUES (1029, 'Consolee', 'Mukansanga', DATE '1990-12-25', 'NID1199012250030', 'consolee.m@email.com', '+250788123030', 'Kabeza, Kigali', 'Resident', SYSDATE-3, 'Active')
  INTO citizen VALUES (1030, 'Frank', 'Tuyisenge', DATE '1987-08-08', 'NID1198708080031', 'frank.t@email.com', '+250788123031', 'Nyarutarama, Kigali', 'Citizen', SYSDATE-2, 'Active')
  INTO citizen VALUES (1031, 'Immaculee', 'Mukamugema', DATE '1993-04-16', 'NID1199304160032', 'immaculee.m@email.com', '+250788123032', 'Kibagabaga, Kigali', 'Citizen', SYSDATE-1, 'Active')
  INTO citizen VALUES (1032, 'George', 'Nshimyimana', DATE '1985-11-03', 'NID1198511030033', 'george.n@email.com', '+250788123033', 'Gisozi, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1033, 'Chantal', 'Mukantagara', DATE '1992-06-21', 'NID1199206210034', 'chantal.m@email.com', '+250788123034', 'Kanombe, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1034, 'Simon', 'Habiyaremye', DATE '1989-02-09', 'NID1198902090035', 'simon.h@email.com', '+250788123035', 'Rusororo, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1035, 'Goreth', 'Nyiransabimana', DATE '1996-10-14', 'NID1199610140036', 'goreth.n@email.com', '+250788123036', 'Niboye, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1036, 'Andrew', 'Mukama', DATE '1984-07-26', 'NID1198407260037', 'andrew.m@email.com', '+250788123037', 'Masoro, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1037, 'Vestine', 'Uwera', DATE '1991-03-08', 'NID1199103080038', 'vestine.u@email.com', '+250788123038', 'Gahanga, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1038, 'Charles', 'Nkundimana', DATE '1988-11-17', 'NID1198811170039', 'charles.n@email.com', '+250788123039', 'Kinyinya, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1039, 'Jeanne', 'Mukamutara', DATE '1994-05-29', 'NID1199405290040', 'jeanne.m@email.com', '+250788123040', 'Kagugu, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1040, 'Thomas', 'Bizumuremyi', DATE '1986-01-12', 'NID1198601120041', 'thomas.b@email.com', '+250788123041', 'Nyakabanda, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1041, 'Odette', 'Nyirahabimana', DATE '1993-09-04', 'NID1199309040042', 'odette.n@email.com', '+250788123042', 'Muhima, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1042, 'Denis', 'Uwizeye', DATE '1987-04-23', 'NID1198704230043', 'denis.u@email.com', '+250788123043', 'Biryogo, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1043, 'Francine', 'Mukandori', DATE '1995-12-06', 'NID1199512060044', 'francine.m@email.com', '+250788123044', 'Cyahafi, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1044, 'Bernard', 'Ntawukuriryayo', DATE '1982-08-18', 'NID1198208180045', 'bernard.n@email.com', '+250788123045', 'Nyagasambu, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1045, 'Solange', 'Mukamusoni', DATE '1990-03-31', 'NID1199003310046', 'solange.m@email.com', '+250788123046', 'Gikomero, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1046, 'Julius', 'Nzabonimpa', DATE '1989-11-09', 'NID1198911090047', 'julius.n@email.com', '+250788123047', 'Jabana, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1047, 'Alphonsine', 'Uwamwiza', DATE '1994-07-22', 'NID1199407220048', 'alphonsine.u@email.com', '+250788123048', 'Jali, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1048, 'Gilbert', 'Niyonzima', DATE '1985-02-14', 'NID1198502140049', 'gilbert.n@email.com', '+250788123049', 'Rukiri, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1049, 'Olive', 'Mukashema', DATE '1992-10-01', 'NID1199210010050', 'olive.m@email.com', '+250788123050', 'Batsinda, Kigali', 'Citizen', SYSDATE, 'Active')
SELECT * FROM dual;

--50 rows inserted

SELECT MAX(citizen_id) FROM citizen;


INSERT ALL
  INTO citizen VALUES (1050, 'Daniel', 'Mutsinzi', DATE '1988-06-13', 'NID1198806130051', 'daniel.m@email.com', '+250788123051', 'KG 75 St, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1051, 'Daphne', 'Nyirasafari', DATE '1991-01-25', 'NID1199101250052', 'daphne.n@email.com', '+250788123052', 'KN 80 Rd, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1052, 'Ernest', 'Habimana', DATE '1986-09-07', 'NID1198609070053', 'ernest.h@email.com', '+250788123053', 'KK 85 Ave, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1053, 'Edith', 'Mukandutiye', DATE '1993-05-19', 'NID1199305190054', 'edith.m@email.com', '+250788123054', 'Kacyiru, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1054, 'Fabrice', 'Nsabimana', DATE '1987-12-31', 'NID1198712310055', 'fabrice.n@email.com', '+250788123055', 'Kimihurura, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1055, 'Francoise', 'Uwamahoro', DATE '1995-08-12', 'NID1199508120056', 'francoise.u@email.com', '+250788123056', 'Remera, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1056, 'Gabriel', 'Nshimiyimana', DATE '1984-04-24', 'NID1198404240057', 'gabriel.n@email.com', '+250788123057', 'Gikondo, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1057, 'Gloriose', 'Mukamana', DATE '1990-11-06', 'NID1199011060058', 'gloriose.m@email.com', '+250788123058', 'Nyamirambo, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1058, 'Herve', 'Uwizeyimana', DATE '1989-07-18', 'NID1198907180059', 'herve.u@email.com', '+250788123059', 'Kimironko, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1059, 'Ines', 'Mukamazimpaka', DATE '1994-03-02', 'NID1199403020060', 'ines.m@email.com', '+250788123060', 'Kabeza, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1060, 'Jacques', 'Ndagijimana', DATE '1983-10-14', 'NID1198310140061', 'jacques.n@email.com', '+250788123061', 'Nyarutarama, Kigali', 'Citizen', SYSDATE, 'Inactive')
  INTO citizen VALUES (1061, 'Janine', 'Mukandayisenga', DATE '1992-06-26', 'NID1199206260062', 'janine.m@email.com', '+250788123062', 'Kibagabaga, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1062, 'Kevin', 'Harerimana', DATE '1988-02-08', 'NID1198802080063', 'kevin.h@email.com', '+250788123063', 'Gisozi, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1063, 'Liliane', 'Nyirahabimana', DATE '1996-09-20', 'NID1199609200064', 'liliane.n@email.com', '+250788123064', 'Kanombe, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1064, 'Michel', 'Nsengimana', DATE '1985-05-04', 'NID1198505040065', 'michel.n@email.com', '+250788123065', 'Rusororo, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1065, 'Monique', 'Mukashyaka', DATE '1991-12-16', 'NID1199112160066', 'monique.m@email.com', '+250788123066', 'Niboye, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1066, 'Nathan', 'Uwimana', DATE '1987-08-28', 'NID1198708280067', 'nathan.u@email.com', '+250788123067', 'Masoro, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1067, 'Nicole', 'Mukarutabana', DATE '1993-04-10', 'NID1199304100068', 'nicole.m@email.com', '+250788123068', 'Gahanga, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1068, 'Oscar', 'Nkundimana', DATE '1986-11-22', 'NID1198611220069', 'oscar.n@email.com', '+250788123069', 'Kinyinya, Kigali', 'Citizen', SYSDATE, 'Suspended')
  INTO citizen VALUES (1069, 'Patricia', 'Mukamutara', DATE '1995-07-05', 'NID1199507050070', 'patricia.m@email.com', '+250788123070', 'Kagugu, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1070, 'Quentin', 'Bizumuremyi', DATE '1982-03-17', 'NID1198203170071', 'quentin.b@email.com', '+250788123071', 'Nyakabanda, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1071, 'Rachel', 'Nyirahabimana', DATE '1990-10-29', 'NID1199010290072', 'rachel.n@email.com', '+250788123072', 'Muhima, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1072, 'Steven', 'Uwizeye', DATE '1989-06-11', 'NID1198906110073', 'steven.u@email.com', '+250788123073', 'Biryogo, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1073, 'Sylvie', 'Mukandori', DATE '1994-02-23', 'NID1199402230074', 'sylvie.m@email.com', '+250788123074', 'Cyahafi, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1074, 'Thierry', 'Ntawukuriryayo', DATE '1988-09-05', 'NID1198809050075', 'thierry.n@email.com', '+250788123075', 'Nyagasambu, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1075, 'Yvette', 'Mukamusoni', DATE '1992-05-18', 'NID1199205180076', 'yvette.m@email.com', '+250788123076', 'Gikomero, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1076, 'Xavier', 'Nzabonimpa', DATE '1985-12-30', 'NID1198512300077', 'xavier.n@email.com', '+250788123077', 'Jabana, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1077, 'Yves', 'Uwamwiza', DATE '1991-08-12', 'NID1199108120078', 'yves.u@email.com', '+250788123078', 'Jali, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1078, 'Zoe', 'Niyonzima', DATE '1987-04-24', 'NID1198704240079', 'zoe.n@email.com', '+250788123079', 'Rukiri, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1079, 'Abel', 'Mukashema', DATE '1993-11-06', 'NID1199311060080', 'abel.m@email.com', '+250788123080', 'Batsinda, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1080, 'Bernadette', 'Mutsinzi', DATE '1986-07-18', 'NID1198607180081', 'bernadette.m@email.com', '+250788123081', 'Kacyiru, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1081, 'Claude', 'Nyirasafari', DATE '1995-03-02', 'NID1199503020082', 'claude.n@email.com', '+250788123082', 'Kimihurura, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1082, 'Delphine', 'Habimana', DATE '1984-10-14', 'NID1198410140083', 'delphine.h@email.com', '+250788123083', 'Remera, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1083, 'Emile', 'Mukandutiye', DATE '1990-06-26', 'NID1199006260084', 'emile.m@email.com', '+250788123084', 'Gikondo, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1084, 'Faustin', 'Nsabimana', DATE '1989-02-08', 'NID1198902080085', 'faustin.n@email.com', '+250788123085', 'Nyamirambo, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1085, 'Gisele', 'Uwamahoro', DATE '1996-09-20', 'NID1199609200086', 'gisele.u@email.com', '+250788123086', 'Kimironko, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1086, 'Henri', 'Nshimiyimana', DATE '1983-05-04', 'NID1198305040087', 'henri.n@email.com', '+250788123087', 'Kabeza, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1087, 'Isabelle', 'Mukamana', DATE '1992-12-16', 'NID1199212160088', 'isabelle.m@email.com', '+250788123088', 'Nyarutarama, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1088, 'Justin', 'Uwizeyimana', DATE '1988-08-28', 'NID1198808280089', 'justin.u@email.com', '+250788123089', 'Kibagabaga, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1089, 'Laetitia', 'Mukamazimpaka', DATE '1994-04-10', 'NID1199404100090', 'laetitia.m@email.com', '+250788123090', 'Gisozi, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1090, 'Lambert', 'Ndagijimana', DATE '1987-11-22', 'NID1198711220091', 'lambert.n@email.com', '+250788123091', 'Kanombe, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1091, 'Marceline', 'Mukandayisenga', DATE '1995-07-05', 'NID1199507050092', 'marceline.m@email.com', '+250788123092', 'Rusororo, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1092, 'Nicolas', 'Harerimana', DATE '1982-03-17', 'NID1198203170093', 'nicolas.h@email.com', '+250788123093', 'Niboye, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1093, 'Odile', 'Nyirahabimana', DATE '1991-10-29', 'NID1199110290094', 'odile.n@email.com', '+250788123094', 'Masoro, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1094, 'Pascal', 'Nsengimana', DATE '1989-06-11', 'NID1198906110095', 'pascal.n@email.com', '+250788123095', 'Gahanga, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1095, 'Prudence', 'Mukashyaka', DATE '1993-02-23', 'NID1199302230096', 'prudence.m@email.com', '+250788123096', 'Kinyinya, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1096, 'Raymond', 'Uwimana', DATE '1988-09-05', 'NID1198809050097', 'raymond.u@email.com', '+250788123097', 'Kagugu, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1097, 'Rosine', 'Mukarutabana', DATE '1992-05-18', 'NID1199205180098', 'rosine.m@email.com', '+250788123098', 'Nyakabanda, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1098, 'Stanislas', 'Nkundimana', DATE '1985-12-30', 'NID1198512300099', 'stanislas.n@email.com', '+250788123099', 'Muhima, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1099, 'Therese', 'Mukamutara', DATE '1991-08-12', 'NID1199108120100', 'therese.m@email.com', '+250788123100', 'Biryogo, Kigali', 'Citizen', SYSDATE, 'Active')
SELECT * FROM dual;

--50 more rows inserted in CITIZEN


SELECT citizen_id, first_name, last_name FROM citizen ORDER BY citizen_id;



-- Drop and recreate sequence starting after max ID
DROP SEQUENCE seq_citizen_id;


-- Find max ID and create sequence starting from max+1
DECLARE
  v_max_id NUMBER;
BEGIN
  SELECT MAX(citizen_id) INTO v_max_id FROM citizen;
  EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_citizen_id START WITH ' || (v_max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;
/



-- Verify you have 100 citizens
SELECT COUNT(*) AS total_citizens FROM citizen;


-- Check the ID range
SELECT MIN(citizen_id) AS min_id, MAX(citizen_id) AS max_id FROM citizen;


SELECT citizen_id, first_name, last_name, email
FROM citizen 
WHERE citizen_id >= 1100
ORDER BY citizen_id;

-- Additional 100 Citizens with UNIQUE emails (IDs 1100-1199)
INSERT ALL
  INTO citizen VALUES (1100, 'Alain', 'Mugenzi', DATE '1985-09-14', 'NID1198509141100', 'alain1100@email.com', '+250788151100', 'KG 100 St, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1101, 'Brigitte', 'Uwera', DATE '1990-04-27', 'NID1199004271101', 'brigitte1101@email.com', '+250788151101', 'KN 105 Rd, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1102, 'Cedric', 'Niyomugabo', DATE '1988-12-10', 'NID1198812101102', 'cedric1102@email.com', '+250788151102', 'KK 110 Ave, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1103, 'Dorothee', 'Mukagatare', DATE '1992-07-23', 'NID1199207231103', 'dorothee1103@email.com', '+250788151103', 'KG 115 St, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1104, 'Edouard', 'Habyarimana', DATE '1987-02-05', 'NID1198702051104', 'edouard1104@email.com', '+250788151104', 'KN 120 Rd, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1105, 'Fabienne', 'Ingabire', DATE '1995-11-18', 'NID1199511181105', 'fabienne1105@email.com', '+250788151105', 'KK 125 Ave, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1106, 'Gerard', 'Bizimana', DATE '1983-06-30', 'NID1198306301106', 'gerard1106@email.com', '+250788151106', 'KG 130 St, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1107, 'Helene', 'Mukamazina', DATE '1991-01-12', 'NID1199101121107', 'helene1107@email.com', '+250788151107', 'KN 135 Rd, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1108, 'Ivan', 'Hakizumwami', DATE '1989-08-25', 'NID1198908251108', 'ivan1108@email.com', '+250788151108', 'KK 140 Ave, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1109, 'Josiane', 'Nyirabazungu', DATE '1993-03-08', 'NID1199303081109', 'josiane1109@email.com', '+250788151109', 'KG 145 St, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1110, 'Karamaga', 'Maniragaba', DATE '1986-10-21', 'NID1198610211110', 'karamaga1110@email.com', '+250788151110', 'KN 150 Rd, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1111, 'Laurence', 'Umutonera', DATE '1994-05-04', 'NID1199405041111', 'laurence1111@email.com', '+250788151111', 'KK 155 Ave, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1112, 'Marcel', 'Ndagijimfura', DATE '1984-12-17', 'NID1198412171112', 'marcel1112@email.com', '+250788151112', 'KG 160 St, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1113, 'Nadia', 'Uwamahina', DATE '1996-07-30', 'NID1199607301113', 'nadia1113@email.com', '+250788151113', 'KN 165 Rd, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1114, 'Olivier', 'Gasanabo', DATE '1982-03-12', 'NID1198203121114', 'olivier1114@email.com', '+250788151114', 'KK 170 Ave, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1115, 'Paulette', 'Murekatete', DATE '1991-10-25', 'NID1199110251115', 'paulette1115@email.com', '+250788151115', 'KG 175 St, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1116, 'Quentin', 'Uwizeyimana', DATE '1988-05-08', 'NID1198805081116', 'quentin1116@email.com', '+250788151116', 'KN 180 Rd, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1117, 'Ruth', 'Mukandayobera', DATE '1993-12-21', 'NID1199312211117', 'ruth1117@email.com', '+250788151117', 'KK 185 Ave, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1118, 'Sylvain', 'Niyitegeranya', DATE '1987-07-04', 'NID1198707041118', 'sylvain1118@email.com', '+250788151118', 'KG 190 St, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1119, 'Tatiana', 'Mukashaka', DATE '1990-02-16', 'NID1199002161119', 'tatiana1119@email.com', '+250788151119', 'KN 195 Rd, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1120, 'Urbain', 'Kamanayo', DATE '1985-09-29', 'NID1198509291120', 'urbain1120@email.com', '+250788151120', 'Nyarugenge, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1121, 'Valerie', 'Mukarutabera', DATE '1992-04-11', 'NID1199204111121', 'valerie1121@email.com', '+250788151121', 'Kicukiro, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1122, 'William', 'Ntarenganya', DATE '1989-11-24', 'NID1198911241122', 'william1122@email.com', '+250788151122', 'Gasabo, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1123, 'Xenia', 'Mukamwisenga', DATE '1994-06-07', 'NID1199406071123', 'xenia1123@email.com', '+250788151123', 'Remera, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1124, 'Yannick', 'Harerimana', DATE '1986-01-19', 'NID1198601191124', 'yannick1124@email.com', '+250788151124', 'Kimihurura, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1125, 'Zita', 'Nyiransabimana', DATE '1991-08-02', 'NID1199108021125', 'zita1125@email.com', '+250788151125', 'Gikondo, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1126, 'Arsene', 'Nsengiyumva', DATE '1983-03-15', 'NID1198303151126', 'arsene1126@email.com', '+250788151126', 'Nyamirambo, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1127, 'Bella', 'Uwimanayo', DATE '1995-10-28', 'NID1199510281127', 'bella1127@email.com', '+250788151127', 'Kacyiru, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1128, 'Clement', 'Mutabaruka', DATE '1988-05-11', 'NID1198805111128', 'clement1128@email.com', '+250788151128', 'Kimironko, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1129, 'Diana', 'Mukansano', DATE '1990-12-23', 'NID1199012231129', 'diana1129@email.com', '+250788151129', 'Kabeza, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1130, 'Elie', 'Tuyizere', DATE '1987-07-06', 'NID1198707061130', 'elie1130@email.com', '+250788151130', 'Nyarutarama, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1131, 'Fiona', 'Mukamugenzi', DATE '1993-02-18', 'NID1199302181131', 'fiona1131@email.com', '+250788151131', 'Kibagabaga, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1132, 'Gustave', 'Nshimiyumukiza', DATE '1985-09-01', 'NID1198509011132', 'gustave1132@email.com', '+250788151132', 'Gisozi, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1133, 'Hilda', 'Mukantwari', DATE '1992-04-14', 'NID1199204141133', 'hilda1133@email.com', '+250788151133', 'Kanombe, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1134, 'Isaac', 'Habiyambere', DATE '1989-11-27', 'NID1198911271134', 'isaac1134@email.com', '+250788151134', 'Rusororo, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1135, 'Joelle', 'Nyirakobwa', DATE '1994-06-10', 'NID1199406101135', 'joelle1135@email.com', '+250788151135', 'Niboye, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1136, 'Koffi', 'Mukamana', DATE '1986-01-22', 'NID1198601221136', 'koffi1136@email.com', '+250788151136', 'Masoro, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1137, 'Lydie', 'Uwera', DATE '1991-08-05', 'NID1199108051137', 'lydie1137@email.com', '+250788151137', 'Gahanga, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1138, 'Maxime', 'Nkundabagenzi', DATE '1988-03-19', 'NID1198803191138', 'maxime1138@email.com', '+250788151138', 'Kinyinya, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1139, 'Nathalie', 'Mukamutega', DATE '1993-10-31', 'NID1199310311139', 'nathalie1139@email.com', '+250788151139', 'Kagugu, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1140, 'Omer', 'Bizumuremyi', DATE '1987-05-14', 'NID1198705141140', 'omer1140@email.com', '+250788151140', 'Nyakabanda, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1141, 'Penelope', 'Nyirahabiyambere', DATE '1992-12-26', 'NID1199212261141', 'penelope1141@email.com', '+250788151141', 'Muhima, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1142, 'Renaud', 'Uwizeyumva', DATE '1989-07-09', 'NID1198907091142', 'renaud1142@email.com', '+250788151142', 'Biryogo, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1143, 'Sabine', 'Mukandoli', DATE '1995-02-21', 'NID1199502211143', 'sabine1143@email.com', '+250788151143', 'Cyahafi, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1144, 'Theophile', 'Ntawugiranayo', DATE '1982-09-04', 'NID1198209041144', 'theophile1144@email.com', '+250788151144', 'Nyagasambu, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1145, 'Ursula', 'Mukamusana', DATE '1990-04-17', 'NID1199004171145', 'ursula1145@email.com', '+250788151145', 'Gikomero, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1146, 'Victor', 'Nzabamwita', DATE '1988-11-30', 'NID1198811301146', 'victor1146@email.com', '+250788151146', 'Jabana, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1147, 'Wendy', 'Uwamahoro', DATE '1993-06-13', 'NID1199306131147', 'wendy1147@email.com', '+250788151147', 'Jali, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1148, 'Xavier', 'Niyonzima', DATE '1985-01-25', 'NID1198501251148', 'xavier1148@email.com', '+250788151148', 'Rukiri, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1149, 'Yolande', 'Mukasekuru', DATE '1992-08-08', 'NID1199208081149', 'yolande1149@email.com', '+250788151149', 'Batsinda, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1150, 'Zacharie', 'Mutsinzi', DATE '1989-03-21', 'NID1198903211150', 'zacharie1150@email.com', '+250788151150', 'Kacyiru, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1151, 'Aline', 'Nyirasangwa', DATE '1994-10-03', 'NID1199410031151', 'aline1151@email.com', '+250788151151', 'Kimihurura, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1152, 'Benoit', 'Habimana', DATE '1986-05-16', 'NID1198605161152', 'benoit1152@email.com', '+250788151152', 'Remera, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1153, 'Corinne', 'Mukandekezi', DATE '1991-12-29', 'NID1199112291153', 'corinne1153@email.com', '+250788151153', 'Gikondo, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1154, 'Didier', 'Nsabimana', DATE '1988-07-12', 'NID1198807121154', 'didier1154@email.com', '+250788151154', 'Nyamirambo, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1155, 'Elodie', 'Uwamahina', DATE '1995-02-24', 'NID1199502241155', 'elodie1155@email.com', '+250788151155', 'Kimironko, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1156, 'Frederic', 'Nshimiyimana', DATE '1983-09-07', 'NID1198309071156', 'frederic1156@email.com', '+250788151156', 'Kabeza, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1157, 'Genevieve', 'Mukamana', DATE '1990-04-20', 'NID1199004201157', 'genevieve1157@email.com', '+250788151157', 'Nyarutarama, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1158, 'Hubert', 'Uwizeyimana', DATE '1989-11-02', 'NID1198911021158', 'hubert1158@email.com', '+250788151158', 'Kibagabaga, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1159, 'Irene', 'Mukamazina', DATE '1994-06-15', 'NID1199406151159', 'irene1159@email.com', '+250788151159', 'Gisozi, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1160, 'Jerome', 'Ndagijimana', DATE '1987-01-28', 'NID1198701281160', 'jerome1160@email.com', '+250788151160', 'Kanombe, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1161, 'Karine', 'Mukandayisenga', DATE '1992-08-11', 'NID1199208111161', 'karine1161@email.com', '+250788151161', 'Rusororo, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1162, 'Leon', 'Harerimana', DATE '1988-03-24', 'NID1198803241162', 'leon1162@email.com', '+250788151162', 'Niboye, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1163, 'Michele', 'Nyirahabimana', DATE '1995-10-06', 'NID1199510061163', 'michele1163@email.com', '+250788151163', 'Masoro, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1164, 'Norbert', 'Nsengimana', DATE '1982-05-19', 'NID1198205191164', 'norbert1164@email.com', '+250788151164', 'Gahanga, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1165, 'Ophelie', 'Mukashyaka', DATE '1990-12-01', 'NID1199012011165', 'ophelie1165@email.com', '+250788151165', 'Kinyinya, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1166, 'Philippe', 'Uwimana', DATE '1989-07-14', 'NID1198907141166', 'philippe1166@email.com', '+250788151166', 'Kagugu, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1167, 'Queen', 'Mukarutabana', DATE '1993-02-26', 'NID1199302261167', 'queen1167@email.com', '+250788151167', 'Nyakabanda, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1168, 'Romain', 'Nkundimana', DATE '1986-09-09', 'NID1198609091168', 'romain1168@email.com', '+250788151168', 'Muhima, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1169, 'Sandra', 'Mukamutara', DATE '1991-04-22', 'NID1199104221169', 'sandra1169@email.com', '+250788151169', 'Biryogo, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1170, 'Thibaut', 'Bizumuremyi', DATE '1988-11-04', 'NID1198811041170', 'thibaut1170@email.com', '+250788151170', 'Cyahafi, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1171, 'Ulrike', 'Nyirahabimana', DATE '1994-06-17', 'NID1199406171171', 'ulrike1171@email.com', '+250788151171', 'Nyagasambu, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1172, 'Valentin', 'Uwizeye', DATE '1987-01-30', 'NID1198701301172', 'valentin1172@email.com', '+250788151172', 'Gikomero, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1173, 'Wenceslas', 'Mukandori', DATE '1992-08-13', 'NID1199208131173', 'wenceslas1173@email.com', '+250788151173', 'Jabana, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1174, 'Xavierine', 'Ntawukuriryayo', DATE '1989-03-26', 'NID1198903261174', 'xavierine1174@email.com', '+250788151174', 'Jali, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1175, 'Yann', 'Mukamusoni', DATE '1995-10-08', 'NID1199510081175', 'yann1175@email.com', '+250788151175', 'Rukiri, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1176, 'Zephyr', 'Nzabonimpa', DATE '1982-05-21', 'NID1198205211176', 'zephyr1176@email.com', '+250788151176', 'Batsinda, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1177, 'Aurelie', 'Uwamwiza', DATE '1990-12-03', 'NID1199012031177', 'aurelie1177@email.com', '+250788151177', 'Kacyiru, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1178, 'Bastien', 'Niyonzima', DATE '1989-07-16', 'NID1198907161178', 'bastien1178@email.com', '+250788151178', 'Kimihurura, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1179, 'Celestine', 'Mukashema', DATE '1993-02-28', 'NID1199302281179', 'celestine1179@email.com', '+250788151179', 'Remera, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1180, 'Damien', 'Mutsinzi', DATE '1986-09-11', 'NID1198609111180', 'damien1180@email.com', '+250788151180', 'Gikondo, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1181, 'Eleonore', 'Nyirasafari', DATE '1991-04-24', 'NID1199104241181', 'eleonore1181@email.com', '+250788151181', 'Nyamirambo, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1182, 'Florent', 'Habimana', DATE '1988-11-06', 'NID1198811061182', 'florent1182@email.com', '+250788151182', 'Kimironko, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1183, 'Gaelle', 'Mukandutiye', DATE '1994-06-19', 'NID1199406191183', 'gaelle1183@email.com', '+250788151183', 'Kabeza, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1184, 'Hippolyte', 'Nsabimana', DATE '1987-01-01', 'NID1198701011184', 'hippolyte1184@email.com', '+250788151184', 'Nyarutarama, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1185, 'Isadora', 'Uwamahoro', DATE '1992-08-14', 'NID1199208141185', 'isadora1185@email.com', '+250788151185', 'Kibagabaga, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1186, 'Jules', 'Nshimiyimana', DATE '1989-03-27', 'NID1198903271186', 'jules1186@email.com', '+250788151186', 'Gisozi, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1187, 'Katherine', 'Mukamana', DATE '1995-10-09', 'NID1199510091187', 'katherine1187@email.com', '+250788151187', 'Kanombe, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1188, 'Lionel', 'Uwizeyimana', DATE '1982-05-22', 'NID1198205221188', 'lionel1188@email.com', '+250788151188', 'Rusororo, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1189, 'Melanie', 'Mukamazimpaka', DATE '1990-12-04', 'NID1199012041189', 'melanie1189@email.com', '+250788151189', 'Niboye, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1190, 'Nicolas', 'Ndagijimana', DATE '1989-07-17', 'NID1198907171190', 'nicolas1190@email.com', '+250788151190', 'Masoro, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1191, 'Oceane', 'Mukandayisenga', DATE '1993-02-28', 'NID1199302281191', 'oceane1191@email.com', '+250788151191', 'Gahanga, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1192, 'Pascal', 'Harerimana', DATE '1986-09-12', 'NID1198609121192', 'pascal1192@email.com', '+250788151192', 'Kinyinya, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1193, 'Quiterie', 'Nyirahabimana', DATE '1991-04-25', 'NID1199104251193', 'quiterie1193@email.com', '+250788151193', 'Kagugu, Kigali', 'Foreigner', SYSDATE, 'Active')
  INTO citizen VALUES (1194, 'Raphael', 'Nsengimana', DATE '1988-11-07', 'NID1198811071194', 'raphael1194@email.com', '+250788151194', 'Nyakabanda, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1195, 'Sophie', 'Mukashyaka', DATE '1994-06-20', 'NID1199406201195', 'sophie1195@email.com', '+250788151195', 'Muhima, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1196, 'Tristan', 'Uwimana', DATE '1987-01-02', 'NID1198701021196', 'tristan1196@email.com', '+250788151196', 'Biryogo, Kigali', 'Resident', SYSDATE, 'Active')
  INTO citizen VALUES (1197, 'Ursule', 'Mukarutabana', DATE '1992-08-15', 'NID1199208151197', 'ursule1197@email.com', '+250788151197', 'Cyahafi, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1198, 'Virgile', 'Nkundimana', DATE '1989-03-28', 'NID1198903281198', 'virgile1198@email.com', '+250788151198', 'Nyagasambu, Kigali', 'Citizen', SYSDATE, 'Active')
  INTO citizen VALUES (1199, 'Wendy', 'Mukamutara', DATE '1995-10-10', 'NID1199510101199', 'wendy1199@email.com', '+250788151199', 'Gikomero, Kigali', 'Foreigner', SYSDATE, 'Active')
SELECT * FROM dual;
COMMIT;




-- Check total count (should be 200)
SELECT COUNT(*) AS total_citizens FROM citizen;

-- Verify no duplicate emails
SELECT email, COUNT(*) as count
FROM citizen
GROUP BY email
HAVING COUNT(*) > 1;

-- Check ID range
SELECT MIN(citizen_id) AS min_id, MAX(citizen_id) AS max_id FROM citizen;

-- Update sequence for future inserts
DROP SEQUENCE seq_citizen_id;
CREATE SEQUENCE seq_citizen_id START WITH 1200 INCREMENT BY 1 NOCACHE NOCYCLE;


SELECT 
    'CITIZEN' AS table_name, COUNT(*) AS records FROM citizen
UNION ALL SELECT 'PERMIT_TYPE', COUNT(*) FROM permit_type
UNION ALL SELECT 'DEPARTMENT', COUNT(*) FROM department
UNION ALL SELECT 'APPLICATION', COUNT(*) FROM application
UNION ALL SELECT 'REVIEW_STEP', COUNT(*) FROM review_step
UNION ALL SELECT 'ISSUED_LICENSE', COUNT(*) FROM issued_license
UNION ALL SELECT 'DOCUMENT', COUNT(*) FROM document
ORDER BY 1;  -- Use column position instead of alias