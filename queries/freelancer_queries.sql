1) Compare my rating V/S Freelancer sharing the same skill- 
Compare my rating with other freelancers who have similar skills. Show how I stand 
against them by calculating the difference in ratings. Sort the results to easily see who is 
better or worse compared to me. 

-- fs1 = my side, fs2 = peer side; skill_ID must match, freelancer_ID must 
differ 
SELECT 
    f2.name                          AS peer_name, 
    s.skill_name                     AS shared_skill, 
    f1.rating                        AS my_rating, 
    f2.rating                        AS peer_rating, 
    ROUND(f2.rating - f1.rating, 1)  AS rating_diff 
FROM freelancer_skill fs1 
JOIN freelancer_skill fs2 
     ON  fs2.skill_ID      = fs1.skill_ID 
    AND  fs2.freelancer_ID <> fs1.freelancer_ID 
JOIN freelancer f1 ON f1.freelancer_ID = fs1.freelancer_ID 
JOIN freelancer f2 ON f2.freelancer_ID = fs2.freelancer_ID 
JOIN skill s       ON s.skill_ID      = fs1.skill_ID 
WHERE fs1.freelancer_ID = 'F001' 
ORDER BY rating_diff ASC; -- negative = peer rated lower, positive = peer rated higher 

2) Open Projects that Match my Skills-
Find open projects that match my skills. Exclude the ones I have already applied to, and 
show only new opportunities. Rank them based on how well they match my skills and 
how soon their deadline is. 

SELECT 
    p.project_ID, 
    p.title, 
    p.budget_min, 
    p.budget_max, 
    p.deadline, 
    cl.company_name, 
    COUNT(DISTINCT fs.skill_ID) AS matching_skills 
FROM project p 
JOIN client cl ON cl.client_ID = p.client_ID 
JOIN ( 
-- get all skill IDs that belong to me 
SELECT sc.skill_ID 
FROM freelancer_skill fs2 
JOIN skill_category sc ON sc.skill_ID = fs2.skill_ID 
WHERE fs2.freelancer_ID = 'F001' 
) my_skills ON TRUE 
JOIN freelancer_skill fs 
ON  fs.skill_ID      = my_skills.skill_ID 
AND  fs.freelancer_ID = 'F001' 
WHERE p.status = 'open' 
AND p.project_ID NOT IN ( -- exclude anything I've already bid on 
SELECT project_ID FROM bid_on WHERE freelancer_ID = 'F001' 
  ) 
GROUP BY p.project_ID, p.title, p.budget_min, p.budget_max, 
         p.deadline, cl.company_name 
ORDER BY matching_skills DESC, p.deadline ASC; 

3) Bookmarked projects still open for bidding-
Show the projects I have bookmarked that are still open for bidding. Also indicate 
whether I have already placed a bid on them or not, and sort them by deadline. 
SELECT 
  p.project_ID, p.title, p.deadline, 
  p.budget_min, p.budget_max, 
  cl.name AS client_name, 
  cl.company_name, 
  CASE WHEN bo.bid_ID IS NOT NULL THEN 'Already bid' 
       ELSE 'Not bid yet' END AS bid_status 
FROM bookmarks bm 
JOIN project p   ON p.project_ID = bm.project_ID 
JOIN client cl   ON cl.client_ID = p.client_ID 
LEFT JOIN bid_on bo 
  ON bo.project_ID = p.project_ID 
 AND bo.freelancer_ID = bm.freelancer_ID 
WHERE bm.freelancer_ID = 'F001' 
  AND p.status = 'open' 
ORDER BY p.deadline ASC; 

4) Total earnings breakdown by month-
Track how much I have earned over time. For each month, show the total earnings and 
number of payments, ordered from recent to older months. 
SELECT 
  TO_CHAR(py.payment_date, 'YYYY-MM') AS month, 
  SUM(py.amount)                        AS total_earned, 
  COUNT(py.payment_ID)                  AS payment_count 
FROM payment py 
JOIN contract c  ON c.contract_ID = py.contract_ID 
JOIN bid b       ON b.bid_ID = c.bid_ID 
JOIN bid_on bo   ON bo.bid_ID = b.bid_ID 
WHERE bo.freelancer_ID = 'F001' 
GROUP BY TO_CHAR(py.payment_date, 'YYYY-MM') 
ORDER BY month DESC; 
