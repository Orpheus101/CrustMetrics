-- Dashboard 3: staff hours and cost per shift
USE crust_metrics;

SELECT
    ro.`date`,
    s.first_name,
    s.last_name,
    s.hourly_rate,
    sh.start_time,
    sh.end_time,
    TIME_TO_SEC(TIMEDIFF(sh.end_time, sh.start_time)) / 3600                 AS hours_in_shift,
    TIME_TO_SEC(TIMEDIFF(sh.end_time, sh.start_time)) / 3600 * s.hourly_rate AS staff_cost
FROM rotations ro
LEFT JOIN staff  s  ON ro.staff_id = s.staff_id
LEFT JOIN shifts sh ON ro.shift_id = sh.shift_id;
