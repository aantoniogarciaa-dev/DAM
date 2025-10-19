
-- ============================================================
--  Proyecto: Base de datos CINE (estructura + datos + vistas)
--  Autor: Antonio (generado con ayuda de ChatGPT)
--  Fecha: 2025-10-19
--  Motor: MySQL/MariaDB (InnoDB, utf8mb4)
-- ============================================================

-- ---------- Crear BD y usarla
CREATE DATABASE IF NOT EXISTS cine
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;
USE cine;

-- ---------- Limpieza segura (si ya existen objetos)
SET FOREIGN_KEY_CHECKS = 0;
DROP VIEW IF EXISTS v_peliculas_director, v_reparto, v_peliculas_generos,
                    v_filmografia_actores, v_filmografia_directores, v_peliculas_por_genero,
                    v_actores_por_genero, v_top_actores_por_peliculas, v_actores_por_oscars,
                    v_num_peliculas_por_genero, v_duracion_media_por_genero,
                    v_peliculas_sin_actores, v_generos_sin_peliculas,
                    v_coactores, v_actores_por_director, v_integrantes_basico, v_peliculas_basico;
DROP TABLE IF EXISTS PELICULA_GENEROS;
DROP TABLE IF EXISTS PELICULA_ACTORES;
DROP TABLE IF EXISTS GENEROS;
DROP TABLE IF EXISTS PELICULAS;
DROP TABLE IF EXISTS DIRECTORES;
DROP TABLE IF EXISTS ACTORES;
DROP TABLE IF EXISTS INTEGRANTES;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
--  ESTRUCTURA (DDL)
-- ============================================================

