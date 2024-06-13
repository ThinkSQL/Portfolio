-- Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?
SELECT 
    MIN(DATE(ws.created_at)) AS Month_Start, 
    COUNT(DISTINCT ws.website_session_id) AS gsearch_sessions,
    CONCAT(
        ROUND(
            (COUNT(DISTINCT ws.website_session_id) * 100 / 
            LAG(COUNT(DISTINCT ws.website_session_id), 1) 
            OVER (ORDER BY MIN(DATE(ws.created_at)))) - 100, 
            1
        ), 
        ' %'
    ) AS traffic_trend,
    COUNT(DISTINCT o.website_session_id) AS orders_from_gsearch,
    CONCAT(
        ROUND(
            (COUNT(DISTINCT o.website_session_id) * 100 / 
            LAG(COUNT(DISTINCT o.website_session_id), 1) 
            OVER (ORDER BY MIN(DATE(ws.created_at)))) - 100, 
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
    MONTH(ws.created_at)
ORDER BY 
    1;
