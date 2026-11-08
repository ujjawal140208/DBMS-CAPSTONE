from datetime import date
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models import Appointment
from app.schemas.entities import AppointmentCreate, AppointmentOut
from app.services.appointments import create_appointment
router = APIRouter(prefix="/appointments", tags=["Appointments"])

@router.get("", response_model=list[AppointmentOut])
def list_appointments(appointment_date: date | None = None, status: str | None = None, doctor_id: int | None = None, patient_id: int | None = None, skip: int = Query(0, ge=0), limit: int = Query(100, ge=1, le=500), db: Session = Depends(get_db)):
    stmt = select(Appointment)
    if appointment_date: stmt = stmt.where(Appointment.appointment_date == appointment_date)
    if status: stmt = stmt.where(Appointment.status == status)
    if doctor_id: stmt = stmt.where(Appointment.doctor_id == doctor_id)
    if patient_id: stmt = stmt.where(Appointment.patient_id == patient_id)
    return list(db.scalars(stmt.order_by(Appointment.appointment_date.desc(), Appointment.start_time).offset(skip).limit(limit)).all())

@router.post("", response_model=AppointmentOut, status_code=201)
def book_appointment(payload: AppointmentCreate, db: Session = Depends(get_db)):
    return create_appointment(db, payload)

@router.get("/{appointment_id}", response_model=AppointmentOut)
def get_appointment(appointment_id: int, db: Session = Depends(get_db)):
    item = db.get(Appointment, appointment_id)
    if not item: raise HTTPException(404, "Appointment not found")
    return item

@router.patch("/{appointment_id}/status", response_model=AppointmentOut)
def update_status(appointment_id: int, status: str, db: Session = Depends(get_db)):
    allowed = {"scheduled", "confirmed", "in_progress", "completed", "cancelled", "no_show"}
    if status not in allowed: raise HTTPException(422, f"Status must be one of: {', '.join(sorted(allowed))}")
    item = db.get(Appointment, appointment_id)
    if not item: raise HTTPException(404, "Appointment not found")
    item.status = status; db.commit(); db.refresh(item); return item
