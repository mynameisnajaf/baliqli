from datetime import datetime

from pydantic import BaseModel, Field

from app.schemas.fish import FishSpeciesOut


class CatchCreate(BaseModel):
    fish_species_id: int
    image_url: str | None = None
    weight_kg: float | None = None
    length_cm: float | None = None
    latitude: float | None = None
    longitude: float | None = None
    location_name: str | None = None
    bait: str | None = None
    fishing_method: str | None = None
    released: bool = False
    privacy: str = "private"
    notes: str | None = None
    ai_confidence: float | None = None


class CatchOut(BaseModel):
    id: int
    user_id: int
    fish_species_id: int
    image_url: str | None = None
    weight_kg: float | None = None
    length_cm: float | None = None
    latitude: float | None = None
    longitude: float | None = None
    location_name: str | None = None
    bait: str | None = None
    fishing_method: str | None = None
    released: bool
    privacy: str
    notes: str | None = None
    ai_confidence: float | None = None
    created_at: datetime
    species: FishSpeciesOut | None = None
    is_new_discovery: bool = False
    unlocked_achievements: list[str] = Field(default_factory=list)

    model_config = {"from_attributes": True}


class ScanIdentifyOut(BaseModel):
    species: FishSpeciesOut
    confidence: float
    alternatives: list[FishSpeciesOut] = Field(default_factory=list)
    is_mock: bool = False
    message_az: str = ""


class ScanConfirmRequest(BaseModel):
    fish_species_id: int
    image_url: str | None = None
    weight_kg: float | None = None
    length_cm: float | None = None
    latitude: float | None = None
    longitude: float | None = None
    location_name: str | None = None
    bait: str | None = None
    fishing_method: str | None = None
    released: bool = False
    privacy: str = "private"
    notes: str | None = None
    ai_confidence: float | None = None
    share: bool = False
    caption: str | None = None
