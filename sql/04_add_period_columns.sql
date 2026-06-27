-- Evaluar Periodos.
SELECT DISTINCT period_brazil_deep FROM economic_data;


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


---- Query para ver cual fue el país que mas turismo tuvo en su mundial (creo que Brasil)
SELECT
    c.country_name,
	ROUND(AVG(e.value) FILTER (WHERE e.period_comparative = 'world_cup_year')::numeric, 0) AS tourism_during_world_cup
	FROM economic_data e
	JOIN countries c ON e.country_code = c.country_code
	JOIN indicators i ON e.series_code = i.series_code
	WHERE i.series_name = 'International tourism, number of arrivals' AND e.period_comparative = 'world_cup_year'
	GROUP BY c.country_name
	ORDER BY tourism_during_world_cup DESC;

