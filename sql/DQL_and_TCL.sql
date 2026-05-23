-- ============================================================================
-- FILE 3: Database DQL & TCL (Advanced Analytics & Transactions)
-- DESCRIPTION: Business Intelligence queries, Performance Tuning, and ACID tests.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PART A: Business Intelligence Demonstration (12 Complex Queries)
-- ----------------------------------------------------------------------------

-- 1. Revenue Aggregation by Subscription Plan (Fulfilling FR6)
SELECT sp.name AS plan_name, COUNT(i.invoice_id) AS total_transactions, SUM(i.amount) AS total_revenue
FROM Subscription_Plans sp
JOIN Subscriptions s ON sp.plan_id = s.plan_id
JOIN Invoices i ON s.subscription_id = i.subscription_id
WHERE i.status = 'Paid'
GROUP BY sp.name
ORDER BY total_revenue DESC;

-- 2. High-Frequency Telemetry Ingestion (Fulfilling FR2)
SELECT m.title, SUM(wh.duration_watched) AS total_minutes_watched, COUNT(wh.history_id) AS total_play_sessions
FROM Movies m
JOIN Watch_Histories wh ON m.movie_id = wh.movie_id
GROUP BY m.title
ORDER BY total_minutes_watched DESC
LIMIT 5;

-- 3. Multidimensional JSONB Metadata Search (Fulfilling FR1)
SELECT title, release_year, metadata_jsonb->>'director' AS director
FROM Movies
WHERE metadata_jsonb->>'resolution' = '4K' 
  AND metadata_jsonb->>'director' IS NOT NULL;

-- 4. Recursive Viral Growth Tracking (Validating Self-Referencing FK / FR7)
SELECT referrer.email AS referrer_email, COUNT(new_user.user_id) AS successful_invites
FROM Users referrer
JOIN Users new_user ON referrer.user_id = new_user.referred_by_id
GROUP BY referrer.email
HAVING COUNT(new_user.user_id) > 1
ORDER BY successful_invites DESC;

-- 5. Dynamic Public Watchlist Curation (Fulfilling FR3)
SELECT m.title, COUNT(wi.movie_id) AS times_listed
FROM Movies m
JOIN Watchlist_Items wi ON m.movie_id = wi.movie_id
JOIN Watchlists w ON wi.watchlist_id = w.watchlist_id
WHERE w.is_public = TRUE
GROUP BY m.title
ORDER BY times_listed DESC
LIMIT 10;

-- 6. Fraud Detection & Delinquency Audit (Financial Security)
SELECT u.email, s.subscription_id, i.status AS payment_status, i.amount
FROM Users u
JOIN Subscriptions s ON u.user_id = s.user_id
JOIN Invoices i ON s.subscription_id = i.subscription_id
WHERE s.is_active = TRUE AND i.status = 'Failed';

-- 7. Cross-Genre Analytical Filtering (Complex M:N Resolution)
SELECT m.title, ROUND(AVG(r.rating), 2) AS avg_rating
FROM Movies m
JOIN Movie_Genre_Relations mgr ON m.movie_id = mgr.movie_id
JOIN Genres g ON mgr.genre_id = g.genre_id
JOIN Reviews r ON m.movie_id = r.movie_id
WHERE g.name IN ('Sci-Fi', 'Action')
GROUP BY m.title
HAVING COUNT(DISTINCT g.name) = 2;

-- 8. Geographic FinTech Demographics (Fulfilling FR5)
SELECT billing_country, payment_type, COUNT(payment_id) AS usage_count
FROM Payment_Methods
GROUP BY billing_country, payment_type
ORDER BY billing_country, usage_count DESC;

-- 9. Review Bombing Protection Audit (Ethical Constraint Check)
SELECT r.review_id, r.rating, u.email, s.is_active
FROM Reviews r
JOIN Users u ON r.user_id = u.user_id
JOIN Subscriptions s ON u.user_id = s.user_id
WHERE s.is_active = FALSE; 

-- 10. Churn Risk Analytics (Temporal Data Evaluation)
SELECT u.email, sp.name AS plan, s.valid_until
FROM Users u
JOIN Subscriptions s ON u.user_id = s.user_id
JOIN Subscription_Plans sp ON s.plan_id = sp.plan_id
WHERE s.is_active = TRUE 
  AND s.valid_until BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days';

-- 11. User Engagement Retention Metrics
SELECT u.email, m.title, COUNT(wh.history_id) AS replay_count
FROM Watch_Histories wh
JOIN Users u ON wh.user_id = u.user_id
JOIN Movies m ON wh.movie_id = m.movie_id
GROUP BY u.email, m.title
HAVING COUNT(wh.history_id) > 3;

-- 12. The "Power User" Composite Metric (Ultimate BI Query)
SELECT u.email, sp.name AS tier, SUM(wh.duration_watched) AS total_minutes, COUNT(DISTINCT r.review_id) AS review_count
FROM Users u
JOIN Subscriptions s ON u.user_id = s.user_id
JOIN Subscription_Plans sp ON s.plan_id = sp.plan_id
JOIN Watch_Histories wh ON u.user_id = wh.user_id
JOIN Reviews r ON u.user_id = r.user_id
WHERE sp.name = 'Premium 4K HDR' AND s.is_active = TRUE
GROUP BY u.email, sp.name
HAVING SUM(wh.duration_watched) > 1000 AND COUNT(DISTINCT r.review_id) >= 2
ORDER BY total_minutes DESC;


-- ----------------------------------------------------------------------------
-- PART B: Query Performance Tuning (Indexing Strategy)
-- ----------------------------------------------------------------------------

-- Pre-Optimization EXPLAIN ANALYZE run:
-- EXPLAIN ANALYZE SELECT title FROM Movies WHERE metadata_jsonb @> '{"resolution": "4K"}';

-- Deploying the GIN Index for JSONB payload acceleration
CREATE INDEX idx_movies_metadata_gin ON Movies USING GIN (metadata_jsonb);

-- Post-Optimization EXPLAIN ANALYZE run:
-- EXPLAIN ANALYZE SELECT title FROM Movies WHERE metadata_jsonb @> '{"resolution": "4K"}';


-- ----------------------------------------------------------------------------
-- PART C: ACID Transaction & Rollback Simulation (TCL)
-- ----------------------------------------------------------------------------

BEGIN; -- 1. Initiate ACID Transaction boundary

-- 2. Optimistically update the subscription status using dynamic subqueries
UPDATE Subscriptions 
SET is_active = TRUE, valid_until = CURRENT_DATE + INTERVAL '1 month'
WHERE subscription_id = (SELECT subscription_id FROM Subscriptions LIMIT 1);

-- 3. Attempt to generate an invoice with an INTENTIONALLY INVALID payment UUID
-- This will trigger SQL State 23503 (Foreign Key Constraint Violation)
INSERT INTO Invoices (invoice_id, subscription_id, payment_id, amount, status)
VALUES (
    gen_random_uuid(), 
    (SELECT subscription_id FROM Subscriptions LIMIT 1), 
    '00000000-0000-0000-0000-000000000000', 
    15.99, 
    'Paid'
);

-- 4. Transaction Aborts & Rolls Back
-- Because of the error in step 3, the status update in step 2 is entirely reverted.
ROLLBACK;