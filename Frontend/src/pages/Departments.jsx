import { useEffect, useState } from 'react';
import api from '../services/api';

export default function Departments() {
  const [items, setItems] = useState([]);
  const [form, setForm] = useState({ name: '', description: '' });
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  async function load() {
    setLoading(true);
    try { const response = await api.get('/departments'); setItems(response.data); setError(''); }
    catch (err) { setError(err.message || 'Could not load departments.'); }
    finally { setLoading(false); }
  }
  useEffect(() => { load(); }, []);
  async function submit(event) {
    event.preventDefault(); setSaving(true); setError(''); setNotice('');
    try { await api.post('/departments', { name: form.name.trim(), description: form.description.trim() || null }); setForm({ name: '', description: '' }); setShowForm(false); setNotice('Department created successfully.'); await load(); }
    catch (err) { setError(err.message || 'Could not create department.'); }
    finally { setSaving(false); }
  }
  return <>
    <div className="page-toolbar"><div><h2>Departments</h2><p className="muted">Organize clinical teams and hospital services.</p></div><button className="primary-button" onClick={() => { setShowForm(v => !v); setError(''); }}>{showForm ? 'Close form' : '＋ Add department'}</button></div>
    {error && <div className="notice error">{error}</div>}{notice && <div className="notice success">{notice}</div>}
    {showForm && <form className="panel form-grid" onSubmit={submit}><label>Department name *<input required minLength="2" maxLength="100" value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} /></label><label className="wide">Description<input value={form.description} onChange={e => setForm({ ...form, description: e.target.value })} placeholder="Brief description of this department" /></label><div className="wide form-actions"><button className="primary-button" disabled={saving}>{saving ? 'Saving…' : 'Save department'}</button></div></form>}
    <section className="panel"><div className="panel-heading"><div><h2>Hospital departments</h2><p>{items.length} active department(s)</p></div><span className="pill">Live data</span></div><div className="department-grid">
      {items.map(d => <article className="department-card" key={d.id}><div className="department-mark">{d.name.slice(0, 1).toUpperCase()}</div><div><h3>{d.name}</h3><p>{d.description || 'Hospital clinical department'}</p><small>Department ID: {d.id}</small></div><span className="active-label"><i /> Active</span></article>)}
      {loading && <p className="empty">Loading departments…</p>}{!loading && !items.length && <p className="empty">No departments found.</p>}
    </div></section>
  </>;
}
