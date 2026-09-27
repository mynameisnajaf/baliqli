from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.marketplace import MarketplaceProduct
from app.schemas.content import MarketplaceProductOut

router = APIRouter()


def _out(p: MarketplaceProduct) -> MarketplaceProductOut:
    images = [x for x in (p.images or "").split(",") if x.strip()]
    return MarketplaceProductOut(
        id=p.id,
        name_az=p.name_az,
        description_az=p.description_az,
        price_azn=p.price_azn,
        images=images,
        seller=p.seller,
        category=p.category,
        stock=p.stock,
        rating=p.rating,
    )


@router.get("/", response_model=list[MarketplaceProductOut])
def list_products(db: Session = Depends(get_db)):
    return [_out(p) for p in db.query(MarketplaceProduct).all()]


@router.get("/{product_id}", response_model=MarketplaceProductOut)
def get_product(product_id: int, db: Session = Depends(get_db)):
    p = db.get(MarketplaceProduct, product_id)
    if not p:
        raise HTTPException(404, "Məhsul tapılmadı")
    return _out(p)
