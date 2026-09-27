"""AI fish identification abstraction."""
from abc import ABC, abstractmethod
from dataclasses import dataclass, field


@dataclass
class IdentifyResult:
    scientific_name: str | None
    name_az_hint: str | None
    confidence: float
    notes: str = ""
    alternatives: list[dict] = field(default_factory=list)
    is_mock: bool = False


class FishIdentifier(ABC):
    @abstractmethod
    async def identify(self, image_bytes: bytes, filename: str | None = None) -> IdentifyResult:
        """Identify fish species from image bytes. Does NOT estimate weight."""
        raise NotImplementedError
