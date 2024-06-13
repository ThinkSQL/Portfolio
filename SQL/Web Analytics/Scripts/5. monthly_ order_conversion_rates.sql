-- I'd like to tell the story of our website performance improvements over the course of the first 8 months. 
-- Could you pull session to order conversion rates, by month?

SELECT 
    MIN(DATE(ws.created_at)) AS Month_Start, 
    COUNT(DISTINCT ws.website_session_id) AS sessions,
  
    COUNT(DISTINCT o.website_session_id) AS orders,
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
            2
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
    1=1
    AND ws.created_at < '2012-11-27'
GROUP BY 
    YEAR(ws.created_at), 
    MONTH(ws.created_at)
ORDER BY 
    1;
