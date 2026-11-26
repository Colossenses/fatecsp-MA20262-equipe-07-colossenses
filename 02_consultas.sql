USE sptrans;

CREATE VIEW vw_viagens AS
SELECT t.trip_id, t.trip_headsign, t.direction_id, t.shape_id,
       r.route_id, r.route_short_name, r.route_long_name, r.route_type,
       a.agency_id, a.agency_name,
       s.service_id, s.start_date, s.end_date,
       s.monday, s.tuesday, s.wednesday, s.thursday, s.friday, s.saturday, s.sunday
FROM dTrip t
JOIN dRoutes r          ON r.route_id   = t.route_id
JOIN dAgency a          ON a.agency_id  = r.agency_id
JOIN dCalendarServico s ON s.service_id = t.service_id;

CREATE VIEW vw_tarifa_rota AS
SELECT r.route_id, r.route_short_name, f.fare_id, f.price, f.currency_type
FROM fFareRules fr
JOIN dRoutes r          ON r.route_id = fr.route_id
JOIN dFareAttributes f  ON f.fare_id  = fr.fare_id;

CREATE VIEW vw_paradas_viagem AS
SELECT st.trip_id, st.stop_sequence, st.arrival_time, st.departure_time,
       p.stop_id, p.stop_name, p.stop_lat, p.stop_lon
FROM fStopTimes st
JOIN dStops p ON p.stop_id = st.stop_id;

CREATE VIEW vw_kpis AS
SELECT
    (SELECT COUNT(DISTINCT route_id) FROM dTrip)                    AS qtde_linhas,
    (SELECT COUNT(DISTINCT trip_id)  FROM dTrip)                    AS qtde_viagens_programadas,
    (SELECT COUNT(DISTINCT stop_id)  FROM fStopTimes)               AS qtde_pontos,
    (SELECT COUNT(*)                 FROM fStopTimes)               AS qtde_passagens_programadas,
    (SELECT AVG(headway_secs) / 60.0 FROM fFrequencies)             AS intervalo_planejado_medio_min,
    (SELECT MIN(price) FROM dFareAttributes)                        AS tarifa_minima_brl,
    (SELECT AVG(price) FROM dFareAttributes)                        AS tarifa_media_brl,
    (SELECT MAX(price) FROM dFareAttributes)                        AS tarifa_maxima_brl;

SELECT r.route_short_name, r.route_long_name,
       COUNT(t.trip_id)                          AS viagens,
       SUM(COALESCE(p.passagens, 0))             AS passagens,
       ROUND(AVG(q.headway_medio_secs)/60.0, 1)  AS intervalo_medio_min
FROM dRoutes r
JOIN dTrip t ON t.route_id = r.route_id
LEFT JOIN (SELECT trip_id, COUNT(*) AS passagens
           FROM fStopTimes GROUP BY trip_id) p ON p.trip_id = t.trip_id
LEFT JOIN (SELECT trip_id, AVG(headway_secs) AS headway_medio_secs
           FROM fFrequencies GROUP BY trip_id) q ON q.trip_id = t.trip_id
GROUP BY r.route_short_name, r.route_long_name
ORDER BY viagens DESC;

SELECT p.stop_id, p.stop_name, COUNT(*) AS passagens
FROM fStopTimes st
JOIN dStops p ON p.stop_id = st.stop_id
GROUP BY p.stop_id, p.stop_name
ORDER BY passagens DESC
LIMIT 10;

SELECT SUM(Seg) AS seg, SUM(Ter) AS ter, SUM(Qua) AS qua, SUM(Qui) AS qui,
       SUM(Sex) AS sex, SUM(Sab) AS sab, SUM(Dom) AS dom
FROM fBusSubwayCPTM;

SELECT route_short_name, ROUND(AVG(price),2) AS tarifa_media
FROM vw_tarifa_rota
GROUP BY route_short_name
ORDER BY tarifa_media DESC;
