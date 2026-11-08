from datetime import date, time, datetime
from decimal import Decimal
from pydantic import BaseModel, ConfigDict, EmailStr, Field, model_validator

class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)

class DepartmentCreate(BaseModel):
    name: str = Field(min_length=2, max_length=100)
    description: str | None = None
class DepartmentOut(ORMModel):
    id: int; name: str; description: str | None; is_active: bool

class DoctorCreate(BaseModel):
    full_name: str = Field(min_length=2, max_length=150)
    email: EmailStr | None = None
    phone: str | None = Field(default=None, max_length=25)
    specialization: str = Field(min_length=2, max_length=120)
    consultation_fee: Decimal = Field(default=Decimal("0.00"), ge=0, max_digits=10, decimal_places=2)
    department_id: int
class DoctorOut(ORMModel):
    id: int; full_name: str; email: str | None; phone: str | None; specialization: str; consultation_fee: Decimal; department_id: int; is_active: bool

class PatientCreate(BaseModel):
    full_name: str = Field(min_length=2, max_length=150)
    date_of_birth: date | None = None
    gender: str | None = Field(default=None, max_length=30)
    phone: str = Field(min_length=7, max_length=25)
    email: EmailStr | None = None
    address: str | None = None
    emergency_contact: str | None = Field(default=None, max_length=25)
class PatientUpdate(BaseModel):
    full_name: str | None = Field(default=None, min_length=2, max_length=150)
    date_of_birth: date | None = None; gender: str | None = None; phone: str | None = None
    email: EmailStr | None = None; address: str | None = None; emergency_contact: str | None = None
class PatientOut(ORMModel):
    id: int; full_name: str; date_of_birth: date | None; gender: str | None; phone: str; email: str | None; address: str | None; emergency_contact: str | None; registered_at: datetime; is_active: bool

class AppointmentCreate(BaseModel):
    patient_id: int; doctor_id: int; department_id: int
    appointment_date: date; start_time: time; end_time: time
    reason: str | None = None
    @model_validator(mode="after")
    def validate_times(self):
        if self.end_time <= self.start_time: raise ValueError("Appointment end time must be after start time")
        return self
class AppointmentStatusUpdate(BaseModel):
    status: str
class AppointmentOut(ORMModel):
    id: int; patient_id: int; doctor_id: int; department_id: int; appointment_date: date; start_time: time; end_time: time; status: str; reason: str | None; created_at: datetime
