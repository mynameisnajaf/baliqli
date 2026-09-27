"""Create tables and seed. Run: PYTHONPATH=. python scripts/init_db.py [--refresh-tutorials]"""
import sys

from app.database.seed import seed_all
from app.database.session import Base, SessionLocal, engine
import app.models  # noqa: F401

if __name__ == "__main__":
    refresh = "--refresh-tutorials" in sys.argv
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        seed_all(db, refresh_tutorials_data=refresh)
        print("DB initialized and seeded." + (" (tutorials refreshed)" if refresh else ""))
    finally:
        db.close()
