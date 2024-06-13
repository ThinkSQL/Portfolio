-- While we're on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? 
SELECT 
    MIN(DATE(ws.created_at)) AS Month_Start, 
    ws.device_type AS device,
    COUNT(DISTINCT ws.website_session_id) AS gsearch_sessions,
    CONCAT(
        ROUND(
            (COUNT(DISTINCT ws.website_session_id) * 100 / 
            LAG(COUNT(DISTINCT ws.website_session_id), 1) 
            OVER (PARTITION BY ws.device_type ORDER BY MIN(DATE(ws.created_at)))) - 100, 
            1
        ), 
        ' %'
    ) AS Monthly_traffic_change,
    
    SUM(CASE WHEN ws.utm_campaign = 'nonbrand' THEN 1 ELSE 0 END) AS nonbrand_sessions,
    SUM(CASE WHEN ws.utm_campaign = 'brand' THEN 1 ELSE 0 END) AS brand_sessions,
    
    CONCAT(
        ROUND(
            (SUM(CASE WHEN ws.utm_campaign = 'nonbrand' THEN 1 ELSE 0 END) * 100 / 
            LAG(SUM(CASE WHEN ws.utm_campaign = 'nonbrand' THEN 1 ELSE 0 END), 1) 
            OVER (PARTITION BY ws.device_type ORDER BY MIN(DATE(ws.created_at)))) - 100, 
            1
        ), 
        ' %'
    ) AS Monthly_nonbrand_traffic_change,
    
    CONCAT(
        ROUND(
            (SUM(CASE WHEN ws.utm_campaign = 'brand' THEN 1 ELSE 0 END) * 100 / 
            LAG(SUM(CASE WHEN ws.utm_campaign = 'brand' THEN 1 ELSE 0 END), 1) 
            OVER (PARTITION BY ws.device_type ORDER BY MIN(DATE(ws.created_at)))) - 100, 
            1
        ), 
        ' %'
    ) AS Monthly_brand_traffic_change,
  
    COUNT(DISTINCT o.website_session_id) AS orders_from_gsearch,
    SUM(CASE WHEN ws.utm_campaign = 'nonbrand' AND o.website_session_id IS NOT NULL THEN 1 ELSE 0 END) AS nonbrand_orders,
    SUM(CASE WHEN ws.utm_campaign = 'brand' AND o.website_session_id IS NOT NULL THEN 1 ELSE 0 END) AS brand_orders,
    CONCAT(
        ROUND(
            (COUNT(DISTINCT o.website_session_id) * 100 / 
            LAG(COUNT(DISTINCT o.website_session_id), 1) 
            OVER (PARTITION BY ws.device_type ORDER BY MIN(DATE(ws.created_at)))) - 100, 
            1
        ), 
        ' %'
    ) AS order_growth_trend,
    
    CONCAT(
        ROUND(
            COUNT(DISTINCT o.website_session_id) * 100 / COUNT(DISTINCT ws.website_session_id), 
            1
        ), 
        ' %'
    ) AS conv_rate
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
