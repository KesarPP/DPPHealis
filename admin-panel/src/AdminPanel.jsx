import React, { useState, useEffect } from 'react';
import { db } from './firebase';
import {
  collection,
  getDocs,
  doc,
  updateDoc,
  onSnapshot,
  query,
  orderBy,
} from 'firebase/firestore';

// ─── Icons as inline SVG ─────────────────────────────────────────────────────
const IconUsers = () => (
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>
    <path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
  </svg>
);
const IconCoaches = () => (
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <circle cx="12" cy="8" r="4"/><path d="M20 21a8 8 0 1 0-16 0"/>
    <path d="M12 12v9m0 0l-3-3m3 3l3-3"/>
  </svg>
);
const IconAssign = () => (
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
    <circle cx="9" cy="7" r="4"/>
    <line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/>
  </svg>
);
const IconLogout = () => (
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
    <polyline points="16 17 21 12 16 7"/>
    <line x1="21" y1="12" x2="9" y2="12"/>
  </svg>
);
const IconSearch = () => (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
  </svg>
);

// ─── Helpers ──────────────────────────────────────────────────────────────────
function initials(name = '') {
  const parts = name.trim().split(' ').filter(Boolean);
  if (parts.length === 0) return '??';
  if (parts.length === 1) return parts[0][0].toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

function Avatar({ name, size = 40, color = '#1B3D6D' }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%',
      background: color, color: '#fff',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontWeight: 700, fontSize: size * 0.35, flexShrink: 0,
    }}>
      {initials(name)}
    </div>
  );
}

function Badge({ children, color = '#3B82F6', bg = '#DBEAFE' }) {
  return (
    <span style={{
      background: bg, color, borderRadius: 20, padding: '3px 10px',
      fontSize: 11, fontWeight: 700, letterSpacing: 0.3,
    }}>
      {children}
    </span>
  );
}

// ─── Stats Card ───────────────────────────────────────────────────────────────
function StatsCard({ label, value, icon, accent }) {
  return (
    <div className="stats-card" style={{ borderTop: `3px solid ${accent}` }}>
      <div style={{ fontSize: 28, marginBottom: 4 }}>{icon}</div>
      <div style={{ fontSize: 32, fontWeight: 800, color: accent }}>{value}</div>
      <div style={{ fontSize: 13, color: '#64748B', fontWeight: 600 }}>{label}</div>
    </div>
  );
}

