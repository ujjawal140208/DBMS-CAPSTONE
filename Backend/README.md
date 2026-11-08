# Backend — Hospital Management API

## Stack
FastAPI, SQLAlchemy 2, Pydantic 2, PyMySQL, MySQL 8+, Uvicorn, pytest.

## Run on Windows (PowerShell)
1. Install MySQL Server and create a local database/user, or run `Backend/sql/01_schema.sql` using a MySQL client.
2. Copy `.env.example` to `.env` and set `DATABASE_URL` to your MySQL credentials.
3. From `Backend/` run:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

Open `http://localhost:8000/docs`. `GET /api/health` reports API/database status.

## Implemented endpoints
- `GET /api/health`
- `GET/POST /api/patients`, `GET/PUT/DELETE /api/patients/{id}`
- `GET/POST /api/doctors`
- `GET/POST /api/departments`
- `GET/POST /api/appointments`, `GET /api/appointments/{id}`, `PATCH /api/appointments/{id}/status`
- `GET /api/dashboard/stats`

Appointment booking validates patient, doctor, department, department assignment, end time and overlapping active appointments. The overlap check is transaction-backed, but the current implementation is not a fully serialized concurrency-safe booking system under simultaneous requests; see root README limitations.

## SQL scripts
Run in numeric order: schema, indexes, views, procedures, triggers, seed data, reports. SQL scripts use MySQL 8 syntax. SQLAlchemy currently exposes core operational modules; prescriptions, medicines, laboratory, billing and payment tables are defined in SQL but their CRUD APIs are not yet implemented.

## Tests
From `Backend/`: `pytest`. Tests currently cover Pydantic appointment time validation. API/database integration tests require an isolated configured test database and are not claimed as completed.
