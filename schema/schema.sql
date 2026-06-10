-- 1. FREELANCER 
CREATE TABLE Freelancer ( 
    freelancer_id SERIAL PRIMARY KEY, 
    name VARCHAR(100), 
    email VARCHAR(100), 
    bio TEXT, 
    hourly_rate NUMERIC, 
    total_earnings NUMERIC, 
    join_date DATE, 
    rating NUMERIC(2,1) 
); 
 
-- Multivalued Phone 
CREATE TABLE Freelancer_Phone ( 
    freelancer_id INT, 
    phone_no VARCHAR(15), 
    PRIMARY KEY (freelancer_id, phone_no), 
    FOREIGN KEY (freelancer_id) REFERENCES 
Freelancer(freelancer_id) 
); 
 
-- 2. SKILL 
CREATE TABLE Skill ( 
    skill_id SERIAL PRIMARY KEY, 
    skill_name VARCHAR(100) 
); 

-- Multivalued Category 
CREATE TABLE Skill_Category ( 
    skill_id INT, 
    category VARCHAR(100), 
    PRIMARY KEY (skill_id, category), 
    FOREIGN KEY (skill_id) REFERENCES Skill(skill_id) 
); 

-- 3. HAS_SKILL 
CREATE TABLE Freelancer_Skill ( 
    freelancer_id INT, 
    skill_id INT, 
    PRIMARY KEY (freelancer_id, skill_id), 
    FOREIGN KEY (freelancer_id) REFERENCES 
Freelancer(freelancer_id), 
    FOREIGN KEY (skill_id) REFERENCES Skill(skill_id) 
); 
 
-- 4. PORTFOLIO 
CREATE TABLE PortfolioItem ( 
    portfolio_id SERIAL PRIMARY KEY, 
    freelancer_id INT, 
    title VARCHAR(100), 
    description TEXT, 
    project_link TEXT, 
    image_file TEXT, 
    tech_stack TEXT, 
    FOREIGN KEY (freelancer_id) REFERENCES 
Freelancer(freelancer_id) 
); 

-- 5. CLIENT 
CREATE TABLE Client ( 
    client_id SERIAL PRIMARY KEY, 
    name VARCHAR(100), 
    email VARCHAR(100), 
    company_name VARCHAR(100), 
    join_date DATE 
); 

-- 6. PROJECT 
CREATE TABLE Project ( 
    project_id SERIAL PRIMARY KEY, 
    client_id INT, 
    title VARCHAR(100), 
    deadline DATE, 
    status VARCHAR(50), 
    budget_min NUMERIC, 
    budget_max NUMERIC, 
    FOREIGN KEY (client_id) REFERENCES Client(client_id) 
); 
 
-- 7. BOOKMARKS (Freelancer ↔ Project) 
CREATE TABLE Bookmarks ( 
    freelancer_id INT, 
    project_id INT, 
    PRIMARY KEY (freelancer_id, project_id), 
    FOREIGN KEY (freelancer_id) REFERENCES 
Freelancer(freelancer_id), 
    FOREIGN KEY (project_id) REFERENCES 
Project(project_id) 
); 
 
-- 8. BID (ENTITY) 
CREATE TABLE Bid ( 
    bid_id SERIAL PRIMARY KEY, 
    amount NUMERIC, 
    proposal TEXT, 
    status VARCHAR(50) 
); 

-- 9. BID_ON (M:N RELATION) 
CREATE TABLE Bid_On ( 
    freelancer_id INT, 
    project_id INT, 
    bid_id INT, 
    PRIMARY KEY (freelancer_id, project_id, bid_id), 
    FOREIGN KEY (freelancer_id) REFERENCES 
Freelancer(freelancer_id), 
    FOREIGN KEY (project_id) REFERENCES 
Project(project_id), 
    FOREIGN KEY (bid_id) REFERENCES Bid(bid_id) 
); 

-- 10. CONTRACT 
CREATE TABLE Contract ( 
    contract_id SERIAL PRIMARY KEY, 
    bid_id INT UNIQUE, 
    start_date DATE, 
    end_date DATE, 
    agreed_amount NUMERIC, 
    FOREIGN KEY (bid_id) REFERENCES Bid(bid_id) 
); 

-- 11. MILESTONE 
CREATE TABLE Milestone ( 
    milestone_no INT, 
    contract_id INT, 
    description TEXT, 
    amount NUMERIC, 
    due_date DATE, 
    status VARCHAR(50), 
    PRIMARY KEY (milestone_no, contract_id), 
    FOREIGN KEY (contract_id) REFERENCES 
Contract(contract_id) 
); 

-- 12. PAYMENT 
CREATE TABLE Payment ( 
    payment_id SERIAL PRIMARY KEY, 
    contract_id INT, 
    amount NUMERIC, 
    method VARCHAR(50), 
    date DATE, 
    FOREIGN KEY (contract_id) REFERENCES 
Contract(contract_id) 
); 
 
-- 13. REVIEW 
CREATE TABLE Review ( 
    review_id SERIAL PRIMARY KEY, 
    contract_id INT UNIQUE, 
    rating NUMERIC(2,1), 
    comments TEXT, 
    date DATE, 
    FOREIGN KEY (contract_id) REFERENCES 
Contract(contract_id) 
); 

-- 14. DISPUTE 
CREATE TABLE Dispute ( 
    dispute_id SERIAL PRIMARY KEY, 
    contract_id INT, 
    reason TEXT, 
    status VARCHAR(50), 
    created_date DATE, 
    FOREIGN KEY (contract_id) REFERENCES 
Contract(contract_id) 
); 
