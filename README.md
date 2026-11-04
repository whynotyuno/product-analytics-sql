# Product Analytics SQL Project

A comprehensive data analytics project demonstrating practical SQL capabilities (SQLite) applied to user behavioral logs and product metrics extraction.

## Project Overview
This repository contains an end-to-end analytical pipeline that processes a synthetic event log mimicking a real-world marketplace platform. The pipeline simulates typical product management inquiries: tracking user growth, building conversion funnels, calculating rolling retention cohort matrices, assessing data pipeline health, and engineering data marts.

## Database Schema
The pipeline operates on `events.db`, which consists of two transactional tables and a customized virtual data mart:
- **`users`**: Customer registry mapping each user to their registration timestamp and device platform (`ios`, `android`, `web`).
- **`events`**: Behavioral clickstream tracking user interactions (`app_open`, `search`, `view_ad`, `favorite`, `contact_seller`).

---

## Executive Insights & Product Findings

Based on the execution of the analytical suite, the following operational and product insights were discovered:

### 1. The Conversion Funnel Bottleneck (`02_funnel.sql`)
- **The Core Problem:** The platform has excellent top-of-funnel engagement but a severe conversion drop-off at the final intent stage. 
- **The Data:** While **96.4%** of users who open the app proceed to search, and **91.1%** of searchers view an ad, only **28.5%** of those who view an ad actually take action to contact a seller.
- **Product Recommendation:** The major friction point is between `view_ad` and `contact_seller`. We need to optimize the ad page layout, improve the visibility of the "Contact" button, or implement single-click messaging to capture passive intent.

### 2. Cross-Platform Behavioral Divergence (`05_data_mart.sql` & `06_window_functions.sql`)
- **Web Efficiency:** Users on the `web` platform convert to commercial intent much faster than mobile app users. The average time from registration to the first seller contact on Web is **81.9 hours**, compared to over **102–104 hours** on Android and iOS.
- **Conversion Paradox:** Web also leads in daily conversion efficiency with a **16.8%** view-to-contact ratio, beating both mobile platforms (~14.5%).
- **Product Recommendation:** Investigate if the Web interface provides a cleaner search layout or more seamless authorization that accelerates intent execution. Mobile apps need optimization to reduce time-to-first-value.

### 3. Data Quality & Pipeline Health Red Flags (`04_data_quality.sql`)
The logging backend suffers from serious synchronization and structural bugs that require immediate attention from the Data Engineering team:
- **Telemetry Anomalies:** **37 rows** recorded user events happening *before* the official registration timestamp (`event_before_registration`). This indicates clock desynchronization or a structural bug in profile state validation.
- **Pipeline Noise:** Detected **50 duplicate event rows** and **25 orphaned entries** lacking a `user_id` (`null_user_id`), causing inflated metrics if not filtered out.
- **Syntax Bugs:** **10 events** were logged with a typo (`view_adv` instead of `view_ad`), pointing to lack of strict enum schema validation in the front-end tracking code.

---

## SQL Pipeline Structure (`queries/`)

| File Name | Analytic Objective | Technical Complexity |
|---|---|---|
| `01_dau.sql` | Computes Daily Active Users (DAU) over time. | Safe `DISTINCT` aggregations bypassing NULL anomalies. |
| `02_funnel.sql` | Builds end-to-end behavior conversion funnels. | Conditional multi-stage boolean flags using subqueries. |
| `03_retention.sql` | Computes Registration Cohort Retention (D1 and D7). | Epoch calculation via `julianday()` with strict cohort boundaries. |
| `04_data_quality.sql` | Identifies desyncs, duplicates, and tracking issues. | Structural integrity audits and lookup desynchronization checks. |
| `05_data_mart.sql` | Generates a high-performance aggregated `VIEW`. | Data Mart engineering mapping unique user-day platform flags. |
| `06_window_functions.sql` | Calculates duration metrics between actions. | Analytical windowing utilizing `ROW_NUMBER() OVER(PARTITION...)`. |

---

## Execution Guide

### Prerequisite Setup
Ensure you have a python environment installed. Generate the analytical database by simulating the user clickstream:
```bash
python generate_db.py
```

### Running the Analytical Suite
To execute all SQL queries sequentially and review the output data directly within your terminal workspace, run the engine compiler:
```bash
python run_queries.py
```
