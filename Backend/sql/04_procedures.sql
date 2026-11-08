USE hospital_db;
DELIMITER $$
CREATE PROCEDURE sp_patient_appointment_history(IN p_patient_id INT)
BEGIN
 SELECT * FROM v_patient_appointment_history WHERE patient_id=p_patient_id ORDER BY appointment_date DESC,start_time DESC;
END$$
CREATE PROCEDURE sp_billing_summary(IN p_patient_id INT)
BEGIN
 SELECT * FROM v_patient_billing_summary WHERE patient_id=p_patient_id;
END$$
CREATE PROCEDURE sp_book_appointment(IN p_patient_id INT, IN p_doctor_id INT, IN p_department_id INT,
 IN p_date DATE, IN p_start TIME, IN p_end TIME, IN p_reason TEXT)
BEGIN
 DECLARE conflict_count INT DEFAULT 0;
 IF p_end <= p_start THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='End time must be after start time'; END IF;
 START TRANSACTION;
 SELECT COUNT(*) INTO conflict_count FROM appointments
 WHERE appointment_date=p_date AND status IN ('scheduled','confirmed','in_progress')
 AND start_time < p_end AND end_time > p_start
 AND (doctor_id=p_doctor_id OR patient_id=p_patient_id) FOR UPDATE;
 IF conflict_count > 0 THEN
   ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Appointment overlaps an active appointment';
 ELSE
   INSERT INTO appointments(patient_id,doctor_id,department_id,appointment_date,start_time,end_time,reason)
   VALUES(p_patient_id,p_doctor_id,p_department_id,p_date,p_start,p_end,p_reason);
   COMMIT;
 END IF;
END$$
DELIMITER ;
