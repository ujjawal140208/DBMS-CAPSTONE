import api from './api';
export const patientService = { list: (params={}) => api.get('/patients',{params}).then(r=>r.data), get: id => api.get(`/patients/${id}`).then(r=>r.data), create: data => api.post('/patients',data).then(r=>r.data), update: (id,data) => api.put(`/patients/${id}`,data).then(r=>r.data), deactivate: id => api.delete(`/patients/${id}`) };
