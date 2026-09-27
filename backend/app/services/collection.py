"""Collection album + achievement unlock logic."""
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.catch import Catch
from app.models.collection import UserCollection
from app.models.fish import FishSpecies
from app.models.gamification import Achievement, UserAchievement


ACHIEVEMENT_RULES = [
    ("first_catch", lambda ctx: ctx["total_catches"] >= 1),
    ("species_5", lambda ctx: ctx["species_count"] >= 5),
    ("species_10", lambda ctx: ctx["species_count"] >= 10),
    ("species_25", lambda ctx: ctx["species_count"] >= 25),
    ("river_explorer", lambda ctx: ctx["categories"].get("river", 0) >= 3),
    ("sea_explorer", lambda ctx: ctx["categories"].get("sea", 0) >= 3),
    ("lake_explorer", lambda ctx: ctx["categories"].get("lake", 0) >= 3),
    ("rare_hunter", lambda ctx: ctx["rare_count"] >= 1),
    ("freshwater_master", lambda ctx: ctx["categories"].get("freshwater", 0) >= 5),
]


def add_catch_to_collection(db: Session, user_id: int, catch: Catch) -> tuple[bool, list[str]]:
    """Return (is_new_discovery, unlocked_achievement_codes)."""
    existing = (
        db.query(UserCollection)
        .filter(
            UserCollection.user_id == user_id,
            UserCollection.fish_species_id == catch.fish_species_id,
        )
        .first()
    )
    is_new = existing is None
    if is_new:
        db.add(
            UserCollection(
                user_id=user_id,
                fish_species_id=catch.fish_species_id,
                first_catch_id=catch.id,
            )
        )
        db.flush()

    unlocked = check_and_unlock_achievements(db, user_id)
    return is_new, unlocked


def check_and_unlock_achievements(db: Session, user_id: int) -> list[str]:
    total_catches = db.query(func.count(Catch.id)).filter(Catch.user_id == user_id).scalar() or 0
    collections = (
        db.query(UserCollection, FishSpecies)
        .join(FishSpecies, FishSpecies.id == UserCollection.fish_species_id)
        .filter(UserCollection.user_id == user_id)
        .all()
    )
    categories: dict[str, int] = {}
    rare_count = 0
    for _, sp in collections:
        categories[sp.category] = categories.get(sp.category, 0) + 1
        if sp.rarity in ("rare", "legendary") or sp.category == "rare":
            rare_count += 1

    ctx = {
        "total_catches": total_catches,
        "species_count": len(collections),
        "categories": categories,
        "rare_count": rare_count,
    }

    already = {
        a.code
        for a in db.query(Achievement)
        .join(UserAchievement)
        .filter(UserAchievement.user_id == user_id)
        .all()
    }
    unlocked: list[str] = []
    for code, rule in ACHIEVEMENT_RULES:
        if code in already:
            continue
        if rule(ctx):
            ach = db.query(Achievement).filter(Achievement.code == code).first()
            if ach:
                db.add(UserAchievement(user_id=user_id, achievement_id=ach.id))
                unlocked.append(code)
    db.flush()
    return unlocked
