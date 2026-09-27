"""Gemini-based fish identifier."""
import json
import re

from app.config import get_settings

from .base import FishIdentifier, IdentifyResult

PROMPT = """You are an expert ichthyologist specializing in fish of Azerbaijan and the Caspian Sea basin.
Identify the fish in this photo. Respond ONLY with valid JSON (no markdown):
{
  "scientific_name": "Genus species",
  "name_az_hint": "Azerbaijani common name if known else English",
  "confidence": 0.0-1.0,
  "notes": "brief habitat note",
  "alternatives": [{"scientific_name": "...", "name_az_hint": "...", "confidence": 0.0}]
}
Do NOT estimate weight or length. Focus on species ID only.
Prefer Caspian / Caucasus / Azerbaijan freshwater and marine species when plausible.
"""


class GeminiFishIdentifier(FishIdentifier):
    def __init__(self) -> None:
        import google.generativeai as genai

        settings = get_settings()
        genai.configure(api_key=settings.gemini_api_key)
        self._model = genai.GenerativeModel("gemini-1.5-flash")

    async def identify(self, image_bytes: bytes, filename: str | None = None) -> IdentifyResult:
        import google.generativeai as genai

        mime = "image/jpeg"
        if filename:
            lower = filename.lower()
            if lower.endswith(".png"):
                mime = "image/png"
            elif lower.endswith(".webp"):
                mime = "image/webp"

        image_part = {"mime_type": mime, "data": image_bytes}
        response = await self._model.generate_content_async([PROMPT, image_part])
        text = response.text or "{}"
        text = text.strip()
        if text.startswith("```"):
            text = re.sub(r"^```(?:json)?\s*", "", text)
            text = re.sub(r"\s*```$", "", text)
        try:
            data = json.loads(text)
        except json.JSONDecodeError:
            return IdentifyResult(
                scientific_name=None,
                name_az_hint=None,
                confidence=0.0,
                notes="Gemini cavabı parse edilə bilmədi.",
                is_mock=False,
            )
        return IdentifyResult(
            scientific_name=data.get("scientific_name"),
            name_az_hint=data.get("name_az_hint"),
            confidence=float(data.get("confidence") or 0.0),
            notes=data.get("notes") or "",
            alternatives=data.get("alternatives") or [],
            is_mock=False,
        )
