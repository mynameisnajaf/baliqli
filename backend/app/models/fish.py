from sqlalchemy import Boolean, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.session import Base


class FishSpecies(Base):
    __tablename__ = "fish_species"

    id: Mapped[int] = mapped_column(primary_key=True)
    name_en: Mapped[str] = mapped_column(String(128), nullable=False)
    name_az: Mapped[str] = mapped_column(String(128), nullable=False, index=True)
    scientific_name: Mapped[str] = mapped_column(String(128), nullable=False)
    category: Mapped[str] = mapped_column(String(32), nullable=False, index=True)
    # freshwater | sea | river | lake | rare
    habitat: Mapped[str] = mapped_column(String(255), nullable=False)
    description_az: Mapped[str] = mapped_column(Text, nullable=False)
    image_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    rarity: Mapped[str] = mapped_column(String(32), default="common")  # common|uncommon|rare|legendary
    has_recipes: Mapped[bool] = mapped_column(Boolean, default=False)
    has_tutorials: Mapped[bool] = mapped_column(Boolean, default=False)
    sort_order: Mapped[int] = mapped_column(Integer, default=0)

    catches = relationship("Catch", back_populates="species")
    collections = relationship("UserCollection", back_populates="species")
