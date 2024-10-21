-- Create a view to describe IP, specific location, and time rounded to 15 minutes as a count
CREATE VIEW ip_location_time_summary AS
SELECT
    ip_address,
    city,
    state_province,
    country_code,  -- Replaced country_name with country_code
    date_trunc('minute', timestamp_with_tz) + interval '15 minutes' * floor(date_part('minute', timestamp_with_tz)::int / 15) AS rounded_time,
    COUNT(*) AS request_count
FROM
    http_headers_enriched
GROUP BY
    ip_address,
    city,
    state_province,
    country_code,  -- Replaced country_name with country_code
    rounded_time
ORDER BY
    rounded_time DESC,
    request_count DESC;
