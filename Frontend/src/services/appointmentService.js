import api from './api';
export const appointmentService = { list: (params={}) => api.get('/appointments',{params}).then(r=>r.data), create: data => api.post('/appointments',data).then(r=>r.data), updateStatus: (id,status) => api.patch(`/appointments/${id}/status`,null,{params:{status}}).then(r=>r.data) };
