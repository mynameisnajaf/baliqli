import json

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.content import Recipe
from app.schemas.content import RecipeOut

router = APIRouter()


def _recipe_out(r: Recipe) -> RecipeOut:
    try:
        ingredients = json.loads(r.ingredients)
    except json.JSONDecodeError:
        ingredients = [r.ingredients]
    try:
        steps = json.loads(r.steps)
    except json.JSONDecodeError:
        steps = [r.steps]
    ids = [int(x) for x in r.fish_species_ids.split(",") if x.strip().isdigit()]
    return RecipeOut(
        id=r.id,
        title_az=r.title_az,
        image_url=r.image_url,
        ingredients=ingredients,
        steps=steps,
        cook_time_min=r.cook_time_min,
        difficulty=r.difficulty,
        fish_species_ids=ids,
        description_az=r.description_az,
    )


@router.get("/", response_model=list[RecipeOut])
def list_recipes(db: Session = Depends(get_db)):
    return [_recipe_out(r) for r in db.query(Recipe).all()]


@router.get("/{recipe_id}", response_model=RecipeOut)
def get_recipe(recipe_id: int, db: Session = Depends(get_db)):
    r = db.get(Recipe, recipe_id)
    if not r:
        raise HTTPException(404, "Resept tapılmadı")
    return _recipe_out(r)
