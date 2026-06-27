CREATE TABLE temp_import (      ------ Me toco crear una tabla temporal, por que pgadmin jode por todo.
    country_name    VARCHAR(100),
    country_code    VARCHAR(3),
    series_name     VARCHAR(200),
    series_code     VARCHAR(50),
    year            INT,
    value           TEXT,
    year_relative   INT
);

---- Probando que si entro todo.
SELECT * FROM temp_import LIMIT 5;

SELECT DISTINCT country_name FROM temp_import;
SELECT DISTINCT series_name FROM temp_import;

--- Ahora me toca convertir la tabla a NUMERIC

ALTER TABLE temp_import ADD COLUMN value_numeric NUMERIC(20,6);

UPDATE temp_import 
SET value_numeric = REPLACE(value, ',', '.')::NUMERIC(20,6);

----- Ahora en el CVS se me subieron celdas con "VALOR!" que flojeraaaaaa
SELECT * FROM temp_import WHERE value = '#VALOR!';

UPDATE temp_import
SET VALUE = NULL
WHERE value = '#VALOR!';


UPDATE temp_import
SET value_numeric = REPLACE(value, ',' , '.')::NUMERIC(20,6)
WHERE VALUE IS NOT NULL;



--- Ahora muevo los datos correctos a economic_data

INSERT INTO economic_data (country_code, series_code, year, value, year_relative)
SELECT country_code, series_code, year, value_numeric, year_relative
FROM temp_import;

SELECT COUNT(*) FROM economic_data;

---- Verificación final.. Espero

SELECT
   c.country_name,
   i.series_name,
   e.year,
   e.value,
   e.year_relative

FROM economic_data e
JOIN countries c ON e.country_code = c.country_code
JOIN indicators i ON e.series_code = i.series_code
WHERE c.country_name = 'Brazil'
  AND i.series_name = 'GDP (current US$)'
  ORDER BY e.year
  LIMIT 10;

DROP TABLE temp_import;












