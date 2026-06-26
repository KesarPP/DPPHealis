import React, { useState, useEffect } from 'react';
import { db } from './firebase';
import {
  collection,
  doc,
  updateDoc,
  deleteDoc,
  onSnapshot,
  getDocs,
  writeBatch,
  query,
  where
} from 'firebase/firestore';

// ─── Inline SVG Icons ─────────────────────────────────────────────────────────
const IconUsers   = () => <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>;
const IconCoaches = () => <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="8" r="4"/><path d="M20 21a8 8 0 1 0-16 0"/></svg>;
const IconAssign  = () => <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg>;
const IconLogout  = () => <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>;
const IconSearch  = () => <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>;
const IconEdit    = () => <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>;
const IconDelete  = () => <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>;
const IconClose   = () => <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>;

// ─── Helpers ──────────────────────────────────────────────────────────────────
function initials(name = '') {
  const parts = name.trim().split(' ').filter(Boolean);
  if (!parts.length) return '??';
  return parts.length === 1
    ? parts[0][0].toUpperCase()
    : (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

function Avatar({ name, size = 38, color = '#1B3D6D' }) {
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
      fontSize: 11, fontWeight: 700, letterSpacing: 0.3, whiteSpace: 'nowrap',
    }}>
      {children}
    </span>
  );
}

function riskBadge(score) {
  if (score == null) return <span style={{ color: '#CBD5E1' }}>—</span>;
  if (score >= 60) return <Badge color="#991B1B" bg="#FEE2E2">HIGH · {score}</Badge>;
  if (score >= 30) return <Badge color="#92400E" bg="#FEF3C7">MODERATE · {score}</Badge>;
  return <Badge color="#065F46" bg="#D1FAE5">LOW · {score}</Badge>;
}

// ─── Stats Card ───────────────────────────────────────────────────────────────
function StatsCard({ label, value, icon, accent }) {
  return (
    <div className="stats-card" style={{ borderTop: `3px solid ${accent}` }}>
      <div style={{ fontSize: 26, marginBottom: 6 }}>{icon}</div>
      <div style={{ fontSize: 30, fontWeight: 800, color: accent }}>{value}</div>
      <div style={{ fontSize: 12, color: '#64748B', fontWeight: 600, marginTop: 2 }}>{label}</div>
    </div>
  );
}

