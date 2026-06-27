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
    country_name,
	ROUND(avg_capital_formation_pre::numeric, 2) AS avg_capital_formation_Pre,
	ROUND(avg_unemployment_post::numeric, 2) AS avg_unemployment_post
FROM country_metrics
ORDER BY country_name;

--- Ahora tengo que hacer unas correlaciones para calcular el desempleo despues de mundial
-- Son dos, una con Qatar y otra sin el, literal esa país no tiene nada malo, tiene mucho dinero, nada de gente

--- Version 1: Los 5 países juntos-

WITH country_metrics AS (
     SELECT
	      c.country_name,
		  AVG(e.value) FILTER (
              WHERE i.series_code = 'NE.GDI.TOTL.ZS'
			  AND e.period_comparative = 'pre_world_cup'
		  ) AS avg_capital_formation_pre,
		  AVG(e.value) FILTER (
             WHERE e.period_comparative = 'post_world_cup'
		  ) AS avg_unemployment_post
      FROM economic_data e
	  JOIN countries c ON e.country_code = c.country_code
	  JOIN indicators i ON i.series_code = i.series_code
	  GROUP BY c.country_name
)
SELECT 
     'Con los 5 países' AS escenario,
	 ROUND(CORR(avg_capital_formation_pre, avg_unemployment_post)::numeric, 4) AS correlacion,
	 COUNT(*) AS n_paises
FROM country_metrics;


-- Versión 2: quitanto a los qataris

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
     'Sin Qatar (Outlier)' AS escenario,
	 ROUND(CORR(avg_capital_formation_pre, avg_unemployment_post)::numeric, 4) AS correlacion,
	 COUNT(*) AS n_paises
FROM country_metrics;

















