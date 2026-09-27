from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.catch import Catch
from app.models.collection import UserCollection
from app.models.user import Follow, User
from app.schemas.auth import ProfileOut
from app.services.auth import get_current_user

router = APIRouter()


@router.get("/{user_id}/profile", response_model=ProfileOut)
def profile(user_id: int, me: User = Depends(get_current_user), db: Session = Depends(get_db)):
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(404, "İstifadəçi tapılmadı")
    catches_count = db.query(func.count(Catch.id)).filter(Catch.user_id == user_id).scalar() or 0
    species_count = db.query(func.count(UserCollection.id)).filter(UserCollection.user_id == user_id).scalar() or 0
    followers = db.query(func.count(Follow.id)).filter(Follow.following_id == user_id).scalar() or 0
    following = db.query(func.count(Follow.id)).filter(Follow.follower_id == user_id).scalar() or 0
    is_following = (
        db.query(Follow)
        .filter(Follow.follower_id == me.id, Follow.following_id == user_id)
        .first()
        is not None
    )
    return ProfileOut(
        id=user.id,
        email=user.email if user.id == me.id else f"hidden_{user.id}@balqici.local",
        username=user.username,
        bio=user.bio,
        avatar_url=user.avatar_url,
        created_at=user.created_at,
        catches_count=catches_count,
        species_count=species_count,
        followers_count=followers,
        following_count=following,
        is_following=is_following,
    )


@router.post("/{user_id}/follow")
def follow(user_id: int, me: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if user_id == me.id:
        raise HTTPException(400, "Özünüzü izləyə bilməzsiniz")
    target = db.get(User, user_id)
    if not target:
        raise HTTPException(404, "İstifadəçi tapılmadı")
    existing = (
        db.query(Follow).filter(Follow.follower_id == me.id, Follow.following_id == user_id).first()
    )
    if existing:
        db.delete(existing)
        db.commit()
        return {"following": False}
    db.add(Follow(follower_id=me.id, following_id=user_id))
    db.commit()
    return {"following": True}