// ─── Edit Modal ───────────────────────────────────────────────────────────────
function EditModal({ record, type, onSave, onClose }) {
  const [form, setForm] = useState({
    name: record.name || '',
    email: record.email || '',
    phoneNumber: record.phoneNumber || '',
  });
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    setSaving(true);
    const colName = type === 'patient' ? 'users' : 'coaches';
    try {
      await updateDoc(doc(db, colName, record.id), {
        name: form.name.trim(),
        email: form.email.trim(),
        phoneNumber: form.phoneNumber.trim(),
      });
      onSave();
    } catch (e) {
      console.error(e);
      alert('Failed to update. Check Firestore rules.');
    }
    setSaving(false);
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal-card" onClick={e => e.stopPropagation()}>
        <div className="modal-header">
          <h3>Edit {type === 'patient' ? 'Patient' : 'Coach'}</h3>
          <button className="modal-close" onClick={onClose}><IconClose /></button>
        </div>
        <div className="modal-body">
          <label>Full Name</label>
          <input
            value={form.name}
            onChange={e => setForm(f => ({ ...f, name: e.target.value }))}
            placeholder="Full name"
          />
          <label>Email</label>
          <input
            value={form.email}
            onChange={e => setForm(f => ({ ...f, email: e.target.value }))}
            placeholder="Email address"
          />
          <label>Phone Number</label>
          <input
            value={form.phoneNumber}
            onChange={e => setForm(f => ({ ...f, phoneNumber: e.target.value }))}
            placeholder="Phone number"
          />
        </div>
        <div className="modal-footer">
          <button className="btn-secondary" onClick={onClose}>Cancel</button>
          <button className="btn-primary" onClick={handleSave} disabled={saving}>
            {saving ? 'Saving…' : 'Save Changes'}
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Delete Confirm Modal ─────────────────────────────────────────────────────
function DeleteModal({ record, type, onConfirm, onClose }) {
  const [deleting, setDeleting] = useState(false);

  const handleDelete = async () => {
    setDeleting(true);
    try {
      if (type === 'patient') {
        const uid = record.id;
        const batch = writeBatch(db);

        // 1. Delete weight_history subcollection
        const weightQuery = await getDocs(collection(db, `users/${uid}/weight_history`));
        weightQuery.forEach(docSnap => batch.delete(docSnap.ref));

        // 2. Delete chats and messages subcollection
        const messagesQuery = await getDocs(collection(db, `chats/${uid}/messages`));
        messagesQuery.forEach(docSnap => batch.delete(docSnap.ref));
        batch.delete(doc(db, 'chats', uid));

        // 3. Delete logs and food_entries subcollection
        const foodQuery = await getDocs(collection(db, `logs/${uid}/food_entries`));
        foodQuery.forEach(docSnap => batch.delete(docSnap.ref));
        batch.delete(doc(db, 'logs', uid));

        // 4. Finally, delete the user document
        batch.delete(doc(db, 'users', uid));

        await batch.commit();

        alert("Patient deleted from database.\n\nNote: You still need to manually delete this user from the 'Authentication' tab in the Firebase Console so they can no longer log in.");

      } else if (type === 'coach') {
        const coachId = record.id;
        const batch = writeBatch(db);

        // 1. Unassign all patients assigned to this coach
        const usersQuery = await getDocs(query(collection(db, 'users'), where('assignedCoachId', '==', coachId)));
        usersQuery.forEach(docSnap => {
          batch.update(docSnap.ref, { assignedCoachId: 'ADMIN_PENDING' });
        });

        // 2. Delete the coach document
        batch.delete(doc(db, 'coaches', coachId));

        await batch.commit();
        alert("Coach deleted and all their patients were unassigned.\n\nNote: You still need to manually delete this coach from the 'Authentication' tab in the Firebase Console.");
      }

      onConfirm();
    } catch (e) {
      console.error('Delete error:', e);
      alert('Failed to delete. Check Firestore rules or console logs.');
    }
    setDeleting(false);
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal-card modal-sm" onClick={e => e.stopPropagation()}>
        <div className="modal-header">
          <h3>Delete {type === 'patient' ? 'Patient' : 'Coach'}</h3>
          <button className="modal-close" onClick={onClose}><IconClose /></button>
        </div>
        <div className="modal-body">
          <p style={{ color: '#475569' }}>
            Are you sure you want to permanently delete <strong>{record.name || 'this record'}</strong>?
            This action cannot be undone.
          </p>
        </div>
        <div className="modal-footer">
          <button className="btn-secondary" onClick={onClose}>Cancel</button>
          <button className="btn-danger" onClick={handleDelete} disabled={deleting}>
            {deleting ? 'Deleting…' : 'Yes, Delete'}
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Action Buttons ───────────────────────────────────────────────────────────
function ActionButtons({ onEdit, onDelete }) {
  return (
    <div style={{ display: 'flex', gap: 6 }}>
      <button className="action-btn edit-btn" onClick={onEdit} title="Edit">
        <IconEdit />
      </button>
      <button className="action-btn delete-btn" onClick={onDelete} title="Delete">
        <IconDelete />
      </button>
    </div>
  );
}

// ─── Patients Tab ─────────────────────────────────────────────────────────────
function PatientsTab({ users, coaches, showToast }) {
  const [search, setSearch] = useState('');
  const [editRecord, setEditRecord] = useState(null);
  const [deleteRecord, setDeleteRecord] = useState(null);

  const coachMap = {};
  coaches.forEach(c => { coachMap[c.id] = c.name || c.email || c.id; });

  const filtered = users.filter(u =>
    (u.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (u.email || '').toLowerCase().includes(search.toLowerCase())
  );

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
              <th>IDRS Risk</th>
              <th>Assigned Coach</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr><td colSpan={6} className="empty-row">No patients found</td></tr>
            ) : filtered.map(u => (
              <tr key={u.id}>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                    <Avatar name={u.name || '??'} size={36} />
                    <span style={{ fontWeight: 600 }}>{u.name || <em style={{ color: '#94A3B8' }}>Unnamed</em>}</span>
                  </div>
                </td>
                <td className="muted">{u.email || '—'}</td>
                <td className="muted">{u.phoneNumber || '—'}</td>
                <td>{riskBadge(u.idrsScore)}</td>
                <td>
                  {u.assignedCoachId
                    ? <Badge color="#1D4ED8" bg="#DBEAFE">{coachMap[u.assignedCoachId] || u.assignedCoachId}</Badge>
                    : <span className="unassigned-text">Unassigned</span>}
                </td>
                <td>
                  <ActionButtons
                    onEdit={() => setEditRecord(u)}
                    onDelete={() => setDeleteRecord(u)}
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {editRecord && (
        <EditModal
          record={editRecord}
          type="patient"
          onSave={() => { setEditRecord(null); showToast('✅ Patient updated successfully!'); }}
          onClose={() => setEditRecord(null)}
        />
      )}
      {deleteRecord && (
        <DeleteModal
          record={deleteRecord}
          type="patient"
          onConfirm={() => { setDeleteRecord(null); showToast('🗑️ Patient deleted.'); }}
          onClose={() => setDeleteRecord(null)}
        />
      )}
    </div>
  );
}

// ─── Coaches Tab ──────────────────────────────────────────────────────────────
function CoachesTab({ coaches, users, showToast }) {
  const [search, setSearch] = useState('');
  const [editRecord, setEditRecord] = useState(null);
  const [deleteRecord, setDeleteRecord] = useState(null);

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
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr><td colSpan={5} className="empty-row">No coaches found</td></tr>
            ) : filtered.map(c => {
              const assignedCount = users.filter(u => u.assignedCoachId === c.id).length;
              return (
                <tr key={c.id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <Avatar name={c.name || 'Coach'} size={36} color="#10B981" />
                      <span style={{ fontWeight: 600 }}>{c.name || <em style={{ color: '#94A3B8' }}>Unnamed</em>}</span>
                    </div>
                  </td>
                  <td className="muted">{c.email || '—'}</td>
                  <td className="muted">{c.phoneNumber || '—'}</td>
                  <td>
                    <Badge color="#065F46" bg="#D1FAE5">{assignedCount} patient{assignedCount !== 1 ? 's' : ''}</Badge>
                  </td>
                  <td>
                    <ActionButtons
                      onEdit={() => setEditRecord(c)}
                      onDelete={() => setDeleteRecord(c)}
                    />
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {editRecord && (
        <EditModal
          record={editRecord}
          type="coach"
          onSave={() => { setEditRecord(null); showToast('✅ Coach updated successfully!'); }}
          onClose={() => setEditRecord(null)}
        />
      )}
      {deleteRecord && (
        <DeleteModal
          record={deleteRecord}
          type="coach"
          onConfirm={() => { setDeleteRecord(null); showToast('🗑️ Coach deleted.'); }}
          onClose={() => setDeleteRecord(null)}
        />
      )}
    </div>
  );
}

// ─── Assign Tab ───────────────────────────────────────────────────────────────
function AssignTab({ users, coaches, showToast }) {
  const [search, setSearch] = useState('');
  const [filterCoach, setFilterCoach] = useState('');
  const [assigning, setAssigning] = useState(null);

  const handleAssign = async (userId, coachId) => {
    setAssigning(userId);
    try {
      await updateDoc(doc(db, 'users', userId), { assignedCoachId: coachId || null });
      showToast(coachId ? '✅ Coach assigned!' : '✅ Patient unassigned.');
    } catch (e) {
      console.error(e);
      showToast('❌ Failed to save. Check Firestore rules.');
    }
    setAssigning(null);
  };

  const coachMap = {};
  coaches.forEach(c => { coachMap[c.id] = c.name || c.email || c.id; });

  const filtered = users.filter(u => {
    const matchSearch = (u.name || '').toLowerCase().includes(search.toLowerCase()) ||
      (u.email || '').toLowerCase().includes(search.toLowerCase());
    const matchCoach =
      filterCoach === '' ? true
      : filterCoach === '__unassigned' ? !u.assignedCoachId
      : u.assignedCoachId === filterCoach;
    return matchSearch && matchCoach;
  });

  return (
    <div className="tab-content">
      <div className="tab-header">
        <div>
          <h2>Assign Patients to Coaches</h2>
          <p>Select a coach from the dropdown next to each patient</p>
        </div>
        <div style={{ display: 'flex', gap: 10 }}>
          <div className="search-box">
            <IconSearch />
            <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search patients…" />
          </div>
          <select className="filter-select" value={filterCoach} onChange={e => setFilterCoach(e.target.value)}>
            <option value="">All</option>
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
              <tr><td colSpan={5} className="empty-row">No patients found</td></tr>
            ) : filtered.map(u => (
              <tr key={u.id}>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                    <Avatar name={u.name || '??'} size={36} />
                    <span style={{ fontWeight: 600 }}>{u.name || <em style={{ color: '#94A3B8' }}>Unnamed</em>}</span>
                  </div>
                </td>
                <td className="muted">{u.email || '—'}</td>
                <td>{riskBadge(u.idrsScore)}</td>
                <td>
                  {u.assignedCoachId
                    ? <Badge color="#1D4ED8" bg="#DBEAFE">{coachMap[u.assignedCoachId] || u.assignedCoachId}</Badge>
                    : <span className="unassigned-text">Unassigned</span>}
                </td>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <select
                      className="assign-select"
                      value={u.assignedCoachId || ''}
                      onChange={e => handleAssign(u.id, e.target.value || null)}
                      disabled={assigning === u.id}
                    >
                      <option value="">— Unassign —</option>
                      {coaches.map(c => <option key={c.id} value={c.id}>{c.name || c.email}</option>)}
                    </select>
                    {assigning === u.id && <span style={{ color: '#94A3B8', fontSize: 12 }}>Saving…</span>}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ─── Main AdminPanel ──────────────────────────────────────────────────────────
export default function AdminPanel({ onLogout }) {
  const [tab, setTab] = useState('patients');
  const [users, setUsers] = useState([]);
  const [coaches, setCoaches] = useState([]);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);

  useEffect(() => {
    const unsub = onSnapshot(
      collection(db, 'users'),
      snap => { setUsers(snap.docs.map(d => ({ id: d.id, ...d.data() }))); setLoading(false); },
      err  => { console.error(err); setLoading(false); }
    );
    return unsub;
  }, []);

  useEffect(() => {
    const unsub = onSnapshot(
      collection(db, 'coaches'),
      snap => setCoaches(snap.docs.map(d => ({ id: d.id, ...d.data() }))),
      err  => console.error(err)
    );
    return unsub;
  }, []);

  const showToast = msg => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  };

  const assigned   = users.filter(u => u.assignedCoachId).length;
  const unassigned = users.length - assigned;

  const navItems = [
    { id: 'patients', label: 'Patients',  icon: <IconUsers /> },
    { id: 'coaches',  label: 'Coaches',   icon: <IconCoaches /> },
    { id: 'assign',   label: 'Assign',    icon: <IconAssign /> },
  ];

  const tabTitles = { patients: 'Patient Management', coaches: 'Coach Management', assign: 'Assign Patients' };

  return (
    <div className="panel-root">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-brand">
          <div className="brand-icon">DPP</div>
          <div>
            <div style={{ fontWeight: 800, fontSize: 13, color: '#fff', lineHeight: 1.3 }}>Diabetes Prevention</div>
            <div style={{ fontSize: 11, color: '#94A3B8' }}>Admin Panel</div>
          </div>
        </div>
        <nav className="sidebar-nav">
          {navItems.map(n => (
            <button key={n.id} className={`nav-item ${tab === n.id ? 'nav-active' : ''}`} onClick={() => setTab(n.id)}>
              {n.icon}<span>{n.label}</span>
            </button>
          ))}
        </nav>
        <div className="sidebar-footer">
          <button className="logout-btn" onClick={onLogout}><IconLogout /><span>Log Out</span></button>
        </div>
      </aside>

      {/* Main */}
      <main className="main-content">
        <header className="topbar">
          <div>
            <h1 className="topbar-title">{tabTitles[tab]}</h1>
            <p className="topbar-sub">Healis DPP · Real-time Firestore</p>
          </div>
          <div className="topbar-right">
            <div className="online-dot" /><span style={{ fontSize: 12, color: '#64748B' }}>Live</span>
          </div>
        </header>

        <div className="stats-row">
          <StatsCard label="Total Patients" value={loading ? '…' : users.length}    icon="👥" accent="#3B82F6" />
          <StatsCard label="Total Coaches"  value={loading ? '…' : coaches.length}  icon="🏥" accent="#10B981" />
          <StatsCard label="Assigned"        value={loading ? '…' : assigned}        icon="🔗" accent="#8B5CF6" />
          <StatsCard label="Unassigned"      value={loading ? '…' : unassigned}      icon="⚠️" accent="#F59E0B" />
        </div>

        {loading ? (
          <div className="loading-screen">
            <div className="spinner-large" />
            <p>Loading from Firestore…</p>
          </div>
        ) : (
          <>
            {tab === 'patients' && <PatientsTab users={users}   coaches={coaches} showToast={showToast} />}
            {tab === 'coaches'  && <CoachesTab  coaches={coaches} users={users}   showToast={showToast} />}
            {tab === 'assign'   && <AssignTab   users={users}   coaches={coaches} showToast={showToast} />}
          </>
        )}
      </main>

      {toast && <div className="toast">{toast}</div>}
    </div>
  );
}
