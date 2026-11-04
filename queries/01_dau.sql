-- DAU: уникальные пользователи по дням (пустые user_id исключаем)
SELECT
    date(event_time)        AS day,
    COUNT(DISTINCT user_id) AS dau
FROM events
WHERE user_id IS NOT NULL
GROUP BY day
ORDER BY day;
