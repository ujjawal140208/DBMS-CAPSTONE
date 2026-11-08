USE hospital_db;
DELIMITER $$
CREATE TRIGGER trg_appointment_audit_insert AFTER INSERT ON appointments
FOR EACH ROW BEGIN
 INSERT INTO audit_log(table_name,record_id,action_name,details)
 VALUES('appointments',NEW.id,'INSERT',JSON_OBJECT('status',NEW.status,'appointment_date',NEW.appointment_date));
END$$
CREATE TRIGGER trg_appointment_audit_update AFTER UPDATE ON appointments
FOR EACH ROW BEGIN
 INSERT INTO audit_log(table_name,record_id,action_name,details)
 VALUES('appointments',NEW.id,'UPDATE',JSON_OBJECT('old_status',OLD.status,'new_status',NEW.status));
END$$
DELIMITER ;
-- Note: booking conflict prevention also belongs in a transaction-aware service.
