# MINOR-PROJECT-4
Advanced SQL project analyzing streaming platform data to answer 12 business questions related to subscriptions, revenue, user engagement, content performance, binge behaviour, upgrades, and churn.
# BingePlay – Streaming Analytics Project

## Project Overview

BingePlay is a fictional Indian OTT streaming platform. This project focuses on analyzing streaming platform data using **Advanced SQL and MySQL** to answer 12 real-world business questions.

The project covers subscription revenue, user signups, viewing behaviour, content ratings, binge-watching patterns, subscription upgrades, user engagement, and churn signals.

**Project:** Week 4 – Advanced SQL Minor Project  
**Track:** Data Analytics & Data Science  
**Platform:** MySQL  
**Organization:** The Unlox Academy

## Business Scenario

BingePlay launched in India on 1 January 2024 with three subscription plans:

| Plan | Monthly Price |
|---|---:|
| Basic | ₹199 |
| Premium | ₹399 |
| Family | ₹699 |

The objective is to analyze user and streaming activity to help the product team make better business decisions.

## Dataset Overview

The project database contains five tables:

| Table | Rows | Description |
|---|---:|---|
| users | 3,000 | User profiles and signup information |
| subscriptions | 4,497 | Subscription history and plan details |
| shows | 100 | Streaming content information |
| watch_sessions | 100,351 | User viewing activity |
| ratings | 5,000 | User ratings for shows |

**Important data-quality detail:** The `watch_sessions` table contains 2 records with a NULL `user_id`. This is important when writing queries involving `NOT IN`, `NOT EXISTS`, and joins.

## Project Questions and Analysis

The project contains 12 business questions divided into three tiers.

### Tier 1 – SQL Foundations

1. **Active Revenue:** Calculate active subscriptions and monthly recurring revenue as of 30 June 2024.
2. **Signup Momentum:** Analyze monthly user signups and identify the month with the highest signups.
3. **Device Analytics:** Compare sessions, watch time, average watch time, and completion rates by device.
4. **Rating Distribution:** Analyze the distribution of ratings and the percentage of 4- and 5-star ratings.
5. **Originals vs Acquired Content:** Compare the number of shows, average IMDb ratings, and release years.

### Tier 2 – Joins and Subqueries

6. **Binge Day Detection:** Identify users who watched the same show at least five times on one day during Q2 2024.
7. **Q1 Signups Who Never Watched:** Identify first-quarter signups who never watched a session, handling NULL values correctly.
8. **Over-paying Premium/Family Users:** Find Premium or Family subscribers whose entire viewing history consists of Basic-tier content.
9. **Upgrade Success Cohort:** Identify January signups who started on Basic, upgraded to Premium or Family, and remained active.
10. **Cliffhanger Comebacks:** Find incomplete viewing sessions followed by another session of the same show within 1–7 days.

### Tier 3 – Advanced SQL

11. **Consecutive-week Engagement:** Identify users with viewing activity in at least four consecutive ISO calendar weeks using gaps-and-islands logic.
12. **Churn Signal Detection:** Identify users whose June watch time decreased by at least 50% compared with May.

## SQL Concepts Used

- SELECT, WHERE, GROUP BY, ORDER BY
- Aggregate functions: COUNT, SUM, AVG
- INNER JOIN and LEFT JOIN
- Subqueries and correlated subqueries
- NOT EXISTS and NULL handling
- CASE statements
- Date and time functions
- Common Table Expressions (CTEs)
- Self joins
- Window functions: ROW_NUMBER() and LAG()
- Gaps-and-islands technique
- Conditional aggregation

## Repository Structure

```text
BingePlay-Streaming-Analytics/
│
├── README.md
│
├── sql/
│   └── BingePlay_Advanced_SQL_Solutions.sql
│
├── report/
│   └── BingePlay_Completed_Project.pdf
│
├── data/
│   └── README.md
│
└── .gitignore
```

The original database setup script should be added as `sql/bingeplay_setup.sql` if you are permitted to redistribute it.

## Tools and Technologies

- MySQL
- MySQL Workbench
- SQL
- Git
- GitHub

## How to Run the Project

1. Install MySQL and open MySQL Workbench.
2. Obtain the BingePlay database setup SQL file from the project materials.
3. Execute the setup script to create and populate the `bingeplay` database.
4. Open the advanced SQL solutions file.
5. Select the `bingeplay` database.
6. Execute the queries individually.
7. Review the query outputs and compare them with your project report.

```sql
USE bingeplay;
SHOW TABLES;
```

## Key Learning Outcomes

- Working with multiple related database tables.
- Writing SQL queries to solve business problems.
- Analyzing user engagement and subscription behaviour.
- Handling NULL values and avoiding common SQL pitfalls.
- Using joins, subqueries, CTEs, and window functions.
- Applying advanced SQL techniques to product analytics.

## Project Disclaimer

BingePlay is a fictional streaming platform created for educational purposes. The dataset is provided as part of an academic project.

The dataset is not included in this repository. Please use the authorized project materials to obtain it, and do not redistribute the dataset without permission.

## Author

**Your Name**

Data Analytics & Data Science Learner

GitHub: [Add your GitHub profile link here]
