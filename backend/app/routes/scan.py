"""Scan → identify → confirm catch (critical MVP flow)."""
import os
import uuid
from pathlib import Path

import aiofiles
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session, joinedload

from app.config import get_settings
from app.database.session import get_db
from app.models.catch import Catch
from app.models.fish import FishSpecies
from app.models.social import Post
from app.models.user import User
from app.schemas.catch import CatchOut, ScanConfirmRequest, ScanIdentifyOut
from app.schemas.fish import FishSpeciesOut
from app.services.ai import get_fish_identifier
from app.services.auth import get_current_user
from app.services.collection import add_catch_to_collection

router = APIRouter()


def _match_species(db: Session, scientific_name: str | None, name_az_hint: str | None) -> FishSpecies | None:
    if scientific_name:
        sp = db.query(FishSpecies).filter(FishSpecies.scientific_name.ilike(scientific_name)).first()
        if sp:
            return sp
        # partial genus/species match
        parts = scientific_name.split()
        if parts:
            sp = db.query(FishSpecies).filter(FishSpecies.scientific_name.ilike(f"%{parts[0]}%")).first()
            if sp:
                return sp
    if name_az_hint:
        sp = db.query(FishSpecies).filter(FishSpecies.name_az.ilike(f"%{name_az_hint}%")).first()
        if sp:
            return sp
    return db.query(FishSpecies).order_by(FishSpecies.id).first()


async def _save_upload(file: UploadFile) -> tuple[bytes, str]:
    settings = get_settings()
    upload_dir = Path(settings.upload_dir)
    upload_dir.mkdir(parents=True, exist_ok=True)
    ext = Path(file.filename or "photo.jpg").suffix or ".jpg"
    name = f"{uuid.uuid4().hex}{ext}"
    path = upload_dir / name
    data = await file.read()
    async with aiofiles.open(path, "wb") as f:
        await f.write(data)
    return data, f"/uploads/{name}"


@router.post("/identify", response_model=ScanIdentifyOut)
async def identify(
    image: UploadFile = File(...),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    data, _url = await _save_upload(image)
    identifier = get_fish_identifier()
    result = await identifier.identify(data, image.filename)
    species = _match_species(db, result.scientific_name, result.name_az_hint)
    if not species:
        raise HTTPException(404, "Növlər bazası boşdur")

    alternatives: list[FishSpeciesOut] = []
    for alt in result.alternatives[:3]:
        sp = _match_species(db, alt.get("scientific_name"), alt.get("name_az_hint"))
        if sp and sp.id != species.id:
            alternatives.append(FishSpeciesOut.model_validate(sp))

    msg = "Süni intellekt növü müəyyən etdi."
    if result.is_mock:
        msg = "Mock rejim: GEMINI_API_KEY yoxdur — test identifikasiyası."

    return ScanIdentifyOut(
        species=FishSpeciesOut.model_validate(species),
        confidence=result.confidence,
        alternatives=alternatives,
        is_mock=result.is_mock,
        message_az=msg,
    )


@router.post("/confirm", response_model=CatchOut)
def confirm_scan(
    body: ScanConfirmRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    species = db.get(FishSpecies, body.fish_species_id)
    if not species:
        raise HTTPException(404, "Növ tapılmadı")

    catch = Catch(
        user_id=user.id,
        fish_species_id=body.fish_species_id,
        image_url=body.image_url,
        weight_kg=body.weight_kg,
        length_cm=body.length_cm,
        latitude=body.latitude,
        longitude=body.longitude,
        location_name=body.location_name,
        bait=body.bait,
        fishing_method=body.fishing_method,
        released=body.released,
        privacy=body.privacy,
        notes=body.notes,
        ai_confidence=body.ai_confidence,
    )
    db.add(catch)
    db.flush()
    is_new, unlocked = add_catch_to_collection(db, user.id, catch)

    if body.share:
        db.add(Post(user_id=user.id, catch_id=catch.id, caption=body.caption or f"{species.name_az} tutdum! 🎣"))

    db.commit()
    catch = db.query(Catch).options(joinedload(Catch.species)).filter(Catch.id == catch.id).one()
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
        species=FishSpeciesOut.model_validate(catch.species),
        is_new_discovery=is_new,
        unlocked_achievements=unlocked,
    )
