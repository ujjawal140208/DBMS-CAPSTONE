from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload
from app.models import Appointment, Doctor, Patient, Department
from app.schemas.entities import AppointmentCreate

ACTIVE_STATUSES = ("scheduled", "confirmed", "in_progress")

def create_appointment(db: Session, payload: AppointmentCreate) -> Appointment:
    patient = db.get(Patient, payload.patient_id)
    doctor = db.get(Doctor, payload.doctor_id)
    department = db.get(Department, payload.department_id)
    if not patient or not patient.is_active: raise HTTPException(404, "Active patient not found")
    if not doctor or not doctor.is_active: raise HTTPException(404, "Active doctor not found")
    if not department or not department.is_active: raise HTTPException(404, "Active department not found")
    if doctor.department_id != payload.department_id: raise HTTPException(422, "Selected doctor does not belong to this department")
    # Transactional overlap validation. For high-concurrency production use, serialize bookings per doctor/day
    # with a dedicated lock row or MySQL advisory lock; the database indexes support the lookup.
    conflict = db.scalar(select(Appointment.id).where(
        Appointment.appointment_date == payload.appointment_date,
        Appointment.status.in_(ACTIVE_STATUSES),
        Appointment.start_time < payload.end_time,
        Appointment.end_time > payload.start_time,
        ((Appointment.doctor_id == payload.doctor_id) | (Appointment.patient_id == payload.patient_id))
    ).limit(1))
    if conflict:
        raise HTTPException(409, "This time overlaps an active appointment for the selected doctor or patient")
    appointment = Appointment(**payload.model_dump(), status="scheduled")
    db.add(appointment)
    try:
        db.commit(); db.refresh(appointment)
    except Exception:
        db.rollback(); raise
    return appointment
