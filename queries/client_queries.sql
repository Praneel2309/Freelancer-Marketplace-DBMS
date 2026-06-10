1) All my posted bits with Bid properties: Count, Lowest, Highest, Average-
For each project, analyze the bidding activity. Show how many bids were placed and find 
the lowest, highest, and average bid amounts. Also include projects that received no 
bids.
  
SELECT 
    p.project_ID, 
    p.title, 
    p.status, 
    p.budget_min, 
    p.budget_max, 
    COUNT(bo.bid_ID)         AS total_bids, 
    MIN(b.amount)            AS lowest_bid, 
    MAX(b.amount)            AS highest_bid, 
    ROUND(AVG(b.amount), 2)  AS avg_bid 
FROM project p 
LEFT JOIN bid_on bo ON bo.project_ID = p.project_ID 
LEFT JOIN bid b     ON b.bid_ID      = bo.bid_ID 
WHERE p.client_ID = 'C001' 
GROUP BY p.project_ID, p.title, p.status, p.budget_min, p.budget_max 
ORDER BY total_bids DESC; 

2) All my projects, whether or not contract was created-
Show all projects, even if no one has been hired for them yet. For each project, display 
its basic details along with contract and freelancer information if available. Make sure 
projects without any activity are still included in the list. -- starting from contract and right-joining to project ensures every project 
shows up.
  
SELECT 
    p.project_ID, 
    p.title, 
    p.status, 
    p.deadline, 
    COALESCE(c.contract_ID, 'None')                        AS contract_ID, 
    COALESCE(CAST(c.agreed_amount AS TEXT), 'No contract') AS agreed_amount, 
    COALESCE(f.name, 'Unassigned')                         AS freelancer_name 
FROM contract c 
RIGHT JOIN bid b      ON c.bid_ID       = b.bid_ID 
RIGHT JOIN bid_on bo  ON b.bid_ID        = bo.bid_ID 
RIGHT JOIN project p  ON bo.project_ID   = p.project_ID 
LEFT JOIN  freelancer f ON f.freelancer_ID = bo.freelancer_ID 
WHERE p.client_ID = 'C001' 
ORDER BY p.deadline ASC NULLS LAST; 

3) Compare all freelancers who bid on my project- rating,skills, past 
contracts-
Compare all freelancers who have placed bids on a project. For each freelancer, show 
their rating, skills, bid details, and how much experience they have based on past work. 
Finally, arrange them to help choose the best candidate. -- prev_bo lets us count contracts this freelancer had BEFORE this bid.

SELECT 
    f.name                             AS freelancer_name, 
    f.rating, 
    f.hourly_rate, 
    b.amount                           AS bid_amount, 
    b.status                           AS bid_status, 
    COUNT(DISTINCT fs.skill_ID)         AS skill_count, 
    COUNT(DISTINCT prev_c.contract_ID)  AS past_contracts 
FROM bid_on bo 
JOIN  bid b         ON  b.bid_ID          = bo.bid_ID 
JOIN  freelancer f  ON  f.freelancer_ID   = bo.freelancer_ID 
LEFT JOIN freelancer_skill fs 
                    ON  fs.freelancer_ID  = f.freelancer_ID 
LEFT JOIN bid_on prev_bo 
                    ON  prev_bo.freelancer_ID = f.freelancer_ID 
                   AND  prev_bo.bid_ID     <> bo.bid_ID 
LEFT JOIN bid prev_b     ON prev_b.bid_ID    = prev_bo.bid_ID 
LEFT JOIN contract prev_c ON prev_c.bid_ID   = prev_b.bid_ID 
WHERE bo.project_ID = 'P001' 
GROUP BY f.freelancer_ID, f.name, f.rating, f.hourly_rate, 
         b.amount, b.status 
ORDER BY f.rating DESC, bid_amount ASC; 

