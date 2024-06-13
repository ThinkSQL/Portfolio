
-- For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each of the two pages to orders. 
-- You can use the same time period you analyzed last time (Jun 19 — Jul 28).

With entry_page as (
SELECT wp.website_session_id, min(website_pageview_id) as pv_id
FROM website_sessions ws
LEFT JOIN  website_pageviews wp on ws.website_session_id = wp.website_session_id
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
entry_url as (
SELECT  wp.pageview_url AS entry_url, ep.website_session_id
FROM entry_page ep
JOIN website_pageviews wp on ep.pv_id = wp.website_pageview_id
WHERE 1=1
AND wp.pageview_url IN ('/home','/lander-1')
GROUP BY 1,2

)

, flags as(
SELECT  DISTINCT wp.website_session_id as session_id,
CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS prod_flag,
CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy_flag,
CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_flag,
CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_flag,
CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_flag,
CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thanks_flag
FROM entry_url eu
LEFT JOIN website_pageviews wp on eu.website_session_id = wp.website_session_id

)
, click_through as (
SELECT f.session_id,
MAX(f.prod_flag) as prod_flags,
MAX(f.fuzzy_flag) as fuzzy_flags,
MAX(f.cart_flag) as cart_flags,
MAX(f.shipping_flag) as shipping_flags,
MAX(f.billing_flag) as billing_flags,
MAX(f.thanks_flag) as thanks_flags
FROM flags f
GROUP BY 1
)
, click_count as(
SELECT eu.entry_url, 
COUNT(distinct eu.website_session_id) as session_id,
SUM(ct.prod_flags) as prod_flags,
SUM(ct.fuzzy_flags) as fuzzy_flags,
SUM(ct.cart_flags) as cart_flags,
SUM(ct.shipping_flags) as shipping_flags,
SUM(ct.billing_flags) as billing_flags,
SUM(ct.thanks_flags) as thanks_flags
FROM click_through ct
LEFT JOIN entry_url eu on ct.session_id = eu.website_session_id
GROUP BY 1)

SELECT 
entry_url, 
session_id as total_sessions,
ROUND(prod_flags*100/session_id, 1) as entry_click_through,
ROUND(fuzzy_flags*100/prod_flags, 1) as product_click_through,
ROUND(cart_flags*100/fuzzy_flags, 1) as fuzzy_click_through,
ROUND(shipping_flags*100/cart_flags, 1) as cart_click_through,
ROUND(billing_flags*100/shipping_flags, 1) as shipping_click_through,
ROUND(thanks_flags*100/billing_flags, 1) as billing_click_through


FROM click_count
GROUP BY 1