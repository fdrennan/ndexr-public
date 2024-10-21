-- Rename columns in geolite2_city_ipv4
ALTER TABLE geolite2_city_ipv4 RENAME COLUMN c1 TO start_ip;
ALTER TABLE geolite2_city_ipv4 RENAME COLUMN c2 TO end_ip;
ALTER TABLE geolite2_city_ipv4 RENAME COLUMN c3 TO country_code;
ALTER TABLE geolite2_city_ipv4 RENAME COLUMN c4 TO region;
ALTER TABLE geolite2_city_ipv4 RENAME COLUMN c5 TO subregion;
ALTER TABLE geolite2_city_ipv4 RENAME COLUMN c6 TO state_province;
ALTER TABLE geolite2_city_ipv4 RENAME COLUMN c7 TO city;
ALTER TABLE geolite2_city_ipv4 RENAME COLUMN c8 TO latitude;
ALTER TABLE geolite2_city_ipv4 RENAME COLUMN c9 TO longitude;
ALTER TABLE geolite2_city_ipv4 RENAME COLUMN c10 TO time_zone;

-- Alter column types in geolite2_city_ipv4
ALTER TABLE geolite2_city_ipv4 ALTER COLUMN start_ip TYPE varchar(15) USING start_ip::varchar(15);
ALTER TABLE geolite2_city_ipv4 ALTER COLUMN end_ip TYPE varchar(15) USING end_ip::varchar(15);
ALTER TABLE geolite2_city_ipv4 ALTER COLUMN country_code TYPE char(2) USING country_code::char(2);
ALTER TABLE geolite2_city_ipv4 ALTER COLUMN region TYPE varchar(100) USING region::varchar(100);
ALTER TABLE geolite2_city_ipv4 ALTER COLUMN subregion TYPE varchar(100) USING subregion::varchar(100);
ALTER TABLE geolite2_city_ipv4 ALTER COLUMN state_province TYPE varchar(100) USING state_province::varchar(100);
ALTER TABLE geolite2_city_ipv4 ALTER COLUMN city TYPE varchar(100) USING city::varchar(100);
ALTER TABLE geolite2_city_ipv4 ALTER COLUMN latitude TYPE decimal(8, 5) USING latitude::decimal(8, 5);
ALTER TABLE geolite2_city_ipv4 ALTER COLUMN longitude TYPE decimal(8, 5) USING longitude::decimal(8, 5);
ALTER TABLE geolite2_city_ipv4 ALTER COLUMN time_zone TYPE varchar(50) USING time_zone::varchar(50);

-- Rename columns in ip2location_lite
ALTER TABLE ip2location_lite RENAME COLUMN c1 TO start_ip;
ALTER TABLE ip2location_lite RENAME COLUMN c2 TO end_ip;
ALTER TABLE ip2location_lite RENAME COLUMN c3 TO country_code;
ALTER TABLE ip2location_lite RENAME COLUMN c4 TO country_name;
ALTER TABLE ip2location_lite RENAME COLUMN c5 TO region;
ALTER TABLE ip2location_lite RENAME COLUMN c6 TO city;
ALTER TABLE ip2location_lite RENAME COLUMN c7 TO latitude;
ALTER TABLE ip2location_lite RENAME COLUMN c8 TO longitude;
ALTER TABLE ip2location_lite RENAME COLUMN c9 TO postal_code;
ALTER TABLE ip2location_lite RENAME COLUMN c10 TO time_zone;

-- Alter column types in ip2location_lite
ALTER TABLE ip2location_lite ALTER COLUMN start_ip TYPE BIGINT USING start_ip::BIGINT;
ALTER TABLE ip2location_lite ALTER COLUMN end_ip TYPE BIGINT USING end_ip::BIGINT;
ALTER TABLE ip2location_lite ALTER COLUMN country_code TYPE char(2) USING country_code::char(2);
ALTER TABLE ip2location_lite ALTER COLUMN country_name TYPE varchar(100) USING country_name::varchar(100);
ALTER TABLE ip2location_lite ALTER COLUMN region TYPE varchar(100) USING region::varchar(100);
ALTER TABLE ip2location_lite ALTER COLUMN city TYPE varchar(100) USING city::varchar(100);
ALTER TABLE ip2location_lite ALTER COLUMN latitude TYPE decimal(9, 6) USING latitude::decimal(9, 6);
ALTER TABLE ip2location_lite ALTER COLUMN longitude TYPE decimal(9, 6) USING longitude::decimal(9, 6);
ALTER TABLE ip2location_lite ALTER COLUMN postal_code TYPE varchar(20) USING postal_code::varchar(20);
ALTER TABLE ip2location_lite ALTER COLUMN time_zone TYPE varchar(10) USING time_zone::varchar(10);


