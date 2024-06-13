
-- For the gsearch lander test, please estimate the revenue that test earned us 
-- (Hint: Look at the increase in CVR from the test (Jun 19 — Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)

With entry_page as (
SELECT wp.website_session_id, min(website_pageview_id) as pv_id
FROM website_pageviews wp
JOIN website_sessions ws on ws.website_session_id = wp.website_session_id
WHERE ws.utm_source = 'gsearch'
AND ws.utm_campaign = 'nonbrand'
AND ws.created_at between (
SELECT min(created_at)
FROM website_pageviews
WHERE pageview_url = '/lander-1'
)
and '2012-07-28'
GROUP BY 1)

,
revenue as (

SELECT DATE_FORMAT(wp.created_at, '%Y-%m') AS Month,
SUM(CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END) AS home_sessions,
SUM(CASE WHEN wp.pageview_url = '/lander-1' THEN 1 ELSE 0 END) AS lander1_sessions,
SUM(CASE WHEN wp.pageview_url = '/home' AND o.website_session_id IS NOT NULL THEN 1 ELSE 0 END) AS home_orders,
SUM(CASE WHEN wp.pageview_url = '/lander-1' AND o.website_session_id IS NOT NULL THEN 1 ELSE 0 END) AS lander1_orders,
SUM(CASE WHEN wp.pageview_url = '/home' AND o.website_session_id IS NOT NULL THEN o.items_purchased*o.price_usd ELSE 0 END) AS home_revenue,
SUM(CASE WHEN wp.pageview_url = '/lander-1' AND o.website_session_id IS NOT NULL THEN o.items_purchased*o.price_usd ELSE 0 END) AS lander1_revenue

FROM entry_page ep
LEFT JOIN website_pageviews wp on ep.pv_id = wp.website_pageview_id
LEFT JOIN orders o  on o.website_session_id = ep.website_session_id
WHERE 1=1

GROUP BY 1
)


SELECT r.month, r.home_sessions, r.home_orders, 
round((r.home_orders*100/r.home_sessions),1) as 'home_cvr_%', 
r.lander1_sessions, r.lander1_orders,
round((r.lander1_orders*100/r.lander1_sessions),1) as 'lander1_cvr_%', 
r.lander1_revenue-r.home_revenue as lander1_revenue_uplift
FROM revenue r
GROUP BY 1
ORDER BY  1
 ;