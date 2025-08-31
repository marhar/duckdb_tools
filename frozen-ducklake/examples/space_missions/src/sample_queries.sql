-- Find the most experienced astronauts by total space days
SELECT name, nationality, total_space_days, total_flights
FROM astronauts 
ORDER BY total_space_days DESC 
LIMIT 10;

-- Which agencies have the highest mission success rates?
SELECT agency, 
       COUNT(*) as total_missions,
       SUM(CASE WHEN success_status = 'Success' THEN 1 ELSE 0 END) as successful_missions,
       ROUND(100.0 * SUM(CASE WHEN success_status = 'Success' THEN 1 ELSE 0 END) / COUNT(*), 2) as success_rate
FROM missions 
GROUP BY agency 
ORDER BY success_rate DESC;

-- Most expensive missions by cost per day
SELECT m.name, m.agency, m.cost_millions_usd, m.duration_days,
       ROUND(m.cost_millions_usd / NULLIF(m.duration_days, 0), 2) as cost_per_day
FROM missions m
WHERE m.duration_days > 0
ORDER BY cost_per_day DESC
LIMIT 10;

-- International crew composition analysis
SELECT m.name as mission, 
       COUNT(DISTINCT a.nationality) as nationalities,
       STRING_AGG(DISTINCT a.nationality, ', ') as countries_represented
FROM missions m
JOIN mission_crew mc ON m.mission_id = mc.mission_id
JOIN astronauts a ON mc.astronaut_id = a.astronaut_id
WHERE mc.primary_crew = TRUE
GROUP BY m.mission_id, m.name
HAVING COUNT(DISTINCT a.nationality) > 1
ORDER BY nationalities DESC;

-- Spacecraft utilization over time
SELECT s.name, s.manufacturer, 
       COUNT(m.mission_id) as missions_flown,
       MIN(m.launch_date) as first_mission,
       MAX(m.launch_date) as last_mission,
       SUM(m.duration_days) as total_mission_days
FROM spacecraft s
LEFT JOIN missions m ON s.spacecraft_id = m.spacecraft_id
GROUP BY s.spacecraft_id, s.name, s.manufacturer
ORDER BY missions_flown DESC;
