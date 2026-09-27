from sqlalchemy import Float, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database.session import Base


class FishingSpot(Base):
    __tablename__ = "fishing_spots"

    id: Mapped[int] = mapped_column(primary_key=True)
    name_az: Mapped[str] = mapped_column(String(255), nullable=False)
    latitude: Mapped[float] = mapped_column(Float, nullable=False)  # approximate
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    description_az: Mapped[str] = mapped_column(Text, nullable=False)
    region: Mapped[str] = mapped_column(String(128), default="")
