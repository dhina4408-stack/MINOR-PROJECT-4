-- BingePlay Week 4 Advanced SQL Minor Project
-- MySQL 8.0+ | Run after loading Advanced SQL Data set for MP 4.sql
-- Results in the accompanying PDF were computed from the supplied dataset.

USE bingeplay;

-- Q1 — Active revenue
SELECT COUNT(*) AS active_subscriptions,
       SUM(monthly_price_inr) AS monthly_revenue_inr
FROM subscriptions
WHERE status = 'active'
  AND start_date <= '2024-06-30'
  AND (end_date IS NULL OR end_date > '2024-06-30');

-- Q2 — Signup momentum
WITH RECURSIVE months AS (
    SELECT 1 AS month_no
    UNION ALL SELECT month_no + 1 FROM months WHERE month_no < 6
)
SELECT month_no,
       MONTHNAME(STR_TO_DATE(CONCAT('2024-', LPAD(month_no, 2, '0'), '-01'), '%Y-%m-%d')) AS month_name,
       COUNT(u.user_id) AS signup_count
FROM months m
LEFT JOIN users u
  ON YEAR(u.signup_date) = 2024 AND MONTH(u.signup_date) = m.month_no
GROUP BY month_no
ORDER BY month_no;

-- Q3 — Device analytics
SELECT device_type,
       COUNT(*) AS total_sessions,
       SUM(watch_minutes) AS total_watch_minutes,
       ROUND(AVG(watch_minutes), 2) AS avg_watch_minutes,
       ROUND(100.0 * SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct
FROM watch_sessions
WHERE user_id IS NOT NULL
GROUP BY device_type
ORDER BY device_type;

-- Q4 — Rating distribution
SELECT stars,
       COUNT(*) AS rating_count,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM ratings), 2) AS rating_pct
FROM ratings
GROUP BY stars
ORDER BY stars;

-- Combined share of 4- and 5-star ratings
SELECT ROUND(100.0 * SUM(CASE WHEN stars >= 4 THEN 1 ELSE 0 END) / COUNT(*), 2) AS four_or_five_star_pct
FROM ratings;

-- Q5 — Originals vs acquired
SELECT CASE WHEN is_original = 1 THEN 'BingePlay Originals' ELSE 'Acquired' END AS content_group,
       COUNT(*) AS show_count,
       ROUND(AVG(imdb_rating), 2) AS avg_imdb_rating,
       ROUND(AVG(release_year), 2) AS avg_release_year
FROM shows
GROUP BY is_original
ORDER BY is_original DESC;

-- Q6 — Binge day detection (Q2 2024)
WITH binge_days AS (
    SELECT user_id, show_id, session_date, COUNT(*) AS session_count
    FROM watch_sessions
    WHERE user_id IS NOT NULL
      AND session_date >= '2024-04-01' AND session_date < '2024-07-01'
    GROUP BY user_id, show_id, session_date
    HAVING COUNT(*) >= 5
), per_user AS (
    SELECT user_id, COUNT(*) AS binge_days
    FROM binge_days GROUP BY user_id
)
SELECT (SELECT COUNT(*) FROM binge_days) AS total_binge_days,
       (SELECT user_id FROM per_user ORDER BY binge_days DESC, user_id LIMIT 1) AS top_user_id,
       (SELECT binge_days FROM per_user ORDER BY binge_days DESC, user_id LIMIT 1) AS top_user_binge_days;

-- Q7 — Q1 signups who never watched (NULL-safe)
SELECT COUNT(*) AS q1_signups,
       SUM(CASE WHEN NOT EXISTS (
           SELECT 1 FROM watch_sessions ws WHERE ws.user_id = u.user_id
       ) THEN 1 ELSE 0 END) AS never_watched
FROM users u
WHERE u.signup_date >= '2024-01-01'
  AND u.signup_date < '2024-04-01';

-- Alternative: LEFT JOIN ... IS NULL. Avoid NOT IN because watch_sessions.user_id contains NULLs.
SELECT u.user_id
FROM users u
LEFT JOIN watch_sessions ws ON ws.user_id = u.user_id
WHERE u.signup_date >= '2024-01-01' AND u.signup_date < '2024-04-01'
  AND ws.session_id IS NULL;

-- Q8 — Premium/Family users watching Basic-only content
WITH current_subscriptions AS (
    SELECT s.*,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY start_date DESC, subscription_id DESC) AS rn
    FROM subscriptions s
    WHERE status = 'active'
      AND start_date <= '2024-06-30'
      AND (end_date IS NULL OR end_date > '2024-06-30')
)
SELECT COUNT(*) AS overpaying_premium_family_users
FROM current_subscriptions cs
WHERE cs.rn = 1
  AND cs.plan IN ('Premium', 'Family')
  AND EXISTS (SELECT 1 FROM watch_sessions ws WHERE ws.user_id = cs.user_id)
  AND NOT EXISTS (
      SELECT 1
      FROM watch_sessions ws JOIN shows sh ON sh.show_id = ws.show_id
      WHERE ws.user_id = cs.user_id
        AND sh.min_plan IN ('Premium', 'Family')
  );

