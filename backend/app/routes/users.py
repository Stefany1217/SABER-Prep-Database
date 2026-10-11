from fastapi import APIRouter

router = APIRouter(prefix="/users", tags=["usuarios"])

@router.get("/health")
def users_health():
    return {"status": "usuarios ok"}

@router.get("/")
def get_users():
    return [
        {"id": 1, "nombre": "admin", "rol": "propietario", "activo": True},
        {"id": 2, "nombre": "profesor1", "rol": "profesor", "activo": True},
    ]

@router.post("/")
def create_user():
    return {"message": "Usuario creado"}
