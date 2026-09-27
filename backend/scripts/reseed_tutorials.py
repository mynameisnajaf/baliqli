"""Refresh tutorials with YouTube content. Run:
  cd backend && PYTHONPATH=. .venv/bin/python scripts/reseed_tutorials.py
"""
from app.database.seed import refresh_tutorials
from app.database.session import SessionLocal
import app.models  # noqa: F401


if __name__ == "__main__":
    db = SessionLocal()
    try:
        n = refresh_tutorials(db)
        print(f"Reseeded {n} tutorials with YouTube URLs.")
    finally:
        db.close()