-- INTEGRANTES
CREATE TABLE INTEGRANTES (
  idIntegrante        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  documentoIdentidad  VARCHAR(40) NOT NULL,
  nombre              VARCHAR(100) NOT NULL,
  apellido            VARCHAR(120) NOT NULL,
  fechaNacimiento     DATE NOT NULL,
  nacionalidad        VARCHAR(80),
  UNIQUE KEY uq_integrantes_documento (documentoIdentidad),
  INDEX idx_integrantes_nombre (nombre),
  INDEX idx_integrantes_apellido (apellido)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- ACTORES (subtipo de INTEGRANTES)
CREATE TABLE ACTORES (
  idActor           INT UNSIGNED PRIMARY KEY,
  tematicaPreferida VARCHAR(120),
  numeroOscars      TINYINT UNSIGNED NOT NULL DEFAULT 0,
  CONSTRAINT fk_actores_integrantes
    FOREIGN KEY (idActor)
    REFERENCES INTEGRANTES(idIntegrante)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT,
  CHECK (numeroOscars >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- DIRECTORES (subtipo de INTEGRANTES)
CREATE TABLE DIRECTORES (
  idDirector                INT UNSIGNED PRIMARY KEY,
  numeroPeliculasFilmadas   SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  CONSTRAINT fk_directores_integrantes
    FOREIGN KEY (idDirector)
    REFERENCES INTEGRANTES(idIntegrante)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT,
  CHECK (numeroPeliculasFilmadas >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- PELICULAS
CREATE TABLE PELICULAS (
  idPelicula       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  titulo           VARCHAR(200) NOT NULL,
  anioPublicacion  YEAR NOT NULL,
  idDirector       INT UNSIGNED NOT NULL,
  duracionMinutos  SMALLINT UNSIGNED NOT NULL,
  INDEX idx_peliculas_titulo (titulo),
  INDEX idx_peliculas_anio (anioPublicacion),
  INDEX idx_peliculas_director (idDirector),
  CONSTRAINT fk_peliculas_director
    FOREIGN KEY (idDirector)
    REFERENCES DIRECTORES(idDirector)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT,
  CHECK (duracionMinutos > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- GENEROS
CREATE TABLE GENEROS (
  idGenero     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(80) NOT NULL,
  descripcion  VARCHAR(255),
  UNIQUE KEY uq_generos_nombre (nombre),
  INDEX idx_generos_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- PELICULA_ACTORES (N:M)
CREATE TABLE PELICULA_ACTORES (
  idPelicula  INT UNSIGNED NOT NULL,
  idActor     INT UNSIGNED NOT NULL,
  PRIMARY KEY (idPelicula, idActor),
  INDEX idx_pa_actor (idActor),
  CONSTRAINT fk_pa_pelicula
    FOREIGN KEY (idPelicula)
    REFERENCES PELICULAS(idPelicula)
    ON UPDATE RESTRICT
    ON DELETE CASCADE,
  CONSTRAINT fk_pa_actor
    FOREIGN KEY (idActor)
    REFERENCES ACTORES(idActor)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- PELICULA_GENEROS (N:M)
CREATE TABLE PELICULA_GENEROS (
  idPelicula  INT UNSIGNED NOT NULL,
  idGenero    INT UNSIGNED NOT NULL,
  PRIMARY KEY (idPelicula, idGenero),
  INDEX idx_pg_genero (idGenero),
  CONSTRAINT fk_pg_pelicula
    FOREIGN KEY (idPelicula)
    REFERENCES PELICULAS(idPelicula)
    ON UPDATE RESTRICT
    ON DELETE CASCADE,
  CONSTRAINT fk_pg_genero
    FOREIGN KEY (idGenero)
    REFERENCES GENEROS(idGenero)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- ============================================================
--  DATOS DE EJEMPLO (DML)
-- ============================================================

-- INTEGRANTES
INSERT INTO INTEGRANTES (documentoIdentidad, nombre, apellido, fechaNacimiento, nacionalidad) VALUES
('12345678A', 'Carlos', 'Martínez', '1985-06-15', 'Española'),
('87654321B', 'Laura', 'Gómez', '1990-03-22', 'Argentina'),
('45678912C', 'Tomás', 'Rivera', '1978-11-05', 'Mexicana'),
('98765432D', 'Ana', 'López', '1982-09-13', 'Chilena'),
('19283746E', 'Marta', 'Sánchez', '1995-02-28', 'Española'),
('56473829F', 'Roberto', 'Delgado', '1975-12-01', 'Colombiana');

-- ACTORES (ids 1..3)
INSERT INTO ACTORES (idActor, tematicaPreferida, numeroOscars) VALUES
(1, 'Acción', 1),
(2, 'Drama', 2),
(3, 'Comedia', 0);

-- DIRECTORES (ids 4..6)
INSERT INTO DIRECTORES (idDirector, numeroPeliculasFilmadas) VALUES
(4, 10),
(5, 5),
(6, 7);

-- PELICULAS
INSERT INTO PELICULAS (titulo, anioPublicacion, idDirector, duracionMinutos) VALUES
('El Último Héroe', 2020, 4, 120),
('Lágrimas del Pasado', 2022, 5, 110),
('Risas Inmortales', 2023, 6, 95);

-- GENEROS
INSERT INTO GENEROS (nombre, descripcion) VALUES
('Acción', 'Películas con escenas intensas, persecuciones y combates.'),
('Drama', 'Historias con gran carga emocional.'),
('Comedia', 'Películas diseñadas para hacer reír.'),
('Ciencia Ficción', 'Historias basadas en avances tecnológicos o futuristas.');

-- PELICULA_ACTORES
INSERT INTO PELICULA_ACTORES (idPelicula, idActor) VALUES
(1, 1),
(1, 2),
(2, 2),
(2, 3),
(3, 1),
(3, 3);

-- PELICULA_GENEROS
INSERT INTO PELICULA_GENEROS (idPelicula, idGenero) VALUES
(1, 1),
(1, 4),
(2, 2),
(3, 3);

-- ============================================================
--  VISTAS (Consultas convertidas a vistas)
-- ============================================================

-- Películas con su director
CREATE OR REPLACE VIEW v_peliculas_director AS
SELECT p.idPelicula, p.titulo, p.anioPublicacion, p.duracionMinutos,
       idr.idIntegrante AS idDirector,
       idr.nombre AS directorNombre, idr.apellido AS directorApellido
FROM PELICULAS p
JOIN DIRECTORES d   ON p.idDirector = d.idDirector
JOIN INTEGRANTES idr ON d.idDirector = idr.idIntegrante;

-- Reparto de cada película
CREATE OR REPLACE VIEW v_reparto AS
SELECT p.idPelicula, p.titulo,
       ia.idIntegrante AS idActor,
       ia.nombre AS actorNombre, ia.apellido AS actorApellido
FROM PELICULAS p
JOIN PELICULA_ACTORES pa ON p.idPelicula = pa.idPelicula
JOIN ACTORES a           ON pa.idActor    = a.idActor
JOIN INTEGRANTES ia      ON a.idActor     = ia.idIntegrante;

-- Géneros de cada película
CREATE OR REPLACE VIEW v_peliculas_generos AS
SELECT p.idPelicula, p.titulo,
       g.idGenero, g.nombre AS genero
FROM PELICULAS p
JOIN PELICULA_GENEROS pg ON p.idPelicula = pg.idPelicula
JOIN GENEROS g           ON pg.idGenero  = g.idGenero;

-- Filmografía de actores
CREATE OR REPLACE VIEW v_filmografia_actores AS
SELECT ia.idIntegrante AS idActor, ia.nombre AS actorNombre, ia.apellido AS actorApellido,
       p.idPelicula, p.titulo, p.anioPublicacion
FROM INTEGRANTES ia
JOIN ACTORES a           ON ia.idIntegrante = a.idActor
JOIN PELICULA_ACTORES pa ON a.idActor       = pa.idActor
JOIN PELICULAS p         ON pa.idPelicula   = p.idPelicula;

-- Filmografía de directores
CREATE OR REPLACE VIEW v_filmografia_directores AS
SELECT idr.idIntegrante AS idDirector, idr.nombre AS directorNombre, idr.apellido AS directorApellido,
       p.idPelicula, p.titulo, p.anioPublicacion
FROM INTEGRANTES idr
JOIN DIRECTORES d ON idr.idIntegrante = d.idDirector
JOIN PELICULAS p  ON d.idDirector     = p.idDirector;

-- Películas por género
CREATE OR REPLACE VIEW v_peliculas_por_genero AS
SELECT g.idGenero, g.nombre AS genero,
       p.idPelicula, p.titulo, p.anioPublicacion
FROM GENEROS g
JOIN PELICULA_GENEROS pg ON g.idGenero    = pg.idGenero
JOIN PELICULAS p         ON pg.idPelicula = p.idPelicula;

-- Actores por género
CREATE OR REPLACE VIEW v_actores_por_genero AS
SELECT DISTINCT g.idGenero, g.nombre AS genero,
       ia.idIntegrante AS idActor, ia.nombre AS actorNombre, ia.apellido AS actorApellido
FROM GENEROS g
JOIN PELICULA_GENEROS pg ON g.idGenero = pg.idGenero
JOIN PELICULAS p         ON pg.idPelicula = p.idPelicula
JOIN PELICULA_ACTORES pa ON p.idPelicula  = pa.idPelicula
JOIN ACTORES a           ON pa.idActor    = a.idActor
JOIN INTEGRANTES ia      ON a.idActor     = ia.idIntegrante;

-- Top actores por nº de películas
CREATE OR REPLACE VIEW v_top_actores_por_peliculas AS
SELECT ia.idIntegrante AS idActor, ia.nombre AS actorNombre, ia.apellido AS actorApellido,
       COUNT(*) AS numPeliculas
FROM ACTORES a
JOIN INTEGRANTES ia   ON a.idActor = ia.idIntegrante
JOIN PELICULA_ACTORES pa ON a.idActor = pa.idActor
GROUP BY ia.idIntegrante, ia.nombre, ia.apellido;

-- Actores por nº de Oscars
CREATE OR REPLACE VIEW v_actores_por_oscars AS
SELECT ia.idIntegrante AS idActor, ia.nombre AS actorNombre, ia.apellido AS actorApellido,
       a.numeroOscars
FROM ACTORES a
JOIN INTEGRANTES ia ON a.idActor = ia.idIntegrante;

-- Nº de películas por género
CREATE OR REPLACE VIEW v_num_peliculas_por_genero AS
SELECT g.idGenero, g.nombre AS genero, COUNT(pg.idPelicula) AS numPeliculas
FROM GENEROS g
LEFT JOIN PELICULA_GENEROS pg ON g.idGenero = pg.idGenero
GROUP BY g.idGenero, g.nombre;

-- Duración media por género
CREATE OR REPLACE VIEW v_duracion_media_por_genero AS
SELECT g.idGenero, g.nombre AS genero, AVG(p.duracionMinutos) AS duracionMediaMin
FROM GENEROS g
JOIN PELICULA_GENEROS pg ON g.idGenero = pg.idGenero
JOIN PELICULAS p         ON pg.idPelicula = p.idPelicula
GROUP BY g.idGenero, g.nombre;

-- Películas sin actores
CREATE OR REPLACE VIEW v_peliculas_sin_actores AS
SELECT p.idPelicula, p.titulo
FROM PELICULAS p
LEFT JOIN PELICULA_ACTORES pa ON p.idPelicula = pa.idPelicula
WHERE pa.idPelicula IS NULL;

-- Géneros sin películas
CREATE OR REPLACE VIEW v_generos_sin_peliculas AS
SELECT g.idGenero, g.nombre
FROM GENEROS g
LEFT JOIN PELICULA_GENEROS pg ON g.idGenero = pg.idGenero
WHERE pg.idGenero IS NULL;

-- Co-actores (pares en misma película)
CREATE OR REPLACE VIEW v_coactores AS
SELECT DISTINCT
  iaA.idIntegrante AS actorA_Id, iaA.nombre AS actorA_Nombre, iaA.apellido AS actorA_Apellido,
  iaB.idIntegrante AS actorB_Id, iaB.nombre AS actorB_Nombre, iaB.apellido AS actorB_Apellido,
  p.idPelicula, p.titulo
FROM PELICULA_ACTORES paA
JOIN PELICULA_ACTORES paB ON paA.idPelicula = paB.idPelicula AND paA.idActor <> paB.idActor
JOIN ACTORES aA ON paA.idActor = aA.idActor
JOIN ACTORES aB ON paB.idActor = aB.idActor
JOIN INTEGRANTES iaA ON aA.idActor = iaA.idIntegrante
JOIN INTEGRANTES iaB ON aB.idActor = iaB.idIntegrante
JOIN PELICULAS p ON paA.idPelicula = p.idPelicula;

-- Actores por director
CREATE OR REPLACE VIEW v_actores_por_director AS
SELECT DISTINCT
  idr.idIntegrante AS idDirector, idr.nombre AS directorNombre, idr.apellido AS directorApellido,
  ia.idIntegrante AS idActor, ia.nombre AS actorNombre, ia.apellido AS actorApellido,
  p.idPelicula, p.titulo
FROM PELICULAS p
JOIN DIRECTORES d  ON p.idDirector = d.idDirector
JOIN INTEGRANTES idr ON d.idDirector = idr.idIntegrante
JOIN PELICULA_ACTORES pa ON p.idPelicula = pa.idPelicula
JOIN ACTORES a       ON pa.idActor = a.idActor
JOIN INTEGRANTES ia  ON a.idActor  = ia.idIntegrante;

-- Vistas utilitarias
CREATE OR REPLACE VIEW v_integrantes_basico AS
SELECT idIntegrante, documentoIdentidad, nombre, apellido, fechaNacimiento, nacionalidad
FROM INTEGRANTES;

CREATE OR REPLACE VIEW v_peliculas_basico AS
SELECT idPelicula, titulo, anioPublicacion, duracionMinutos, idDirector
FROM PELICULAS;

-- ============================================================
--  FIN DEL SCRIPT
-- ============================================================
