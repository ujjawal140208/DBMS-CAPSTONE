from datetime import time
import pytest
from pydantic import ValidationError
from app.schemas.entities import AppointmentCreate

def test_appointment_rejects_end_before_start():
    with pytest.raises(ValidationError):
        AppointmentCreate(patient_id=1, doctor_id=1, department_id=1, appointment_date="2026-10-25", start_time=time(11,0), end_time=time(10,0))

def test_appointment_accepts_valid_times():
    item = AppointmentCreate(patient_id=1, doctor_id=1, department_id=1, appointment_date="2026-10-25", start_time=time(10,0), end_time=time(10,30))
    assert item.end_time > item.start_time
