"""Create tables and seed. Run: PYTHONPATH=. python scripts/init_db.py"""
from app.database.seed import seed_all
from app.database.session import Base, SessionLocal, engine
import app.models  # noqa: F401

if __name__ == "__main__":
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        seed_all(db)
        print("DB initialized and seeded.")
    finally:
        db.close()
