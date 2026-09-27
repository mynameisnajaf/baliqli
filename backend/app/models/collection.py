from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.session import Base


class UserCollection(Base):
    __tablename__ = "user_collections"
    __table_args__ = (UniqueConstraint("user_id", "fish_species_id", name="uq_user_species"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    fish_species_id: Mapped[int] = mapped_column(ForeignKey("fish_species.id"), index=True)
    discovered_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    first_catch_id: Mapped[int | None] = mapped_column(ForeignKey("catches.id"), nullable=True)

    user = relationship("User", back_populates="collection")
    species = relationship("FishSpecies", back_populates="collections")