-- Q9 — Upgrade success cohort
WITH ranked_subscriptions AS (
    SELECT s.*,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY start_date, subscription_id) AS rn
    FROM subscriptions s
), first_subscription AS (
    SELECT * FROM ranked_subscriptions WHERE rn = 1
), first_upgrade AS (
    SELECT s.user_id, MIN(s.start_date) AS first_upgrade_date
    FROM subscriptions s
    JOIN first_subscription f ON f.user_id = s.user_id
    WHERE s.start_date > f.start_date
      AND CASE s.plan WHEN 'Basic' THEN 1 WHEN 'Premium' THEN 2 WHEN 'Family' THEN 3 END
        > CASE f.plan WHEN 'Basic' THEN 1 WHEN 'Premium' THEN 2 WHEN 'Family' THEN 3 END
    GROUP BY s.user_id
), eligible AS (
    SELECT u.user_id, DATEDIFF(fu.first_upgrade_date, u.signup_date) AS days_to_upgrade
    FROM users u
    JOIN first_subscription f ON f.user_id = u.user_id AND f.plan = 'Basic'
    JOIN first_upgrade fu ON fu.user_id = u.user_id
    WHERE u.signup_date >= '2024-01-01' AND u.signup_date < '2024-02-01'
      AND EXISTS (
          SELECT 1 FROM subscriptions s
          WHERE s.user_id = u.user_id AND s.status = 'active'
            AND s.start_date <= '2024-06-30'
            AND (s.end_date IS NULL OR s.end_date > '2024-06-30')
      )
)
SELECT COUNT(*) AS upgraded_users,
       ROUND(AVG(days_to_upgrade), 2) AS avg_days_signup_to_first_upgrade
FROM eligible;

-- Q10 — Cliffhanger comebacks
WITH comeback_events AS (
    SELECT DISTINCT a.user_id, a.show_id, a.session_date AS incomplete_date
    FROM watch_sessions a
    JOIN watch_sessions b
      ON b.user_id = a.user_id
     AND b.show_id = a.show_id
     AND b.session_date BETWEEN DATE_ADD(a.session_date, INTERVAL 1 DAY)
                            AND DATE_ADD(a.session_date, INTERVAL 7 DAY)
    WHERE a.user_id IS NOT NULL AND a.completed = 0
), per_show AS (
    SELECT show_id, COUNT(*) AS comeback_count
    FROM comeback_events GROUP BY show_id
), ranked_shows AS (
    SELECT ps.*, ROW_NUMBER() OVER (ORDER BY comeback_count DESC, show_id) AS rn
    FROM per_show ps
)
SELECT (SELECT COUNT(*) FROM comeback_events) AS total_comeback_events,
       rs.show_id, sh.title, rs.comeback_count
FROM ranked_shows rs JOIN shows sh ON sh.show_id = rs.show_id
WHERE rs.rn = 1;

-- Q11 — Consecutive-week engagement (ISO weeks)
WITH active_weeks AS (
    SELECT DISTINCT user_id,
           DATE_SUB(session_date, INTERVAL WEEKDAY(session_date) DAY) AS week_start
    FROM watch_sessions
    WHERE user_id IS NOT NULL
), numbered AS (
    SELECT user_id, week_start,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY week_start) AS rn
    FROM active_weeks
), islands AS (
    SELECT user_id, COUNT(*) AS streak_weeks
    FROM numbered
    GROUP BY user_id, TO_DAYS(week_start) - 7 * rn
), user_streaks AS (
    SELECT user_id, MAX(streak_weeks) AS longest_streak
    FROM islands GROUP BY user_id
)
SELECT SUM(CASE WHEN longest_streak >= 4 THEN 1 ELSE 0 END) AS users_with_4plus_weeks,
       MAX(longest_streak) AS longest_streak_weeks,
       SUBSTRING_INDEX(GROUP_CONCAT(CASE WHEN longest_streak = (SELECT MAX(longest_streak) FROM user_streaks) THEN user_id END ORDER BY user_id), ',', 1) AS example_user_id
FROM user_streaks;

-- Q12 — Churn signal detection
WITH monthly_watch AS (
    SELECT user_id,
           SUM(CASE WHEN session_date >= '2024-05-01' AND session_date < '2024-06-01' THEN watch_minutes ELSE 0 END) AS may_minutes,
           SUM(CASE WHEN session_date >= '2024-06-01' AND session_date < '2024-07-01' THEN watch_minutes ELSE 0 END) AS june_minutes
    FROM watch_sessions
    WHERE user_id IS NOT NULL
      AND session_date >= '2024-05-01' AND session_date < '2024-07-01'
    GROUP BY user_id
), churn_signals AS (
    SELECT mw.user_id, u.name, mw.may_minutes, mw.june_minutes,
           ROUND(100.0 * (mw.may_minutes - mw.june_minutes) / mw.may_minutes, 2) AS drop_pct
    FROM monthly_watch mw JOIN users u ON u.user_id = mw.user_id
    WHERE mw.may_minutes > 0
      AND mw.june_minutes <= mw.may_minutes * 0.50
)
SELECT * FROM churn_signals ORDER BY drop_pct DESC, user_id;

-- Total count
WITH monthly_watch AS (
    SELECT user_id,
           SUM(CASE WHEN session_date >= '2024-05-01' AND session_date < '2024-06-01' THEN watch_minutes ELSE 0 END) AS may_minutes,
           SUM(CASE WHEN session_date >= '2024-06-01' AND session_date < '2024-07-01' THEN watch_minutes ELSE 0 END) AS june_minutes
    FROM watch_sessions
    WHERE user_id IS NOT NULL AND session_date >= '2024-05-01' AND session_date < '2024-07-01'
    GROUP BY user_id
)
SELECT COUNT(*) AS churn_signal_users
FROM monthly_watch
WHERE may_minutes > 0 AND june_minutes <= may_minutes * 0.50;

