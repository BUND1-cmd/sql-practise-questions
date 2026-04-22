-- ============================================================
-- CO-OPERATIVE BANK KENYA
-- LOAN PORTFOLIO ANALYSIS - SQL QUERIES
-- ============================================================
-- These queries power the Excel Dashboard
-- Run each query, export results to Excel
-- ============================================================

USE coopbank;

-- ============================================================
-- QUERY 1: PORTFOLIO SUMMARY (KPI Cards)
-- ============================================================
SELECT
    COUNT(*) as total_loans,
    SUM(principal) as total_portfolio_value,
    AVG(principal) as average_loan_size,
    SUM(CASE WHEN status = 'Active' THEN principal ELSE 0 END) as active_portfolio,
    SUM(CASE WHEN status = 'Defaulted' THEN principal ELSE 0 END) as defaulted_portfolio,
    SUM(CASE WHEN status = 'Closed' THEN principal ELSE 0 END) as closed_portfolio,
    ROUND(SUM(CASE WHEN status = 'Defaulted' THEN principal ELSE 0 END) /
    SUM(principal) * 100, 2) as default_rate_percentage
FROM loans;

-- ============================================================
-- QUERY 2: LOANS BY TYPE
-- ============================================================
SELECT
    loan_type,
    COUNT(*) as number_of_loans,
    SUM(principal) as total_value,
    AVG(principal) as average_value,
    AVG(interest_rate) as avg_interest_rate,
    SUM(CASE WHEN status = 'Defaulted' THEN 1 ELSE 0 END) as defaults
FROM loans
GROUP BY loan_type
ORDER BY total_value DESC;

-- ============================================================
-- QUERY 3: BRANCH PERFORMANCE
-- ============================================================
SELECT
    b.branch_name,
    b.city,
    b.region,
    COUNT(l.loan_id) as total_loans,
    SUM(l.principal) as total_disbursed,
    AVG(l.principal) as avg_loan_size,
    SUM(CASE WHEN l.status = 'Active' THEN l.principal ELSE 0 END) as active_loans,
    SUM(CASE WHEN l.status = 'Defaulted' THEN l.principal ELSE 0 END) as defaulted_loans,
    ROUND(SUM(CASE WHEN l.status = 'Defaulted' THEN 1 ELSE 0 END) /
    COUNT(*) * 100, 2) as default_rate
FROM branches b
LEFT JOIN loans l ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.branch_name, b.city, b.region
ORDER BY total_disbursed DESC;

-- ============================================================
-- QUERY 4: CUSTOMER LOAN PORTFOLIO
-- ============================================================
SELECT
    c.full_name,
    c.occupation,
    c.city,
    c.monthly_income,
    c.credit_score,
    COUNT(l.loan_id) as number_of_loans,
    SUM(l.principal) as total_borrowed,
    SUM(l.monthly_payment) as total_monthly_obligation,
    ROUND(SUM(l.monthly_payment) / c.monthly_income * 100, 2) as debt_to_income_ratio,
    CASE
        WHEN ROUND(SUM(l.monthly_payment) / c.monthly_income * 100, 2) > 50 THEN 'High Risk'
        WHEN ROUND(SUM(l.monthly_payment) / c.monthly_income * 100, 2) > 30 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as risk_category
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.full_name, c.occupation, c.city,
         c.monthly_income, c.credit_score
ORDER BY debt_to_income_ratio DESC;

-- ============================================================
-- QUERY 5: MONTHLY DISBURSEMENT TREND
-- ============================================================
SELECT
    DATE_FORMAT(disbursement_date, '%Y-%m') as month,
    COUNT(*) as loans_disbursed,
    SUM(principal) as total_disbursed,
    AVG(principal) as avg_loan_size
FROM loans
GROUP BY DATE_FORMAT(disbursement_date, '%Y-%m')
ORDER BY month;

