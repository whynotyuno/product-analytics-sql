-- Проверки качества данных (логирование событий)

-- 1. События без user_id
SELECT 'null_user_id' AS check_name, COUNT(*) AS bad_rows
FROM events WHERE user_id IS NULL;

-- 2. Полные дубли событий
SELECT 'duplicates' AS check_name, COALESCE(SUM(cnt - 1), 0) AS bad_rows
FROM (
    SELECT COUNT(*) AS cnt
    FROM events
    GROUP BY user_id, event_name, event_time
    HAVING COUNT(*) > 1
);

-- 3. События раньше регистрации пользователя
SELECT 'event_before_registration' AS check_name, COUNT(*) AS bad_rows
FROM events e
JOIN users u ON u.user_id = e.user_id
WHERE e.event_time < u.registered_at;

-- 4. Неизвестные названия событий
SELECT 'unknown_event_name' AS check_name, COUNT(*) AS bad_rows
FROM events
WHERE event_name NOT IN ('app_open', 'search', 'view_ad', 'favorite', 'contact_seller');