-- Alter table http_headers to rename columns for consistency
ALTER TABLE http_headers RENAME COLUMN http_x_real_ip TO ip_address;
ALTER TABLE http_headers RENAME COLUMN site TO site_name;

-- Alter column types in http_headers (assuming VARCHAR(15) for IP address)
ALTER TABLE http_headers ALTER COLUMN ip_address TYPE varchar(15) USING ip_address::varchar(15);
ALTER TABLE http_headers ALTER COLUMN site_name TYPE varchar(100) USING site_name::varchar(100);

-- Confirm ownership
ALTER TABLE http_headers OWNER TO fdrennan;


-- Create the enriched http_headers table with detailed geographic information
CREATE TABLE http_headers_enriched AS
SELECT
    hh.timestamp AS timestamp_with_tz,
    hh.ip_address,
    hh.site_name,
    ip.country_code,
    ip.region,
    ip.subregion,  -- Include subregion if available
    ip.state_province,  -- Include state or province if available
    ip.city,
    ip.latitude,
    ip.longitude,
    ip.time_zone
FROM
    http_headers hh
LEFT JOIN
    geolite2_city_ipv4 ip
ON
    (inet(ip.start_ip) <= inet(hh.ip_address)) AND
    (inet(ip.end_ip) >= inet(hh.ip_address));

-- Update ownership of the new table
ALTER TABLE http_headers_enriched OWNER TO fdrennan;


CREATE INDEX idx_geolite2_start_ip ON geolite2_city_ipv4 (start_ip);
CREATE INDEX idx_geolite2_end_ip ON geolite2_city_ipv4 (end_ip);

ALTER TABLE geolite2_city_ipv4 ALTER COLUMN start_ip TYPE inet USING start_ip::inet;
ALTER TABLE geolite2_city_ipv4 ALTER COLUMN end_ip TYPE inet USING end_ip::inet;

CREATE INDEX idx_http_headers_ip_address ON http_headers (ip_address);




CREATE MATERIALIZED VIEW mv_user_activity_dashboard AS
SELECT
    hh."timestamp",
    hh.ip_address,
    hh.site_name,
    g2c.country_code,
    g2c.region,
    g2c.subregion,
    g2c.state_province,
    g2c.city,
    g2c.latitude,
    g2c.longitude,
    g2c.time_zone
FROM
    http_headers hh
LEFT JOIN
    geolite2_city_ipv4 g2c
ON
    hh.ip_address >= g2c.start_ip AND hh.ip_address <= g2c.end_ip;

ALTER MATERIALIZED VIEW mv_user_activity_dashboard OWNER TO fdrennan;

CREATE INDEX idx_user_activity_dashboard_ip_address ON mv_user_activity_dashboard (ip_address);


-- Drop the existing table if you need to start fresh
-- DROP TABLE IF EXISTS http_headers;
-- Add new columns to the existing http_headers table
ALTER TABLE http_headers
ADD COLUMN host VARCHAR(255),
ADD COLUMN user_agent TEXT,
ADD COLUMN accept TEXT,
ADD COLUMN accept_encoding TEXT,
ADD COLUMN accept_language TEXT,
ADD COLUMN connection VARCHAR(50),
ADD COLUMN cookie TEXT,
ADD COLUMN x_forwarded_for INET,
ADD COLUMN x_forwarded_proto VARCHAR(10);

-- Create an index on the new x_forwarded_for column
CREATE INDEX idx_http_headers_x_forwarded_for
ON http_headers (x_forwarded_for);







