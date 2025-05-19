WITH transaction_metrics AS (
	#Extracting transaction metrics per customer
    SELECT
        DISTINCT owner_id,
        COUNT(*) AS total_transactions,
        TIMESTAMPDIFF(MONTH, MIN(transaction_date), MAX(transaction_date)) + 1 AS months_transacted #Added 1 to avoid division by zero when transactions occur in the same month
    FROM adashi_staging.savings_savingsaccount
    GROUP BY owner_id
),
transaction_frequency AS (
	#Classifying customers into frequency groups based on the computed average transaction per month
    SELECT
        owner_id,
        ROUND(total_transactions / months_transacted, 2) AS transactions_per_month,
        CASE
            WHEN (total_transactions / months_transacted) >= 10 THEN 'High Frequency'
            WHEN (total_transactions / months_transacted) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM transaction_metrics
)
SELECT
    frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(transactions_per_month), 1) AS avg_transactions_per_month
FROM transaction_frequency
GROUP BY frequency_category
ORDER BY customer_count
;