from fastapi import APIRouter

from . import achievements, auth, catches, collection, fish_species, map_routes, marketplace, posts, recipes, scan, tutorials, users

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(fish_species.router, prefix="/fish-species", tags=["fish-species"])
api_router.include_router(catches.router, prefix="/catches", tags=["catches"])
api_router.include_router(collection.router, prefix="/collection", tags=["collection"])
api_router.include_router(scan.router, prefix="/scan", tags=["scan"])
api_router.include_router(posts.router, prefix="/posts", tags=["posts"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(map_routes.router, prefix="/map", tags=["map"])
api_router.include_router(recipes.router, prefix="/recipes", tags=["recipes"])
api_router.include_router(tutorials.router, prefix="/tutorials", tags=["tutorials"])
api_router.include_router(achievements.router, prefix="/achievements", tags=["achievements"])
api_router.include_router(marketplace.router, prefix="/marketplace", tags=["marketplace"])
