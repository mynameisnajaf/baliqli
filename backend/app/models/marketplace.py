from sqlalchemy import Float, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database.session import Base


class MarketplaceProduct(Base):
    __tablename__ = "marketplace_products"

    id: Mapped[int] = mapped_column(primary_key=True)
    name_az: Mapped[str] = mapped_column(String(255), nullable=False)
    description_az: Mapped[str] = mapped_column(Text, nullable=False)
    price_azn: Mapped[float] = mapped_column(Float, nullable=False)
    images: Mapped[str] = mapped_column(Text, default="")  # comma-separated URLs
    seller: Mapped[str] = mapped_column(String(128), nullable=False)
    category: Mapped[str] = mapped_column(String(64), default="avadanlıq")
    stock: Mapped[int] = mapped_column(Integer, default=10)
    rating: Mapped[float] = mapped_column(Float, default=4.5)
