from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models import Department, Doctor
from app.schemas.entities import DepartmentCreate, DepartmentOut, DoctorCreate, DoctorOut
router = APIRouter(tags=["Doctors & Departments"])

@router.get("/departments", response_model=list[DepartmentOut])
def departments(db: Session = Depends(get_db)):
    return list(db.scalars(select(Department).where(Department.is_active.is_(True)).order_by(Department.name)).all())

@router.post("/departments", response_model=DepartmentOut, status_code=201)
def create_department(payload: DepartmentCreate, db: Session = Depends(get_db)):
    item = Department(**payload.model_dump()); db.add(item)
    try: db.commit(); db.refresh(item)
    except Exception as exc: db.rollback(); raise HTTPException(409, "Department name already exists") from exc
    return item

@router.get("/doctors", response_model=list[DoctorOut])
def doctors(department_id: int | None = None, q: str | None = None, db: Session = Depends(get_db)):
    stmt = select(Doctor).where(Doctor.is_active.is_(True))
    if department_id: stmt = stmt.where(Doctor.department_id == department_id)
    if q: stmt = stmt.where(Doctor.full_name.ilike(f"%{q}%"))
    return list(db.scalars(stmt.order_by(Doctor.full_name)).all())

@router.post("/doctors", response_model=DoctorOut, status_code=201)
def create_doctor(payload: DoctorCreate, db: Session = Depends(get_db)):
    if not db.get(Department, payload.department_id): raise HTTPException(422, "Department does not exist")
    item = Doctor(**payload.model_dump()); db.add(item)
    try: db.commit(); db.refresh(item)
    except Exception as exc: db.rollback(); raise HTTPException(409, "Doctor email or phone may already exist") from exc
    return item
