"""Выполняет все .sql из папки queries и печатает результаты."""
import glob
import sqlite3

con = sqlite3.connect("events.db")
for path in sorted(glob.glob("queries/*.sql")):
    print("=" * 70)
    print(path)
    with open(path, encoding="utf-8") as f:
        statements = [s.strip() for s in f.read().split(";") if s.strip()]
    for stmt in statements:
        cur = con.execute(stmt)
        if cur.description:
            cols = [c[0] for c in cur.description]
            rows = cur.fetchall()
            print(" | ".join(cols))
            for r in rows[:8]:
                print(" | ".join(str(x) for x in r))
            if len(rows) > 8:
                print(f"... всего строк: {len(rows)}")
            print()
con.commit()
