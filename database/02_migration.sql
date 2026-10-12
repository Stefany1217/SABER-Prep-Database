-- =====================================================================
-- MIGRACION PARA PRE-ICFES
-- Objetivo: corregir y complementar la estructura actual sin borrar
-- lo que ya existe.
-- NOTA: Todas las clases son VIRTUALES (la empresa es 100% remota)
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 1. TABLAS PARA ROLES Y PERMISOS
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS roles (
    id_rol          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_rol      VARCHAR(30) NOT NULL UNIQUE,
    descripcion     TEXT,
    activo          BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS permisos (
    id_permiso      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_permiso  VARCHAR(60) NOT NULL UNIQUE,
    modulo          VARCHAR(50) NOT NULL,
    accion          VARCHAR(50) NOT NULL,
    descripcion     TEXT
);

CREATE TABLE IF NOT EXISTS rol_permiso (
    id_rol          INTEGER NOT NULL REFERENCES roles(id_rol) ON DELETE CASCADE,
    id_permiso      INTEGER NOT NULL REFERENCES permisos(id_permiso) ON DELETE CASCADE,
    PRIMARY KEY (id_rol, id_permiso)
);

-- Insertar roles base
INSERT INTO roles (nombre_rol, descripcion)
VALUES
    ('propietario', 'Acceso total al sistema. Puede gestionar usuarios, estudiantes, pagos y resultados.'),
    ('administrador', 'Gestiona estudiantes, pagos, resultados, inscripciones y reportes. No puede gestionar usuarios.'),
    ('profesor', 'Solo puede registrar y consultar asistencias de sus clases virtuales.'),
    ('consultor', 'Solo lectura. Puede consultar información pero no modificar.')
ON CONFLICT (nombre_rol) DO NOTHING;

-- Insertar permisos base
INSERT INTO permisos (nombre_permiso, modulo, accion, descripcion)
VALUES
    ('ver_estudiantes', 'estudiantes', 'lectura', 'Consultar estudiantes'),
    ('crear_estudiantes', 'estudiantes', 'crear', 'Crear estudiantes'),
    ('editar_estudiantes', 'estudiantes', 'editar', 'Editar estudiantes'),
    ('desactivar_estudiantes', 'estudiantes', 'desactivar', 'Desactivar estudiantes'),

    ('ver_asistencias', 'asistencias', 'lectura', 'Consultar asistencias'),
    ('crear_asistencias', 'asistencias', 'crear', 'Registrar asistencias'),
    ('editar_asistencias', 'asistencias', 'editar', 'Editar asistencias'),

    ('ver_pagos', 'pagos', 'lectura', 'Consultar pagos'),
    ('crear_pagos', 'pagos', 'crear', 'Registrar pagos'),
    ('editar_pagos', 'pagos', 'editar', 'Editar pagos'),

    ('ver_resultados', 'resultados', 'lectura', 'Consultar resultados de simulacros'),
    ('crear_resultados', 'resultados', 'crear', 'Registrar resultados de simulacros'),
    ('editar_resultados', 'resultados', 'editar', 'Editar resultados de simulacros'),

    ('ver_inscripciones', 'inscripciones', 'lectura', 'Consultar inscripciones'),
    ('crear_inscripciones', 'inscripciones', 'crear', 'Crear inscripciones'),
    ('editar_inscripciones', 'inscripciones', 'editar', 'Editar inscripciones'),
    ('eliminar_inscripciones', 'inscripciones', 'eliminar', 'Eliminar inscripciones'),

    ('ver_reportes', 'reportes', 'lectura', 'Consultar reportes de desempeño y asistencia'),
    ('gestionar_usuarios', 'usuarios', 'admin', 'Crear, editar y desactivar usuarios del sistema'),
    ('access_total', 'sistema', 'todo', 'Acceso total al sistema')
ON CONFLICT (nombre_permiso) DO NOTHING;

-- Permisos por cada rol
-- PROPIETARIO: acceso total
INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT 1, id_permiso FROM permisos
ON CONFLICT DO NOTHING;

-- ADMINISTRADOR: todo menos gestionar usuarios
INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT 2, id_permiso FROM permisos
WHERE nombre_permiso NOT IN ('gestionar_usuarios', 'access_total')
ON CONFLICT DO NOTHING;

-- PROFESOR: solo asistencias y consulta
INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT 3, id_permiso FROM permisos
WHERE nombre_permiso IN (
    'ver_estudiantes',
    'ver_asistencias',
    'crear_asistencias',
    'editar_asistencias',
    'ver_inscripciones',
    'ver_resultados',
    'ver_reportes'
)
ON CONFLICT DO NOTHING;

-- CONSULTOR: solo lectura
INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT 4, id_permiso FROM permisos
WHERE nombre_permiso IN (
    'ver_estudiantes',
    'ver_asistencias',
    'ver_pagos',
    'ver_resultados',
    'ver_inscripciones',
    'ver_reportes'
)
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- 2. TABLAS DE CALENDARIOS
-- =====================================================================
-- Tres tipos de calendarios:
-- - Calendario A: 2-3 meses
-- - Calendario B: 2-3 meses
-- - Vacacional: ~1 mes (máx 2 grupos de 30-50 estudiantes)
-- =====================================================================

CREATE TABLE IF NOT EXISTS calendarios (
    id_calendario     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_calendario VARCHAR(60) NOT NULL UNIQUE,
    tipo_calendario   VARCHAR(20) NOT NULL
                      CHECK (tipo_calendario IN ('A', 'B', 'VACACIONAL')),
    descripcion       TEXT,
    duracion_dias     INTEGER NOT NULL CHECK (duracion_dias > 0),
    fecha_inicio      DATE NOT NULL,
    fecha_fin         DATE NOT NULL,
    activo            BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (fecha_fin >= fecha_inicio)
);

-- ---------------------------------------------------------------------
-- 3. TABLA DE GRUPOS
-- =====================================================================
-- Un grupo es un conjunto de estudiantes en una clase virtual
-- a una hora específica.
-- Capacidad: 20-150 estudiantes (margen flexible)
-- Vacacional: 30-50 estudiantes
-- =====================================================================

CREATE TABLE IF NOT EXISTS grupos (
    id_grupo          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_curso          INTEGER NOT NULL REFERENCES cursos(id_curso) ON DELETE CASCADE,
    nombre_grupo      VARCHAR(30) NOT NULL,
    tipo_grupo        VARCHAR(20) NOT NULL DEFAULT 'A'
                      CHECK (tipo_grupo IN ('A', 'B', 'VACACIONAL')),
    capacidad_maxima  SMALLINT NOT NULL
                      CHECK (capacidad_maxima BETWEEN 20 AND 150),
    dia_semana        VARCHAR(10) NOT NULL
                      CHECK (dia_semana IN ('lunes','martes','miercoles','jueves',
                                            'viernes','sabado','domingo')),
    hora_inicio       TIME NOT NULL,
    hora_fin          TIME NOT NULL,
    id_docente        INTEGER REFERENCES docentes(id_docente),
    plataforma        VARCHAR(100) DEFAULT 'Google Meet',
    enlace_reunion    VARCHAR(500),
    activo            BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (id_curso, nombre_grupo),
    CHECK (hora_fin > hora_inicio)
);

-- =====================================================================
-- 4. MODIFICAR TABLA estudiantes
-- =====================================================================
-- Campos requeridos por requisito:
-- - nombre_completo (ya existe)
-- - tipo_documento (ya existe)
-- - doc_identidad (ya existe)
-- - fecha_nacimiento (ya existe)
-- - telefono_celular (AGREGAR - obligatorio)
-- - correo_electronico (ya existe)
-- Campos adicionales:
-- - telefono_fijo (opcional)
-- - estado_matricula (AGREGAR)
-- - fecha_creacion (AGREGAR)
-- =====================================================================

ALTER TABLE estudiantes
    ADD COLUMN IF NOT EXISTS telefono_celular VARCHAR(20);

UPDATE estudiantes
SET telefono_celular = 'NO REGISTRADO'
WHERE telefono_celular IS NULL;

ALTER TABLE estudiantes
    ADD COLUMN IF NOT EXISTS telefono_fijo VARCHAR(20);

ALTER TABLE estudiantes
    ADD COLUMN IF NOT EXISTS estado_matricula VARCHAR(20) DEFAULT 'activo'
    CHECK (estado_matricula IN ('activo', 'inactivo', 'retirado', 'graduado'));

UPDATE estudiantes
SET estado_matricula = 'activo'
WHERE estado_matricula IS NULL;

ALTER TABLE estudiantes
    ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Hacer que el correo sea único si no lo es ya
CREATE UNIQUE INDEX IF NOT EXISTS idx_estudiantes_correo ON estudiantes(correo_electronico)
WHERE correo_electronico IS NOT NULL;

-- Hacer que el teléfono celular sea obligatorio
ALTER TABLE estudiantes ALTER COLUMN telefono_celular SET NOT NULL;

-- =====================================================================
-- 5. MODIFICAR TABLA acudientes
-- =====================================================================
-- Campos requeridos por requisito:
-- - nombre_completo (ya existe)
-- - parentesco (está en estudiante_acudiente, no aquí)
-- - telefono_celular (AGREGAR - obligatorio)
-- - doc_identidad (ya existe)
-- Campos adicionales:
-- - telefono_fijo (AGREGAR - opcional)
-- - es_principal (NO va aquí, va en estudiante_acudiente)
-- - fecha_creacion (AGREGAR)
-- =====================================================================

ALTER TABLE acudientes
    ADD COLUMN IF NOT EXISTS telefono_celular VARCHAR(20);

-- Migrar datos del campo 'telefono' a 'telefono_celular' si es necesario
UPDATE acudientes
SET telefono_celular = telefono
WHERE telefono_celular IS NULL AND telefono IS NOT NULL;

UPDATE acudientes
SET telefono_celular = 'NO REGISTRADO'
WHERE telefono_celular IS NULL;

ALTER TABLE acudientes
    ADD COLUMN IF NOT EXISTS telefono_fijo VARCHAR(20);

ALTER TABLE acudientes
    ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Hacer que el correo sea único si no lo es ya
CREATE UNIQUE INDEX IF NOT EXISTS idx_acudientes_correo ON acudientes(correo_electronico)
WHERE correo_electronico IS NOT NULL;

-- Hacer que el teléfono celular sea obligatorio
ALTER TABLE acudientes ALTER COLUMN telefono_celular SET NOT NULL;

-- =====================================================================
-- 6. MODIFICAR TABLA estudiante_acudiente
-- =====================================================================
-- CORRECCIÓN: es_principal va AQUÍ, no en acudientes
-- Porque un acudiente puede ser principal para un estudiante
-- y no principal para otro
-- =====================================================================

ALTER TABLE estudiante_acudiente
    ADD COLUMN IF NOT EXISTS es_principal BOOLEAN DEFAULT FALSE;

-- =====================================================================
-- 7. MODIFICAR TABLA docentes
-- =====================================================================
-- Docentes que imparten clases virtuales
-- =====================================================================

ALTER TABLE docentes
    ADD COLUMN IF NOT EXISTS tipo_documento VARCHAR(10)
    DEFAULT 'CC'
    CHECK (tipo_documento IN ('TI', 'CC', 'CE', 'PPT', 'OTRO'));

UPDATE docentes
SET tipo_documento = 'CC'
WHERE tipo_documento IS NULL;

ALTER TABLE docentes
    ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Hacer que el correo sea único si no lo es ya
CREATE UNIQUE INDEX IF NOT EXISTS idx_docentes_correo ON docentes(correo_electronico)
WHERE correo_electronico IS NOT NULL;

-- =====================================================================
-- 8. MODIFICAR TABLA usuarios
-- =====================================================================
-- Sistema de autenticación con roles y permisos
-- Permitir activar/desactivar sin borrar
-- =====================================================================

ALTER TABLE usuarios
    ADD COLUMN IF NOT EXISTS id_rol INTEGER REFERENCES roles(id_rol);

-- Mapear roles antiguos (texto) a ids reales si existen datos antiguos
UPDATE usuarios u
SET id_rol = (
    SELECT r.id_rol
    FROM roles r
    WHERE r.nombre_rol = u.rol
)
WHERE u.id_rol IS NULL
  AND u.rol IS NOT NULL;

-- Valor por defecto para registros sin rol (administrador)
UPDATE usuarios
SET id_rol = 2
WHERE id_rol IS NULL;

ALTER TABLE usuarios
    ADD COLUMN IF NOT EXISTS activo BOOLEAN DEFAULT TRUE;

UPDATE usuarios
SET activo = TRUE
WHERE activo IS NULL;

ALTER TABLE usuarios
    ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE usuarios
    ADD COLUMN IF NOT EXISTS fecha_ultima_sesion TIMESTAMP;

-- Hacer que el nombre de usuario sea único
CREATE UNIQUE INDEX IF NOT EXISTS idx_usuarios_nombre ON usuarios(nombre_usuario);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_usuarios_rol ON usuarios(id_rol);
CREATE INDEX IF NOT EXISTS idx_usuarios_activo ON usuarios(activo);

-- =====================================================================
-- 9. MODIFICAR TABLA cursos
-- =====================================================================
-- Cursos vinculados a calendarios (A, B o Vacacional)
-- =====================================================================

ALTER TABLE cursos
    ADD COLUMN IF NOT EXISTS id_calendario INTEGER REFERENCES calendarios(id_calendario);

ALTER TABLE cursos
    ADD COLUMN IF NOT EXISTS capacidad_maxima SMALLINT DEFAULT 100
    CHECK (capacidad_maxima > 0 AND capacidad_maxima <= 100);

UPDATE cursos
SET capacidad_maxima = 100
WHERE capacidad_maxima IS NULL;

ALTER TABLE cursos
    ADD COLUMN IF NOT EXISTS activo BOOLEAN DEFAULT TRUE;

UPDATE cursos
SET activo = TRUE
WHERE activo IS NULL;

ALTER TABLE cursos
    ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_cursos_calendario ON cursos(id_calendario);
CREATE INDEX IF NOT EXISTS idx_cursos_activo ON cursos(activo);

-- =====================================================================
-- 10. MODIFICAR TABLA inscripciones
-- =====================================================================
-- Vincula estudiantes con grupos (clases virtuales)
-- =====================================================================

ALTER TABLE inscripciones
    ADD COLUMN IF NOT EXISTS id_grupo INTEGER REFERENCES grupos(id_grupo);

ALTER TABLE inscripciones
    ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_inscripciones_grupo ON inscripciones(id_grupo);
CREATE INDEX IF NOT EXISTS idx_inscripciones_estado ON inscripciones(estado);

-- =====================================================================
-- 11. MODIFICAR TABLA asistencias
-- =====================================================================
-- Registro de asistencia en clases virtuales
-- Estados: presente, ausente, tarde, excusa
-- =====================================================================

ALTER TABLE asistencias
    ADD COLUMN IF NOT EXISTS estado_asistencia VARCHAR(20)
    DEFAULT 'presente'
    CHECK (estado_asistencia IN ('presente', 'ausente', 'tarde', 'excusa'));

-- Migrar datos de la columna asistio si existen
UPDATE asistencias
SET estado_asistencia = CASE
    WHEN asistio = TRUE THEN 'presente'
    WHEN asistio = FALSE THEN 'ausente'
    ELSE 'presente'
END
WHERE estado_asistencia = 'presente' AND asistio IS NOT NULL;

ALTER TABLE asistencias
    ADD COLUMN IF NOT EXISTS fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

UPDATE asistencias
SET fecha_registro = CURRENT_TIMESTAMP
WHERE fecha_registro IS NULL;

CREATE INDEX IF NOT EXISTS idx_asistencias_estado ON asistencias(estado_asistencia);
CREATE INDEX IF NOT EXISTS idx_asistencias_fecha ON asistencias(fecha_registro);

-- =====================================================================
-- 12. TABLA clases
-- =====================================================================
-- Clases virtuales realizadas
-- Cada clase pertenece a un grupo y tiene un docente
-- =====================================================================

CREATE TABLE IF NOT EXISTS clases (
    id_clase        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_grupo        INTEGER NOT NULL REFERENCES grupos(id_grupo) ON DELETE CASCADE,
    id_docente      INTEGER NOT NULL REFERENCES docentes(id_docente),
    fecha_clase     DATE NOT NULL,
    hora_inicio     TIME NOT NULL,
    hora_fin        TIME NOT NULL,
    tema            VARCHAR(150),
    plataforma      VARCHAR(100) DEFAULT 'Google Meet',
    enlace_reunion  VARCHAR(500),
    fecha_creacion  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (id_grupo, fecha_clase, hora_inicio)
);

CREATE INDEX IF NOT EXISTS idx_clases_grupo ON clases(id_grupo);
CREATE INDEX IF NOT EXISTS idx_clases_fecha ON clases(fecha_clase);

-- =====================================================================
-- 13. MODIFICAR TABLA resultado_simulacro
-- =====================================================================
-- Ya contiene las 5 materias requeridas:
-- - Lectura Crítica
-- - Matemáticas
-- - Inglés
-- - Ciencias Naturales
-- - Sociales y Ciudadanas
-- =====================================================================

ALTER TABLE resultado_simulacro
    ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_resultados_inscripcion ON resultado_simulacro(id_inscripcion);
CREATE INDEX IF NOT EXISTS idx_resultados_simulacro ON resultado_simulacro(id_simulacro);
CREATE INDEX IF NOT EXISTS idx_resultados_puntaje ON resultado_simulacro(puntaje_global);

-- =====================================================================
-- 14. TABLA SIMULACROS
-- =====================================================================

ALTER TABLE simulacros
    ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- =====================================================================
-- 15. TABLA PAGOS
-- =====================================================================

ALTER TABLE pagos
    ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_pagos_fecha ON pagos(fecha_pago);

-- =====================================================================
-- 16. VISTAS IMPORTANTES
-- =====================================================================

-- Vista: saldo pendiente por inscripción
CREATE OR REPLACE VIEW vista_saldo_inscripcion AS
SELECT
    i.id_inscripcion,
    e.nombre_completo AS estudiante,
    c.nombre_curso,
    g.nombre_grupo,
    i.valor_acordado,
    COALESCE(SUM(p.monto_pagado), 0) AS total_pagado,
    (i.valor_acordado - COALESCE(SUM(p.monto_pagado), 0)) AS saldo_pendiente,
    i.estado
FROM inscripciones i
JOIN estudiantes e ON e.id_estudiante = i.id_estudiante
JOIN cursos c ON c.id_curso = i.id_curso
LEFT JOIN grupos g ON g.id_grupo = i.id_grupo
LEFT JOIN pagos p ON p.id_inscripcion = i.id_inscripcion
WHERE i.estado = 'activa'
GROUP BY i.id_inscripcion, e.nombre_completo, c.nombre_curso, g.nombre_grupo, i.valor_acordado, i.estado;

-- Vista: asistencia por estudiante
CREATE OR REPLACE VIEW vista_asistencia_por_estudiante AS
SELECT
    i.id_inscripcion,
    e.nombre_completo AS estudiante,
    c.nombre_curso,
    g.nombre_grupo,
    COUNT(a.id_asistencia) AS total_clases,
    SUM(CASE WHEN a.estado_asistencia = 'presente' THEN 1 ELSE 0 END) AS presentes,
    SUM(CASE WHEN a.estado_asistencia = 'ausente' THEN 1 ELSE 0 END) AS ausentes,
    SUM(CASE WHEN a.estado_asistencia = 'tarde' THEN 1 ELSE 0 END) AS tardes,
    SUM(CASE WHEN a.estado_asistencia = 'excusa' THEN 1 ELSE 0 END) AS excusas,
    ROUND(
        (SUM(CASE WHEN a.estado_asistencia = 'presente' THEN 1 ELSE 0 END) * 100.0) /
        NULLIF(COUNT(a.id_asistencia), 0),
        2
    ) AS porcentaje_asistencia
FROM inscripciones i
JOIN estudiantes e ON e.id_estudiante = i.id_estudiante
JOIN cursos c ON c.id_curso = i.id_curso
LEFT JOIN grupos g ON g.id_grupo = i.id_grupo
LEFT JOIN asistencias a ON a.id_inscripcion = i.id_inscripcion
WHERE i.estado = 'activa'
GROUP BY i.id_inscripcion, e.nombre_completo, c.nombre_curso, g.nombre_grupo;

-- Vista: desempeño por estudiante (promedio de simulacros)
CREATE OR REPLACE VIEW vista_desempeño_estudiante AS
SELECT
    i.id_inscripcion,
    e.nombre_completo AS estudiante,
    c.nombre_curso,
    g.nombre_grupo,
    COUNT(r.id_resultado) AS total_simulacros,
    ROUND(AVG(r.puntaje_global), 2) AS promedio_global,
    ROUND(AVG(r.lectura_critica), 2) AS promedio_lectura_critica,
    ROUND(AVG(r.matematicas), 2) AS promedio_matematicas,
    ROUND(AVG(r.ingles), 2) AS promedio_ingles,
    ROUND(AVG(r.ciencias_naturales), 2) AS promedio_ciencias_naturales,
    ROUND(AVG(r.sociales_ciudadanas), 2) AS promedio_sociales_ciudadanas,
    MAX(r.puntaje_global) AS mejor_puntaje,
    MIN(r.puntaje_global) AS peor_puntaje
FROM inscripciones i
JOIN estudiantes e ON e.id_estudiante = i.id_estudiante
JOIN cursos c ON c.id_curso = i.id_curso
LEFT JOIN grupos g ON g.id_grupo = i.id_grupo
LEFT JOIN resultado_simulacro r ON r.id_inscripcion = i.id_inscripcion
WHERE i.estado = 'activa'
GROUP BY i.id_inscripcion, e.nombre_completo, c.nombre_curso, g.nombre_grupo;

-- Vista: usuarios activos del sistema
CREATE OR REPLACE VIEW vista_usuarios_activos AS
SELECT
    u.id_usuario,
    u.nombre_usuario,
    r.nombre_rol,
    d.nombre_completo AS docente,
    u.activo,
    u.fecha_creacion,
    u.fecha_ultima_sesion
FROM usuarios u
JOIN roles r ON r.id_rol = u.id_rol
LEFT JOIN docentes d ON d.id_docente = u.id_docente
WHERE u.activo = TRUE
ORDER BY u.nombre_usuario;

COMMIT;
