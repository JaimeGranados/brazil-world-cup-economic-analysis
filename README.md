# Can Brazil Host Again?Economic Legacy Analysis of the 2014 FIFA World Cup
  ### ¿Puede Brasil volver a ser sede? Análisis del legado económico del Mundial 2014
<img width="1920" height="1102" alt="pexels-people-1284253_1920" src="https://github.com/user-attachments/assets/eecf85f5-6813-451c-a7e5-017e744dedf3" />




 ### 🌐 English Version 

#### 🎯Central Research Question

*Did brazil's economic indicators improve or worsen after the 2014 FIFA World Cup, and what thresholds does it need to reach to be a viable host nation in 2030 or 2034?*


### Project Overview

This is a portafolio project developed as part of Data Analytics learning journe. It analyzes the **economic legacy of the FIFA World Cup in Brazil**, benchmarking it against four other host nations using World Bank indicators across a relative time window centered oin each country's World Cup year.

The project covers the full data pipeline: from raw CSV extractions and cleaning, througth relational database desing and advanced SQL analysis, to an interactive Power BI dashboard with 6 pages.

**Target audience:** Colombian and international companies evaluating data analytics profiles.

### Tech Stack

##  Tech Stack

| Tool                  | Purpose                                              |
|-----------------------|------------------------------------------------------|
| **PostgreSQL**        | Relational database, advanced SQL queries, views     |
| **Power BI Desktop**  | Interactive dashboard (6 pages)                      |
| **Power Query (M)**   | Data transformation and cleaning                     |
| **Python**            | Generating SQL correction script for year-value misalignment |
| **Git + GitHub**      | Version control and portfolio publishing             |

### Dashboard Pages
 #### Home
 Project presentation page with title, central question and navigation
 
<p align="center">
  <img width="700" alt="Home" src="https://github.com/user-attachments/assets/74bdf018-e51e-4de4-832d-86e79875ab27" />
</p>

#### Overview
Key performance indicators (KPIs) for brazil post-World Cup, including GDP per capita, unemployment, GDP growth, and tourism arrivals - with conditional color coding (red = worsened, green = improved vs pre-WC period)

<p align="center">
<img width="700"  alt="Overview" src="https://github.com/user-attachments/assets/572e540c-9de9-4819-b57e-50978cef2436" />
</p>

### Brazil Trends
Year-by-year evolution of all 7 economic indicators for Brazil (2002-2024), with an indicators slicer, a reference lline at 2014 (World Cup year), and period summary table.

<p align="center">
<img width="700"  alt="Brazil_Trends" src="https://github.com/user-attachments/assets/3d23206a-a922-4c69-9c5e-13b1f660af93" />
</p>

### Country Comparison
Side-by-side comparison of all 5 host nations across pre-WC and post-WC averages, with ranking table and interactive indicator slicer.

<p align="center">
  <strong>Comparison</strong><br>
  <img width="700" 
       alt="Comparison" 
       src="https://github.com/user-attachments/assets/297c5e9f-9fce-4557-b2ce-2d6018e93bda" />
</p>

### Rankings
Full ranking of the 5 countries by indicator, showing which nations improved or worsened the most relative to their own pre-WC baseline. Gold/silver/bronze/red conditional formatting highlights position.

<p align="center">
  <strong>Ranking</strong><br>
  <img width="700" 
       alt="Ranking" 
       src="https://github.com/user-attachments/assets/687eb599-2eb0-49a6-aeb0-3dbf07e553d8" />
</p>

### Benchmarks
Gap analysis comparing Brazil's post-WC change against Germany 2006 (primary benchmark) and Qatar 2022 (secondary benchmark), with viability score and key conclusions.

<p align="center">
  <strong>Benchmarks</strong><br>
  <img width="700" 
       alt="Benchmarks" 
       src="https://github.com/user-attachments/assets/eea34043-6801-4001-89b5-1d81b2edb223" />
</p>

## Database: `world_cup_legacy` (PostgreSQL)

### Tables

| Table            | Description |
|------------------|-----------|
| `countries`      | 5 host nations with their World Cup year |
| `indicators`     | 7 World Bank series with metadata columns (<em>higher is better</em>, <em>use absolute change</em>) |
| `economic_data`  | 775 rows of economic data with `year_relative` and two generated period columns |

### 7 Analytical Views (`v_` prefix)

