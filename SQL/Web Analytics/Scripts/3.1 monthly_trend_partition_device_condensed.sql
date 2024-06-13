-- While we're on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? 

SELECT 
    MIN(DATE(ws.created_at)) AS Month_Start, 
    ws.device_type AS device,
    SUM( CASE WHEN ws.utm_campaign = 'nonbrand' THEN 1 ELSE 0 END) AS nonbrand_sessions,
    SUM( CASE WHEN ws.utm_campaign = 'nonbrand' AND o.website_session_id IS NOT NULL THEN 1 ELSE 0  END) AS nonbrand_orders
FROM 
    website_sessions ws
LEFT JOIN 
    orders o 
ON 
    o.website_session_id = ws.website_session_id
WHERE 
    ws.utm_source = 'gsearch'
    AND ws.created_at < '2012-11-27'
GROUP BY 
    YEAR(ws.created_at), 
    MONTH(ws.created_at),
    ws.device_type
ORDER BY 
    MIN(DATE(ws.created_at)), 
    ws.device_type;
