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
period_change AS(
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
),
ranking_completo AS (
    SELECT 
         country_name,
		 series_name,
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
)
SELECT
    country_name,
	COUNT(*) AS veces_en_puesto_1
FROM ranking_completo
WHERE ranking = 1
GROUP BY country_name
ORDER BY veces_en_puesto_1 DESC;


--- BENCHMARK

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
	--- Brasil
	b.avg_pre AS brazil_avg_pre,
	b.avg_post AS brazil_avg_post,
	CASE WHEN b.use_absolute_change THEN b.absolute_change::text
	     ELSE b.pct_change::text END AS brazil_change,
   --- Alemenia (Benchamark Principal)
   g.avg_pre AS germany_avg_pre,
   g.avg_post AS germany_avg_post,
   CASE WHEN g.use_absolute_change THEN g.absolute_change::text
        ELSE g.pct_change::text END AS germany_change,
	--- Qatar (Bencharmark Secundario)
	q.avg_pre AS qatar_avg_pre,
	q.avg_post AS qatar_avg_post,
	CASE WHEN q.use_absolute_change THEN q.absolute_change::text
	     ELSE q.pct_change::text END AS qatar_change,
	--- Diferencia Brasil vs Alemania
	CASE WHEN b.use_absolute_change
	     THEN ROUND((g.absolute_change - b.absolute_change)::numeric, 2)::text
		 ELSE ROUND((g.pct_change - b.pct_change)::numeric, 2)::text
	END AS gap_vs_germany,
	-- Brecha Brasil vs Qatar
	CASE WHEN b.use_absolute_change
	     THEN ROUND((q.absolute_change - b.absolute_change)::numeric, 2)::text
		 ELSE ROUND((q.pct_change - b.pct_change)::numeric, 2)::text
	END AS gap_vs_qatar
FROM period_change b
JOIN period_change g ON b.series_name = g.series_name AND g.country_name = 'Germany'
JOIN period_change q ON b.series_name = q.series_name AND q.country_name = 'Qatar'
WHERE b.country_name = 'Brazil'
ORDER BY b.series_name;

































