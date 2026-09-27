from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, joinedload

from app.database.session import get_db
from app.models.collection import UserCollection
from app.models.fish import FishSpecies
from app.models.user import User
from app.schemas.collection import CollectionItemOut, CollectionProgressOut
from app.schemas.fish import FishSpeciesOut
from app.services.auth import get_current_user

router = APIRouter()


@router.get("/", response_model=CollectionProgressOut)
def my_collection(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    total = db.query(FishSpecies).count()
    items = (
        db.query(UserCollection)
        .options(joinedload(UserCollection.species))
        .filter(UserCollection.user_id == user.id)
        .order_by(UserCollection.discovered_at.desc())
        .all()
    )
    by_category: dict[str, dict[str, int]] = {}
    all_species = db.query(FishSpecies).all()
    for sp in all_species:
        by_category.setdefault(sp.category, {"total": 0, "discovered": 0})
        by_category[sp.category]["total"] += 1
    for item in items:
        cat = item.species.category
        by_category.setdefault(cat, {"total": 0, "discovered": 0})
        by_category[cat]["discovered"] += 1

    discovered = len(items)
    percent = round((discovered / total * 100) if total else 0.0, 1)
    return CollectionProgressOut(
        total_species=total,
        discovered=discovered,
        percent=percent,
        by_category=by_category,
        items=[
            CollectionItemOut(
                fish_species_id=i.fish_species_id,
                discovered_at=i.discovered_at,
                first_catch_id=i.first_catch_id,
                species=FishSpeciesOut.model_validate(i.species),
            )
            for i in items
        ],
    )


@router.get("/album")
def album(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Full album: discovered cards + locked silhouettes."""
    discovered_ids = {
        r.fish_species_id
        for r in db.query(UserCollection.fish_species_id).filter(UserCollection.user_id == user.id)
    }
    species = db.query(FishSpecies).order_by(FishSpecies.category, FishSpecies.sort_order).all()
    album = []
    for sp in species:
        album.append(
            {
                "discovered": sp.id in discovered_ids,
                "species": FishSpeciesOut.model_validate(sp) if sp.id in discovered_ids else {
                    "id": sp.id,
                    "name_az": "???",
                    "name_en": "???",
                    "scientific_name": "???",
                    "category": sp.category,
                    "habitat": "???",
                    "description_az": "Hələ kəşf edilməyib",
                    "image_url": None,
                    "rarity": sp.rarity,
                    "has_recipes": False,
                    "has_tutorials": False,
                },
                "silhouette": sp.id not in discovered_ids,
            }
        )
    return {"items": album, "discovered": len(discovered_ids), "total": len(species)}
