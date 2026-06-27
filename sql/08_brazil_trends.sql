SELECT 
     e.year,
	 e.year_relative,
	 e.period_brazil_deep,
	 MAX(e.value) FILTER (WHERE i.series_code = 'Y.GDP.MKTP.CD') AS gdp_total,
	 MAX(e.value) FILTER (WHERE i.series_code = 'NY.GDP.MKTP.KD.ZG') AS gdp_growth,
	 MAX(e.value) FILTER (WHERE i.series_code = 'NY.GDP.PCAP.CD') AS gdp_per_capita,
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