# Frontend — CarePoint

## Run
Copy `.env.example` to `.env`, then from `Frontend/`:

```powershell
npm install
npm run dev
```

Open `http://localhost:5173`. Set `VITE_API_BASE_URL=http://localhost:8000/api` if the backend runs elsewhere.

Dashboard, patient CRUD/deactivation, doctor/department listing, and appointment listing use live API requests. The remaining navigation pages are connected to their intended endpoints but require corresponding backend routes before they can display records. Do not use real patient information in this demo.