drop materialized view mv_user_activity_dashboard;
CREATE MATERIALIZED view mv_user_activity_dashboard AS
SELECT hh."timestamp",
       hh.ip_address,
       hh.site_name,
       hh.host,
       hh.user_agent,
       hh.accept,
       hh.accept_encoding,
       hh.accept_language,
       hh.connection,
       hh.cookie,
       hh.x_forwarded_for,
       hh.x_forwarded_proto,
       g2c.country_code,
       g2c.region,
       g2c.subregion,
       g2c.state_province,
       g2c.city,
       g2c.latitude,
       g2c.longitude,
       g2c.time_zone
FROM http_headers hh
LEFT JOIN geolite2_city_ipv4 g2c ON hh.ip_address >= g2c.start_ip AND hh.ip_address <= g2c.end_ip
order by hh.timestamp desc


ALTER TABLE geolite2_city_ipv6
    RENAME COLUMN c1 TO ipv6_start;

ALTER TABLE geolite2_city_ipv6
    RENAME COLUMN c2 TO ipv6_end;

ALTER TABLE geolite2_city_ipv6
    RENAME COLUMN c3 TO country;

ALTER TABLE geolite2_city_ipv6
    RENAME COLUMN c4 TO region_name;

ALTER TABLE geolite2_city_ipv6
    RENAME COLUMN c5 TO subregion_name;

ALTER TABLE geolite2_city_ipv6
    RENAME COLUMN c6 TO state;

ALTER TABLE geolite2_city_ipv6
    RENAME COLUMN c7 TO city_name;

ALTER TABLE geolite2_city_ipv6
    RENAME COLUMN c8 TO lat;

ALTER TABLE geolite2_city_ipv6
    RENAME COLUMN c9 TO lon;

ALTER TABLE geolite2_city_ipv6
    RENAME COLUMN c10 TO tz;




ALTER TABLE geolite2_city_ipv6
    ALTER COLUMN ipv6_start TYPE inet USING ipv6_start::inet;

ALTER TABLE geolite2_city_ipv6
    ALTER COLUMN ipv6_end TYPE inet USING ipv6_end::inet;

ALTER TABLE geolite2_city_ipv6
    ALTER COLUMN country TYPE varchar(2);

ALTER TABLE geolite2_city_ipv6
    ALTER COLUMN region_name TYPE varchar(100);

ALTER TABLE geolite2_city_ipv6
    ALTER COLUMN subregion_name TYPE varchar(100);

ALTER TABLE geolite2_city_ipv6
    ALTER COLUMN state TYPE varchar(100);

ALTER TABLE geolite2_city_ipv6
    ALTER COLUMN state TYPE varchar;

ALTER TABLE geolite2_city_ipv6
    ALTER COLUMN lat TYPE numeric(8, 5) USING lat::numeric;

ALTER TABLE geolite2_city_ipv6
    ALTER COLUMN lon TYPE numeric(8, 5) USING lon::numeric;

ALTER TABLE geolite2_city_ipv6
    ALTER COLUMN tz TYPE varchar(50);




DROP MATERIALIZED VIEW IF EXISTS mv_user_activity_dashboard;

CREATE MATERIALIZED VIEW mv_user_activity_dashboard AS
SELECT hh."timestamp",
       hh.ip_address,
       hh.site_name,
       hh.host,
       hh.user_agent,
       hh.accept,
       hh.accept_encoding,
       hh.accept_language,
       hh.connection,
       hh.cookie,
       hh.x_forwarded_for,
       hh.x_forwarded_proto,
       COALESCE(g2c4.country_code, g2c6.country::bpchar)      AS country_code,
       COALESCE(g2c4.region, g2c6.region_name)                AS region,
       COALESCE(g2c4.subregion, g2c6.subregion_name)          AS subregion,
       COALESCE(g2c4.state_province, g2c6.state)              AS state_province,
       COALESCE(g2c4.city, g2c6.city_name::character varying) AS city,
       COALESCE(g2c4.latitude::numeric, g2c6.lat::numeric)    AS latitude,
       COALESCE(g2c4.longitude::numeric, g2c6.lon::numeric)   AS longitude,
       COALESCE(g2c4.time_zone, g2c6.tz::character varying)   AS time_zone
FROM http_headers hh
         LEFT JOIN geolite2_city_ipv4 g2c4 ON hh.ip_address >= g2c4.start_ip AND hh.ip_address <= g2c4.end_ip
         LEFT JOIN geolite2_city_ipv6 g2c6 ON hh.ip_address >= g2c6.ipv6_start AND hh.ip_address <= g2c6.ipv6_end
