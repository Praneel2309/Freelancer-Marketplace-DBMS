1) Freelancer: 
FreelancerID → Name 
FreelancerID → Email 
FreelancerID → Bio 
FreelancerID → HourlyRate 
FreelancerID → TotalEarnings 
FreelancerID → Rating 
FreelancerID → JoinDate 
Email → FreelancerID (assuming email is unique) 

2) Skills: 
SkillID → SkillName 

3) FreelancerSkill (Junction Table) 
(FreelancerID, SkillID) → ∅ 

4) Client:
ClientID → Name 
ClientID → Email 
ClientID → CompanyName 
ClientID → JoinDate 
Email → ClientID (assuming unique email) 

5) Project:
ProjectID → Title 
ProjectID → Status 
ProjectID → UpperLimit 
ProjectID → LowerLimit 
ProjectID → Deadline 
ProjectID → ClientID 

6) Bid:
BidID → Amount 
BidID → Proposal 
BidID → Status

7) Bid_on:
(FreelancerID, ProjectID, BidID) → ∅ 

8) Contract:
ContractID → AgreedAmount 
ContractID → StartDate 
ContractID → EndDate 
ContractID → BidID 

9) Payment:
PaymentID → Amount 
PaymentID → Method 
PaymentID → Date 
PaymentID → ContractID 

10) Review:
ReviewID → Rating 
ReviewID → Comment 
ReviewID → Date 
ReviewID → ContractID 

11) Milestones:
(ContractID, MilestoneNo) → Description 
(ContractID, MilestoneNo) → Amount 
(ContractID, MilestoneNo) → Status 
(ContractID, MilestoneNo) → DueDate 
(ContractID, MilestoneNo) → EndDate 

12) Dispute:
DisputeID → ContractID 
DisputeID → Reason 
DisputeID → Status 
DisputeID → Created_date 

13) Portfolio:
PortfolioID → FreelancerID 
PortfolioID → Title 
PortfolioID → Techstack 
PortfolioID → Description 
PortfolioID → ProjectLink 
PortfolioID → Image 

14) Freelancer Phone:
(FreelancerID, PhoneNo) → ∅    

15) Bookmark:
(FreelancerID, ProjectId) → ∅

16) Skill_category: 
(SkillID, Category) → ∅
