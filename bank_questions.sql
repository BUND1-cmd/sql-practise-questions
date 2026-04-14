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


-- Q7. How many accounts does each account type have?
-- Show account_type and count.


-- Q8. What is the average loan principal by loan type?
-- Show loan_type and average principal.


-- Q9. Which branch has the most staff?
-- Show branch name and staff count.


-- Q10. What is the total deposit amount vs total withdrawal amount?
-- Hint: Use CASE WHEN inside SUM
-- Show transaction_type and total_amount.


-- ============================================================
-- SECTION 3: JOINS
-- ============================================================

-- Q11. Show each customer's full name and their account balance.
-- Join customers and accounts tables.


-- Q12. Show all transactions with the customer full name.
-- Join transactions, accounts and customers tables.
-- Hint: transactions → accounts → customers (two joins)


-- Q13. Show all customers who have a loan — include their
-- full name, loan type and principal amount.


-- Q14. Show customers who have BOTH an account AND a loan.
-- Use INNER JOIN on both tables.


-- Q15. Show ALL customers including those with no loans.
-- Use LEFT JOIN — customers with no loan show NULL.


-- ============================================================
-- SECTION 4: FILTERING & SORTING
-- ============================================================

-- Q16. Show all Active loans with interest rate above 12%.
-- Include customer_id, loan_type, principal, interest_rate.


-- Q17. Show all Completed transactions between
-- 2024-02-01 and 2024-03-31.
-- Use BETWEEN for the date range.


-- Q18. Show all customers whose name contains 'wa' (case insensitive).
-- Use LIKE.


-- Q19. Show accounts in Nairobi branches only.
-- Branch names containing 'Nairobi'.


-- Q20. Show the 3 largest transactions by amount.


-- ============================================================
-- SECTION 5: GROUP BY & HAVING
-- ============================================================

-- Q21. Show total transaction amount per account.
-- Only show accounts with total transactions above 100,000.


-- Q22. Show number of loans per customer.
-- Only show customers with more than 1 loan.


-- Q23. Show average balance per city using customers and accounts.
-- Join the two tables first, then group by city.


-- Q24. Show total deposits per month.
-- Group by month using MONTH(transaction_date).
-- Only show Completed deposits.


-- Q25. Show branches with more than 25 staff.


-- ============================================================
-- SECTION 6: CTE QUIZ (Master CTEs)
-- ============================================================

-- CTE Q1 — BASIC CTE
-- Write a CTE called 'high_balance' that selects all accounts
-- with balance above 200,000. Then query it to show only Active accounts.


-- CTE Q2 — CTE WITH AGGREGATION
-- Write a CTE called 'customer_totals' that calculates
-- total transaction amount per customer (join transactions and accounts).
-- Then query it to show only customers with total above 500,000.


-- CTE Q3 — MULTIPLE CTEs
-- Write TWO CTEs:
-- 1. 'active_loans' — all Active loans
-- 2. 'big_loans' — loans with principal above 1,000,000
-- Then find loans that appear in BOTH CTEs.
-- Hint: Join the two CTEs together.


-- CTE Q4 — CTE FOR RANKING
-- Write a CTE that calculates total balance per city.
-- Then rank cities by total balance highest to lowest.
-- Hint: Use the CTE result with ORDER BY.


-- CTE Q5 — REAL WORLD SCENARIO
-- The risk team wants to flag customers whose loan principal
-- is MORE THAN 3X their account balance — these are high risk customers.
-- Write a CTE that:
-- 1. Joins customers, accounts and loans
-- 2. Calculates loan_to_balance ratio (principal / balance)
-- 3. Flags customers where ratio > 3 as 'High Risk'
-- Show customer name, balance, principal and risk flag.


-- ============================================================
-- SECTION 7: WINDOW FUNCTIONS
-- ============================================================

-- Q26. Show each transaction with a running total of amounts
-- ordered by transaction_date.


-- Q27. Rank customers by their account balance highest to lowest.
-- Show customer name, balance and rank.


-- Q28. Show each account's balance and the difference
-- from the average balance across all accounts.
-- Hint: balance - AVG(balance) OVER()


-- Q29. For each account show the transaction amount
-- and the previous transaction amount.
-- Hint: LAG(amount) OVER (PARTITION BY account_id ORDER BY transaction_date)


-- Q30. Show each branch's staff count and what percentage
-- of total staff they represent.
-- Hint: staff_count / SUM(staff_count) OVER() * 100


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
