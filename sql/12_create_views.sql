--- v_period_evolution

CREATE VIEW v_period_evolution AS
SELECT 
    c.country_name,
    i.series_name,
    ROUND(AVG(e.value) FILTER (WHERE e.period_comparative = 'pre_world_cup')::numeric, 2) AS avg_pre,
    COUNT(e.value) FILTER (WHERE e.period_comparative = 'pre_world_cup') AS n_pre,
    ROUND(AVG(e.value) FILTER (WHERE e.period_comparative = 'world_cup_year')::numeric, 2) AS avg_during,
    ROUND(AVG(e.value) FILTER (WHERE e.period_comparative = 'post_world_cup')::numeric, 2) AS avg_post,
    COUNT(e.value) FILTER (WHERE e.period_comparative = 'post_world_cup') AS n_post
FROM economic_data e
JOIN countries c ON e.country_code = c.country_code
JOIN indicators i ON e.series_code = i.series_code
WHERE e.period_comparative != 'out_of_range'
GROUP BY c.country_name, i.series_name
ORDER BY c.country_name, i.series_name;

-- Vista 2: Rankings

DROP VIEW v_rankings;

CREATE VIEW v_rankings AS
WITH period_avg AS (
    SELECT 
        c.country_name,
        i.series_name,
        i.higher_is_better,
        i.use_absolute_change,
        AVG(e.value) FILTER (WHERE e.period_comparative = 'pre_world_cup') AS avg_pre,
        AVG(e.value) FILTER (WHERE e.period_comparative = 'post_world_cup') AS avg_post
    FROM economic_data e
    JOIN countries c ON e.country_code = c.country_code
    JOIN indicators i ON e.series_code = i.series_code
    WHERE e.period_comparative != 'out_of_range'
    GROUP BY c.country_name, i.series_name, i.higher_is_better, i.use_absolute_change
),
period_change AS (
    SELECT 
        country_name,
        series_name,
        higher_is_better,
        use_absolute_change,
        ROUND(avg_pre::numeric, 2) AS avg_pre,
        ROUND(avg_post::numeric, 2) AS avg_post,
        ROUND((avg_post - avg_pre)::numeric, 2) AS absolute_change,
        CASE 
            WHEN ABS(avg_pre) < 0.5 THEN NULL
            ELSE ROUND(((avg_post - avg_pre) / NULLIF(avg_pre, 0) * 100)::numeric, 2)
        END AS pct_change
    FROM period_avg
)
SELECT 
    country_name,
    series_name,
    avg_pre,
    avg_post,
    absolute_change,
    pct_change,
    RANK() OVER (
        PARTITION BY series_name 
        ORDER BY 
            CASE 
                WHEN use_absolute_change AND higher_is_better THEN absolute_change
                WHEN use_absolute_change AND NOT higher_is_better THEN -absolute_change
                WHEN NOT use_absolute_change AND higher_is_better THEN pct_change
                ELSE -pct_change
            END DESC
    ) AS ranking
FROM period_change
ORDER BY series_name, ranking;

SELECT * FROM v_rankings;

-- VISTA 3: Brasil tendencia o_O

CREATE VIEW v_brazil_trends AS
SELECT 
     e.year,
	 e.year_relative,
	 e.period_brazil_deep,
	 MAX(e.value) FILTER (WHERE i.series_code = 'NY.GDP.MKTP.CD') AS gdp_total,
	 MAX(e.value) FILTER (WHERE i.series_code = 'NY.GDP.MKTP.KD.ZG') AS gdp_growth,
	 MAX(e.value) FILTER (WHERE i.series_code = 'NY.GDP.PCAP.CD') AS gpd_per_capita,
	 MAX(e.value) FILTER (WHERE i.series_code = 'SL.UEM.TOTL.ZS') AS unemployment,
	 MAX(e.value) FILTER (WHERE i.series_code = 'FP.CPI.TOTL.ZG') AS inflation,
	 MAX(e.value) FILTER (WHERE i.series_code = 'ST.INT.ARVL') AS tourism,
	 MAX(e.value) FILTER (WHERE i.series_code = 'NE.GDI.TOTL.ZS') AS capital_formation
