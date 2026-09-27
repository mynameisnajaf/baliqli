from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.content import Tutorial, TutorialProgress
from app.models.user import User
from app.schemas.content import TutorialOut
from app.services.auth import get_current_user, get_optional_user

router = APIRouter()


def _out(t: Tutorial, completed: bool = False) -> TutorialOut:
    return TutorialOut(
        id=t.id,
        title_az=t.title_az,
        thumbnail_url=t.thumbnail_url,
        description_az=t.description_az,
        content_md=t.content_md,
        video_url=t.video_url,
        difficulty=t.difficulty,
        duration_min=t.duration_min,
        category=t.category,
        completed=completed,
    )


@router.get("/", response_model=list[TutorialOut])
def list_tutorials(
    user: User | None = Depends(get_optional_user),
    db: Session = Depends(get_db),
):
    completed_ids: set[int] = set()
    if user:
        completed_ids = {
            r.tutorial_id
            for r in db.query(TutorialProgress).filter(TutorialProgress.user_id == user.id)
        }
    return [_out(t, t.id in completed_ids) for t in db.query(Tutorial).all()]


@router.get("/{tutorial_id}", response_model=TutorialOut)
def get_tutorial(
    tutorial_id: int,
    user: User | None = Depends(get_optional_user),
    db: Session = Depends(get_db),
):
    t = db.get(Tutorial, tutorial_id)
    if not t:
        raise HTTPException(404, "Dərs tapılmadı")
    completed = False
    if user:
        completed = (
            db.query(TutorialProgress)
            .filter(TutorialProgress.user_id == user.id, TutorialProgress.tutorial_id == tutorial_id)
            .first()
            is not None
        )
    return _out(t, completed)


@router.post("/{tutorial_id}/complete")
def complete(tutorial_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    t = db.get(Tutorial, tutorial_id)
    if not t:
        raise HTTPException(404, "Dərs tapılmadı")
    existing = (
        db.query(TutorialProgress)
        .filter(TutorialProgress.user_id == user.id, TutorialProgress.tutorial_id == tutorial_id)
        .first()
    )
    if not existing:
        db.add(TutorialProgress(user_id=user.id, tutorial_id=tutorial_id))
        db.commit()
    return {"completed": True}
