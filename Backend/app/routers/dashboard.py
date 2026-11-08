from datetime import date
from fastapi import APIRouter, Depends
from sqlalchemy import select, func
from sqlalchemy.orm import Session, joinedload
from app.database.session import get_db
from app.models import Patient, Doctor, Department, Appointment
router = APIRouter(prefix="/dashboard", tags=["Dashboard"])

@router.get("/stats")
def dashboard_stats(db: Session = Depends(get_db)):
    today = date.today()
    count = lambda model, *criteria: db.scalar(select(func.count()).select_from(model).where(*criteria)) or 0
    active = Appointment.status.in_(["scheduled", "confirmed", "in_progress"])
    total_today = count(Appointment, Appointment.appointment_date == today)
    by_status = {status: count(Appointment, Appointment.appointment_date == today, Appointment.status == status) for status in ["scheduled", "confirmed", "in_progress", "completed", "cancelled", "no_show"]}
    recent = db.scalars(select(Appointment).options(joinedload(Appointment.patient), joinedload(Appointment.doctor)).order_by(Appointment.created_at.desc()).limit(8)).unique().all()
    return {"total_patients": count(Patient, Patient.is_active.is_(True)), "total_doctors": count(Doctor, Doctor.is_active.is_(True)), "total_departments": count(Department, Department.is_active.is_(True)), "today_appointments": total_today, "appointments_by_status_today": by_status, "recent_appointments": [{"id": a.id, "patient_name": a.patient.full_name, "doctor_name": a.doctor.full_name, "date": a.appointment_date.isoformat(), "start_time": a.start_time.strftime("%H:%M"), "status": a.status} for a in recent]}
