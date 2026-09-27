"""Mock identifier for local/dev when GEMINI_API_KEY is missing."""
import hashlib

from .base import FishIdentifier, IdentifyResult

# Realistic Azerbaijan species rotation for testing
MOCK_SPECIES = [
    ("Cyprinus carpio", "Sazan", 0.91),
    ("Rutilus frisii kutum", "Kütüm", 0.88),
    ("Huso huso", "Beluga nərə", 0.72),
    ("Salmo trutta caspius", "Qızılbalıq", 0.85),
    ("Abramis brama", "Çapak", 0.90),
    ("Aspius aspius", "Qılınc balığı", 0.82),
    ("Sander lucioperca", "Durnabalığı", 0.87),
    ("Mugil cephalus", "Kefal", 0.84),
    ("Silurus glanis", "Naxa", 0.79),
    ("Perca fluviatilis", "Xanımbaliğı", 0.86),
    ("Carassius gibelio", "Gümüşü karas", 0.93),
    ("Alosa caspia", "Xəşəm", 0.81),
    ("Acipenser gueldenstaedtii", "Rus nərəsi", 0.70),
    ("Tinca tinca", "Lin", 0.88),
    ("Esox lucius", "Çökə", 0.83),
]


class MockFishIdentifier(FishIdentifier):
    async def identify(self, image_bytes: bytes, filename: str | None = None) -> IdentifyResult:
        seed_src = (filename or "") + str(len(image_bytes)) + hashlib.md5(image_bytes[:4096]).hexdigest()
        digest = hashlib.sha256(seed_src.encode()).hexdigest()
        idx = int(digest[:8], 16) % len(MOCK_SPECIES)
        sci, az, conf = MOCK_SPECIES[idx]
        alt_idx = (idx + 1) % len(MOCK_SPECIES)
        alt = MOCK_SPECIES[alt_idx]
        return IdentifyResult(
            scientific_name=sci,
            name_az_hint=az,
            confidence=conf,
            notes="Mock identifikasiya — GEMINI_API_KEY təyin edilməyib.",
            alternatives=[{"scientific_name": alt[0], "name_az_hint": alt[1], "confidence": alt[2] * 0.7}],
            is_mock=True,
        )
