import axios from 'axios';
const api = axios.create({ baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api', timeout: 10000, headers: { 'Content-Type': 'application/json' } });
api.interceptors.response.use(response => response, error => { const message = error.response?.data?.detail || error.message || 'Request failed'; return Promise.reject(new Error(Array.isArray(message) ? message.map(x => x.msg).join(', ') : message)); });
export default api;
