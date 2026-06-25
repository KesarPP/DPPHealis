import React, { useState } from 'react';

const ADMIN_USERNAME = 'dpp@healis2026';
const ADMIN_PASSWORD = '20dpp@healis26';

export default function LoginPage({ onLogin }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPass, setShowPass] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setTimeout(() => {
      if (username === ADMIN_USERNAME && password === ADMIN_PASSWORD) {
        onLogin();
      } else {
        setError('Invalid credentials. Please try again.');
      }
      setLoading(false);
    }, 600);
  };

  return (
    <div className="login-root">
      <div className="login-card">
        <div className="login-logo">
          <div className="login-logo-icon">DPP</div>
          <div className="login-logo-text">
            <span className="login-title">Diabetes Prevention</span>
            <span className="login-subtitle">Admin Panel</span>
          </div>
        </div>

        <p className="login-desc">Sign in to manage patients and coaches</p>

        <form onSubmit={handleSubmit} className="login-form">
          <div className="login-field">
            <label>Username</label>
            <div className="login-input-wrap">
              <span className="login-icon">👤</span>
              <input
                type="text"
                value={username}
                onChange={e => setUsername(e.target.value)}
                placeholder="Enter username"
                autoComplete="username"
                required
              />
            </div>
          </div>

          <div className="login-field">
            <label>Password</label>
            <div className="login-input-wrap">
              <span className="login-icon">🔒</span>
              <input
                type={showPass ? 'text' : 'password'}
                value={password}
                onChange={e => setPassword(e.target.value)}
                placeholder="Enter password"
                autoComplete="current-password"
                required
              />
              <button type="button" className="login-toggle" onClick={() => setShowPass(v => !v)}>
                {showPass ? '🙈' : '👁️'}
              </button>
            </div>
          </div>

          {error && <div className="login-error">{error}</div>}

          <button type="submit" className="login-btn" disabled={loading}>
            {loading ? <span className="login-spinner" /> : 'Sign In'}
          </button>
        </form>

        <div className="login-footer">Healis © 2026 — Admin Access Only</div>
      </div>
    </div>
  );
}
