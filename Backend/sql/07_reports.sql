USE hospital_db;
-- 1. All active patients
SELECT id,full_name,phone FROM patients WHERE is_active=TRUE ORDER BY full_name;
-- 2. Unique doctor specializations
SELECT DISTINCT specialization FROM doctors ORDER BY specialization;
-- 3. Department and doctor list
SELECT dep.name,d.full_name FROM departments dep INNER JOIN doctors d ON d.department_id=dep.id;
-- 4. Departments including those without doctors
SELECT dep.name,d.full_name FROM departments dep LEFT JOIN doctors d ON d.department_id=dep.id;
-- 5. Appointment count by status
SELECT status,COUNT(*) AS total FROM appointments GROUP BY status;
-- 6. Departments with more than five appointments
SELECT dep.name,COUNT(a.id) AS total FROM departments dep LEFT JOIN appointments a ON a.department_id=dep.id GROUP BY dep.id,dep.name HAVING COUNT(a.id)>5;
-- 7. Average consultation fee
SELECT AVG(consultation_fee) AS average_fee FROM doctors;
-- 8. Patient appointment history
SELECT * FROM v_patient_appointment_history WHERE patient_id=1 ORDER BY appointment_date DESC;
-- 9. Doctors with no appointments
SELECT d.id,d.full_name FROM doctors d WHERE NOT EXISTS(SELECT 1 FROM appointments a WHERE a.doctor_id=d.id);
-- 10. Patients with no appointments
SELECT p.id,p.full_name FROM patients p WHERE NOT EXISTS(SELECT 1 FROM appointments a WHERE a.patient_id=p.id);
-- 11. Appointment overlap audit query (pairs scheduled at same date)
SELECT a1.id AS first_id,a2.id AS second_id,a1.doctor_id,a1.appointment_date FROM appointments a1 JOIN appointments a2 ON a1.id<a2.id AND a1.doctor_id=a2.doctor_id AND a1.appointment_date=a2.appointment_date AND a1.start_time<a2.end_time AND a1.end_time>a2.start_time AND a1.status IN ('scheduled','confirmed','in_progress') AND a2.status IN ('scheduled','confirmed','in_progress');
-- 12. Workload by doctor
SELECT d.full_name,COUNT(a.id) AS appointments FROM doctors d LEFT JOIN appointments a ON a.doctor_id=d.id GROUP BY d.id,d.full_name ORDER BY appointments DESC;
-- 13. Outstanding bills
SELECT * FROM v_outstanding_bills ORDER BY bill_date;
-- 14. Payments by method
SELECT method,SUM(amount) AS recorded_payments FROM payments GROUP BY method;
-- 15. Frequent visitors (3 or more appointments)
SELECT p.full_name,COUNT(a.id) AS visits FROM patients p JOIN appointments a ON a.patient_id=p.id GROUP BY p.id,p.full_name HAVING COUNT(a.id)>=3;
-- 16. Lab test status report
SELECT lt.name,plo.status,COUNT(*) AS total FROM patient_lab_orders plo JOIN lab_tests lt ON lt.id=plo.lab_test_id GROUP BY lt.name,plo.status;
-- 17. Appointments for today
SELECT * FROM v_patient_appointment_history WHERE appointment_date=CURRENT_DATE ORDER BY start_time;
-- 18. CASE: bill payment label
SELECT b.id,b.total_amount,COALESCE(paid.paid_amount,0) AS paid_amount,CASE WHEN COALESCE(paid.paid_amount,0)=0 THEN 'Unpaid' WHEN paid.paid_amount<b.total_amount THEN 'Partially paid' ELSE 'Paid' END AS payment_label FROM bills b LEFT JOIN (SELECT bill_id,SUM(amount) paid_amount FROM payments GROUP BY bill_id) paid ON paid.bill_id=b.id;
-- 19. Monthly appointment totals (MySQL date functions)
SELECT DATE_FORMAT(appointment_date,'%Y-%m') AS month,COUNT(*) AS total FROM appointments GROUP BY DATE_FORMAT(appointment_date,'%Y-%m') ORDER BY month;
-- 20. Department statistics with CTE (MySQL 8+)
WITH department_counts AS (SELECT department_id,COUNT(*) total FROM appointments GROUP BY department_id) SELECT dep.name,COALESCE(dc.total,0) AS appointment_count FROM departments dep LEFT JOIN department_counts dc ON dc.department_id=dep.id;
-- 21. Average bill total per patient
SELECT patient_id,AVG(total_amount) AS average_bill FROM bills GROUP BY patient_id;
-- 22. Appointments in the next seven days
SELECT * FROM appointments WHERE appointment_date BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE,INTERVAL 7 DAY) ORDER BY appointment_date,start_time;
