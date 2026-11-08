import api from './api';
export const medicalService = { medicines: () => api.get('/medicines').then(r=>r.data), prescriptions: () => api.get('/prescriptions').then(r=>r.data), labTests: () => api.get('/lab-tests').then(r=>r.data) };