// ─── Patients Tab ─────────────────────────────────────────────────────────────
function PatientsTab({ users, coaches }) {
  const [search, setSearch] = useState('');
  const filtered = users.filter(u =>
    (u.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (u.email || '').toLowerCase().includes(search.toLowerCase())
  );

  const coachMap = {};
  coaches.forEach(c => { coachMap[c.id] = c.name || c.email || c.id; });

  return (
    <div className="tab-content">
      <div className="tab-header">
        <div>
          <h2>Patients <span className="count-badge">{users.length}</span></h2>
          <p>All registered patients in the program</p>
        </div>
        <div className="search-box">
          <IconSearch />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search patients…" />
        </div>
      </div>
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Patient</th>
              <th>Email</th>
              <th>Phone</th>
              <th>IDRS Score</th>
              <th>Risk</th>
              <th>Assigned Coach</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr><td colSpan={6} style={{ textAlign: 'center', padding: 32, color: '#94A3B8' }}>No patients found</td></tr>
            ) : filtered.map(u => (
              <tr key={u.id}>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                    <Avatar name={u.name || 'Unknown'} size={36} />
                    <span style={{ fontWeight: 600 }}>{u.name || 'Unknown'}</span>
                  </div>
                </td>
                <td style={{ color: '#64748B' }}>{u.email || '—'}</td>
                <td style={{ color: '#64748B' }}>{u.phoneNumber || '—'}</td>
                <td>
                  {u.idrsScore != null
                    ? <Badge color="#7C3AED" bg="#EDE9FE">{u.idrsScore}</Badge>
                    : <span style={{ color: '#CBD5E1' }}>N/A</span>}
                </td>
                <td>
                  {u.idrsScore >= 60
                    ? <Badge color="#991B1B" bg="#FEE2E2">HIGH</Badge>
                    : u.idrsScore >= 30
                      ? <Badge color="#92400E" bg="#FEF3C7">MODERATE</Badge>
                      : u.idrsScore != null
                        ? <Badge color="#065F46" bg="#D1FAE5">LOW</Badge>
                        : <span style={{ color: '#CBD5E1' }}>—</span>}
                </td>
                <td>
                  {u.assignedCoachId
                    ? <Badge color="#1D4ED8" bg="#DBEAFE">{coachMap[u.assignedCoachId] || u.assignedCoachId}</Badge>
                    : <span style={{ color: '#CBD5E1' }}>Unassigned</span>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ─── Coaches Tab ──────────────────────────────────────────────────────────────
function CoachesTab({ coaches, users }) {
  const [search, setSearch] = useState('');
  const filtered = coaches.filter(c =>
    (c.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (c.email || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="tab-content">
      <div className="tab-header">
        <div>
          <h2>Coaches <span className="count-badge">{coaches.length}</span></h2>
          <p>All registered coaches / clinicians</p>
        </div>
        <div className="search-box">
          <IconSearch />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search coaches…" />
        </div>
      </div>
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Coach</th>
              <th>Email</th>
              <th>Phone</th>
              <th>Patients Assigned</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr><td colSpan={4} style={{ textAlign: 'center', padding: 32, color: '#94A3B8' }}>No coaches found</td></tr>
            ) : filtered.map(c => {
              const assignedCount = users.filter(u => u.assignedCoachId === c.id).length;
              return (
                <tr key={c.id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <Avatar name={c.name || 'Coach'} size={36} color="#10B981" />
                      <span style={{ fontWeight: 600 }}>{c.name || 'Unknown'}</span>
                    </div>
                  </td>
                  <td style={{ color: '#64748B' }}>{c.email || '—'}</td>
                  <td style={{ color: '#64748B' }}>{c.phoneNumber || '—'}</td>
                  <td>
                    <Badge color="#065F46" bg="#D1FAE5">{assignedCount} patient{assignedCount !== 1 ? 's' : ''}</Badge>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ─── Assign Tab ───────────────────────────────────────────────────────────────
function AssignTab({ users, coaches, onAssign, assigning }) {
  const [search, setSearch] = useState('');
  const [selectedCoachFilter, setSelectedCoachFilter] = useState('');
  const filtered = users.filter(u => {
    const matchSearch = (u.name || '').toLowerCase().includes(search.toLowerCase()) ||
      (u.email || '').toLowerCase().includes(search.toLowerCase());
    const matchCoach = selectedCoachFilter === '' || u.assignedCoachId === selectedCoachFilter;
    return matchSearch && matchCoach;
  });

  const coachMap = {};
  coaches.forEach(c => { coachMap[c.id] = c.name || c.email || c.id; });

  return (
    <div className="tab-content">
      <div className="tab-header">
        <div>
          <h2>Assign Patients to Coaches</h2>
          <p>Select a coach from the dropdown to assign a patient</p>
        </div>
        <div style={{ display: 'flex', gap: 10 }}>
          <div className="search-box">
            <IconSearch />
            <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search patients…" />
          </div>
          <select
            className="filter-select"
            value={selectedCoachFilter}
            onChange={e => setSelectedCoachFilter(e.target.value)}
          >
            <option value="">All Coaches</option>
            <option value="__unassigned">Unassigned</option>
            {coaches.map(c => <option key={c.id} value={c.id}>{c.name || c.email}</option>)}
          </select>
        </div>
      </div>

      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Patient</th>
              <th>Email</th>
              <th>IDRS Risk</th>
              <th>Current Coach</th>
              <th>Assign Coach</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr><td colSpan={5} style={{ textAlign: 'center', padding: 32, color: '#94A3B8' }}>No patients found</td></tr>
            ) : filtered
              .filter(u => selectedCoachFilter !== '__unassigned' || !u.assignedCoachId)
              .map(u => (
                <tr key={u.id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <Avatar name={u.name || 'Unknown'} size={36} />
                      <span style={{ fontWeight: 600 }}>{u.name || 'Unknown'}</span>
                    </div>
                  </td>
                  <td style={{ color: '#64748B' }}>{u.email || '—'}</td>
                  <td>
                    {u.idrsScore >= 60
                      ? <Badge color="#991B1B" bg="#FEE2E2">HIGH {u.idrsScore}</Badge>
                      : u.idrsScore >= 30
                        ? <Badge color="#92400E" bg="#FEF3C7">MODERATE {u.idrsScore}</Badge>
                        : u.idrsScore != null
                          ? <Badge color="#065F46" bg="#D1FAE5">LOW {u.idrsScore}</Badge>
                          : <span style={{ color: '#CBD5E1' }}>—</span>}
                  </td>
                  <td>
                    {u.assignedCoachId
                      ? <Badge color="#1D4ED8" bg="#DBEAFE">{coachMap[u.assignedCoachId] || u.assignedCoachId}</Badge>
                      : <span style={{ color: '#CBD5E1', fontSize: 13 }}>Unassigned</span>}
                  </td>
                  <td>
                    <select
                      className="assign-select"
                      value={u.assignedCoachId || ''}
                      onChange={e => onAssign(u.id, e.target.value || null)}
                      disabled={assigning === u.id}
                    >
                      <option value="">— Unassign —</option>
                      {coaches.map(c => (
                        <option key={c.id} value={c.id}>{c.name || c.email}</option>
                      ))}
                    </select>
                    {assigning === u.id && <span style={{ marginLeft: 8, color: '#64748B', fontSize: 12 }}>Saving…</span>}
                  </td>
                </tr>
              ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ─── Main Admin Panel ─────────────────────────────────────────────────────────
export default function AdminPanel({ onLogout }) {
  const [tab, setTab] = useState('patients');
  const [users, setUsers] = useState([]);
  const [coaches, setCoaches] = useState([]);
  const [loading, setLoading] = useState(true);
  const [assigning, setAssigning] = useState(null);
  const [toast, setToast] = useState(null);

  // ── Load users (real-time) ─────────────────────────────────────────────────
  useEffect(() => {
    const unsub = onSnapshot(
      collection(db, 'users'),
      snap => {
        setUsers(snap.docs.map(d => ({ id: d.id, ...d.data() })));
        setLoading(false);
      },
      err => { console.error(err); setLoading(false); }
    );
    return unsub;
  }, []);

  // ── Load coaches (real-time) ───────────────────────────────────────────────
  useEffect(() => {
    const unsub = onSnapshot(
      collection(db, 'coaches'),
      snap => setCoaches(snap.docs.map(d => ({ id: d.id, ...d.data() }))),
      err => console.error(err)
    );
    return unsub;
  }, []);

  // ── Assign a coach to a user ───────────────────────────────────────────────
  const handleAssign = async (userId, coachId) => {
    setAssigning(userId);
    try {
      await updateDoc(doc(db, 'users', userId), { assignedCoachId: coachId || null });
      showToast(coachId ? '✅ Coach assigned successfully!' : '✅ Patient unassigned.');
    } catch (e) {
      showToast('❌ Failed to update assignment. Check Firestore rules.');
      console.error(e);
    }
    setAssigning(null);
  };

  const showToast = (msg) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  };

  const assignedCount = users.filter(u => u.assignedCoachId).length;
  const unassignedCount = users.length - assignedCount;

  const navItems = [
    { id: 'patients', label: 'Patients', icon: <IconUsers /> },
    { id: 'coaches', label: 'Coaches', icon: <IconCoaches /> },
    { id: 'assign', label: 'Assign', icon: <IconAssign /> },
  ];

  return (
    <div className="panel-root">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-brand">
          <div className="brand-icon">DPP</div>
          <div>
            <div style={{ fontWeight: 800, fontSize: 14, color: '#fff' }}>Diabetes Prevention</div>
            <div style={{ fontSize: 11, color: '#94A3B8' }}>Admin Panel</div>
          </div>
        </div>

        <nav className="sidebar-nav">
          {navItems.map(n => (
            <button
              key={n.id}
              className={`nav-item ${tab === n.id ? 'nav-active' : ''}`}
              onClick={() => setTab(n.id)}
            >
              {n.icon}
              <span>{n.label}</span>
            </button>
          ))}
        </nav>

        <div className="sidebar-footer">
          <button className="logout-btn" onClick={onLogout}>
            <IconLogout />
            <span>Log Out</span>
          </button>
        </div>
      </aside>

      {/* Main */}
      <main className="main-content">
        {/* Top Bar */}
        <header className="topbar">
          <div>
            <h1 className="topbar-title">
              {tab === 'patients' ? 'Patient Management'
                : tab === 'coaches' ? 'Coach Management'
                  : 'Assign Patients'}
            </h1>
            <p className="topbar-sub">Healis DPP Admin — Real-time Firestore</p>
          </div>
          <div className="topbar-right">
            <div className="online-dot" />
            <span style={{ fontSize: 13, color: '#64748B' }}>Live</span>
          </div>
        </header>

        {/* Stats */}
        <div className="stats-row">
          <StatsCard label="Total Patients" value={loading ? '…' : users.length} icon="👥" accent="#3B82F6" />
          <StatsCard label="Total Coaches" value={loading ? '…' : coaches.length} icon="🏥" accent="#10B981" />
          <StatsCard label="Assigned" value={loading ? '…' : assignedCount} icon="🔗" accent="#8B5CF6" />
          <StatsCard label="Unassigned" value={loading ? '…' : unassignedCount} icon="⚠️" accent="#F59E0B" />
        </div>

        {/* Tab Content */}
        {loading ? (
          <div className="loading-screen">
            <div className="spinner-large" />
            <p>Loading data from Firestore…</p>
          </div>
        ) : (
          <>
            {tab === 'patients' && <PatientsTab users={users} coaches={coaches} />}
            {tab === 'coaches' && <CoachesTab coaches={coaches} users={users} />}
            {tab === 'assign' && <AssignTab users={users} coaches={coaches} onAssign={handleAssign} assigning={assigning} />}
          </>
        )}
      </main>

      {/* Toast */}
      {toast && <div className="toast">{toast}</div>}
    </div>
  );
}
