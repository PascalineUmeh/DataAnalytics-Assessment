SELECT 
    s.plan_id,
    p.owner_id,
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investments'
        ELSE 'Others'
    END AS type,
    MAX(s.transaction_date) AS last_transaction_date,
    DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) AS inactivity_days
FROM
    adashi_staging.plans_plan p
        JOIN
    adashi_staging.savings_savingsaccount s ON p.id = s.plan_id
WHERE
    s.confirmed_amount > 0
GROUP BY s.plan_id , p.owner_id , type
HAVING inactivity_days > 365
ORDER BY last_transaction_date DESC
;