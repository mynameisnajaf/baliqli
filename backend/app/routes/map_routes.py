"""Map activity — approximate public locations only."""
import random

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, joinedload

from app.config import get_settings
from app.database.session import get_db
from app.models.catch import Catch
from app.models.spot import FishingSpot
from app.models.user import User
from app.schemas.content import FishingSpotOut, MapActivityOut
from app.services.auth import get_current_user

router = APIRouter()


def _jitter(lat: float, lng: float) -> tuple[float, float]:
    settings = get_settings()
    j = settings.privacy_coord_jitter_degrees
    # deterministic-ish per catch via seeded random would be better; random OK for MVP
    return lat + random.uniform(-j, j), lng + random.uniform(-j, j)


@router.get("/activity", response_model=list[MapActivityOut])
def activity(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    out: list[MapActivityOut] = []
    spots = db.query(FishingSpot).all()
    for s in spots:
        out.append(
            MapActivityOut(
                type="spot",
                id=s.id,
                name=s.name_az,
                latitude=s.latitude,
                longitude=s.longitude,
            )
        )

    catches = (
        db.query(Catch)
        .options(joinedload(Catch.species))
        .filter(Catch.privacy == "public_approx", Catch.latitude.isnot(None), Catch.longitude.isnot(None))
        .order_by(Catch.created_at.desc())
        .limit(100)
        .all()
    )
    for c in catches:
        lat, lng = _jitter(c.latitude, c.longitude)
        out.append(
            MapActivityOut(
                type="catch",
                id=c.id,
                name=c.location_name or "Ov",
                latitude=lat,
                longitude=lng,
                species_az=c.species.name_az if c.species else None,
                created_at=c.created_at,
            )
        )
    return out


@router.get("/spots", response_model=list[FishingSpotOut])
def spots(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    return db.query(FishingSpot).all()
