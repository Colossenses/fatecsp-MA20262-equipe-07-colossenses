-- =====================================================================
-- SPTrans (GTFS) - Esquema relacional
-- Origem: modelo do Power Pivot (SPTrans_03_Power_Pivot.xlsx)
-- Tipos portáteis (PostgreSQL / SQLite / MySQL com ajustes mínimos).
-- Ordem de criação respeita as chaves estrangeiras.
-- =====================================================================

-- ---------- DIMENSÕES ----------
CREATE TABLE dAgency (
    agency_id        VARCHAR(20)  PRIMARY KEY,
    agency_name      VARCHAR(150) NOT NULL,
    agency_url       VARCHAR(255),
    agency_timezone  VARCHAR(50),
    agency_lang      VARCHAR(10)
);

CREATE TABLE dRoutes (
    route_id          VARCHAR(30)  PRIMARY KEY,
    agency_id         VARCHAR(20)  NOT NULL,
    route_short_name  VARCHAR(30),
    route_long_name   VARCHAR(255),
    route_type        INTEGER,
    route_color       VARCHAR(10),
    route_text_color  VARCHAR(10),
    FOREIGN KEY (agency_id) REFERENCES dAgency (agency_id)
);

CREATE TABLE dCalendarServico (
    service_id  VARCHAR(30) PRIMARY KEY,
    monday      INTEGER, tuesday INTEGER, wednesday INTEGER, thursday INTEGER,
    friday      INTEGER, saturday INTEGER, sunday INTEGER,
    start_date  DATE,
    end_date    DATE
);

-- shape_id se repete em várias viagens e em vários pontos do traçado,
-- então precisa de uma tabela própria para virar chave estrangeira.
CREATE TABLE dShape (
    shape_id VARCHAR(30) PRIMARY KEY
);

CREATE TABLE dTrip (
    trip_id        VARCHAR(40) PRIMARY KEY,
    route_id       VARCHAR(30) NOT NULL,
    service_id     VARCHAR(30) NOT NULL,
    trip_headsign  VARCHAR(255),
    direction_id   INTEGER,
    shape_id       VARCHAR(30),
    FOREIGN KEY (route_id)   REFERENCES dRoutes (route_id),
    FOREIGN KEY (service_id) REFERENCES dCalendarServico (service_id),
    FOREIGN KEY (shape_id)   REFERENCES dShape (shape_id)
);

CREATE TABLE dStops (
    stop_id    VARCHAR(30) PRIMARY KEY,
    stop_name  VARCHAR(255),
    stop_desc  VARCHAR(255),
    stop_lat   DOUBLE,
    stop_lon   DOUBLE
);

CREATE TABLE dFareAttributes (
    fare_id            VARCHAR(30) PRIMARY KEY,
    price              NUMERIC(8,2),
    currency_type      VARCHAR(5),
    payment_method     INTEGER,
    transfers          INTEGER,
    transfer_duration  INTEGER
);

-- Tabela de datas (não tem relação no modelo do Power Pivot;
-- serve de dimensão de tempo para análises).
CREATE TABLE dCalendario (
    Data       DATE PRIMARY KEY,
    Ano        INTEGER,
    Mes        INTEGER,
    NomeMes    VARCHAR(20),
    AnoMes     VARCHAR(7),
    DiaSemana  INTEGER,      -- 1 = segunda ... 7 = domingo
    NomeDia    VARCHAR(20)
);

-- ---------- FATOS ----------
CREATE TABLE Shapes (
    shape_id             VARCHAR(30) NOT NULL,
    shape_pt_sequence    INTEGER     NOT NULL,
    shape_pt_lat         DOUBLE,
    shape_pt_lon         DOUBLE,
    shape_dist_traveled  DOUBLE,
    PRIMARY KEY (shape_id, shape_pt_sequence),
    FOREIGN KEY (shape_id) REFERENCES dShape (shape_id)
);

CREATE TABLE fStopTimes (
    trip_id         VARCHAR(40) NOT NULL,
    stop_sequence   INTEGER     NOT NULL,
    stop_id         VARCHAR(30) NOT NULL,
    arrival_time    TIME,
    departure_time  TIME,
    PRIMARY KEY (trip_id, stop_sequence),
    FOREIGN KEY (trip_id) REFERENCES dTrip (trip_id),
    FOREIGN KEY (stop_id) REFERENCES dStops (stop_id)
);

CREATE TABLE fFrequencies (
    trip_id       VARCHAR(40) NOT NULL,
    start_time    TIME        NOT NULL,
    end_time      TIME,
    headway_secs  INTEGER,
    PRIMARY KEY (trip_id, start_time),
    FOREIGN KEY (trip_id) REFERENCES dTrip (trip_id)
);

CREATE TABLE fFareRules (
    fare_id         VARCHAR(30) NOT NULL,
    route_id        VARCHAR(30) NOT NULL,
    origin_id       VARCHAR(30),
    destination_id  VARCHAR(30),
    contains_id     VARCHAR(30),
    FOREIGN KEY (fare_id)  REFERENCES dFareAttributes (fare_id),
    FOREIGN KEY (route_id) REFERENCES dRoutes (route_id)
);

-- As 3 tabelas de passagens por dia da semana têm a mesma estrutura
-- (1 linha por viagem, relação 1:1 com dTrip).
CREATE TABLE fBusSubwayCPTM (
    trip_id VARCHAR(40) PRIMARY KEY,
    Seg INTEGER, Ter INTEGER, Qua INTEGER, Qui INTEGER, Sex INTEGER, Sab INTEGER, Dom INTEGER,
    FOREIGN KEY (trip_id) REFERENCES dTrip (trip_id)
);
CREATE TABLE fIndividualPass (
    trip_id VARCHAR(40) PRIMARY KEY,
    Seg INTEGER, Ter INTEGER, Qua INTEGER, Qui INTEGER, Sex INTEGER, Sab INTEGER, Dom INTEGER,
    FOREIGN KEY (trip_id) REFERENCES dTrip (trip_id)
);
CREATE TABLE fBusSubwayCPTMCompleto (
    trip_id VARCHAR(40) PRIMARY KEY,
    Seg INTEGER, Ter INTEGER, Qua INTEGER, Qui INTEGER, Sex INTEGER, Sab INTEGER, Dom INTEGER,
    FOREIGN KEY (trip_id) REFERENCES dTrip (trip_id)
);

-- ---------- ÍNDICES nas chaves estrangeiras mais usadas em JOIN ----------
CREATE INDEX ix_routes_agency   ON dRoutes (agency_id);
CREATE INDEX ix_trip_route      ON dTrip (route_id);
CREATE INDEX ix_trip_service    ON dTrip (service_id);
CREATE INDEX ix_trip_shape      ON dTrip (shape_id);
CREATE INDEX ix_stoptimes_stop  ON fStopTimes (stop_id);
CREATE INDEX ix_farerules_fare  ON fFareRules (fare_id);
CREATE INDEX ix_farerules_route ON fFareRules (route_id);