FROM economic_data e
JOIN countries c ON e.country_code = c.country_code
JOIN indicators i ON e.series_code = i.series_code
WHERE c.country_name = 'Brazil'
GROUP BY e.year, e.year_relative, e.period_brazil_deep
ORDER BY e.year;

SELECT * FROM v_brazil_trends;


-- VISTA 4: Todos los países y sus tendencias
CREATE VIEW v_all_countries_trends AS
SELECT
    c.country_name,
	e.year,
	e.year_relative,
	e.period_comparative,
	MAX(e.value) FILTER (WHERE i.series_code = 'NY.GDP.MKTP.CD') AS gdp_total,
	MAX(e.value) FILTER (WHERE i.series_code = 'NY.GDP.MKTP.KD.ZG') AS gpd_growth,
	MAX(e.value) FILTER (WHERE i.series_code = 'NY.GDP.PCAP.CD') AS gdp_per_capita,
	MAX(e.value) FILTER (WHERE i.series_code = 'SL.UEM.TOTL.ZS') AS unemployment,
	MAX(e.value) FILTER (WHERE i.series_code = 'FP.CPI.TOTL.ZG') AS inflation,
	MAX(e.value) FILTER (WHERE i.series_code = 'ST.INT.ARVL') AS tourism,
	MAX(e.value) FILTER (WHERE i.series_code = 'NE.GDI.TOTL.ZS') AS capital_formation
FROM economic_data e
JOIN countries c ON e.country_code = c.country_code
JOIN indicators i ON e.series_code = i.series_code
GROUP BY c.country_name, e.year, e.year_relative, e.period_comparative
ORDER BY c.country_name, e.year_relative;


SELECT * FROM v_all_countries_trends LIMIT 40


-- VISTA 5.1: Correlaciones de los 5 países
DROP VIEW v_correlations_all;

CREATE VIEW v_correlations_all AS
WITH country_metrics AS (
    SELECT 
        c.country_name,
        AVG(e.value) FILTER (
            WHERE i.series_code = 'NE.GDI.TOTL.ZS' 
            AND e.period_comparative = 'pre_world_cup'
        ) AS avg_capital_formation_pre,
        AVG(e.value) FILTER (
            WHERE i.series_code = 'SL.UEM.TOTL.ZS' 
            AND e.period_comparative = 'post_world_cup'
        ) AS avg_unemployment_post
    FROM economic_data e
    JOIN countries c ON e.country_code = c.country_code
    JOIN indicators i ON e.series_code = i.series_code
    GROUP BY c.country_name
)
SELECT 
    'Con los 5 países' AS escenario,
    ROUND(CORR(avg_capital_formation_pre, avg_unemployment_post)::numeric, 4) AS correlacion,
    COUNT(*) AS n_paises
FROM country_metrics;

--- VISTA 5.2: Correlaciones sin Qatar

CREATE VIEW v_correlations_no_qatar AS
WITH country_metrics AS (
     SELECT 
          c.country_name,
		  AVG(e.value) FILTER (
              WHERE i.series_code = 'NE.GDI.TOTL.ZS'
			  AND e.period_comparative = 'pre_world_cup'
		  ) AS avg_capital_formation_pre,
		  AVG(e.value) FILTER (
              WHERE i.series_code = 'SL.UEM.TOTL.ZS'
			  AND e.period_comparative = 'post_world_cup'
		  ) AS avg_unemployment_post
	   FROM economic_data e
	   JOIN countries c ON e.country_code = c.country_code
	   JOIN indicators i ON e.series_code = i.series_code
	   WHERE c.country_name != 'Qatar'
	   GROUP BY c.country_name
)
SELECT
    'Sin Qatar (Outliers)' As escenario,
	ROUND(CORR(avg_capital_formation_pre, avg_unemployment_post)::numeric, 4) AS correlacion,
	COUNT(*) AS n_paises
