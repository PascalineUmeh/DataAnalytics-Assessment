WITH plan_type AS (
	#Identifying customers who have savings plan and investment plan, indicating their deposit
	SELECT p.owner_id, 
	CASE WHEN p.is_regular_savings = 1 THEN s.plan_id END AS savings,
	CASE WHEN p.is_a_fund = 1 THEN s.plan_id END AS investment,
	s.confirmed_amount
	FROM adashi_staging.savings_savingsaccount s 
	JOIN adashi_staging.plans_plan p ON s.plan_id = p.id
    )
#Identifying customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits
SELECT t.owner_id,
	CONCAT(u.first_name, ' ', u.last_name) AS name, #Combining first name and last name to create a full name for each customer
    COUNT(DISTINCT t.savings) AS savings_count,
    COUNT(DISTINCT t.investment) AS investment_count,
    ROUND(SUM(t.confirmed_amount) / 100, 2) AS total_deposits
    FROM adashi_staging.users_customuser u
JOIN plan_type t ON u.id = t.owner_id
WHERE t.confirmed_amount > 0
GROUP BY u.id, u.name
HAVING savings_count > 0 AND investment_count > 0
ORDER BY total_deposits DESC
;