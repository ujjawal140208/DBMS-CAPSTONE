import { useEffect, useState } from 'react';
import api from '../services/api';

const initialForm = { full_name: '', email: '', phone: '', specialization: '', consultation_fee: '0', department_id: '' };

export default function Doctors() {
  const [items, setItems] = useState([]);
  const [departments, setDepartments] = useState([]);
  const [form, setForm] = useState(initialForm);
  const [showForm, setShowForm] = useState(false);
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  async function load() {
    setLoading(true);
    try {
      const [doctorResponse, departmentResponse] = await Promise.all([
        api.get('/doctors', { params: { q: query || undefined } }),
        api.get('/departments'),
      ]);
      setItems(doctorResponse.data);
      setDepartments(departmentResponse.data);
      setError('');
    } catch (err) {
      setError(err.message || 'Could not load doctors.');
    } finally { setLoading(false); }
  }
  useEffect(() => { load(); }, []);

  async function submit(event) {
    event.preventDefault(); setSaving(true); setError(''); setNotice('');
    try {
      await api.post('/doctors', {
        ...form,
        email: form.email.trim() || null,
        phone: form.phone.trim() || null,
        consultation_fee: Number(form.consultation_fee || 0),
        department_id: Number(form.department_id),
      });
      setForm(initialForm); setShowForm(false); setNotice('Doctor added successfully.'); await load();
    } catch (err) { setError(err.message || 'Could not save doctor.'); }
    finally { setSaving(false); }
  }

  return <>
    <div className="page-toolbar"><div><h2>Medical team</h2><p className="muted">Manage doctors and their department assignments.</p></div><button className="primary-button" onClick={() => { setShowForm(v => !v); setError(''); }}>{showForm ? 'Close form' : '＋ Add doctor'}</button></div>
    {error && <div className="notice error">{error}</div>}{notice && <div className="notice success">{notice}</div>}
    {showForm && <form className="panel form-grid" onSubmit={submit}>
      <label>Full name *<input required minLength="2" value={form.full_name} onChange={e => setForm({ ...form, full_name: e.target.value })} /></label>
      <label>Specialization *<input required minLength="2" value={form.specialization} onChange={e => setForm({ ...form, specialization: e.target.value })} /></label>
      <label>Department *<select required value={form.department_id} onChange={e => setForm({ ...form, department_id: e.target.value })}><option value="">Select department</option>{departments.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}</select></label>
      <label>Email<input type="email" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} /></label>
      <label>Phone<input value={form.phone} onChange={e => setForm({ ...form, phone: e.target.value })} /></label>
      <label>Consultation fee (₹)<input type="number" min="0" step="0.01" required value={form.consultation_fee} onChange={e => setForm({ ...form, consultation_fee: e.target.value })} /></label>
      <div className="wide form-actions"><button className="primary-button" disabled={saving || !departments.length}>{saving ? 'Saving…' : 'Save doctor'}</button></div>
      {!departments.length && <p className="wide muted">Create a department first before adding a doctor.</p>}
    </form>}
    <section className="panel"><div className="panel-heading"><div><h2>Doctors</h2><p>{items.length} active record(s)</p></div><form className="search-form" onSubmit={e => { e.preventDefault(); load(); }}><input className="search-input" placeholder="Search doctor name…" value={query} onChange={e => setQuery(e.target.value)} /><button className="secondary-button">Search</button></form></div>
      <div className="table-wrap"><table><thead><tr><th>ID</th><th>Doctor</th><th>Specialization</th><th>Department</th><th>Consultation fee</th></tr></thead><tbody>
        {items.map(d => <tr key={d.id}><td>DR-{String(d.id).padStart(4, '0')}</td><td><strong>{d.full_name}</strong><small className="subline">{d.email || d.phone || 'Contact not provided'}</small></td><td>{d.specialization}</td><td>{departments.find(dep => dep.id === d.department_id)?.name || `Department #${d.department_id}`}</td><td>₹{Number(d.consultation_fee).toLocaleString('en-IN', { minimumFractionDigits: 2 })}</td></tr>)}
        {!loading && !items.length && <tr><td colSpan="5" className="empty">No doctors found.</td></tr>}{loading && <tr><td colSpan="5" className="empty">Loading doctors…</td></tr>}
      </tbody></table></div></section>
  </>;
}
