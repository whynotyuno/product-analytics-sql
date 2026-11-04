-- Витрина: одна строка = пользователь + день, с флагами действий.
-- Очищаем данные (без NULL, без дублей, без неизвестных событий).
DROP VIEW IF EXISTS mart_user_day;

CREATE VIEW mart_user_day AS
WITH clean AS (
    SELECT DISTINCT user_id, event_name, event_time
    FROM events
    WHERE user_id IS NOT NULL
      AND event_name IN ('app_open', 'search', 'view_ad', 'favorite', 'contact_seller')
)
SELECT
    c.user_id,
    u.platform,
    date(c.event_time)                              AS day,
    MAX(c.event_name = 'search')                    AS has_search,
    MAX(c.event_name = 'view_ad')                   AS has_view,
    MAX(c.event_name = 'contact_seller')            AS has_contact,
    COUNT(*)                                        AS events_cnt
FROM clean c
JOIN users u ON u.user_id = c.user_id
GROUP BY c.user_id, u.platform, date(c.event_time);

-- Пример использования витрины: конверсия просмотра в контакт по платформам
SELECT
    platform,
    SUM(has_view)    AS days_with_view,
    SUM(has_contact) AS days_with_contact,
    ROUND(100.0 * SUM(has_contact) / SUM(has_view), 1) AS view_to_contact_pct
FROM mart_user_day
GROUP BY platform
ORDER BY view_to_contact_pct DESC;
