-- I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. 
-- Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?

with traffic_source as(

SELECT ws.utm_source, ws.utm_campaign, ws.http_referer, ws.website_session_id, ws.created_at
FROM website_sessions ws
WHERE 1=1
AND ws.created_at < '2012-11-27'
)


SELECT DATE_FORMAT(ts.created_at, '%Y-%m') AS Month,
  
    sum(case when ts.utm_source = 'gsearch' then 1 end) as gsearch_paid_session,
    sum(case when ts.utm_source = 'bsearch'  then 1 end) as bsearch_paid_session,
	sum(case when ts.http_referer is not null and ts.utm_source is null then 1 end) as  organic_search,
    sum(case when ts.http_referer is null and ts.utm_source is null then 1 end) as direct_type_in
    


FROM traffic_source ts

WHERE 1=1

GROUP BY  
1   


ORDER BY 1,2,3

 ;

-- SELECT 
--     DATE_FORMAT(ts.created_at, '%Y-%m') AS Month,  -- Adjust for MySQL date formatting
--     ts.utm_source AS Source,
--     COUNT(DISTINCT ts.website_session_id) AS Session_Count
-- FROM 
--     traffic_source ts
-- GROUP BY 
--   DATE_FORMAT(ts.created_at, '%Y-%m'),
--     ts.utm_source
-- ORDER BY 
-- DATE_FORMAT(ts.created_at, '%Y-%m'),
--     ts.utm_source;
