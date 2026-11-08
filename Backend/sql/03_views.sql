USE hospital_db;
CREATE OR REPLACE VIEW v_patient_appointment_history AS
SELECT a.id AS appointment_id, p.id AS patient_id, p.full_name AS patient_name,
 d.full_name AS doctor_name, dep.name AS department_name, a.appointment_date,
 a.start_time, a.end_time, a.status
FROM appointments a JOIN patients p ON p.id=a.patient_id
JOIN doctors d ON d.id=a.doctor_id JOIN departments dep ON dep.id=a.department_id;
CREATE OR REPLACE VIEW v_doctor_schedule AS
SELECT d.id AS doctor_id, d.full_name AS doctor_name, a.appointment_date, a.start_time, a.end_time,
 p.full_name AS patient_name, a.status FROM doctors d JOIN appointments a ON a.doctor_id=d.id
JOIN patients p ON p.id=a.patient_id;
CREATE OR REPLACE VIEW v_department_doctors AS
SELECT dep.id AS department_id, dep.name AS department_name, d.id AS doctor_id,
 d.full_name AS doctor_name, d.specialization, d.consultation_fee
FROM departments dep LEFT JOIN doctors d ON d.department_id=dep.id AND d.is_active=TRUE;
CREATE OR REPLACE VIEW v_patient_billing_summary AS
SELECT p.id AS patient_id, p.full_name AS patient_name, COUNT(DISTINCT b.id) AS bill_count,
 COALESCE(SUM(b.total_amount),0) AS total_billed,
 COALESCE(SUM(pay.paid_amount),0) AS total_paid,
 COALESCE(SUM(b.total_amount),0)-COALESCE(SUM(pay.paid_amount),0) AS outstanding_balance
FROM patients p LEFT JOIN bills b ON b.patient_id=p.id
LEFT JOIN (SELECT bill_id, SUM(amount) paid_amount FROM payments GROUP BY bill_id) pay ON pay.bill_id=b.id
GROUP BY p.id,p.full_name;
CREATE OR REPLACE VIEW v_outstanding_bills AS
SELECT b.id AS bill_id,p.full_name AS patient_name,b.bill_date,b.total_amount,
 COALESCE(x.paid_amount,0) AS paid_amount,b.total_amount-COALESCE(x.paid_amount,0) AS outstanding_balance,b.status
FROM bills b JOIN patients p ON p.id=b.patient_id
LEFT JOIN (SELECT bill_id,SUM(amount) paid_amount FROM payments GROUP BY bill_id) x ON x.bill_id=b.id
WHERE b.status <> 'void' AND b.total_amount > COALESCE(x.paid_amount,0);
