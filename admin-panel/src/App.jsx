import React, { useState } from 'react';
import LoginPage from './LoginPage';
import AdminPanel from './AdminPanel';

export default function App() {
  const [loggedIn, setLoggedIn] = useState(false);
  return loggedIn
    ? <AdminPanel onLogout={() => setLoggedIn(false)} />
    : <LoginPage onLogin={() => setLoggedIn(true)} />;
}
