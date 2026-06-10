1) Platform Revenue trend - total payments grouped by month-
Track how the platform’s earnings change over time on a monthly basis. For each 
month, calculate total payments along with some basic statistics like average, minimum, 
and maximum payment amounts. Finally, arrange the results from oldest to newest 
month. 
  
SELECT 
    DATE_TRUNC('month', py.payment_date) AS month, 
    COUNT(DISTINCT c.contract_ID)        AS active_contracts, 
    COUNT(py.payment_ID)                 AS payment_count, 
    SUM(py.amount)                       AS total_revenue, 
    ROUND(AVG(py.amount), 2)             AS avg_payment, 
    MIN(py.amount)                       AS min_payment, 
    MAX(py.amount)                       AS max_payment 
FROM payment py 
JOIN contract c   ON c.contract_ID     = py.contract_ID 
JOIN bid b        ON b.bid_ID           = c.bid_ID 
JOIN bid_on bo    ON bo.bid_ID           = b.bid_ID 
JOIN freelancer f ON f.freelancer_ID     = bo.freelancer_ID 
GROUP BY DATE_TRUNC('month', py.payment_date) 
ORDER BY month ASC; 

2) Skill Category demand map- Bids & Bookmarks per category- 
Analyze each skill category to understand its popularity and activity. For every category, 
check how many freelancers have that skill, how many bids are made, and how often 
projects are bookmarked. Finally, sort the categories based on overall activity. 

SELECT 
    sc.category, 
    COUNT(DISTINCT fs.freelancer_ID) AS freelancers_with_skill, 
    COUNT(DISTINCT bo.bid_ID)         AS total_bids, 
    COUNT(DISTINCT bm.project_ID)     AS total_bookmarks, 
    ROUND(AVG(f.rating), 2)           AS avg_freelancer_rating, 
    ROUND(AVG(b.amount), 2)           AS avg_bid_amount 
FROM skill_category sc 
JOIN  skill s            ON s.skill_ID        = sc.skill_ID 
JOIN  freelancer_skill fs ON fs.skill_ID       = s.skill_ID 
JOIN  freelancer f        ON f.freelancer_ID   = fs.freelancer_ID 
LEFT JOIN bid_on bo       ON bo.freelancer_ID  = f.freelancer_ID 
LEFT JOIN bid b           ON b.bid_ID          = bo.bid_ID 
LEFT JOIN bookmarks bm    ON bm.freelancer_ID  = f.freelancer_ID 
GROUP BY sc.category 
ORDER BY total_bids DESC, total_bookmarks DESC; 

3)Skill demand v/s Supply Gap-
Compare how much each skill category is needed versus how many freelancers are 
available for it. Identify which skills have high demand but low supply. Finally, rank the 
categories based on this demand-to-supply gap. 
  
-- CTE 1: how many projects touched each skill category (demand) 
WITH skill_demand AS ( 
    SELECT sc.category, 
           COUNT(DISTINCT p.project_ID) AS project_count 
    FROM project p 
    JOIN bid_on bo          ON bo.project_ID  = p.project_ID 
    JOIN bid b              ON b.bid_ID        = bo.bid_ID 
    JOIN freelancer_skill fs ON fs.freelancer_ID = bo.freelancer_ID 
    JOIN skill_category sc  ON sc.skill_ID     = fs.skill_ID 
    GROUP BY sc.category 
), 
  
-- CTE 2: how many freelancers can serve each category (supply) 
skill_supply AS ( 
    SELECT sc.category, 
           COUNT(DISTINCT fs.freelancer_ID) AS freelancer_count 
    FROM freelancer_skill fs 
    JOIN skill_category sc ON sc.skill_ID = fs.skill_ID 
    GROUP BY sc.category 
) 
SELECT 
    d.category, 
    d.project_count    AS demand, 
    s.freelancer_count AS supply, 
    ROUND(d.project_count::numeric / NULLIF(s.freelancer_count, 0), 2) 
                       AS demand_supply_ratio 
FROM skill_demand d 
LEFT JOIN skill_supply s ON s.category = d.category 
ORDER BY demand_supply_ratio DESC; 

4) Freelancers who bid frequently but never got a single contract- 
Find freelancers who keep placing bids but never actually get hired. Only consider those 
who have tried multiple times (at least 3 bids). Show their activity details and sort them 
based on how frequently they bid. 

-- anti-join: LEFT JOIN to contract, keep only where contract is NULL 
SELECT 
    f.freelancer_ID, 
    f.name, 
    f.rating, 
    f.join_date, 
    COUNT(bo.bid_ID)            AS total_bids, 
    ROUND(AVG(b.amount), 2)     AS avg_bid_amount, 
    CURRENT_DATE - f.join_date  AS days_on_platform 
