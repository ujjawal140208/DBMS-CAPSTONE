from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, or_, func
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models import Patient
from app.schemas.entities import PatientCreate, PatientUpdate, PatientOut
router = APIRouter(prefix="/patients", tags=["Patients"])

@router.get("", response_model=list[PatientOut])
def list_patients(q: str | None = None, skip: int = Query(0, ge=0), limit: int = Query(20, ge=1, le=100), db: Session = Depends(get_db)):
    stmt = select(Patient).where(Patient.is_active.is_(True))
    if q: stmt = stmt.where(or_(Patient.full_name.ilike(f"%{q}%"), Patient.phone.ilike(f"%{q}%"), Patient.email.ilike(f"%{q}%")))
    return list(db.scalars(stmt.order_by(Patient.id.desc()).offset(skip).limit(limit)).all())

@router.post("", response_model=PatientOut, status_code=201)
def create_patient(payload: PatientCreate, db: Session = Depends(get_db)):
    patient = Patient(**payload.model_dump())
    db.add(patient)
    try: db.commit(); db.refresh(patient)
    except Exception as exc:
        db.rollback(); raise HTTPException(409, "Patient phone or email may already exist") from exc
    return patient

@router.get("/{patient_id}", response_model=PatientOut)
def get_patient(patient_id: int, db: Session = Depends(get_db)):
    item = db.get(Patient, patient_id)
    if not item: raise HTTPException(404, "Patient not found")
    return item

@router.put("/{patient_id}", response_model=PatientOut)
def update_patient(patient_id: int, payload: PatientUpdate, db: Session = Depends(get_db)):
    item = db.get(Patient, patient_id)
    if not item: raise HTTPException(404, "Patient not found")
    for key, value in payload.model_dump(exclude_unset=True).items(): setattr(item, key, value)
    try: db.commit(); db.refresh(item)
    except Exception as exc: db.rollback(); raise HTTPException(409, "Phone or email may already exist") from exc
    return item

@router.delete("/{patient_id}", status_code=204)
def deactivate_patient(patient_id: int, db: Session = Depends(get_db)):
    item = db.get(Patient, patient_id)
    if not item: raise HTTPException(404, "Patient not found")
    item.is_active = False; db.commit()
