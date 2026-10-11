INSERT INTO roles (nombre_rol, descripcion) VALUES
('propietario', 'Acceso total al sistema'),
('administrador', 'Administra estudiantes, pagos, resultados y usuarios'),
('profesor', 'Registra y consulta asistencias'),
('consultor', 'Solo puede consultar información');

INSERT INTO permisos (nombre_permiso, modulo, accion, descripcion) VALUES
('ver_estudiantes', 'estudiantes', 'lectura', 'Consultar estudiantes'),
('crear_estudiantes', 'estudiantes', 'crear', 'Crear estudiantes'),
('editar_estudiantes', 'estudiantes', 'editar', 'Editar estudiantes'),
('desactivar_estudiantes', 'estudiantes', 'desactivar', 'Desactivar estudiantes'),
('ver_asistencias', 'asistencias', 'lectura', 'Consultar asistencia'),
('crear_asistencias', 'asistencias', 'crear', 'Registrar asistencia'),
('editar_asistencias', 'asistencias', 'editar', 'Editar asistencia'),
('ver_pagos', 'pagos', 'lectura', 'Consultar pagos'),
('crear_pagos', 'pagos', 'crear', 'Registrar pago'),
('editar_pagos', 'pagos', 'editar', 'Editar pago'),
('ver_resultados', 'resultados', 'lectura', 'Consultar resultados'),
('crear_resultados', 'resultados', 'crear', 'Crear resultados'),
('editar_resultados', 'resultados', 'editar', 'Editar resultados'),
('ver_reportes', 'reportes', 'lectura', 'Ver reportes'),
('gestionar_usuarios', 'usuarios', 'admin', 'Gestionar usuarios'),
('access_total', 'sistema', 'todo', 'Acceso total');

INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT 1, id_permiso FROM permisos;

INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT 2, id_permiso FROM permisos WHERE nombre_permiso NOT IN ('gestionar_usuarios', 'access_total');

INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT 3, id_permiso FROM permisos WHERE nombre_permiso IN (
    'ver_estudiantes',
    'ver_asistencias',
    'crear_asistencias',
    'editar_asistencias',
    'ver_inscripciones',
    'ver_resultados',
    'ver_reportes'
);

INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT 4, id_permiso FROM permisos WHERE nombre_permiso IN (
    'ver_estudiantes',
    'ver_asistencias',
    'ver_pagos',
    'ver_resultados',
    'ver_reportes'
);

INSERT INTO docentes (nombre_completo, tipo_documento, doc_identidad, especialidad, telefono, correo_electronico)
VALUES ('Laura García', 'CC', '1050001111', 'Matemáticas', '3001234567', 'laura@preicfes.com');

INSERT INTO usuarios (id_rol, id_docente, nombre_usuario, contrasena_hash, activo)
VALUES (3, 1, 'profesor1', 'demo_hash', TRUE);

INSERT INTO estudiantes (
    tipo_documento, doc_identidad, nombre_completo, fecha_nacimiento,
    telefono_celular, correo_electronico, direccion, estado_matricula
)
VALUES (
    'CC', '1012345678', 'Ana Sofía López', '2008-05-14',
    '3104567890', 'ana.lopez@gmail.com', 'Calle 80 #30-20, Bogotá', 'activo'
);

INSERT INTO acudientes (
    tipo_documento, doc_identidad, nombre_completo, parentesco,
    telefono, correo_electronico, direccion
)
VALUES (
    'CC', '987654321', 'Carlos López', 'Padre', '3001112233',
    'carlos.lopez@gmail.com', 'Calle 80 #30-20, Bogotá'
);

INSERT INTO estudiante_acudiente (id_estudiante, id_acudiente, parentesco, es_principal)
VALUES (1, 1, 'Padre', TRUE);

INSERT INTO calendarios (nombre_calendario, tipo_calendario, descripcion, duracion_dias, fecha_inicio, fecha_fin)
VALUES ('Calendario A 2026', 'A', 'Curso intensivo', 90, '2026-02-01', '2026-05-01');

INSERT INTO cursos (id_calendario, nombre_curso, descripcion, fecha_inicio, fecha_fin, capacidad_maxima, valor_total)
VALUES (1, 'Saber 11 - Intensivo', 'Preparación para pruebas Saber', '2026-02-01', '2026-05-01', 100, 1200000);

INSERT INTO grupos (id_curso, nombre_grupo, tipo_grupo, capacidad_maxima, dia_semana, hora_inicio, hora_fin, docente_titular)
VALUES (1, 'Grupo A1', 'A', 35, 'lunes', '18:00:00', '20:00:00', 1);

INSERT INTO inscripciones (
    id_estudiante, id_grupo, id_curso, fecha_inscripcion, estado,
    valor_acordado, modalidad_pago, numero_cuotas
)
VALUES (
    1, 1, 1, '2026-01-25', 'activa', 1200000, 'cuotas', 3
);
