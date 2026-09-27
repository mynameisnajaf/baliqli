from datetime import datetime

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.session import Base


class Catch(Base):
    __tablename__ = "catches"

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    fish_species_id: Mapped[int] = mapped_column(ForeignKey("fish_species.id"), index=True)
    image_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    weight_kg: Mapped[float | None] = mapped_column(Float, nullable=True)
    length_cm: Mapped[float | None] = mapped_column(Float, nullable=True)
    latitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    longitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    bait: Mapped[str | None] = mapped_column(String(128), nullable=True)
    fishing_method: Mapped[str | None] = mapped_column(String(128), nullable=True)
    released: Mapped[bool] = mapped_column(Boolean, default=False)
    privacy: Mapped[str] = mapped_column(String(32), default="private")
    # private | followers | public_approx
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    ai_confidence: Mapped[float | None] = mapped_column(Float, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="catches")
    species = relationship("FishSpecies", back_populates="catches")
    post = relationship("Post", back_populates="catch", uselist=False)
