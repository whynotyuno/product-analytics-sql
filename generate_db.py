"""Создаёт SQLite-базу events.db с пользователями и событиями (как в продуктовой аналитике).
В данные намеренно добавлен мусор (дубли, пустые user_id, события до регистрации),
чтобы потренировать проверки качества данных."""
import random
import sqlite3
from datetime import datetime, timedelta

random.seed(42)
START = datetime(2026, 9, 1)
DAYS = 30
N_USERS = 3000

con = sqlite3.connect("events.db")
cur = con.cursor()
cur.executescript("""
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS events;
CREATE TABLE users (
    user_id       INTEGER PRIMARY KEY,
    registered_at TEXT NOT NULL,
    platform      TEXT NOT NULL
);
CREATE TABLE events (
    event_id   INTEGER PRIMARY KEY,
    user_id    INTEGER,
    event_name TEXT NOT NULL,
    event_time TEXT NOT NULL
);
""")

users, events = [], []

def add_event(uid, name, ts):
    events.append((uid, name, ts.strftime("%Y-%m-%d %H:%M:%S")))

for uid in range(1, N_USERS + 1):
    reg = START + timedelta(days=random.randint(0, DAYS - 1),
                            seconds=random.randint(0, 86399))
    platform = random.choices(["ios", "android", "web"], [0.35, 0.45, 0.2])[0]
    users.append((uid, reg.strftime("%Y-%m-%d %H:%M:%S"), platform))

    # вероятность вернуться падает со временем
    for d in range(0, (START + timedelta(days=DAYS) - reg).days + 1):
        if d > 0 and random.random() > 0.6 / (1 + 0.4 * d):
            continue
        ts = reg + timedelta(days=d, seconds=random.randint(0, 3600))
        add_event(uid, "app_open", ts)
        if random.random() < 0.8:
            add_event(uid, "search", ts + timedelta(seconds=30))
            if random.random() < 0.7:
                add_event(uid, "view_ad", ts + timedelta(seconds=90))
                if random.random() < 0.3:
                    add_event(uid, "favorite", ts + timedelta(seconds=150))
                if random.random() < 0.15:
                    add_event(uid, "contact_seller", ts + timedelta(seconds=210))

# --- мусор в данных ---
for e in random.sample(events, 40):                      # дубли
    events.append(e)
for _ in range(25):                                       # события без user_id
    add_event(None, "view_ad", START + timedelta(days=random.randint(0, 29)))
for uid in random.sample(range(1, N_USERS + 1), 30):      # событие раньше регистрации
    add_event(uid, "app_open", START - timedelta(days=3))
for _ in range(10):                                       # неизвестное название события
    add_event(random.randint(1, N_USERS), "view_adv", START + timedelta(days=5))

random.shuffle(events)
cur.executemany("INSERT INTO users VALUES (?,?,?)", users)
cur.executemany("INSERT INTO events (user_id, event_name, event_time) VALUES (?,?,?)", events)
con.commit()
print(f"users={len(users)}, events={len(events)}")
