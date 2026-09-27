from datetime import datetime

from pydantic import BaseModel

from app.schemas.fish import FishSpeciesOut


class CollectionItemOut(BaseModel):
    fish_species_id: int
    discovered_at: datetime
    first_catch_id: int | None = None
    species: FishSpeciesOut

    model_config = {"from_attributes": True}


class CollectionProgressOut(BaseModel):
    total_species: int
    discovered: int
    percent: float
    by_category: dict[str, dict[str, int]]
    items: list[CollectionItemOut]
