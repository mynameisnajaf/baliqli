from pydantic import BaseModel


class FishSpeciesOut(BaseModel):
    id: int
    name_en: str
    name_az: str
    scientific_name: str
    category: str
    habitat: str
    description_az: str
    image_url: str | None = None
    rarity: str
    has_recipes: bool
    has_tutorials: bool

    model_config = {"from_attributes": True}
