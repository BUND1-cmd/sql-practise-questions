-- ============================================================
-- EQUITY BANK KENYA - PRACTICE QUESTIONS
-- ============================================================
-- Instructions:
-- 1. Run bank_database.sql first to create all tables
-- 2. Answer each question by writing your query below it
-- 3. Push to GitHub after completing each section
-- ============================================================

USE equity_bank;

-- ============================================================
-- SECTION 1: BASIC QUERIES (Warm Up)
-- ============================================================

-- Q1. Show all customers from Nairobi.
-- Expected: 3 customers
select customer_id,full_name,city from customers 
where city = "Nairobi"

-- Q2. Show all accounts with balance above 500,000 KES.
-- Expected: 3 accounts
select account_id,account_type,balance from accounts
where balance>500000 


-- Q3. Show all transactions that are Pending or Failed.
-- Expected: 2 transactions
select transaction_id,account_id,status from transactions
where status in ("Pending","Failed")


-- Q4. Show the top 5 accounts by balance, highest first.
-- Expected: ACC-010, ACC-004, ACC-008, ACC-002, ACC-006
select account_id,customer_id,balance from accounts
order by balance desc
limit 5


-- Q5. Show all customers who joined after 2020.
-- Expected: 5 customers
select customer_id,full_name,date_joined from customers
where date_joined>"2020-12-31"


-- ============================================================
-- SECTION 2: AGGREGATE FUNCTIONS
-- ============================================================

-- Q6. What is the total balance across all accounts?
-- Expected: 10,285,000.00
select sum(balance) as total_balance from accounts


-- Q7. How many accounts does each account type have?
-- Show account_type and count.
select account_type,count (*) as account_count from accounts
group by account_type


-- Q8. What is the average loan principal by loan type?
-- Show loan_type and average principal.
select loan_type,avg(principal)as average_loan from loans
group by loan_type


-- Q9. Which branch has the most staff?
-- Show branch name and staff count.
select branch_name,staff_count from branches
order by staff_count desc
limit 1

-- Q10. What is the total deposit amount vs total withdrawal amount?
-- Hint: Use CASE WHEN inside SUM
-- Show transaction_type and total_amount.
select
 sum(case when transaction_type="Deposit" then amount else 0 end) as total_deposit,
 sum(case when transaction_type="Withdrawal" then amount else 0 end) as total_withdrawal
from transactions

-- ============================================================
-- SECTION 3: JOINS
-- ============================================================

-- Q11. Show each customer's full name and their account balance.
-- Join customers and accounts tables.
select customers.full_name,balance from customers
inner join accounts on customers.customer_id = accounts.customer_id

-- Q12. Show all transactions with the customer full name.
-- Join transactions, accounts and customers tables.
-- Hint: transactions → accounts → customers (two joins)
select customers.full_name,transaction_id,transaction_type,balance from transactions
join accounts on transactions.account_id= accounts.account_id
join customers on accounts.customer_id= customers.customer_id

-- Q13. Show all customers who have a loan — include their
-- full name, loan type and principal amount.
select customers.full_name,loan_type,principal from loans
join customers on loans.customer_id= customers.customer_id

-- Q14. Show customers who have BOTH an account AND a loan.
-- Use INNER JOIN on both tables.
select customers.full_name,accounts.customer_id,accounts.account_type,loans.loan_type from accounts
inner join customers on accounts.customer_id= customers.customer_id
inner join loans on accounts.customer_id = loans.customer_id

-- Q15. Show ALL customers including those with no loans.
-- Use LEFT JOIN — customers with no loan show NULL.
select customers.full_name,loan_id,loan_type,principal,interest_rate from customers
left join loans on customers.customer_id= loans.customer_id


-- ============================================================
-- SECTION 4: FILTERING & SORTING
-- ============================================================

-- Q16. Show all Active loans with interest rate above 12%.
-- Include customer_id, loan_type, principal, interest_rate.
select customer_id,loan_type,principal,interest_rate,status from loans
where status = "Active" and interest_rate> 12.00



-- Q17. Show all Completed transactions between
-- 2024-02-01 and 2024-03-31.
-- Use BETWEEN for the date range.
select transaction_type,amount,transaction_date,status from transactions
where transaction_date between '2024-02-01' and '2024-03-31' and status in ("Completed")


-- Q18. Show all customers whose name contains 'wa' (case insensitive).
-- Use LIKE.
select full_name,email from customers
where full_name like '%wa%'


-- Q19. Show accounts in Nairobi branches only.
-- Branch names containing 'Nairobi'.
select branch_id,branch_name,city,manager from branches
where branch_name like '%nairobi%'


-- Q20. Show the 3 largest transactions by amount.
select transaction_id,amount from transactions 
order by amount desc
limit 3


-- ============================================================
-- SECTION 5: GROUP BY & HAVING
-- ============================================================

-- Q21. Show total transaction amount per account.
-- Only show accounts with total transactions above 100,000.
select account_id,
 sum(amount) as total_transaction 
from transactions
group by account_id
having total_transaction > 100000


-- Q22. Show number of loans per customer.
-- Only show customers with more than 1 loan.
select customer_id, count(*) as number_of_loans
from loans
group by customer_id
having count(*) > 1;


-- Q23. Show average balance per city using customers and accounts.
-- Join the two tables first, then group by city.
select avg(accounts.balance) as average_balance,customers.city 
from accounts
join customers on accounts.customer_id= customers.customer_id
group by city

-- Q24. Show total deposits per month.
-- Group by month using MONTH(transaction_date).
-- Only show Completed deposits.
select MONTH(transaction_date) as month,sum(amount)as total_deposits
from transactions
where transaction_type = "Deposit"
 and status= "Completed"
group by MONTH(transaction_date)


