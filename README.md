# Product Analytics in SQL

SQL queries for typical product analytics tasks (DAU, funnel, retention, data quality, data mart, window functions) on a synthetic event log of a marketplace app.

> **Note:** the data is synthetic and produced by `generate_db.py`. All platforms behave identically in the generator, so differences between them in the output are noise, not findings. The goal of the project is the SQL itself.

## About

The queries answer questions a product analyst gets regularly:

1. how many users are active each day;
2. where users drop off on the way to contacting a seller;
3. how many users come back after registration;
4. whether the event log can be trusted;
5. how to prepare clean data for further analysis.

## Data

`generate_db.py` creates a SQLite database `events.db` (30 days, 3,000 users).

| Table | Columns | Description |
|---|---|---|
| `users` | `user_id`, `registered_at`, `platform` | registered users (`ios`, `android`, `web`) |
| `events` | `event_id`, `user_id`, `event_name`, `event_time` | user actions: `app_open`, `search`, `view_ad`, `favorite`, `contact_seller` |

Defects are injected on purpose to test the data-quality checks: duplicate rows, events without `user_id`, events before registration and a misspelled event name.

## Queries

| File | Task | Techniques |
|---|---|---|
| `01_dau.sql` | Daily active users | `COUNT(DISTINCT)`, NULL filtering |
| `02_funnel.sql` | Funnel: open → search → view → contact | CTE, per-user flags via `MAX(...)` |
| `03_retention.sql` | D1 and D7 retention by registration cohort | CTE, `LEFT JOIN`, `julianday()` |
| `04_data_quality.sql` | Logging checks: NULL ids, duplicates, events before registration, unknown events | `GROUP BY ... HAVING`, `JOIN` |
| `05_data_mart.sql` | User × day mart with action flags | `VIEW`, data cleaning, aggregation |
| `06_window_functions.sql` | Time from registration to first seller contact | `ROW_NUMBER() OVER (PARTITION BY ...)` |

## Results

Synthetic data, 3,000 users.

| Check | Result |
|---|---|
| Funnel | 3,000 opened → 2,892 searched (96.4%) → 2,636 viewed an ad (91.1%) → 752 contacted a seller (28.5%) |
| Retention (23 cohorts) | D1: 34–54%, D7: 7–24% |
| Data quality | 25 events without `user_id`, 50 duplicate rows, 37 events before registration, 10 events with an unknown name |

The data-quality checks find exactly the defects injected by the generator. The `mart_user_day` view removes them once, so later queries stay simple.

## Project structure

```
.
├── generate_db.py     # creates events.db with synthetic data
├── run_queries.py     # runs all queries from queries/ and prints results
├── queries/
│   ├── 01_dau.sql
│   ├── 02_funnel.sql
│   ├── 03_retention.sql
│   ├── 04_data_quality.sql
│   ├── 05_data_mart.sql
│   └── 06_window_functions.sql
└── README.md
```

## Getting started

### Prerequisites

- Python 3.9+ (standard library only, no extra packages)

### Installation

```bash
git clone https://github.com/whynotyuno/<repository-name>.git
cd product-analytics-sql
```

### Usage

```bash
python generate_db.py    # creates events.db
python run_queries.py    # runs every query in queries/
```

## Limitations

- Synthetic data: no real behavioral patterns and no differences between platforms.
- The funnel checks whether a user ever reached a step; event order is not enforced.
- Time to first contact is averaged only over users who contacted a seller.
- Retention is classic day-N (exact day), not rolling.

## Author

[whynotyuno](https://github.com/whynotyuno)