4) My payment history- each payment linked to contract and milestone 
progress-
Track all payments made for projects along with their related work progress. For each 
payment, show how many milestones exist and how many have been completed. 
Arrange the results in order of when the payments were made. 

SELECT 
    p.title                    AS project_title, 
    c.contract_ID, 
    c.agreed_amount, 
    py.payment_ID, 
    py.amount                  AS payment_made, 
    py.method, 
    py.payment_date, 
    COUNT(m.milestone_no)      AS total_milestones, 
    SUM(CASE WHEN m.status = 'completed' 
              THEN 1 ELSE 0 END) AS completed_milestones 
FROM project p 
JOIN bid_on bo  ON bo.project_ID  = p.project_ID 
JOIN bid b      ON b.bid_ID       = bo.bid_ID 
JOIN contract c ON c.bid_ID        = b.bid_ID 
JOIN payment py ON py.contract_ID  = c.contract_ID 
LEFT JOIN milestone m ON m.contract_ID = c.contract_ID 
WHERE p.client_ID = 'C001' 
GROUP BY p.title, c.contract_ID, c.agreed_amount, 
         py.payment_ID, py.amount, py.method, py.payment_date 
ORDER BY py.payment_date ASC; 

5) Top rated freelancers for a skill category 
Client wants to discover freelancers with a specific skill (e.g., "Web Development"), 
ranked by rating and number of completed contracts. 

SELECT 
  f.freelancer_ID, f.name, f.rating, f.hourly_rate, 
  STRING_AGG(DISTINCT s.skill_name, ', ') AS skills, 
  COUNT(DISTINCT c.contract_ID) AS completed_contracts, 
  ROUND(AVG(r.rating), 1) AS avg_review_rating 
FROM freelancer f 
JOIN freelancer_skill fs  ON fs.freelancer_ID = f.freelancer_ID 
JOIN skill s              ON s.skill_ID = fs.skill_ID 
JOIN skill_category sc    ON sc.skill_ID = s.skill_ID 
LEFT JOIN bid_on bo       ON bo.freelancer_ID = f.freelancer_ID 
LEFT JOIN bid b           ON b.bid_ID = bo.bid_ID AND b.status = 'accepted' 
LEFT JOIN contract c      ON c.bid_ID = b.bid_ID 
LEFT JOIN review r        ON r.contract_ID = c.contract_ID 
WHERE sc.category = 'Web Development' 
GROUP BY f.freelancer_ID, f.name, f.rating, f.hourly_rate 
HAVING COUNT(DISTINCT c.contract_ID) >= 1 
ORDER BY avg_review_rating DESC, completed_contracts DESC 
LIMIT 10; 

6) Milestone Dashboard - Done/Overdue/Due Soon/On track 
Show the status of each project milestone based on its progress and deadline. Classify 
them as done, overdue, due soon, or on track depending on their completion and due 
date. Then list them in an organized way based on project and timeline.
  
SELECT 
    p.title        
    f.name         
AS project, 
AS freelancer, 
    m.milestone_no, 
    m.description, 
    m.amount, 
    m.due_date, 
    m.status, 
CASE 
WHEN m.status = 'completed'               
WHEN m.due_date < CURRENT_DATE             
END AS health 
FROM client cl 
JOIN project p    
JOIN bid_on bo    
JOIN bid b        
JOIN contract c   
THEN 'Done' 
THEN 'Overdue' 
WHEN m.due_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'Due soon' 
ELSE                                               
ON p.client_ID     = cl.client_ID 
ON bo.project_ID   = p.project_ID 
'On track' 
ON b.bid_ID        = bo.bid_ID AND b.status = 'accepted' 
ON c.bid_ID        = b.bid_ID 
JOIN milestone m  ON m.contract_ID   = c.contract_ID 
JOIN freelancer f ON f.freelancer_ID = bo.freelancer_ID 
WHERE cl.client_ID = 'C001' 
ORDER BY p.title, m.due_date; 
