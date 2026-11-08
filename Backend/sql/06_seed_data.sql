USE hospital_db;
INSERT IGNORE INTO departments(name,description) VALUES
('Cardiology','Heart and circulatory system'),('Neurology','Brain and nervous system'),('Orthopedics','Bones and joints'),('Pediatrics','Child healthcare'),('General Medicine','Primary and general care');
INSERT IGNORE INTO doctors(full_name,email,phone,specialization,consultation_fee,department_id) VALUES
('Dr. Aditi Sharma','aditi.sharma@example.test','9000000001','Cardiologist',700,1),
('Dr. Kabir Mehta','kabir.mehta@example.test','9000000002','Neurologist',800,2),
('Dr. Riya Verma','riya.verma@example.test','9000000003','Orthopedic Surgeon',650,3),
('Dr. Arjun Rao','arjun.rao@example.test','9000000004','Pediatrician',500,4),
('Dr. Neha Kapoor','neha.kapoor@example.test','9000000005','General Physician',400,5);
INSERT IGNORE INTO patients(full_name,date_of_birth,gender,phone,email,address) VALUES
('Aarav Singh','1998-02-12','Male','9100000001','aarav.singh@example.test','Delhi'),('Diya Patel','2001-07-04','Female','9100000002','diya.patel@example.test','Noida'),
('Vivaan Gupta','1987-11-21','Male','9100000003','vivaan.gupta@example.test','Gurugram'),('Ananya Joshi','1995-03-15','Female','9100000004','ananya.joshi@example.test','Delhi'),
('Ishaan Kumar','2004-09-09','Male','9100000005','ishaan.kumar@example.test','Faridabad'),('Meera Nair','1979-05-30','Female','9100000006','meera.nair@example.test','Delhi'),
('Reyansh Das','1992-12-01','Male','9100000007','reyansh.das@example.test','Ghaziabad'),('Sara Khan','2000-06-18','Female','9100000008','sara.khan@example.test','Delhi'),
('Advik Malhotra','1985-08-22','Male','9100000009','advik.malhotra@example.test','Noida'),('Ira Chawla','1999-04-11','Female','9100000010','ira.chawla@example.test','Delhi'),
('Krishna Iyer','1972-01-25','Male','9100000011','krishna.iyer@example.test','Gurugram'),('Myra Bansal','2010-10-10','Female','9100000012','myra.bansal@example.test','Delhi'),
('Atharv Jain','1997-02-28','Male','9100000013','atharv.jain@example.test','Noida'),('Pari Sethi','1989-07-19','Female','9100000014','pari.sethi@example.test','Delhi'),
('Dhruv Arora','2002-03-03','Male','9100000015','dhruv.arora@example.test','Faridabad'),('Kiara Roy','1994-12-14','Female','9100000016','kiara.roy@example.test','Delhi'),
('Rudra Mishra','1980-06-06','Male','9100000017','rudra.mishra@example.test','Ghaziabad'),('Aanya Reddy','2003-01-17','Female','9100000018','aanya.reddy@example.test','Delhi'),
('Yuvaan Sood','1991-09-27','Male','9100000019','yuvaan.sood@example.test','Noida'),('Navya Pillai','1996-05-08','Female','9100000020','navya.pillai@example.test','Delhi'),
('Kabir Bose','1983-04-04','Male','9100000021','kabir.bose@example.test','Gurugram'),('Saanvi Gill','2005-11-13','Female','9100000022','saanvi.gill@example.test','Delhi'),
('Ayaan Dutta','1990-08-08','Male','9100000023','ayaan.dutta@example.test','Noida'),('Tara Menon','1976-02-20','Female','9100000024','tara.menon@example.test','Delhi'),
('Arnav Khanna','2001-10-02','Male','9100000025','arnav.khanna@example.test','Faridabad'),('Zoya Ali','1993-03-26','Female','9100000026','zoya.ali@example.test','Delhi'),
('Samarth Yadav','1988-12-31','Male','9100000027','samarth.yadav@example.test','Ghaziabad'),('Anvi Thakur','1998-07-07','Female','9100000028','anvi.thakur@example.test','Delhi'),
('Devansh Paul','1970-09-16','Male','9100000029','devansh.paul@example.test','Noida'),('Prisha Fernandes','2006-04-23','Female','9100000030','prisha.fernandes@example.test','Delhi');
INSERT IGNORE INTO medicines(name,category,manufacturer,unit_price) VALUES ('Paracetamol 500mg','Analgesic','Demo Pharma',2.50),('Cetirizine 10mg','Antihistamine','Demo Pharma',3.00),('Amoxicillin 250mg','Antibiotic','Demo Pharma',8.00);
INSERT IGNORE INTO lab_tests(name,description,standard_price) VALUES ('Complete Blood Count','CBC blood test',450),('Blood Glucose','Blood glucose test',150),('Lipid Profile','Cholesterol and lipid panel',700);
