CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;
-- 1. country table
CREATE TABLE country (
CID VARCHAR(10) PRIMARY KEY,
Country VARCHAR(100) UNIQUE
);
SELECT * FROM COUNTRY;
-- 2. emission_3 table
CREATE TABLE emission_3 (
country VARCHAR(100),
energy_type VARCHAR(50),
year INT,
emission INT,
per_capita_emission DOUBLE,
FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM EMISSION_3;
-- 3. population table
CREATE TABLE population (
countries VARCHAR(100),
year INT,
Value DOUBLE,
FOREIGN KEY (countries) REFERENCES country(Country)
);
SELECT * FROM POPULATION;
-- 4. production table
CREATE TABLE production (
country VARCHAR(100),
energy VARCHAR(50),
year INT,
production INT,
FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM PRODUCTION;
-- 5. gdp_3 table
CREATE TABLE gdp_3 (
Country VARCHAR(100),
year INT,
Value DOUBLE,
FOREIGN KEY (Country) REFERENCES country(Country)
);
SELECT * FROM GDP_3;
-- 6. consumption table
CREATE TABLE consumption (
country VARCHAR(100),
energy VARCHAR(50),
year INT,
consumption INT,
FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM CONSUMPTION;

-- General & Comparative Analysis
-- 1. What isthe total emission per country for the most recent year available?
SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country
ORDER BY total_emission DESC;

-- 2. What are the top 5 countries by GDP in the most recent year?
SELECT Country, Value AS GDP
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY GDP DESC
LIMIT 5;

-- 3. Compare energy production and consumption by country and year.
SELECT p.country, p.year,
       SUM(p.production) AS total_production,
       SUM(c.consumption) AS total_consumption
FROM production p
JOIN consumption c
ON p.country = c.country AND p.year = c.year
GROUP BY p.country, p.year;

-- 4. Which energy types contribute most to emissions across all countries?
SELECT energy_type, SUM(emission) AS total_emission
FROM emission_3
GROUP BY energy_type
ORDER BY total_emission DESC;

--  Trend Analysis Over Time
-- 5.How have global emissions changed year over year?
SELECT year, SUM(emission) AS global_emission
FROM emission_3
GROUP BY year
ORDER BY year;

-- 6.What is the trend in GDP for each country over the given years?
SELECT country, year, value AS gdp
FROM gdp_3
ORDER BY country, year;

-- 7.How has population growth affected total emissions in each country?
SELECT e.country, e.year, e.emission, p.value AS population
FROM emission_3 e
JOIN population p
ON e.country = p.countries AND e.year = p.year;

-- 8.Has energy consumption increased or decreased over the years for major economies?
SELECT country, year, SUM(consumption) AS total_consumption
FROM consumption
WHERE country IN ('USA', 'China', 'India', 'Japan', 'Germany')
GROUP BY country, year
ORDER BY country, year;

-- 9.What is the average yearly change in emissions per capita for each country?
SELECT country,
       AVG(yearly_change) AS avg_yearly_change
FROM (
    SELECT e.country,
           e.year,
           (e.emission / p.value)
           - LAG(e.emission / p.value)
             OVER (PARTITION BY e.country ORDER BY e.year)
           AS yearly_change
    FROM emission_3 e
    JOIN population p
    ON e.country = p.countries AND e.year = p.year
) t
WHERE yearly_change IS NOT NULL
GROUP BY country;

-- Ratio & Per Capita Analysis
-- 10.What is the emission-to-GDP ratio for each country by year?
SELECT e.country,
       e.year,
       SUM(e.emission)/g.Value AS emission_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g
     ON e.country = g.Country
     AND e.year = g.year
GROUP BY e.country, e.year, g.Value
ORDER BY e.country, e.year;

-- 11.What is the energy consumption per capita for each country over the last decade?
SELECT c.country,
       c.year,
       SUM(c.consumption) / p.value AS consumption_per_capita
FROM consumption c
JOIN population p
ON c.country = p.countries
AND c.year = p.year
WHERE c.year >= (SELECT MAX(year) - 9 FROM consumption)
GROUP BY c.country, c.year, p.value
ORDER BY c.country, c.year;

-- 12.How does energy production per capita vary across countries?
SELECT pr.country,
       pr.year,
       SUM(pr.production) / p.value AS production_per_capita
FROM production pr
JOIN population p
ON pr.country = p.countries
AND pr.year = p.year
GROUP BY pr.country, pr.year, p.value
ORDER BY pr.country, pr.year;

-- 13.Which countries have the highest energy consumption relative to GDP?
SELECT c.country,
       SUM(c.consumption) / g.value AS consumption_gdp_ratio
FROM consumption c
JOIN gdp_3 g
ON c.country = g.country
AND c.year = g.year
GROUP BY c.country, g.value
ORDER BY consumption_gdp_ratio DESC;

-- 14.What is the correlation between GDP growth and energy production growth?
SELECT p.country,
       p.year,
       p.production,
       g.value AS gdp
FROM production p
JOIN gdp_3 g
ON p.country = g.country
AND p.year = g.year
ORDER BY p.country, p.year;

-- Global Comparisons
-- 15.What are the top 10 countries by population and how do their emissions compare?
SELECT p.countries,
       p.value AS population,
       e.emission
FROM population p
JOIN emission_3 e
ON p.countries = e.country
AND p.year = e.year
ORDER BY p.value DESC
LIMIT 10;

-- 16.Which countries have improved (reduced) their per capita emissions the most over the last decade?
SELECT country,
       MIN(per_capita_emission) AS lowest_emission
FROM emission_3
WHERE year >= (SELECT MAX(year) - 9 FROM emission_3)
GROUP BY country
ORDER BY lowest_emission;

-- 17.What is the global share (%) of emissions by country?
SELECT country,
       SUM(emission) * 100 /
       (SELECT SUM(emission) FROM emission_3) AS emission_share
FROM emission_3
GROUP BY country;

-- 18.What is the global average GDP, emission, and population by year?
SELECT e.year,
       AVG(g.value) AS avg_gdp,
       AVG(e.emission) AS avg_emission,
       AVG(p.value) AS avg_population
FROM emission_3 e
JOIN gdp_3 g
ON e.country = g.country AND e.year = g.year
JOIN population p
ON e.country = p.countries AND e.year = p.year
GROUP BY e.year
ORDER BY e.year;





