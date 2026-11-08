import api from './api';
export const billingService = { bills: () => api.get('/bills').then(r=>r.data), payments: () => api.get('/payments').then(r=>r.data) };
