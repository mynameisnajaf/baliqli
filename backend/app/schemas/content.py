from datetime import datetime

from pydantic import BaseModel


class RecipeOut(BaseModel):
    id: int
    title_az: str
    image_url: str | None = None
    ingredients: list[str]
    steps: list[str]
    cook_time_min: int
    difficulty: str
    fish_species_ids: list[int]
    description_az: str | None = None

    model_config = {"from_attributes": True}


class TutorialOut(BaseModel):
    id: int
    title_az: str
    thumbnail_url: str | None = None
    description_az: str
    content_md: str
    video_url: str | None = None
    difficulty: str
    duration_min: int
    category: str
    completed: bool = False

    model_config = {"from_attributes": True}


class AchievementOut(BaseModel):
    id: int
    code: str
    title_az: str
    description_az: str
    icon: str
    category: str
    unlocked: bool = False
    unlocked_at: datetime | None = None

    model_config = {"from_attributes": True}


class MarketplaceProductOut(BaseModel):
    id: int
    name_az: str
    description_az: str
    price_azn: float
    images: list[str]
    seller: str
    category: str
    stock: int
    rating: float

    model_config = {"from_attributes": True}


class FishingSpotOut(BaseModel):
    id: int
    name_az: str
    latitude: float
    longitude: float
    description_az: str
    region: str

    model_config = {"from_attributes": True}


class MapActivityOut(BaseModel):
    type: str  # catch | spot
    id: int
    name: str
    latitude: float
    longitude: float
    species_az: str | None = None
    created_at: datetime | None = None
