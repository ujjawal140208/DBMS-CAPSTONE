USE hospital_db;
-- Core lookup indexes are created with the tables in 01_schema.sql.
-- These additional indexes support common report filters and join patterns.
CREATE INDEX ix_doctors_active_specialization ON doctors(is_active, specialization);
CREATE INDEX ix_patients_registered_at ON patients(registered_at);
CREATE INDEX ix_bills_status_date ON bills(status, bill_date);
CREATE INDEX ix_lab_orders_status_date ON patient_lab_orders(status, ordered_at);
