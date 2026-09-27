from datetime import datetime

from pydantic import BaseModel

from app.schemas.catch import CatchOut


class CommentCreate(BaseModel):
    body: str


class CommentOut(BaseModel):
    id: int
    post_id: int
    user_id: int
    username: str | None = None
    body: str
    created_at: datetime

    model_config = {"from_attributes": True}


class PostCreate(BaseModel):
    catch_id: int | None = None
    caption: str | None = None


class PostOut(BaseModel):
    id: int
    user_id: int
    username: str | None = None
    catch_id: int | None = None
    caption: str | None = None
    likes_count: int
    created_at: datetime
    liked_by_me: bool = False
    catch: CatchOut | None = None
    comments: list[CommentOut] = []

    model_config = {"from_attributes": True}
