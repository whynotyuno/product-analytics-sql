-- Retention D1 / D7 по дням регистрации (когорты)
WITH activity AS (
    SELECT DISTINCT user_id, date(event_time) AS d
    FROM events
    WHERE user_id IS NOT NULL
),
cohort AS (
    SELECT user_id, date(registered_at) AS reg_date FROM users
)
SELECT
    c.reg_date,
    COUNT(DISTINCT c.user_id) AS cohort_size,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN julianday(a.d) - julianday(c.reg_date) = 1
                                      THEN c.user_id END) / COUNT(DISTINCT c.user_id), 1) AS d1_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN julianday(a.d) - julianday(c.reg_date) = 7
                                      THEN c.user_id END) / COUNT(DISTINCT c.user_id), 1) AS d7_pct
FROM cohort c
LEFT JOIN activity a ON a.user_id = c.user_id
WHERE c.reg_date <= date('2026-09-23')   -- когорты, у которых D7 уже наступил
GROUP BY c.reg_date
ORDER BY c.reg_date;
