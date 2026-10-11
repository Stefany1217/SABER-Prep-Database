'use client';

import { useState } from 'react';

export default function HomePage() {
  const [usuario, setUsuario] = useState('admin');
  const [password, setPassword] = useState('123456');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    alert(`Bienvenido ${usuario}. La autenticación se integrará con FastAPI en la siguiente etapa.`);
  };

  return (
    <main className="login-page">
      <div className="login-card">
        <h1>PRE-ICFES</h1>
        <p>Gestión académica y administrativa</p>

        <form onSubmit={handleSubmit}>
          <label>
            Usuario
            <input value={usuario} onChange={(e) => setUsuario(e.target.value)} />
          </label>

          <label>
            Contraseña
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
          </label>

          <button type="submit">Ingresar</button>
        </form>
      </div>
    </main>
  );
}
