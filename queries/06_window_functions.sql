-- Оконные функции: сколько часов проходит от регистрации до первого контакта с продавцом
WITH first_contact AS (
    SELECT
        user_id,
        event_time,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time) AS rn
    FROM events
    WHERE event_name = 'contact_seller' AND user_id IS NOT NULL
)
SELECT
    u.platform,
    COUNT(*) AS users_with_contact,
    ROUND(AVG((julianday(f.event_time) - julianday(u.registered_at)) * 24), 1) AS avg_hours_to_first_contact
FROM first_contact f
JOIN users u ON u.user_id = f.user_id
WHERE f.rn = 1
  AND f.event_time >= u.registered_at
GROUP BY u.platform;