-- ============================================================
-- QUERY 6: DEFAULT ANALYSIS
-- ============================================================
SELECT
    l.loan_id,
    c.full_name,
    c.city,
    c.credit_score,
    l.loan_type,
    l.principal,
    l.interest_rate,
    l.disbursement_date,
    l.status,
    COUNT(CASE WHEN r.status = 'Missed' THEN 1 END) as missed_payments,
    SUM(CASE WHEN r.status = 'Completed' THEN r.amount_paid ELSE 0 END) as total_paid
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
LEFT JOIN repayments r ON l.loan_id = r.loan_id
GROUP BY l.loan_id, c.full_name, c.city, c.credit_score,
         l.loan_type, l.principal, l.interest_rate,
         l.disbursement_date, l.status
ORDER BY missed_payments DESC;

-- ============================================================
-- QUERY 7: INTEREST INCOME ANALYSIS
-- ============================================================
SELECT
    loan_type,
    SUM(principal) as total_principal,
    AVG(interest_rate) as avg_rate,
    SUM(principal * interest_rate / 100) as annual_interest_income,
    SUM(principal * interest_rate / 100 * tenure_months / 12) as total_interest_income
FROM loans
WHERE status = 'Active'
GROUP BY loan_type
ORDER BY total_interest_income DESC;

-- ============================================================
-- QUERY 8: REPAYMENT PERFORMANCE
-- ============================================================
SELECT
    l.loan_type,
    COUNT(DISTINCT l.loan_id) as total_loans,
    SUM(CASE WHEN r.status = 'Completed' THEN r.amount_paid ELSE 0 END) as total_collected,
    COUNT(CASE WHEN r.status = 'Missed' THEN 1 END) as missed_payments,
    COUNT(CASE WHEN r.status = 'Completed' THEN 1 END) as completed_payments,
    ROUND(COUNT(CASE WHEN r.status = 'Completed' THEN 1 END) /
    COUNT(*) * 100, 2) as repayment_rate
FROM loans l
JOIN repayments r ON l.loan_id = r.loan_id
GROUP BY l.loan_type
ORDER BY repayment_rate DESC;

-- ============================================================
-- QUERY 9: HIGH RISK CUSTOMERS (CTE)
-- ============================================================
WITH customer_risk AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.monthly_income,
        c.credit_score,
        SUM(l.monthly_payment) as total_monthly_obligations,
        SUM(l.principal) as total_borrowed,
        ROUND(SUM(l.monthly_payment) / c.monthly_income * 100, 2) as dti_ratio
    FROM customers c
    JOIN loans l ON c.customer_id = l.customer_id
    WHERE l.status = 'Active'
    GROUP BY c.customer_id, c.full_name, c.monthly_income, c.credit_score
)
SELECT
    full_name,
    monthly_income,
    credit_score,
    total_monthly_obligations,
    total_borrowed,
    dti_ratio,
    CASE
        WHEN dti_ratio > 50 OR credit_score < 650 THEN 'HIGH RISK'
        WHEN dti_ratio > 30 OR credit_score < 700 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END as risk_flag
FROM customer_risk
ORDER BY dti_ratio DESC;

-- ============================================================
-- QUERY 10: PORTFOLIO AGING (CTE)
-- ============================================================
WITH loan_age AS (
    SELECT
        loan_id,
        loan_type,
        principal,
        status,
        disbursement_date,
        TIMESTAMPDIFF(MONTH, disbursement_date, CURDATE()) as months_since_disbursement
    FROM loans
)
SELECT
    CASE
        WHEN months_since_disbursement <= 12 THEN '0-12 Months'
        WHEN months_since_disbursement <= 24 THEN '13-24 Months'
        WHEN months_since_disbursement <= 36 THEN '25-36 Months'
        ELSE 'Over 36 Months'
    END as age_bucket,
    COUNT(*) as number_of_loans,
    SUM(principal) as total_value,
    SUM(CASE WHEN status = 'Defaulted' THEN 1 ELSE 0 END) as defaults
FROM loan_age
GROUP BY age_bucket
ORDER BY age_bucket;

