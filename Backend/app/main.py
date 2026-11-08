from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from app.core.config import settings
from app.database.connection import engine
from app.models import Department, Doctor, Patient, Appointment  # register ORM metadata
from app.routers import patients, catalog, appointments, dashboard

app = FastAPI(title=settings.app_name, version="1.0.0", description="Hospital administration API. Configure MySQL before using data endpoints.")
app.add_middleware(CORSMiddleware, allow_origins=[settings.frontend_origin, "http://127.0.0.1:5173"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])
app.include_router(patients.router, prefix=settings.api_prefix)
app.include_router(catalog.router, prefix=settings.api_prefix)
app.include_router(appointments.router, prefix=settings.api_prefix)
app.include_router(dashboard.router, prefix=settings.api_prefix)

@app.get(f"{settings.api_prefix}/health", tags=["Health"])
def health():
    try:
        with engine.connect() as connection: connection.execute(text("SELECT 1"))
        return {"status": "ok", "database": "connected"}
    except Exception:
        return {"status": "degraded", "database": "unavailable", "message": "Check Backend/.env and ensure MySQL is running."}

@app.get("/", include_in_schema=False)
def root(): return {"message": "Hospital Management API", "docs": "/docs"}
