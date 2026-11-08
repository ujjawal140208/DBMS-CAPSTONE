import api from './api';
export const doctorService = { list: (params={}) => api.get('/doctors',{params}).then(r=>r.data), create: data => api.post('/doctors',data).then(r=>r.data), departments: () => api.get('/departments').then(r=>r.data), createDepartment: data => api.post('/departments',data).then(r=>r.data) };
