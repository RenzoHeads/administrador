-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS tarea_etiquetas_id_seq;

-- Table Definition
CREATE TABLE "public"."tarea_etiquetas" (
    "id" int4 NOT NULL DEFAULT nextval('tarea_etiquetas_id_seq'::regclass),
    "tarea_id" int4 NOT NULL,
    "etiqueta_id" int4 NOT NULL,
    PRIMARY KEY ("id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS listas_id_seq;

-- Table Definition
CREATE TABLE "public"."listas" (
    "id" int4 NOT NULL DEFAULT nextval('listas_id_seq'::regclass),
    "usuario_id" int4,
    "nombre" varchar(100),
    "descripcion" text,
    "color" varchar(20),
    PRIMARY KEY ("id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS categorias_id_seq;

-- Table Definition
CREATE TABLE "public"."categorias" (
    "id" int4 NOT NULL DEFAULT nextval('categorias_id_seq'::regclass),
    "nombre" varchar(100),
    "color" varchar(20),
    PRIMARY KEY ("id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS etiquetas_id_seq;

-- Table Definition
CREATE TABLE "public"."etiquetas" (
    "id" int4 NOT NULL DEFAULT nextval('etiquetas_id_seq'::regclass),
    "nombre" varchar(100),
    "color" varchar(20),
    PRIMARY KEY ("id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS recordatorios_id_seq;

-- Table Definition
CREATE TABLE "public"."recordatorios" (
    "id" int4 NOT NULL DEFAULT nextval('recordatorios_id_seq'::regclass),
    "tarea_id" int4,
    "fecha_hora" timestamp,
    "token_fcm" text,
    "mensaje" text,
    "enviado" bool DEFAULT false,
    "fecha_envio" timestamp,
    "intentos_envio" int4 DEFAULT 0,
    "error_envio" text,
    PRIMARY KEY ("id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS tareas_id_seq;

-- Table Definition
CREATE TABLE "public"."tareas" (
    "id" int4 NOT NULL DEFAULT nextval('tareas_id_seq'::regclass),
    "usuario_id" int4,
    "lista_id" int4,
    "titulo" varchar(200),
    "descripcion" text,
    "fecha_creacion" timestamp DEFAULT CURRENT_TIMESTAMP,
    "fecha_vencimiento" timestamp,
    "categoria_id" int4,
    "estado_id" int4,
    "prioridad_id" int4,
    PRIMARY KEY ("id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS usuarios_id_seq;

-- Table Definition
CREATE TABLE "public"."usuarios" (
    "id" int4 NOT NULL DEFAULT nextval('usuarios_id_seq'::regclass),
    "nombre" varchar(100),
    "email" varchar(100) NOT NULL,
    "contrasena" text NOT NULL,
    "imagen_perfil" text,
    "reset_token" varchar(100),
    "reset_token_expira_en" timestamp,
    "token_fcm" text,
    PRIMARY KEY ("id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS estados_id_seq;

-- Table Definition
CREATE TABLE "public"."estados" (
    "id" int4 NOT NULL DEFAULT nextval('estados_id_seq'::regclass),
    "nombre" varchar(20) NOT NULL,
    PRIMARY KEY ("id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS prioridades_id_seq;

-- Table Definition
CREATE TABLE "public"."prioridades" (
    "id" int4 NOT NULL DEFAULT nextval('prioridades_id_seq'::regclass),
    "nombre" varchar(20) NOT NULL,
    PRIMARY KEY ("id")
);

ALTER TABLE "public"."tarea_etiquetas" ADD FOREIGN KEY ("tarea_id") REFERENCES "public"."tareas"("id") ON DELETE CASCADE;
ALTER TABLE "public"."tarea_etiquetas" ADD FOREIGN KEY ("etiqueta_id") REFERENCES "public"."etiquetas"("id") ON DELETE CASCADE;


-- Indices
CREATE UNIQUE INDEX tarea_etiquetas_unique ON public.tarea_etiquetas USING btree (tarea_id, etiqueta_id);
ALTER TABLE "public"."listas" ADD FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios"("id");
ALTER TABLE "public"."recordatorios" ADD FOREIGN KEY ("tarea_id") REFERENCES "public"."tareas"("id") ON DELETE CASCADE;


-- Indices
CREATE INDEX idx_recordatorios_fecha_hora_enviado ON public.recordatorios USING btree (fecha_hora, enviado);
ALTER TABLE "public"."tareas" ADD FOREIGN KEY ("estado_id") REFERENCES "public"."estados"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "public"."tareas" ADD FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios"("id");
ALTER TABLE "public"."tareas" ADD FOREIGN KEY ("lista_id") REFERENCES "public"."listas"("id");
ALTER TABLE "public"."tareas" ADD FOREIGN KEY ("categoria_id") REFERENCES "public"."categorias"("id");
ALTER TABLE "public"."tareas" ADD FOREIGN KEY ("prioridad_id") REFERENCES "public"."prioridades"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- Indices
CREATE UNIQUE INDEX usuarios_email_key ON public.usuarios USING btree (email);


-- Indices
CREATE UNIQUE INDEX estados_nombre_key ON public.estados USING btree (nombre);


-- Indices
CREATE UNIQUE INDEX prioridades_nombre_key ON public.prioridades USING btree (nombre);
