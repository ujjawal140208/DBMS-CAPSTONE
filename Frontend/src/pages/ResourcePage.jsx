import { useCallback, useEffect, useState } from 'react';
import api from '../services/api';

export default function ResourcePage({ title, endpoint, columns }) {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const load = useCallback(async () => {
    setLoading(true); setError('');
    try {
      const response = await api.get(endpoint);
      setItems(Array.isArray(response.data) ? response.data : []);
    } catch (err) {
      setError(err.message || 'Could not load this module.');
      setItems([]);
    } finally { setLoading(false); }
  }, [endpoint]);
  useEffect(() => { load(); }, [load]);
  const endpointMissing = /404|not found/i.test(error);
  return <>
    <div className="page-toolbar"><div><h2>{title}</h2><p className="muted">Records are requested from the live backend API. No mock data is shown.</p></div><button className="secondary-button" onClick={load} disabled={loading}>{loading ? 'Refreshing…' : '↻ Refresh'}</button></div>
    {error && <div className="notice error"><strong>{endpointMissing ? 'This module is not connected to a backend endpoint yet.' : 'Could not load data.'}</strong><div>{error}</div>{endpointMissing && <p className="muted">The frontend is ready to display these records once the corresponding FastAPI routes are implemented.</p>}</div>}
    <section className="panel"><div className="panel-heading"><div><h2>{title}</h2><p>{loading ? 'Loading records…' : `${items.length} record(s) loaded`}</p></div><span className="pill">Live API</span></div><div className="table-wrap"><table><thead><tr>{columns.map(column => <th key={column.key}>{column.label}</th>)}</tr></thead><tbody>
      {items.map((item, index) => <tr key={item.id ?? index}>{columns.map(column => <td key={column.key}>{formatValue(item[column.key])}</td>)}</tr>)}
      {loading && <tr><td colSpan={columns.length} className="empty">Loading {title.toLowerCase()}…</td></tr>}
      {!loading && !items.length && !error && <tr><td colSpan={columns.length} className="empty">No records available yet.</td></tr>}
      {!loading && !items.length && error && <tr><td colSpan={columns.length} className="empty">No live records to display.</td></tr>}
    </tbody></table></div></section>
  </>;
}
function formatValue(value) {
  if (value === null || value === undefined || value === '') return '—';
  if (typeof value === 'boolean') return value ? 'Yes' : 'No';
  if (typeof value === 'object') return JSON.stringify(value);
  return String(value);
}