| View                        | Purpose |
|-----------------------------|---------|
| `v_period_evolution`        | Average values by period (pre/during/post) per country and indicator |
| `v_rankings`                | Ranking of 5 countries per indicator based on relative change |
| `v_brazil_trends`           | Year-by-year wide-format data for Brazil (2002-2024) |
| `v_all_countries_trends`    | Year-by-year wide-format data for all 5 countries |
| `v_correlations_all`        | Pearson correlation: capital formation (pre) vs unemployment (post) — 5 countries |
| `v_correlations_no_qatar`   | Same correlation excluding Qatar (outlier analysis) |
| `v_benchmarks`              | Gap analysis: Brazil vs Germany and Qatar benchmarks |

### Methodology
#### Time Window
- **Technical window:** t-4 to t+10 (relative to each country's World Cup year, where t=0)
- **Compartive window:** t-4 to t+8 (common coverage across all 5 countries)
- **Brazil "Current" period:** t+6 to t+10 (exclusive to Brazil - Russia and Qatar lack post-WC data beyond t+6 and t+2 respectively due to recency)


### Period Classification

| Period                | `year_relative` range |
|-----------------------|-----------------------|
| Pre-World Cup         | t-4 to t-1            |
| World Cup Year        | t=0                   |
| Post-World Cup        | t+1 to t+8            |
| Current (Brazil only) | t+6 to t+10           |

Period colums are implemented as `GENERATED ALWAYS AS STORED` columns in PostgresSQL, ensuring automatic synchronization wiht `year_relative` for anyone who clones the repo.

### Ranking Metric by Indicator Type

For indicators already expressed as rates/percentages (GDP growth, Inflatio, Unemployment),the ranking uses **absolute change in percentage points** rather than relative percentage chage — because when the baseline value is close to zero, relative change becomes mathematically misleaging (e.g,. going from 0.2% to 2% growth appears as 955% change). For absolute quantities (GDP in USD, tourism arrivals, GPD per capita), percentage change is used to allow fair comparison across of different sizes.

`pct_change` is set to NULL when `|avg_pre| < 0.5` to avoid displaying distorted values.

### Benchmark Selection
Germany 2006 was chosen as the **primary benchmark** for three reasons:

1. Largest, most comparable economy structure to Brazil among the 5 host nations
2. Ranked #1 in 3 out of 7 indicators post-WC - Strongest overall performer2
3. Complete data coverage across the full t-4 to t+8 window

Qatar 2022 is presented as a **secondary reference** only - its structural economic differences (hydrocarbon-depent, heavy reliance on foreign labor) make it an unrealistic target for Brazil.

### Correlation Analysis
Pearson correlation between Gross Capital Formation (pre-WC average) and Unemployment (post-WC average):
- **With all 5 countries:** r = 0.60
- **Excluding Qatar(Outliers):** r = 0.55

Both scenarios show moderate negative correlation -- Higher pre-WC investments is associated with lower post-WC unemployment. Results are reported for both scenarios for methodological transparency; Qatar's structural outliers status (near-zero unemployment due to foreign labor) would otherwise distor the analysis.

### Data Quality Notes
- **775 rows** of economic data (5 countries x 7 indicators x variable year range)
- **26 legitimate NULLs** - missing World Bank data for specific country/year/indicator combinations (mainly international tourism for Qatar 2002-2008.) These are documented data gaps, not pipeline errors.
- **Year-value misaligment bug:** The original World Bank CSV had columns `2009, 2011, 2010` (out of order). Power Query's handling of this caused a systematic 13 position offset between year labels and their actual values. Detected by comparing Brazil's GDP per capita (showed $1.92 in 2002 when the real value is $2.855). Corrected via `0.5_fix_values_sql` - a Python-generated scritp with precise UPDATE statements sourced directly from the original World Bank CSV. No values were altered; only the year values asignment was corrected.


# Brazil World Cup Economic Impact Analysis

Comprehensive analysis of Brazil's economic performance before and after hosting the **2014 FIFA World Cup**, compared to other host nations.

## Repository Structure

## Repository Structure

```bash
brazil-world-cup-economic-analysis/
├── sql/
│   ├── 01_schema.sql                  # Database schema and table creation
│   ├── 02_insert_reference.sql        # Reference data (countries, indicators)
│   ├── 03_import_data.sql             # Data import from CSV
│   ├── 04_add_period_columns.sql      # GENERATED period classification columns
│   ├── 05_fix_values.sql              # Year-value misalignment correction
│   ├── 06_period_evolution.sql        # Block A: averages by period
│   ├── 07_rankings.sql                # Block B: country rankings
│   ├── 08_brazil_trends.sql           # Block C: Brazil year-by-year trends
│   ├── 09_all_countries_trends.sql    # Block C: all countries trends
│   ├── 10_correlations.sql            # Block D: correlation analysis
│   ├── 11_benchmarks.sql              # Block E: gap vs benchmark countries
│   └── 12_create_views.sql            # All 7 analytical views
├── data/
│   └── world_indicators_clean.csv     # Cleaned dataset (775 rows)
├── power_bi/
│   └── brazil_world_cup_analysis.pbix # Power BI dashboard (data embedded)
├── dashboard_images/
│   ├── Home.png
│   ├── Overview.png
│   ├── Brazil_Trends.png
│   ├── Country_Comparison.png
│   ├── Rankings.png
│   └── Benchmarks.png
└── README.md
```

##  Data Sources

| Source | Usage |
|---|---|
| [World Bank Open Data — World Development Indicators](https://data.worldbank.org/) | All 7 economic indicators for 5 countries (2002–2024) |
| [EOS Intelligence](https://www.eos-intelligence.com/) | Reference: sector investment analysis Brazil 2014 |
| [Berkeley Economic Review](https://econreview.berkeley.edu/) | Reference: Germany vs Brazil comparative analysis |
| [Borgen Magazine](https://www.borgenmagazine.com/) | Reference: poverty and employment impact post-WC |

### World Bank Indicator Codes

| Indicator | Code |
|---|---|
| GDP (current US$) | `NY.GDP.MKTP.CD` |
| GDP growth (annual %) | `NY.GDP.MKTP.KD.ZG` |
| GDP per capita (current US$) | `NY.GDP.PCAP.CD` |
| Unemployment, total (% of total labor force) | `SL.UEM.TOTL.ZS` |
| Inflation, consumer prices (annual %) | `FP.CPI.TOTL.ZG` |
| International tourism, number of arrivals | `ST.INT.ARVL` |
| Gross capital formation (% of GDP) | `NE.GDI.TOTL.ZS` |


## How to Use
### View the Dashboard (no setup required)
1.  Download `power_bi/WC_BRAZIL.pbix`
2.  Open with Power Bi Desktop (Free)
3.  All data si embedded - no databse connection needed

### Reproduce the Database
1. Install PostgresSQL
2. Create a database named **"world_cup_legacy"**
3. Run SQL scripts in order: **01_schema_sql** -> **12_create_views.sql**
4. import **data/world_indicators_clean.cvs** as instructed in **03_import_data.sql**
5. Run **05_import_data.sql** to apply the year-value correction

## Author
**Jaime Granados** Data Analyst | Portfolio Project 2026 GitHub

--------------------------------------------------------------------------------------------------------------------------

# Versión en Español

## Pregunta Central de la Investigación
*Los indicadores económicos de Brasil mejoraron o empeoraron tras el Mundial 2014, y qué umbrales necesita alcanzar para ser sede viable en 2030 o 2034*

## Descripción del Proyecto
Este es un proyecto de portafolio desarrollado como parte de un proceso de aprendizaje y de gusto personal en Data Analytics. Analiza el **legado económico del Mundial FIFA 2014 en Brasil**, comparándolo con cuatro países sede adicionales mediante indicadores del World Bank en una ventana temporal relativa centrada en el año del mundia de cada país.

El proyecto cubre pipeline completo de datos: desde la extracción y limpieza del CSV original, el diseño de la base de datos relacional y análisis SQL avanzado, hasta un dashboard interactivo en POWER BI con 6 páginas.


## 🛠️ Herramientas

| Herramienta | Propósito |
|---|---|
| PostgreSQL | Base de datos relacional, queries SQL avanzados, vistas |
| Power BI Desktop | Dashboard interactivo (6 páginas) |
| Power Query (M) | Transformación y limpieza de datos |
| Python (uso único) | Generación del script de corrección SQL para desfase año-valor |
| Git + GitHub | Control de versiones y publicación del portafolio |

## Páginas del Dashboard

### Home
Página del presentación del proyecto con título, pregunta central y navegación.

### Overview
Indicadores clave (KPIS) de Brasil post-Mundial - GDP per cápita, desempleo, crecimiento del GPD y turismo - con colores condicionales (rojo = empeoró, verde = mejoró vs período pre-mundial).

### Brazil Trends
Evolución año a año de los 7 indicadores económicos para Brasil (2002-2024), con slicer de indicador, línea de referencia en 2014 y tabla resumen por período.

### Country Comparison
Comparación de los 5 países sede frente a frente, mostrando promedio pre y post-Mundial con slicer interactivo de indicador.

### Rankings
Ranking completo de los 5 países por indicador, mostrando qué naciones mejoraron o empeoraron más respecto a su propia línea base pre-Mundial

### Benchmarks
Análisis de brachas comparando el cambio post-Mundial de Brasil contra Alemania 2006(benchmark principal) y Qatar 2022 (referencia secundario), con puntuación de viabilidad y conclusiones clave.


## 🗄️ Esquema de Base de Datos

**Base de datos:** `world_cup_legacy` (PostgreSQL)

| Tabla | Descripción |
|--------|-------------|
| `countries` | 5 países sede con su año de Mundial |
| `indicators` | 7 series del World Bank con columnas de metadata (`higher_is_better`, `use_absolute_change`) |
| `economic_data` | 775 filas de datos económicos con `year_relative` y dos columnas de período generadas automáticamente |


## Metodología

### Ventana Temporal
- **Ventana Técnica:**t-4 a t+10 (relativa al año del Mundial de cada país, donde t=0)
- **Ventana comparativa:**t-4 a t+8 (cobertura común entre los 5 países)
- **Período "Actual" de Brasil:** t+6 a t+10 (exclusivo para Brasil - Rusia y Qatar no tienen datos suficientres más allá de t+6 y t+2 respectivamente por la recencia de sus mundiales)

## Métricas de Ranking por Tipo de Indicador
Para indicadores expresados como tasas/porcentajes (crecimiento del GDP, inflación, desempleo), el ranking usa **diferencia absoluta en puntos porcentuales**, no cambio porcentual relativo - ya que cuando el valor base está cercano a cero, el cambio relativo se distorsiona artificialmente. Para cantidades absolutas (GDP en dólarese, turistas, GDP per cápita), se usa el **cambio porcentual** para permitir comparaciones justas entre economías de tamaños distintos.

### Selección de Benchmark
Alemania 2006 fue elegida como **benchmark principal** por:

1. Economía más grande y comparable en estructural a Brasil entre los 5 países sede
2. Clasificó #1 en 3 de 7 indicadores post-mundial — mejor desempeño general
3. Cobertura completa de datos en toda la ventana t-4 a t+8

Qatar 2022 se presenta solo como **referencia secundaria** — sus diferencias estructurales (economía basada en hidrocarburos, alta dependencia de mano de obra extranjera) lo hacen un objetivo no replicable para Brasil.

## Correción de Desfase Año-Valor

El CSV original de World Bank Tenía columnas 2009,2011,2010 fuera de orden cronológico. EL manejo de este orden en Power Query causó un desfase sistemático de 13 posiciones entre las etiquetas de año y sus valores reales. Se detectó al verificar ue el GDP per cápita de Brasil aparecía como `$1.92` en 2002, cuando el valor real es `$2.855`. La correción se aplicó en PostgresSQL mediante `05_fix_values.sql`, generado a partir del CSV original del World Bank como fuente de verdad.

## Notas de Calidad de Datos
- **775 filas** de datos económicos (5 países x 7 indicadores x rango de años variable)
- **26 NULLs legítimos** — datos no reportados por el World Bank para ciertas combinaciones país/año/indicador (principalmente turismo internacional para Qatar 2002-2008). Son vacíos documentados, no errores de pipeline.

## 🌐 Fuentes de Datos

| Fuente | Uso |
|---------|-----|
|  [World Bank Open Data — World Development Indicators](https://data.worldbank.org/) | Los 7 indicadores económicos para 5 países (2002–2024) |
| [EOS Intelligence](https://www.eos-intelligence.com/) | Referencia: análisis de inversión por sectores en Brasil 2014 |
| [Berkeley Economic Review](https://econreview.berkeley.edu/) | Referencia: comparativa Alemania vs Brasil |
| [Borgen Magazine](https://www.borgenmagazine.com/) | Referencia: impacto en pobreza y empleo post-mundial |

## Cómo Usar
### Ver el Dashboard (sin configuración adicional)
1. Descarga `power_bi/brazil_world_cup_analysis`
2. Ábrelo con Power BI Desktop (gratuito)
3. Todos los datos están embibidos - no se necesita conexión a base de datos

## Reproducir la Base de Datos
1. Instala PostgresSQL
2. Crea una base de datos llamada `world_cup_legacy`
3. Ejecuta los scripts SQL en orden: `01_schema.sql` -> `12_create_views.sql`
4. Importa `data/world_indicators_clean.csv` según las instrucciones en `03_importa_data.sql`
5. Ejecuta `05_fix_values.sql` para aplicar la correción desfase año-valor

## Autor
**Jaime Granados** Estudiante de Data Analyst | Proyecto de Portafolio 2026 GitHub









