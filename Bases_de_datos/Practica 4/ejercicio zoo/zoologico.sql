-- ==========================================
-- 🐯 BASE DE DATOS ZOOLOGICO - MySQL
-- Creado por: Antonio García
-- Fecha: 2025-10-14
-- ==========================================

-- 1️⃣ Crear base de datos
DROP DATABASE IF EXISTS zoo;
CREATE DATABASE zoo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE zoo;

-- 2️⃣ Crear tablas
CREATE TABLE especies (
  id_especie INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  nombre_cientifico VARCHAR(150) NOT NULL,
  familia VARCHAR(120) NOT NULL,
  UNIQUE (nombre_cientifico)
) ENGINE=InnoDB;

CREATE TABLE habitats (
  id_habitat INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  capacidad INT NOT NULL CHECK (capacidad > 0),
  UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE animales (
  id_animal INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  genero ENUM('M','F') NOT NULL,
  id_especie INT NOT NULL,
  id_habitat INT NOT NULL,
  FOREIGN KEY (id_especie) REFERENCES especies(id_especie),
  FOREIGN KEY (id_habitat) REFERENCES habitats(id_habitat)
) ENGINE=InnoDB;

CREATE TABLE cuidadores (
  id_cuidador INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellidos VARCHAR(150) NOT NULL,
  email VARCHAR(254) NOT NULL UNIQUE,
  telefono VARCHAR(25)
) ENGINE=InnoDB;

CREATE TABLE asignaciones (
  id_animal INT NOT NULL,
  id_cuidador INT NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NULL,
  PRIMARY KEY (id_animal, id_cuidador, fecha_inicio),
  FOREIGN KEY (id_animal) REFERENCES animales(id_animal) ON DELETE CASCADE,
  FOREIGN KEY (id_cuidador) REFERENCES cuidadores(id_cuidador) ON DELETE CASCADE,
  CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

-- 3️⃣ Inserts de prueba
INSERT INTO especies (nombre, nombre_cientifico, familia) VALUES
('León', 'Panthera leo', 'Felidae'),
('Elefante africano', 'Loxodonta africana', 'Elephantidae'),
('Pingüino emperador', 'Aptenodytes forsteri', 'Spheniscidae');

INSERT INTO habitats (nombre, descripcion, capacidad) VALUES
('Sabana Africana', 'Praderas extensas con árboles dispersos', 10),
('Selva Tropical', 'Zona húmeda con vegetación densa', 15),
('Zona Polar', 'Área helada con nieve y hielo', 20);

INSERT INTO animales (nombre, fecha_nacimiento, genero, id_especie, id_habitat) VALUES
('Simba', '2019-05-20', 'M', 1, 1),
('Dumbo', '2015-09-13', 'M', 2, 2),
('Pingu', '2021-02-10', 'F', 3, 3);

INSERT INTO cuidadores (nombre, apellidos, email, telefono) VALUES
('Carlos', 'Martínez López', 'carlos.martinez@zoo.com', '600123456'),
('Laura', 'García Ruiz', 'laura.garcia@zoo.com', '600654321'),
('Marta', 'Sánchez Torres', 'marta.sanchez@zoo.com', '600987654');

INSERT INTO asignaciones (id_animal, id_cuidador, fecha_inicio, fecha_fin) VALUES
(1, 1, '2024-01-01', NULL),
(2, 2, '2023-03-15', '2024-03-15'),
(3, 3, '2024-06-01', NULL);

-- 4️⃣ Vistas
CREATE OR REPLACE VIEW v_animales_resumen AS
SELECT a.id_animal, a.nombre AS animal, e.nombre AS especie, h.nombre AS habitat
FROM animales a
JOIN especies e ON a.id_especie = e.id_especie
JOIN habitats h ON a.id_habitat = h.id_habitat;

-- 5️⃣ Funciones
DELIMITER //
CREATE FUNCTION fn_edad_anios(fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE());
END //
DELIMITER ;

-- 6️⃣ Procedimientos
DELIMITER //
CREATE PROCEDURE sp_asignar_cuidador(
    IN p_id_animal INT,
    IN p_id_cuidador INT,
    IN p_fecha_inicio DATE
)
BEGIN
    UPDATE asignaciones
    SET fecha_fin = DATE_SUB(p_fecha_inicio, INTERVAL 1 DAY)
    WHERE id_animal = p_id_animal
      AND id_cuidador = p_id_cuidador
      AND fecha_fin IS NULL
      AND p_fecha_inicio IS NOT NULL;

    INSERT INTO asignaciones (id_animal, id_cuidador, fecha_inicio, fecha_fin)
    VALUES (p_id_animal, p_id_cuidador, p_fecha_inicio, NULL);
END //
DELIMITER ;
