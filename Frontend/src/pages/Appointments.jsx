import { useEffect, useState } from 'react';
import api from '../services/api';

const emptyForm = { patient_id: '', doctor_id: '', department_id: '', appointment_date: '', start_time: '09:00', end_time: '09:30', reason: '' };
const statuses = ['scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show'];

export default function Appointments() {
  const [items, setItems] = useState([]); const [patients, setPatients] = useState([]); const [doctors, setDoctors] = useState([]); const [departments, setDepartments] = useState([]);
  const [form, setForm] = useState(emptyForm); const [showForm, setShowForm] = useState(false); const [filters, setFilters] = useState({ appointment_date: '', status: '' });
  const [loading, setLoading] = useState(true); const [saving, setSaving] = useState(false); const [error, setError] = useState(''); const [notice, setNotice] = useState('');
  async function load(nextFilters = filters) {
    setLoading(true);
    try {
      const params = { ...nextFilters }; Object.keys(params).forEach(key => { if (!params[key]) delete params[key]; });
      const [a, p, d, dep] = await Promise.all([api.get('/appointments', { params }), api.get('/patients', { params: { limit: 100 } }), api.get('/doctors'), api.get('/departments')]);
      setItems(a.data); setPatients(p.data); setDoctors(d.data); setDepartments(dep.data); setError('');
    } catch (err) { setError(err.message || 'Could not load appointments.'); }
    finally { setLoading(false); }
  }
  useEffect(() => { load(); }, []);
  const availableDoctors = doctors.filter(d => !form.department_id || String(d.department_id) === String(form.department_id));
  async function submit(event) {
    event.preventDefault(); setSaving(true); setError(''); setNotice('');
    try {
      await api.post('/appointments', { ...form, patient_id: Number(form.patient_id), doctor_id: Number(form.doctor_id), department_id: Number(form.department_id), reason: form.reason.trim() || null });
      setForm(emptyForm); setShowForm(false); setNotice('Appointment booked successfully.'); await load();
    } catch (err) { setError(err.message || 'Could not book appointment.'); }
    finally { setSaving(false); }
  }
  async function changeStatus(id, status) {
    setError(''); setNotice('');
    try { await api.patch(`/appointments/${id}/status`, null, { params: { status } }); setNotice('Appointment status updated.'); await load(); }
    catch (err) { setError(err.message || 'Could not update appointment.'); }
  }
  return <>
    <div className="page-toolbar"><div><h2>Appointments</h2><p className="muted">Book visits, manage schedules and update appointment status.</p></div><button className="primary-button" onClick={() => { setShowForm(v => !v); setError(''); }}>{showForm ? 'Close form' : '＋ Book appointment'}</button></div>
    {error && <div className="notice error">{error}</div>}{notice && <div className="notice success">{notice}</div>}
    {showForm && <form className="panel form-grid" onSubmit={submit}>
      <label>Patient *<select required value={form.patient_id} onChange={e => setForm({ ...form, patient_id: e.target.value })}><option value="">Select patient</option>{patients.map(p => <option key={p.id} value={p.id}>{p.full_name} · #{p.id}</option>)}</select></label>
      <label>Department *<select required value={form.department_id} onChange={e => setForm({ ...form, department_id: e.target.value, doctor_id: '' })}><option value="">Select department</option>{departments.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}</select></label>
      <label>Doctor *<select required value={form.doctor_id} onChange={e => setForm({ ...form, doctor_id: e.target.value })}><option value="">Select doctor</option>{availableDoctors.map(d => <option key={d.id} value={d.id}>{d.full_name} — {d.specialization}</option>)}</select></label>
      <label>Date *<input required type="date" min={new Date().toISOString().slice(0, 10)} value={form.appointment_date} onChange={e => setForm({ ...form, appointment_date: e.target.value })} /></label>
      <label>Start time *<input required type="time" value={form.start_time} onChange={e => setForm({ ...form, start_time: e.target.value })} /></label>
      <label>End time *<input required type="time" min={form.start_time} value={form.end_time} onChange={e => setForm({ ...form, end_time: e.target.value })} /></label>
      <label className="wide">Reason for visit<input value={form.reason} onChange={e => setForm({ ...form, reason: e.target.value })} placeholder="Optional reason or notes" /></label>
      <div className="wide form-actions"><button className="primary-button" disabled={saving || !patients.length || !doctors.length || !departments.length}>{saving ? 'Booking…' : 'Confirm appointment'}</button></div>
      {(!patients.length || !doctors.length || !departments.length) && <p className="wide muted">You need at least one active patient, doctor and department before booking.</p>}
    </form>}
    <section className="panel"><div className="panel-heading"><div><h2>Appointment schedule</h2><p>{items.length} appointment(s) shown</p></div><div className="filter-row"><input aria-label="Filter by date" type="date" className="search-input" value={filters.appointment_date} onChange={e => setFilters({ ...filters, appointment_date: e.target.value })} /><select aria-label="Filter by status" className="search-input" value={filters.status} onChange={e => setFilters({ ...filters, status: e.target.value })}><option value="">All statuses</option>{statuses.map(s => <option key={s} value={s}>{s.replace('_', ' ')}</option>)}</select><button className="secondary-button" onClick={load}>Filter</button><button className="text-button" onClick={() => { const cleared = { appointment_date: '', status: '' }; setFilters(cleared); load(cleared); }}>Reset</button></div></div>
      <div className="table-wrap"><table><thead><tr><th>Appointment</th><th>Patient ID</th><th>Doctor ID</th><th>Date</th><th>Time</th><th>Status</th><th>Update status</th></tr></thead><tbody>
        {items.map(a => <tr key={a.id}><td><strong>APT-{String(a.id).padStart(4, '0')}</strong><small className="subline">{a.reason || 'General consultation'}</small></td><td>PT-{String(a.patient_id).padStart(4, '0')}</td><td>DR-{String(a.doctor_id).padStart(4, '0')}</td><td>{a.appointment_date}</td><td>{String(a.start_time).slice(0, 5)}–{String(a.end_time).slice(0, 5)}</td><td><span className={`status status-${a.status}`}>{a.status.replace('_', ' ')}</span></td><td><select className="compact-select" aria-label={`Update appointment ${a.id} status`} value={a.status} onChange={e => changeStatus(a.id, e.target.value)}>{statuses.map(s => <option key={s} value={s}>{s.replace('_', ' ')}</option>)}</select></td></tr>)}
        {loading && <tr><td colSpan="7" className="empty">Loading appointments…</td></tr>}{!loading && !items.length && <tr><td colSpan="7" className="empty">No appointments match these filters.</td></tr>}
      </tbody></table></div></section>
  </>;
}
