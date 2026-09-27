from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from app.database.session import get_db
from app.models.catch import Catch
from app.models.user import User
from app.schemas.catch import CatchCreate, CatchOut
from app.schemas.fish import FishSpeciesOut
from app.services.auth import get_current_user
from app.services.collection import add_catch_to_collection

router = APIRouter()


def _catch_out(catch: Catch, is_new: bool = False, unlocked: list[str] | None = None) -> CatchOut:
    return CatchOut(
        id=catch.id,
        user_id=catch.user_id,
        fish_species_id=catch.fish_species_id,
        image_url=catch.image_url,
        weight_kg=catch.weight_kg,
        length_cm=catch.length_cm,
        latitude=catch.latitude,
        longitude=catch.longitude,
        location_name=catch.location_name,
        bait=catch.bait,
        fishing_method=catch.fishing_method,
        released=catch.released,
        privacy=catch.privacy,
        notes=catch.notes,
        ai_confidence=catch.ai_confidence,
        created_at=catch.created_at,
        species=FishSpeciesOut.model_validate(catch.species) if catch.species else None,
        is_new_discovery=is_new,
        unlocked_achievements=unlocked or [],
    )


@router.get("/", response_model=list[CatchOut])
def list_my_catches(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(Catch)
        .options(joinedload(Catch.species))
        .filter(Catch.user_id == user.id)
        .order_by(Catch.created_at.desc())
        .all()
    )
    return [_catch_out(c) for c in rows]


@router.post("/", response_model=CatchOut)
def create_catch(body: CatchCreate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    catch = Catch(user_id=user.id, **body.model_dump())
    db.add(catch)
    db.flush()
    is_new, unlocked = add_catch_to_collection(db, user.id, catch)
    db.commit()
    db.refresh(catch)
    catch = db.query(Catch).options(joinedload(Catch.species)).filter(Catch.id == catch.id).one()
    return _catch_out(catch, is_new, unlocked)


@router.get("/{catch_id}", response_model=CatchOut)
def get_catch(catch_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    catch = db.query(Catch).options(joinedload(Catch.species)).filter(Catch.id == catch_id).first()
    if not catch or catch.user_id != user.id:
        raise HTTPException(404, "Ov tapılmadı")
    return _catch_out(catch)


@router.delete("/{catch_id}")
def delete_catch(catch_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    catch = db.get(Catch, catch_id)
    if not catch or catch.user_id != user.id:
        raise HTTPException(404, "Ov tapılmadı")
    db.delete(catch)
    db.commit()
    return {"ok": True}
