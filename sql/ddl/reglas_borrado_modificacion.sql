USE vinoteca;

-- Eliminar restricciones viejas
ALTER TABLE vino_cepa DROP CONSTRAINT fk_vino_cepa_vino;
ALTER TABLE vino_cepa DROP CONSTRAINT fk_vino_cepa_cepa;

-- Recrear con ON DELETE CASCADE
ALTER TABLE vino_cepa
ADD CONSTRAINT fk_vino_cepa_vino FOREIGN KEY (vino_id)
    REFERENCES vino(vino_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

ALTER TABLE vino_cepa
ADD CONSTRAINT fk_vino_cepa_cepa FOREIGN KEY (cepa_id)
    REFERENCES cepa(cepa_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Eliminar FK actual
ALTER TABLE region
DROP CONSTRAINT fk_region_pais;

-- Volver a agregar la FK
ALTER TABLE region
ADD CONSTRAINT fk_region_pais FOREIGN KEY (pais_id)
    REFERENCES pais(pais_id)
    ON UPDATE CASCADE   -- Si cambia el ID del país, se actualiza en cascada en region
    ON DELETE NO ACTION; -- Bloquea la eliminación del país si tiene regiones vinculadas
