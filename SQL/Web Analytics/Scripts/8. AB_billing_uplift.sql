-- I'd love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test (Sep 10 — Nov 10), 
-- in terms of revenue per billing page session, and then pull the number of billing page sessions for the past month (up to 2012-11-27) to understand monthly impact. 

With ab_billing as(
SELECT wp.website_session_id as session_id, wp.pageview_url as billing_page,
o.order_id,
o.price_usd* o.items_purchased as revenue
FROM website_pageviews wp 
LEFT JOIN orders o on o.website_session_id = wp.website_session_id
WHERE 1=1
AND wp.created_at between '2012-09-10' AND '2012-11-10'
AND wp.pageview_url like'/billing%'

)
, revenue as(
SELECT ab.billing_page, count(distinct ab.session_id) as sessions, 
SUM(CASE WHEN AB.order_id is not null then 1 end) as orders, sum(ab.revenue) as revenue
FROM ab_billing ab
GROUP BY 1
)

, uplift as(
SELECT r.*, round(r.revenue/r.sessions ,2) as rev_per_session,
round(r.orders*100/r.sessions,1) as conv_rate
FROM revenue r
)

SELECT *
FROM uplift up

-- Old billing $22.83
-- New billing $31.34
-- uplift $8.51/session
-- 17% increased conv rate

-- SELECT count(wp.website_session_id)*8.51 as billing2_increased_revenue
-- FROM website_pageviews wp
-- WHERE wp.pageview_url = '/billing-2'
-- and wp.created_at between '2012-10-27' AND '2012-11-27'