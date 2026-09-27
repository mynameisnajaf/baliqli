from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from app.database.session import get_db
from app.models.catch import Catch
from app.models.social import Comment, Post, PostLike
from app.models.user import User
from app.schemas.catch import CatchOut
from app.schemas.fish import FishSpeciesOut
from app.schemas.social import CommentCreate, CommentOut, PostCreate, PostOut
from app.services.auth import get_current_user

router = APIRouter()


def _post_out(post: Post, me: User, db: Session) -> PostOut:
    liked = (
        db.query(PostLike).filter(PostLike.post_id == post.id, PostLike.user_id == me.id).first() is not None
    )
    catch_out = None
    if post.catch:
        c = post.catch
        catch_out = CatchOut(
            id=c.id,
            user_id=c.user_id,
            fish_species_id=c.fish_species_id,
            image_url=c.image_url,
            weight_kg=c.weight_kg,
            length_cm=c.length_cm,
            latitude=None if c.privacy == "private" else c.latitude,
            longitude=None if c.privacy == "private" else c.longitude,
            location_name=c.location_name,
            bait=c.bait,
            fishing_method=c.fishing_method,
            released=c.released,
            privacy=c.privacy,
            notes=c.notes,
            ai_confidence=c.ai_confidence,
            created_at=c.created_at,
            species=FishSpeciesOut.model_validate(c.species) if c.species else None,
        )
    comments = [
        CommentOut(
            id=cm.id,
            post_id=cm.post_id,
            user_id=cm.user_id,
            username=cm.user.username if cm.user else None,
            body=cm.body,
            created_at=cm.created_at,
        )
        for cm in (post.comments or [])
    ]
    return PostOut(
        id=post.id,
        user_id=post.user_id,
        username=post.user.username if post.user else None,
        catch_id=post.catch_id,
        caption=post.caption,
        likes_count=post.likes_count,
        created_at=post.created_at,
        liked_by_me=liked,
        catch=catch_out,
        comments=comments,
    )


@router.get("/", response_model=list[PostOut])
def feed(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    posts = (
        db.query(Post)
        .options(
            joinedload(Post.user),
            joinedload(Post.catch).joinedload(Catch.species),
            joinedload(Post.comments).joinedload(Comment.user),
        )
        .order_by(Post.created_at.desc())
        .limit(50)
        .all()
    )
    return [_post_out(p, user, db) for p in posts]


@router.post("/", response_model=PostOut)
def create_post(body: PostCreate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if body.catch_id:
        catch = db.get(Catch, body.catch_id)
        if not catch or catch.user_id != user.id:
            raise HTTPException(404, "Ov tapılmadı")
    post = Post(user_id=user.id, catch_id=body.catch_id, caption=body.caption)
    db.add(post)
    db.commit()
    post = (
        db.query(Post)
        .options(
            joinedload(Post.user),
            joinedload(Post.catch).joinedload(Catch.species),
            joinedload(Post.comments).joinedload(Comment.user),
        )
        .filter(Post.id == post.id)
        .one()
    )
    return _post_out(post, user, db)


@router.post("/{post_id}/like")
def like_post(post_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    post = db.get(Post, post_id)
    if not post:
        raise HTTPException(404, "Paylaşım tapılmadı")
    existing = db.query(PostLike).filter(PostLike.post_id == post_id, PostLike.user_id == user.id).first()
    if existing:
        db.delete(existing)
        post.likes_count = max(0, post.likes_count - 1)
        db.commit()
        return {"liked": False, "likes_count": post.likes_count}
    db.add(PostLike(post_id=post_id, user_id=user.id))
    post.likes_count += 1
    db.commit()
    return {"liked": True, "likes_count": post.likes_count}


@router.post("/{post_id}/comments", response_model=CommentOut)
def add_comment(
    post_id: int,
    body: CommentCreate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    post = db.get(Post, post_id)
    if not post:
        raise HTTPException(404, "Paylaşım tapılmadı")
    cm = Comment(post_id=post_id, user_id=user.id, body=body.body)
    db.add(cm)
    db.commit()
    db.refresh(cm)
    return CommentOut(
        id=cm.id,
        post_id=cm.post_id,
        user_id=cm.user_id,
        username=user.username,
        body=cm.body,
        created_at=cm.created_at,
    )