ORDER BY hh."timestamp" DESC;

ALTER MATERIALIZED VIEW mv_user_activity_dashboard OWNER TO fdrennan;



-- Step 1: Create the combined table with the name ip_location
CREATE TABLE ip_location (
    ip_start inet,
    ip_end inet,
    country_code text,
    region text,
    subregion text,
    city text,
    latitude numeric,
    longitude numeric,
    timezone text
);

-- Step 2: Insert combined data from both IPv4 and IPv6 tables into the new ip_location table
INSERT INTO ip_location (ip_start, ip_end, country_code, region, subregion, city, latitude, longitude, timezone)
SELECT
    c1::inet AS ip_start,
    c2::inet AS ip_end,
    c3::text AS country_code,
    c4::text AS region,
    c5::text AS subregion,
    c6::text AS city,
    c8::numeric AS latitude,
    c9::numeric AS longitude,
    c10::text AS timezone
FROM geolite2_city_ipv6

UNION

SELECT
    c1::inet AS ip_start,
    c2::inet AS ip_end,
    c3::text AS country_code,
    c4::text AS region,
    c5::text AS subregion,
    c6::text AS city,
    c8::numeric AS latitude,
    c9::numeric AS longitude,
    c10::text AS timezone
FROM geolite2_city_ipv4;

-- Step 3: Create indexes on the new ip_location table for IP range queries
-- Create a GiST index for range queries on IPs using the inet_ops operator class
CREATE INDEX idx_ip_location_ip_range ON ip_location USING gist (ip_start inet_ops, ip_end inet_ops);

-- Step 4: Analyze the new table to update query planner statistics
ANALYZE ip_location;

create materialized view mv_user_activity_dashboard as
with matched_ip_datamv_user_activity_dashboard as (
    select
        hh.timestamp,
        hh.ip_address,
        hh.site_name,
        hh.host,
        hh.user_agent,
        hh.accept,
        hh.accept_encoding,
        hh.accept_language,
        hh.connection,
        hh.cookie,
        hh.x_forwarded_for,
        hh.x_forwarded_proto,
        il.country_code,
        il.region,
        il.subregion,
        il.city,
        il.latitude,
        il.longitude,
        il.timezone
    from
        http_headers hh
    left join
        ip_location il
    on
        hh.ip_address between il.ip_start and il.ip_end
        or hh.x_forwarded_for between il.ip_start and il.ip_end
)

select *
from matched_ip_datamv_user_activity_dashboard





create materialized view mv_user_activity_dashboard as
WITH matched_ip_data AS (SELECT hh."timestamp",
                                hh.ip_address,
                                hh.site_name,
                                hh.host,
                                hh.user_agent,
                                hh.accept,
                                hh.accept_encoding,
                                hh.accept_language,
                                hh.connection,
                                hh.cookie,
                                hh.x_forwarded_for,
                                hh.x_forwarded_proto,
                                il.country_code,
                                il.region,
                                il.subregion,
                                il.city,
                                il.latitude,
                                il.longitude,
                                il.timezone
                         FROM http_headers hh
                                  LEFT JOIN ip_location il
                                            ON hh.ip_address >= il.ip_start AND hh.ip_address <= il.ip_end OR
                                               hh.x_forwarded_for >= il.ip_start AND hh.x_forwarded_for <= il.ip_end)
SELECT matched_ip_data."timestamp",
       matched_ip_data.ip_address,
       matched_ip_data.site_name,
       matched_ip_data.host,
       matched_ip_data.user_agent,
       matched_ip_data.accept,
       matched_ip_data.accept_encoding,
       matched_ip_data.accept_language,
       matched_ip_data.connection,
       matched_ip_data.cookie,
       matched_ip_data.x_forwarded_for,
       matched_ip_data.x_forwarded_proto,
       matched_ip_data.country_code,
       matched_ip_data.region,
       matched_ip_data.subregion,
       matched_ip_data.city,
       matched_ip_data.latitude,
       matched_ip_data.longitude,
       matched_ip_data.timezone
FROM matched_ip_data
order by matched_ip_data.timestamp desc;
alter materialized view mv_user_activity_dashboard owner to fdrennan;