FROM country_metrics;


SELECT * FROM v_correlations_no_qatar;


-- VISTA 6: Los Benchamarks

-- VISTA 6: Benchmarks
CREATE VIEW v_benchmarks AS
WITH period_avg AS (
    SELECT 
        c.country_name,
        i.series_name,
        i.higher_is_better,
        i.use_absolute_change,
        AVG(e.value) FILTER (WHERE e.period_comparative = 'pre_world_cup') AS avg_pre,
        AVG(e.value) FILTER (WHERE e.period_comparative = 'post_world_cup') AS avg_post
    FROM economic_data e
    JOIN countries c ON e.country_code = c.country_code
    JOIN indicators i ON e.series_code = i.series_code
    WHERE e.period_comparative != 'out_of_range'
    GROUP BY c.country_name, i.series_name, i.higher_is_better, i.use_absolute_change
),
period_change AS (
    SELECT 
        country_name,
        series_name,
        higher_is_better,
        use_absolute_change,
        ROUND(avg_pre::numeric, 2) AS avg_pre,
        ROUND(avg_post::numeric, 2) AS avg_post,
        ROUND((avg_post - avg_pre)::numeric, 2) AS absolute_change,
        CASE 
            WHEN ABS(avg_pre) < 0.5 THEN NULL
            ELSE ROUND(((avg_post - avg_pre) / NULLIF(avg_pre, 0) * 100)::numeric, 2)
        END AS pct_change
    FROM period_avg
)
SELECT 
    b.series_name,
    b.higher_is_better,
    b.use_absolute_change,
    b.avg_pre AS brazil_avg_pre,
    b.avg_post AS brazil_avg_post,
    CASE WHEN b.use_absolute_change THEN b.absolute_change::text
         ELSE b.pct_change::text END AS brazil_change,
    g.avg_pre AS germany_avg_pre,
    g.avg_post AS germany_avg_post,
    CASE WHEN g.use_absolute_change THEN g.absolute_change::text
         ELSE g.pct_change::text END AS germany_change,
    q.avg_pre AS qatar_avg_pre,
    q.avg_post AS qatar_avg_post,
    CASE WHEN q.use_absolute_change THEN q.absolute_change::text
         ELSE q.pct_change::text END AS qatar_change,
    CASE WHEN b.use_absolute_change 
         THEN ROUND((g.absolute_change - b.absolute_change)::numeric, 2)::text
         ELSE ROUND((g.pct_change - b.pct_change)::numeric, 2)::text
    END AS gap_vs_germany,
    CASE WHEN b.use_absolute_change 
         THEN ROUND((q.absolute_change - b.absolute_change)::numeric, 2)::text
         ELSE ROUND((q.pct_change - b.pct_change)::numeric, 2)::text
    END AS gap_vs_qatar
FROM period_change b
JOIN period_change g ON b.series_name = g.series_name AND g.country_name = 'Germany'
JOIN period_change q ON b.series_name = q.series_name AND q.country_name = 'Qatar'
WHERE b.country_name = 'Brazil'
ORDER BY b.series_name;

SELECT * FROM v_benchmarks;


SELECT 
    country_name,
    series_name,
    AVG(value) FILTER (WHERE period_comparative = 'pre_world_cup') AS avg_pre,
    AVG(value) FILTER (WHERE period_comparative = 'post_world_cup') AS avg_post
FROM economic_data e
JOIN countries c ON e.country_code = c.country_code
JOIN indicators i ON e.series_code = i.series_code
WHERE c.country_name = 'Brazil'
AND period_comparative != 'out_of_range'
GROUP BY country_name, series_name;




