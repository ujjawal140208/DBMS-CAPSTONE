CREATE DATABASE IF NOT EXISTS hospital_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hospital_db;
CREATE TABLE IF NOT EXISTS departments (
 id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE,
 description TEXT NULL, is_active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS doctors (
 id INT AUTO_INCREMENT PRIMARY KEY, full_name VARCHAR(150) NOT NULL,
 email VARCHAR(255) NULL UNIQUE, phone VARCHAR(25) NULL UNIQUE,
 specialization VARCHAR(120) NOT NULL, consultation_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
 department_id INT NOT NULL, is_active BOOLEAN NOT NULL DEFAULT TRUE,
 CONSTRAINT chk_doctor_fee CHECK (consultation_fee >= 0),
 CONSTRAINT fk_doctor_department FOREIGN KEY (department_id) REFERENCES departments(id) ON UPDATE CASCADE ON DELETE RESTRICT,
 INDEX ix_doctors_department (department_id), INDEX ix_doctors_name (full_name)
);
CREATE TABLE IF NOT EXISTS patients (
 id INT AUTO_INCREMENT PRIMARY KEY, full_name VARCHAR(150) NOT NULL,
 date_of_birth DATE NULL, gender VARCHAR(30) NULL, phone VARCHAR(25) NOT NULL UNIQUE,
 email VARCHAR(255) NULL UNIQUE, address TEXT NULL, emergency_contact VARCHAR(25) NULL,
 registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, is_active BOOLEAN NOT NULL DEFAULT TRUE,
 INDEX ix_patients_name (full_name)
);
CREATE TABLE IF NOT EXISTS appointments (
 id INT AUTO_INCREMENT PRIMARY KEY, patient_id INT NOT NULL, doctor_id INT NOT NULL, department_id INT NOT NULL,
 appointment_date DATE NOT NULL, start_time TIME NOT NULL, end_time TIME NOT NULL,
 status ENUM('scheduled','confirmed','in_progress','completed','cancelled','no_show') NOT NULL DEFAULT 'scheduled',
 reason TEXT NULL, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT chk_appointment_time CHECK (end_time > start_time),
 CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT fk_appointment_department FOREIGN KEY (department_id) REFERENCES departments(id) ON UPDATE CASCADE ON DELETE RESTRICT,
 INDEX ix_appointments_doctor_start (doctor_id, appointment_date, start_time, end_time),
 INDEX ix_appointments_patient_start (patient_id, appointment_date, start_time, end_time),
 INDEX ix_appointments_status_date (status, appointment_date)
);
CREATE TABLE IF NOT EXISTS medicines (
 id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(150) NOT NULL, category VARCHAR(100) NULL,
 manufacturer VARCHAR(150) NULL, unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
 is_active BOOLEAN NOT NULL DEFAULT TRUE, CONSTRAINT chk_medicine_price CHECK(unit_price >= 0), INDEX ix_medicines_name(name)
);
CREATE TABLE IF NOT EXISTS prescriptions (
 id INT AUTO_INCREMENT PRIMARY KEY, patient_id INT NOT NULL, doctor_id INT NOT NULL, appointment_id INT NULL,
 prescribed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, notes TEXT NULL,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT,
 FOREIGN KEY(appointment_id) REFERENCES appointments(id) ON DELETE SET NULL,
 INDEX ix_prescriptions_patient(patient_id)
);
CREATE TABLE IF NOT EXISTS prescription_items (
 id INT AUTO_INCREMENT PRIMARY KEY, prescription_id INT NOT NULL, medicine_id INT NOT NULL,
 dosage VARCHAR(100) NOT NULL, frequency VARCHAR(100) NOT NULL, duration_days INT NOT NULL,
 instructions TEXT NULL, CONSTRAINT chk_duration CHECK(duration_days > 0),
 FOREIGN KEY(prescription_id) REFERENCES prescriptions(id) ON DELETE CASCADE,
 FOREIGN KEY(medicine_id) REFERENCES medicines(id) ON DELETE RESTRICT
);
CREATE TABLE IF NOT EXISTS lab_tests (
 id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(150) NOT NULL UNIQUE, description TEXT NULL,
 standard_price DECIMAL(10,2) NOT NULL DEFAULT 0.00, is_active BOOLEAN NOT NULL DEFAULT TRUE,
 CONSTRAINT chk_lab_price CHECK(standard_price >= 0)
);
CREATE TABLE IF NOT EXISTS patient_lab_orders (
 id INT AUTO_INCREMENT PRIMARY KEY, patient_id INT NOT NULL, lab_test_id INT NOT NULL, appointment_id INT NULL,
 status ENUM('requested','in_progress','completed','cancelled') NOT NULL DEFAULT 'requested',
 result_text TEXT NULL, ordered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, report_date DATETIME NULL,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(lab_test_id) REFERENCES lab_tests(id) ON DELETE RESTRICT,
 FOREIGN KEY(appointment_id) REFERENCES appointments(id) ON DELETE SET NULL,
 INDEX ix_lab_orders_patient_status(patient_id,status)
);
CREATE TABLE IF NOT EXISTS bills (
 id INT AUTO_INCREMENT PRIMARY KEY, patient_id INT NOT NULL, appointment_id INT NULL,
 bill_date DATE NOT NULL, subtotal DECIMAL(12,2) NOT NULL, discount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
 total_amount DECIMAL(12,2) NOT NULL, status ENUM('unpaid','partially_paid','paid','void') NOT NULL DEFAULT 'unpaid',
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(appointment_id) REFERENCES appointments(id) ON DELETE SET NULL,
 CONSTRAINT chk_bill_amounts CHECK(subtotal >= 0 AND discount >= 0 AND total_amount >= 0 AND discount <= subtotal),
 INDEX ix_bills_patient_date(patient_id,bill_date)
);
CREATE TABLE IF NOT EXISTS bill_items (
 id INT AUTO_INCREMENT PRIMARY KEY, bill_id INT NOT NULL, description VARCHAR(255) NOT NULL,
 quantity DECIMAL(10,2) NOT NULL DEFAULT 1.00, unit_price DECIMAL(12,2) NOT NULL,
 line_total DECIMAL(12,2) NOT NULL,
 FOREIGN KEY(bill_id) REFERENCES bills(id) ON DELETE CASCADE,
 CONSTRAINT chk_bill_item CHECK(quantity > 0 AND unit_price >= 0 AND line_total >= 0)
);
CREATE TABLE IF NOT EXISTS payments (
 id INT AUTO_INCREMENT PRIMARY KEY, bill_id INT NOT NULL, amount DECIMAL(12,2) NOT NULL,
 payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 method ENUM('cash','card','upi','bank_transfer','simulated_online') NOT NULL,
 transaction_reference VARCHAR(100) NULL UNIQUE, notes VARCHAR(255) NULL,
 FOREIGN KEY(bill_id) REFERENCES bills(id) ON DELETE RESTRICT,
 CONSTRAINT chk_payment_amount CHECK(amount > 0), INDEX ix_payments_bill_date(bill_id,payment_date)
);
CREATE TABLE IF NOT EXISTS audit_log (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, table_name VARCHAR(64) NOT NULL, record_id INT NOT NULL,
 action_name VARCHAR(20) NOT NULL, changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 details JSON NULL
);
