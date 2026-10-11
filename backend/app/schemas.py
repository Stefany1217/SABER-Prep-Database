from pydantic import BaseModel, Field
from typing import Optional


class UsuarioCreate(BaseModel):
    nombre_usuario: str = Field(..., min_length=3, max_length=50)
    rol: str = Field(...)
    activo: bool = True


class UsuarioOut(BaseModel):
    id_usuario: int
    nombre_usuario: str
    rol: str
    activo: bool


class EstudianteCreate(BaseModel):
    tipo_documento: str
    doc_identidad: str
    nombre_completo: str
    fecha_nacimiento: str
    telefono_celular: str
    correo_electronico: Optional[str] = None
    direccion: Optional[str] = None


class EstudianteOut(BaseModel):
    id_estudiante: int
    tipo_documento: str
    doc_identidad: str
    nombre_completo: str
    estado_matricula: str
