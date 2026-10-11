from fastapi import APIRouter

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

@router.get("/")
def dashboard_summary():
    return {
        "estudiantes_total": 120,
        "asistencias_hoy": 85,
        "pagos_mes": 15000000,
        "cursos_activos": 4,
    }
