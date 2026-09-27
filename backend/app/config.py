"""Application settings — never hardcode secrets."""
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    database_url: str = "postgresql+psycopg2://balqici:balqici@localhost:5432/balqici"
    secret_key: str = "dev-only-change-me-balqici-secret-key-32chars"
    access_token_expire_minutes: int = 60 * 24 * 7
    algorithm: str = "HS256"
    gemini_api_key: str = ""
    api_host: str = "0.0.0.0"
    api_port: int = 8000
    cors_origins: str = "*"
    upload_dir: str = "./uploads"
    privacy_coord_jitter_degrees: float = 0.02  # ~2km approx

    @property
    def cors_origin_list(self) -> list[str]:
        if self.cors_origins.strip() == "*":
            return ["*"]
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def use_mock_ai(self) -> bool:
        return not bool(self.gemini_api_key.strip())


@lru_cache
def get_settings() -> Settings:
    return Settings()
