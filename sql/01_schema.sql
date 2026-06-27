CREATE TABLE countries (
   country_code      VARCHAR(3) PRIMARY KEY,
   country_name       VARCHAR(100) NOT NULL,
   world_cup_year    INT NOT NULL
);

CREATE TABLE indicators (
    series_code VARCHAR(50) PRIMARY KEY,
	series_name VARCHAR(200) NOT NULL
);


CREATE TABLE economic_data(
    id             SERIAL PRIMARY KEY,
	country_code   VARCHAR(3) NOT NULL REFERENCES countries(country_code),
	series_code    VARCHAR(50) NOT NULL REFERENCES indicators(series_code),
	year           INT NOT NULL,
	value          NUMERIC(20,6),
	year_relative  INT NOT NULL
);

