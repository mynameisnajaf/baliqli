from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column

from app.database.session import Base


class Recipe(Base):
    __tablename__ = "recipes"

    id: Mapped[int] = mapped_column(primary_key=True)
    title_az: Mapped[str] = mapped_column(String(255), nullable=False)
    image_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    ingredients: Mapped[str] = mapped_column(Text, nullable=False)  # JSON list as text
    steps: Mapped[str] = mapped_column(Text, nullable=False)
    cook_time_min: Mapped[int] = mapped_column(Integer, default=30)
    difficulty: Mapped[str] = mapped_column(String(32), default="orta")
    fish_species_ids: Mapped[str] = mapped_column(String(255), default="")  # comma-separated ids
    description_az: Mapped[str | None] = mapped_column(Text, nullable=True)


class Tutorial(Base):
    __tablename__ = "tutorials"

    id: Mapped[int] = mapped_column(primary_key=True)
    title_az: Mapped[str] = mapped_column(String(255), nullable=False)
    thumbnail_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    description_az: Mapped[str] = mapped_column(Text, nullable=False)
    content_md: Mapped[str] = mapped_column(Text, nullable=False)
    video_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    difficulty: Mapped[str] = mapped_column(String(32), default="başlanğıc")
    duration_min: Mapped[int] = mapped_column(Integer, default=10)
    category: Mapped[str] = mapped_column(String(32), default="fishing")
    # fishing | equipment | handling


class TutorialProgress(Base):
    __tablename__ = "tutorial_progress"
    __table_args__ = (UniqueConstraint("user_id", "tutorial_id", name="uq_tutorial_progress"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    tutorial_id: Mapped[int] = mapped_column(ForeignKey("tutorials.id", ondelete="CASCADE"), index=True)
    completed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
