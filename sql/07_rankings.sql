--- Aquí se uso metrica de ranking "ptc_change"
ALTER TABLE indicators ADD COLUMN higher_is_better BOOLEAN; 

UPDATE indicators SET higher_is_better = TRUE
WHERE series_code in ('NE.GDI.TOTL.ZS', 'NY.GDP.MKTP.CD','NY.GDP.MKTP.KD.ZG','NY.GDP.PCAP.CD','ST.INT.ARVL');

UPDATE indicators SET higher_is_better = FALSE 
WHERE series_code IN ('FP.CPI.TOTL.ZG', 'SL.UEM.TOTL.ZS');

SELECT series_code, series_name, higher_is_better FROM indicators;

WITH period_avg  AS(
       SELECT 
	        c.country_name,
			i.series_name,
			i.higher_is_better, 
			AVG(e.value) FILTER (WHERE e.period_comparative = 'pre_world_cup') AS avg_pre,
			AVG(e.value) FILTER (WHERE e.period_comparative = 'post_world_cup') AS avg_post
	   FROM economic_data e
	   JOIN countries c ON e.country_code = c.country_code
	   JOIN indicators i ON e.series_code = i.series_code
	   WHERE e.period_comparative != 'out_of_range'
	   GROUP BY c.country_name, i.series_name, i.higher_is_better
),
period_change AS (
    SELECT 
	     country_name,
		 series_name,
		 ROUND(avg_pre::numeric, 2) AS avg_pre,
		 ROUND(avg_post::numeric, 2) AS avg_post,
		 ROUND(((avg_post - avg_pre) / NULLIF(avg_pre, 0) * 100)::numeric, 2) AS pct_change, higher_is_better
	FROM period_avg	 
)
SELECT 
    country_name,
	series_name,
	avg_pre,
	avg_post,
	pct_change,
	RANK() OVER(
          PARTITION BY series_name
		  ORDER BY CASE WHEN higher_is_better THEN pct_change ELSE -pct_change END DESC
	) AS ranking
FROM period_change
ORDER BY series_name, ranking;



--- Despues correr la query de arriba, pues me di cuenta que hay datos que se desploman por ser porcentajes
-- Como Russia, cuando solo sube 2 puntos, el porcentaje lo toma com 995% xd, asi que hay que tratar el valor por lo que es

--- Cambio a Diferencia absoluta

ALTER TABLE indicators ADD COLUMN use_absolute_change BOOLEAN;

UPDATE indicators SET use_absolute_change = TRUE
WHERE series_code in ('NY.GDP.MKTP.KD.ZG', 'FP.CPI.TOTL.ZG','SL.UEM.TOTL.ZS');

UPDATE indicators SET use_absolute_change = FALSE
WHERE series_code IN('NY.GDP.MKTP.CD', 'NY.GDP.PCAP.CD', 'ST.INT.ARVL', 'NE.GDI.TOTL.ZS');

SELECT series_code, series_name, higher_is_better, use_absolute_change
FROM indicators;


---  Ahora hacer la query del ranking, pero con los nuevos indicadores

WITH period_avg AS(
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
	   ROUND(((avg_post - avg_pre) / NULLIF(avg_pre, 0) *100)::numeric, 2) AS pct_change
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

--- Ultima query para que haya protección de datos (espero)

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







