-- Воронка: app_open -> search -> view_ad -> contact_seller
-- Считаем пользователей, дошедших до каждого шага хотя бы раз
WITH user_steps AS (
    SELECT
        user_id,
        MAX(event_name = 'app_open')       AS s1_open,
        MAX(event_name = 'search')         AS s2_search,
        MAX(event_name = 'view_ad')        AS s3_view,
        MAX(event_name = 'contact_seller') AS s4_contact
    FROM events
    WHERE user_id IS NOT NULL
    GROUP BY user_id
)
SELECT
    SUM(s1_open)    AS opened,
    SUM(s2_search)  AS searched,
    SUM(s3_view)    AS viewed_ad,
    SUM(s4_contact) AS contacted,
    ROUND(100.0 * SUM(s2_search)  / SUM(s1_open), 1)   AS pct_open_to_search,
    ROUND(100.0 * SUM(s3_view)    / SUM(s2_search), 1) AS pct_search_to_view,
    ROUND(100.0 * SUM(s4_contact) / SUM(s3_view), 1)   AS pct_view_to_contact
FROM user_steps;
