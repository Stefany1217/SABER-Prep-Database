export default function DashboardPage() {
  return (
    <main className="dashboard-page">
      <h1>Dashboard PRE-ICFES</h1>

      <div className="stats-grid">
        <div className="stat-box">
          <span>Estudiantes</span>
          <strong>120</strong>
        </div>
        <div className="stat-box">
          <span>Asistencia hoy</span>
          <strong>85%</strong>
        </div>
        <div className="stat-box">
          <span>Pagos del mes</span>
          <strong>$15.000.000</strong>
        </div>
        <div className="stat-box">
          <span>Cursos activos</span>
          <strong>4</strong>
        </div>
      </div>
    </main>
  );
}
