"""JWT local auth — interfaces structured so Supabase/Firebase can replace later."""
from datetime import datetime, timedelta, timezone
from typing import Protocol

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from app.config import get_settings
from app.database.session import get_db
from app.models.user import User

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
bearer_scheme = HTTPBearer(auto_error=False)


class AuthProvider(Protocol):
    """Swap-friendly auth contract for future Supabase/Firebase."""

    def hash_password(self, password: str) -> str: ...
    def verify_password(self, plain: str, hashed: str) -> bool: ...
    def create_access_token(self, subject: str) -> str: ...
    def decode_token(self, token: str) -> dict: ...


class LocalJWTAuth:
    def hash_password(self, password: str) -> str:
        return pwd_context.hash(password)

    def verify_password(self, plain: str, hashed: str) -> bool:
        return pwd_context.verify(plain, hashed)

    def create_access_token(self, subject: str) -> str:
        settings = get_settings()
        expire = datetime.now(timezone.utc) + timedelta(minutes=settings.access_token_expire_minutes)
        return jwt.encode(
            {"sub": subject, "exp": expire},
            settings.secret_key,
            algorithm=settings.algorithm,
        )

    def decode_token(self, token: str) -> dict:
        settings = get_settings()
        return jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])


auth_provider: AuthProvider = LocalJWTAuth()


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> User:
    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Autentifikasiya tələb olunur")
    try:
        payload = auth_provider.decode_token(credentials.credentials)
        user_id = int(payload.get("sub", 0))
    except (JWTError, ValueError):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Yanlış token")
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="İstifadəçi tapılmadı")
    return user


def get_optional_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> User | None:
    if credentials is None:
        return None
    try:
        return get_current_user(credentials, db)
    except HTTPException:
        return None
