USE vinoteca;

-- Eliminar restricciones viejas
ALTER TABLE vino_cepa DROP CONSTRAINT fk_vino_cepa_vino;
ALTER TABLE vino_cepa DROP CONSTRAINT fk_vino_cepa_cepa;

-- Recrear con ON DELETE CASCADE
ALTER TABLE vino_cepa
ADD CONSTRAINT fk_vino_cepa_vino FOREIGN KEY (id_vino)
    REFERENCES vino(id_vino)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

ALTER TABLE vino_cepa
ADD CONSTRAINT fk_vino_cepa_cepa FOREIGN KEY (id_cepa)
    REFERENCES cepa(id_cepa)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Eliminar FK actual
ALTER TABLE region
DROP CONSTRAINT fk_region_pais;

-- Volver a agregar la FK
ALTER TABLE region
ADD CONSTRAINT fk_region_pais FOREIGN KEY (id_pais)
    REFERENCES pais(id_pais)
    ON UPDATE CASCADE   -- Si cambia el ID del país, se actualiza en cascada en region
    ON DELETE NO ACTION; -- Bloquea la eliminación del país si tiene regiones vinculadas
