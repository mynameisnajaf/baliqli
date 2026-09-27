from functools import lru_cache

from app.config import get_settings

from .base import FishIdentifier
from .gemini import GeminiFishIdentifier
from .mock import MockFishIdentifier


@lru_cache
def get_fish_identifier() -> FishIdentifier:
    settings = get_settings()
    if settings.use_mock_ai:
        return MockFishIdentifier()
    return GeminiFishIdentifier()
