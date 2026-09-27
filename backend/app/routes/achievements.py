from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.gamification import Achievement, UserAchievement
from app.models.user import User
from app.schemas.content import AchievementOut
from app.services.auth import get_current_user

router = APIRouter()


@router.get("/", response_model=list[AchievementOut])
def list_achievements(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    unlocked = {
        ua.achievement_id: ua.unlocked_at
        for ua in db.query(UserAchievement).filter(UserAchievement.user_id == user.id)
    }
    out = []
    for a in db.query(Achievement).all():
        out.append(
            AchievementOut(
                id=a.id,
                code=a.code,
                title_az=a.title_az,
                description_az=a.description_az,
                icon=a.icon,
                category=a.category,
                unlocked=a.id in unlocked,
                unlocked_at=unlocked.get(a.id),
            )
        )
    return out