FROM freelancer f 
JOIN      bid_on bo  ON bo.freelancer_ID = f.freelancer_ID 
JOIN      bid b      ON b.bid_ID          = bo.bid_ID 
LEFT JOIN contract c ON c.bid_ID           = b.bid_ID 
WHERE c.contract_ID IS NULL 
GROUP BY f.freelancer_ID, f.name, f.rating, f.join_date 
HAVING COUNT(bo.bid_ID) >= 3 
ORDER BY total_bids DESC; 

5)Cross Join-Every Freelancer x Every client pair with interaction status-
Show every possible freelancer and client pair, even if they have never interacted. For 
each pair, check whether they have worked together, only placed bids, or had no 
interaction at all. Also count how many bids and contracts exist between them, and sort 
the results by activity. 
  
-- CROSS JOIN gives all pairs; LEFT JOINs check if anything actually happened 
SELECT 
    f.name                          AS freelancer_name, 
    cl.name                         AS client_name, 
    COUNT(DISTINCT bo.bid_ID)        AS bids_placed, 
    COUNT(DISTINCT c.contract_ID)   AS contracts, 
    CASE 
        WHEN COUNT(DISTINCT c.contract_ID) > 0 THEN 'Contracted' 
        WHEN COUNT(DISTINCT bo.bid_ID) > 0     THEN 'Bid only' 
        ELSE                                         'No interaction' 
    END AS relationship_status 
FROM freelancer f 
CROSS JOIN client cl 
LEFT JOIN project p  ON  p.client_ID       = cl.client_ID 
LEFT JOIN bid_on bo  ON  bo.project_ID     = p.project_ID 
                    AND  bo.freelancer_ID  = f.freelancer_ID 
LEFT JOIN bid b      ON  b.bid_ID           = bo.bid_ID 
LEFT JOIN contract c ON  c.bid_ID           = b.bid_ID 
GROUP BY f.freelancer_ID, f.name, cl.client_ID, cl.name 
ORDER BY contracts DESC, bids_placed DESC; 
6) Top clients and top freelancers by earnings report-
Find out who earned and who spent the most on the platform. Show both clients and 
freelancers in one list with their total money and number of deals. Then arrange 
everyone from highest to lowest based on money. 
  
-- top half: clients ranked by what they spent 
SELECT 
    'Client'                        AS role, 
    cl.name                         AS entity_name, 
    SUM(c.agreed_amount)            AS total_value, 
    COUNT(DISTINCT c.contract_ID)  AS contracts 
FROM client cl 
JOIN project p  ON p.client_ID  = cl.client_ID 
JOIN bid_on bo  ON bo.project_ID = p.project_ID 
JOIN bid b      ON b.bid_ID      = bo.bid_ID 
JOIN contract c ON c.bid_ID      = b.bid_ID 
GROUP BY cl.client_ID, cl.name 
UNION ALL -- bottom half: freelancers ranked by what they earned 
SELECT 
    'Freelancer'                    AS role, 
    f.name                          AS entity_name, 
    SUM(c.agreed_amount)            AS total_value, 
    COUNT(DISTINCT c.contract_ID)  AS contracts 
FROM freelancer f 
JOIN bid_on bo  ON bo.freelancer_ID = f.freelancer_ID 
JOIN bid b      ON b.bid_ID         = bo.bid_ID 
JOIN contract c ON c.bid_ID          = b.bid_ID 
GROUP BY f.freelancer_ID, f.name 
ORDER BY total_value DESC; 
7) Skill categories ranked by number of freelancers-
Given data about freelancers, their skills, and skill categories, determine how different 
skill categories perform. For each category, calculate the number of unique freelancers, 
total skills, and the average rating. Only include those categories that have at least 2 
freelancers, and rank them based on the number of freelancers. 

SELECT 
    sc.category, 
COUNT(DISTINCT fs.freelancer_ID) AS freelancer_count, 
COUNT(DISTINCT s.skill_ID)        
ROUND(AVG(f.rating), 2)           
FROM skill_category sc 
JOIN skill s             
AS skills_in_category, 
AS avg_rating_in_category 
ON s.skill_ID        = sc.skill_ID 
JOIN freelancer_skill fs  ON fs.skill_ID       = s.skill_ID 
JOIN freelancer f         
ON f.freelancer_ID   = fs.freelancer_ID 
GROUP BY sc.category 
HAVING COUNT(DISTINCT fs.freelancer_ID) >= 2 
ORDER BY freelancer_count DESC;
