WITH account_tenure AS (
    SELECT
        id AS customer_id,
        CONCAT(first_name, ' ', last_name) AS name, #Combining first name and last name to create a full name for each customer
        TIMESTAMPDIFF(MONTH, created_on, CURRENT_DATE) AS tenure_months #Calculating months since signup
        FROM adashi_staging.users_customuser
	),
transactions_stats AS (
    SELECT owner_id,
		#Count the number of transactions per customer
        COUNT(*) AS total_transactions, 
        ROUND(AVG(confirmed_amount) * 0.001, 2) AS avg_profit_per_transaction #Calculating the average profit per transaction and rounding up in 2 decimail places
    FROM adashi_staging.savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY owner_id
)
SELECT 
		a.customer_id,
        a.name,
        a.tenure_months,
        t.total_transactions,
        #Calculating estimated CLV and rounding up in 2 decimail places
        ROUND((t.total_transactions / a.tenure_months) * 12 * t.avg_profit_per_transaction, 2) AS estimated_clv 
    FROM
        account_tenure a JOIN transactions_stats t ON a.customer_id = t.owner_id
    WHERE a.tenure_months > 0 #Filtering out customers with tenure = 0 to avoid divide-by-zero errors
    GROUP BY
        a.customer_id, a.name, a.tenure_months, t.total_transactions, t.avg_profit_per_transaction
	ORDER BY estimated_clv DESC  #Sorting by estimated CLV from highest to lowest
;