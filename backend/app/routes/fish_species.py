from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.fish import FishSpecies
from app.schemas.fish import FishSpeciesOut

router = APIRouter()


@router.get("/", response_model=list[FishSpeciesOut])
def list_species(
    category: str | None = Query(None),
    q: str | None = Query(None),
    db: Session = Depends(get_db),
):
    query = db.query(FishSpecies).order_by(FishSpecies.sort_order, FishSpecies.id)
    if category:
        query = query.filter(FishSpecies.category == category)
    if q:
        like = f"%{q}%"
        query = query.filter(
            (FishSpecies.name_az.ilike(like))
            | (FishSpecies.name_en.ilike(like))
            | (FishSpecies.scientific_name.ilike(like))
        )
    return query.all()


@router.get("/categories")
def categories(db: Session = Depends(get_db)):
    rows = db.query(FishSpecies.category).distinct().all()
    return {"categories": [r[0] for r in rows]}


@router.get("/{species_id}", response_model=FishSpeciesOut)
def get_species(species_id: int, db: Session = Depends(get_db)):
    sp = db.get(FishSpecies, species_id)
    if not sp:
        raise HTTPException(404, "Növ tapılmadı")
    return sp
