# PRE-ICFES

Sistema de gestión académica para una empresa de preparación para las pruebas Saber en Colombia.

Stack recomendado:
- Frontend: Next.js
- Backend: FastAPI
- Base de datos: PostgreSQL en Docker

## Estructura

- `database/` : esquema SQL y datos iniciales
- `backend/` : API FastAPI
- `frontend/` : aplicación web con Next.js

## Requisitos

- Docker Desktop
- Python 3.11+
- Node.js 18+
- Git

## Ejecutar base de datos

```powershell
docker run --name mi-postgres -e POSTGRES_PASSWORD=postgres -p 5433:5432 -d postgres
```

```powershell
docker exec -it mi-postgres psql -U postgres -c "CREATE DATABASE preicfes;"
Get-Content database\01_schema.sql | docker exec -i mi-postgres psql -U postgres -d preicfes
Get-Content database\02_seed.sql | docker exec -i mi-postgres psql -U postgres -d preicfes
```

## Ejecutar backend

```powershell
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn main:app --reload
```

Ajusta `.env` con tus datos locales.

## Ejecutar frontend

```powershell
cd frontend
npm install
npm run dev
```

Abre:
- http://localhost:8000 para FastAPI
- http://localhost:3000 para la UI

## Roles del sistema

- propietario: acceso completo
- administrador: gestión operativa
- profesor: solo asistencia
- consultor: solo lectura
