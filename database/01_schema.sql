-- ===============================================================
-- BASE DE DATOS PRE-ICFES
-- ===============================================================

CREATE TABLE roles (
    id_rol INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_rol VARCHAR(30) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE permisos (
    id_permiso INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_permiso VARCHAR(60) NOT NULL UNIQUE,
    modulo VARCHAR(50) NOT NULL,
    accion VARCHAR(50) NOT NULL,
    descripcion TEXT
);

CREATE TABLE rol_permiso (
    id_rol INTEGER NOT NULL REFERENCES roles(id_rol) ON DELETE CASCADE,
    id_permiso INTEGER NOT NULL REFERENCES permisos(id_permiso) ON DELETE CASCADE,
    PRIMARY KEY (id_rol, id_permiso)
);

CREATE TABLE docentes (
    id_docente INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_completo VARCHAR(120) NOT NULL,
    tipo_documento VARCHAR(10) NOT NULL CHECK (tipo_documento IN ('CC','TI','CE','PPT','OTRO')),
    doc_identidad VARCHAR(20) NOT NULL UNIQUE,
    especialidad VARCHAR(80),
    telefono VARCHAR(20),
    correo_electronico VARCHAR(100),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE usuarios (
    id_usuario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_rol INTEGER NOT NULL REFERENCES roles(id_rol),
    id_docente INTEGER UNIQUE REFERENCES docentes(id_docente),
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        (id_rol = 3 AND id_docente IS NOT NULL) OR
        (id_rol IN (1,2,4) AND id_docente IS NULL)
    )
);

CREATE TABLE estudiantes (
    id_estudiante INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo_documento VARCHAR(10) NOT NULL CHECK (tipo_documento IN ('CC','TI','CE','PPT','OTRO')),
    doc_identidad VARCHAR(20) NOT NULL UNIQUE,
    nombre_completo VARCHAR(120) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono_celular VARCHAR(20) NOT NULL,
    correo_electronico VARCHAR(100),
    direccion VARCHAR(200),
    estado_matricula VARCHAR(20) NOT NULL DEFAULT 'activo'
        CHECK (estado_matricula IN ('activo','inactivo','retirado','graduado')),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE acudientes (
    id_acudiente INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo_documento VARCHAR(10) NOT NULL CHECK (tipo_documento IN ('CC','TI','CE','PPT','OTRO')),
    doc_identidad VARCHAR(20) NOT NULL UNIQUE,
    nombre_completo VARCHAR(120) NOT NULL,
    parentesco VARCHAR(30) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    correo_electronico VARCHAR(100),
    direccion VARCHAR(200),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE estudiante_acudiente (
    id_estudiante INTEGER NOT NULL REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    id_acudiente INTEGER NOT NULL REFERENCES acudientes(id_acudiente) ON DELETE CASCADE,
    parentesco VARCHAR(30) NOT NULL,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id_estudiante, id_acudiente)
);

CREATE TABLE calendarios (
    id_calendario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_calendario VARCHAR(60) NOT NULL UNIQUE,
    tipo_calendario VARCHAR(20) NOT NULL CHECK (tipo_calendario IN ('A','B','VACACIONAL')),
    descripcion TEXT,
    duracion_dias INTEGER NOT NULL CHECK (duracion_dias > 0),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CHECK (fecha_fin >= fecha_inicio)
);

CREATE TABLE cursos (
    id_curso INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_calendario INTEGER NOT NULL REFERENCES calendarios(id_calendario),
    nombre_curso VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    capacidad_maxima SMALLINT NOT NULL CHECK (capacidad_maxima > 0 AND capacidad_maxima <= 100),
    valor_total NUMERIC(12,2) NOT NULL CHECK (valor_total >= 0),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (fecha_fin >= fecha_inicio)
);

CREATE TABLE grupos (
    id_grupo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_curso INTEGER NOT NULL REFERENCES cursos(id_curso) ON DELETE CASCADE,
    nombre_grupo VARCHAR(30) NOT NULL,
    tipo_grupo VARCHAR(20) NOT NULL CHECK (tipo_grupo IN ('A','B','VACACIONAL')),
    capacidad_maxima SMALLINT NOT NULL CHECK (capacidad_maxima BETWEEN 30 AND 100),
    dia_semana VARCHAR(10) NOT NULL CHECK (dia_semana IN ('lunes','martes','miercoles','jueves','viernes','sabado','domingo')),
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    docente_titular INTEGER REFERENCES docentes(id_docente),
    UNIQUE (id_curso, nombre_grupo),
    CHECK (hora_fin > hora_inicio)
);

CREATE TABLE inscripciones (
    id_inscripcion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudiante INTEGER NOT NULL REFERENCES estudiantes(id_estudiante),
    id_grupo INTEGER NOT NULL REFERENCES grupos(id_grupo),
    id_curso INTEGER NOT NULL REFERENCES cursos(id_curso),
    fecha_inscripcion DATE NOT NULL DEFAULT CURRENT_DATE,
    estado VARCHAR(20) NOT NULL DEFAULT 'activa' CHECK (estado IN ('activa','retirada','finalizada')),
    valor_acordado NUMERIC(12,2) NOT NULL CHECK (valor_acordado >= 0),
    modalidad_pago VARCHAR(15) NOT NULL CHECK (modalidad_pago IN ('unico','cuotas')),
    numero_cuotas SMALLINT NOT NULL DEFAULT 3 CHECK (numero_cuotas >= 1),
    UNIQUE (id_estudiante, id_grupo),
    UNIQUE (id_estudiante, id_curso),
    CHECK ((modalidad_pago = 'unico' AND numero_cuotas = 1) OR (modalidad_pago = 'cuotas' AND numero_cuotas >= 2))
);

CREATE TABLE cuotas (
    id_cuota INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_inscripcion INTEGER NOT NULL REFERENCES inscripciones(id_inscripcion) ON DELETE CASCADE,
    numero_cuota SMALLINT NOT NULL CHECK (numero_cuota >= 1),
    porcentaje NUMERIC(5,2) NOT NULL CHECK (porcentaje > 0),
    valor NUMERIC(12,2) NOT NULL CHECK (valor > 0),
    fecha_vencimiento DATE NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente','pagada','vencida','anulada')),
    UNIQUE (id_inscripcion, numero_cuota)
);

CREATE TABLE pagos (
    id_pago INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_inscripcion INTEGER NOT NULL REFERENCES inscripciones(id_inscripcion) ON DELETE CASCADE,
    id_cuota INTEGER REFERENCES cuotas(id_cuota) ON DELETE SET NULL,
    fecha_pago DATE NOT NULL DEFAULT CURRENT_DATE,
    monto_pagado NUMERIC(12,2) NOT NULL CHECK (monto_pagado > 0),
    metodo_pago VARCHAR(20) NOT NULL CHECK (metodo_pago IN ('efectivo','transferencia','tarjeta','otro')),
    descripcion VARCHAR(200),
    comprobante VARCHAR(200)
);

CREATE TABLE clases (
    id_clase INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_grupo INTEGER NOT NULL REFERENCES grupos(id_grupo) ON DELETE CASCADE,
    id_docente INTEGER NOT NULL REFERENCES docentes(id_docente),
    fecha_clase DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    tema VARCHAR(150),
    modalidad VARCHAR(20) NOT NULL DEFAULT 'virtual' CHECK (modalidad IN ('virtual','presencial')),
    UNIQUE (id_grupo, fecha_clase, hora_inicio)
);

CREATE TABLE asistencias (
    id_asistencia INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_clase INTEGER NOT NULL REFERENCES clases(id_clase) ON DELETE CASCADE,
    id_inscripcion INTEGER NOT NULL REFERENCES inscripciones(id_inscripcion) ON DELETE CASCADE,
    estado_asistencia VARCHAR(20) NOT NULL CHECK (estado_asistencia IN ('presente','ausente','tarde','excusa')),
    observacion VARCHAR(200),
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (id_clase, id_inscripcion)
);

CREATE TABLE simulacros (
    id_simulacro INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_curso INTEGER NOT NULL REFERENCES cursos(id_curso),
    nombre_simulacro VARCHAR(80) NOT NULL,
    fecha_simulacro DATE NOT NULL,
    descripcion TEXT
);

CREATE TABLE resultados_simulacro (
    id_resultado INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_simulacro INTEGER NOT NULL REFERENCES simulacros(id_simulacro) ON DELETE CASCADE,
    id_inscripcion INTEGER NOT NULL REFERENCES inscripciones(id_inscripcion) ON DELETE CASCADE,
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,
    puntaje_global SMALLINT NOT NULL CHECK (puntaje_global BETWEEN 0 AND 500),
    lectura_critica SMALLINT CHECK (lectura_critica BETWEEN 0 AND 100),
    matematicas SMALLINT CHECK (matematicas BETWEEN 0 AND 100),
    ingles SMALLINT CHECK (ingles BETWEEN 0 AND 100),
    ciencias_naturales SMALLINT CHECK (ciencias_naturales BETWEEN 0 AND 100),
    sociales_ciudadanas SMALLINT CHECK (sociales_ciudadanas BETWEEN 0 AND 100),
    UNIQUE (id_simulacro, id_inscripcion)
);

CREATE INDEX idx_estudiantes_doc ON estudiantes(doc_identidad);
CREATE INDEX idx_acudientes_doc ON acudientes(doc_identidad);
CREATE INDEX idx_inscripciones_estudiante ON inscripciones(id_estudiante);
CREATE INDEX idx_inscripciones_grupo ON inscripciones(id_grupo);
CREATE INDEX idx_inscripciones_curso ON inscripciones(id_curso);
CREATE INDEX idx_cuotas_inscripcion ON cuotas(id_inscripcion);
CREATE INDEX idx_pagos_inscripcion ON pagos(id_inscripcion);
CREATE INDEX idx_pagos_cuota ON pagos(id_cuota);
CREATE INDEX idx_clases_grupo ON clases(id_grupo);
CREATE INDEX idx_asistencias_clase ON asistencias(id_clase);
CREATE INDEX idx_resultados_simulacro ON resultados_simulacro(id_inscripcion, id_simulacro);

CREATE VIEW vista_saldo_inscripcion AS
SELECT
    i.id_inscripcion,
    e.nombre_completo AS estudiante,
    c.nombre_curso,
    g.nombre_grupo,
    i.valor_acordado,
    COALESCE(SUM(p.monto_pagado), 0) AS total_pagado,
    i.valor_acordado - COALESCE(SUM(p.monto_pagado), 0) AS saldo_pendiente
FROM inscripciones i
JOIN estudiantes e ON e.id_estudiante = i.id_estudiante
JOIN grupos g ON g.id_grupo = i.id_grupo
JOIN cursos c ON c.id_curso = i.id_curso
LEFT JOIN pagos p ON p.id_inscripcion = i.id_inscripcion
GROUP BY i.id_inscripcion, e.nombre_completo, c.nombre_curso, g.nombre_grupo, i.valor_acordado;

CREATE VIEW vista_asistencia_por_estudiante AS
SELECT
    i.id_inscripcion,
    e.nombre_completo AS estudiante,
    c.nombre_curso,
    COUNT(a.id_asistencia) AS total_clases,
    SUM(CASE WHEN a.estado_asistencia = 'presente' THEN 1 ELSE 0 END) AS asistencias,
    SUM(CASE WHEN a.estado_asistencia = 'ausente' THEN 1 ELSE 0 END) AS ausencias,
    ROUND(
        (SUM(CASE WHEN a.estado_asistencia = 'presente' THEN 1 ELSE 0 END) * 100.0) /
        NULLIF(COUNT(a.id_asistencia), 0),
        2
    ) AS porcentaje_asistencia
FROM inscripciones i
JOIN estudiantes e ON e.id_estudiante = i.id_estudiante
JOIN grupos g ON g.id_grupo = i.id_grupo
JOIN cursos c ON c.id_curso = i.id_curso
LEFT JOIN asistencias a ON a.id_inscripcion = i.id_inscripcion
GROUP BY i.id_inscripcion, e.nombre_completo, c.nombre_curso;
