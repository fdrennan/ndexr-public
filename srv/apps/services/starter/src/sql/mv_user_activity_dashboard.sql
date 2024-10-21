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
ORDER BY matched_ip_data."timestamp" DESC;