-- Q25. Show branches with more than 25 staff.
select branch_name,staff_count from branches
having staff_count>25


-- ============================================================
-- SECTION 6: CTE QUIZ (Master CTEs)
-- ============================================================

-- CTE Q1 — BASIC CTE
-- Write a CTE called 'high_balance' that selects all accounts
-- with balance above 200,000. Then query it to show only Active accounts.
with high_balance as (
    select account_id,account_type,STATUS
    from accounts
    where status= "Active"
)
select account_id,status
from high_balance
-- CTE Q2 — CTE WITH AGGREGATION
-- Write a CTE called 'customer_totals' that calculates
-- total transaction amount per customer (join transactions and accounts).
-- Then query it to show only customers with total above 500,000.
WITH customer_totals AS (
  SELECT
    accounts.customer_id,
    SUM(transactions.amount) AS total_amount
  FROM transactions
  JOIN accounts ON transactions.account_id = accounts.account_id
  GROUP BY accounts.customer_id
)
SELECT
  customer_id,
  total_amount
FROM customer_totals
WHERE total_amount > 500000;

-- CTE Q3 — MULTIPLE CTEs
-- Write TWO CTEs:
-- 1. 'active_loans' — all Active loans
-- 2. 'big_loans' — loans with principal above 1,000,000
-- Then find loans that appear in BOTH CTEs.
-- Hint: Join the two CTEs together.
WITH active_loans AS (
  SELECT loan_id, customer_id, status
  FROM loans
  WHERE status = "Active"
),
big_loans AS (
  SELECT loan_id, customer_id, principal
  FROM loans
  WHERE principal > 1000000
)
SELECT active_loans.loan_id, active_loans.customer_id, active_loans.status, big_loans.principal
FROM active_loans
JOIN big_loans ON active_loans.loan_id = big_loans.loan_id;


-- CTE Q4 — CTE FOR RANKING
-- Write a CTE that calculates total balance per city.
-- Then rank cities by total balance highest to lowest.
-- Hint: Use the CTE result with ORDER BY.
with city_balance as(
    select sum(accounts.balance) as total_balance,customers.city
    from accounts
    join customers on accounts.customer_id= customers.customer_id
    group by customers.city
)
select city,rank() over (order by total_balance)
from city_balance

-- CTE Q5 — REAL WORLD SCENARIO
-- The risk team wants to flag customers whose loan principal
-- is MORE THAN 3X their account balance — these are high risk customers.
-- Write a CTE that:
-- 1. Joins customers, accounts and loans
-- 2. Calculates loan_to_balance ratio (principal / balance)
-- 3. Flags customers where ratio > 3 as 'High Risk'
-- Show customer name, balance, principal and risk flag.
WITH high_risk AS (
  SELECT
    customers.customer_id,
    customers.full_name,
    SUM(accounts.balance) AS total_balance,
    SUM(loans.principal) AS total_principal
  FROM customers
  JOIN accounts ON customers.customer_id = accounts.customer_id
  JOIN loans ON customers.customer_id = loans.customer_id
  GROUP BY customers.customer_id, customers.full_name
)
SELECT
  full_name,
  total_balance,
  total_principal,
  (total_principal / total_balance) AS loan_to_balance_ratio,
  CASE WHEN (total_principal / total_balance) > 3 THEN 'High Risk' ELSE 'Low Risk' END AS risk_flag
FROM high_risk

-- ============================================================
-- SECTION 7: WINDOW FUNCTIONS
-- ============================================================

-- Q26. Show each transaction with a running total of amounts
-- ordered by transaction_date.
select transaction_id,
 transaction_date,
 sum(amount) over(order by transaction_date) as running_total
 from transactions;

-- Q27. Rank customers by their account balance highest to lowest.
-- Show customer name, balance and rank.
SELECT customers.full_name, accounts.balance,
RANK() OVER (ORDER BY balance DESC) as rank
FROM customers
JOIN accounts ON customers.customer_id = accounts.customer_id;


-- Q28. Show each account's balance and the difference
-- from the average balance across all accounts.
-- Hint: balance - AVG(balance) OVER()
SELECT account_id, balance, balance - AVG(balance) OVER() AS difference_from_avg
FROM accounts;


-- Q29. For each account show the transaction amount
-- and the previous transaction amount.
-- Hint: LAG(amount) OVER (PARTITION BY account_id ORDER BY transaction_date)
select account_id,amount,
lag(amount) over (partition by account_id order by transaction_date)
from transactions
-- Q30. Show each branch's staff count and what percentage
-- of total staff they represent.
-- Hint: staff_count / SUM(staff_count) OVER() * 100
SELECT branch_name, staff_count, staff_count/SUM(staff_count) OVER() * 100 AS percentage
FROM branches;

-- ============================================================
-- SECTION 8: ADVANCED SCENARIOS
-- ============================================================

-- Q31. FRAUD DETECTION
-- Find accounts with more than 2 transactions in a single day.
-- Show account_id, transaction_date and transaction count.


-- Q32. DORMANT ACCOUNTS
-- Find accounts with no transactions after 2024-02-01.
-- Use LEFT JOIN and IS NULL.


-- Q33. LOAN DEFAULT RISK
-- Find customers where their total loan principal
-- exceeds their account balance.
-- Show customer name, total loans, balance and difference.


-- Q34. BRANCH PERFORMANCE
-- Show each branch with:
-- - Number of accounts
-- - Total balance
-- - Average balance
-- Join accounts and branches tables.


-- Q35. CUSTOMER 360 VIEW
-- For each customer show:
-- - Full name and city
-- - Account balance
-- - Total loans
-- - Total transactions
-- This requires joining ALL 4 tables.
-- ============================================================
-- END OF QUESTIONS
-- ============================================================
