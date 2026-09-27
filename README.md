# Balıqçı 🎣

Azərbaycan balıqçıları üçün mobil MVP — **foto → AI identifikasiya → ov → kolleksiya albomu**.

Gamification = **Fish Collection album** (token/crypto/coin/points yoxdur). Nailiyyətlər/badges OK.

## Stack

| Layer | Tech |
|-------|------|
| Mobile | Flutter (Riverpod, Dio, go_router, flutter_map) |
| API | FastAPI + SQLAlchemy + PostgreSQL |
| AI | `AIService` → `GeminiFishIdentifier` **və ya** `MockFishIdentifier` |

## Quick start

### 1. Environment

```bash
cp .env.example .env
# İstəyə görə GEMINI_API_KEY əlavə edin — boş qalsa Mock AI işləyir
```

### 2. Backend (Docker — tövsiyə)

```bash
docker compose up --build
# API: http://localhost:8000
# Docs: http://localhost:8000/docs
# Seed avtomatik startup-da işləyir (~60 AZ balıq növü)
```

### 3. Backend (lokal PostgreSQL)

```bash
cd backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export DATABASE_URL=postgresql+psycopg2://balqici:balqici@localhost:5432/balqici
export PYTHONPATH=.
uvicorn app.main:app --reload --port 8080
```

> Qeyd: SQLAlchemy üçün `postgresql+psycopg2://` URL-i istifadə edin.

### 4. Flutter

```bash
cd mobile
flutter pub get
# Emulator/Android üçün host:
flutter run --dart-define=API_BASE=http://10.0.2.2:8080
# iOS simulator / desktop:
flutter run --dart-define=API_BASE=http://127.0.0.1:8080
```

Default API base: `http://127.0.0.1:8080`.

## Critical MVP flow

```
USER → photo → AI identify → species → create catch
     → check collection → NEW SPECIES? → add + discovery UI → optional share
```

- `POST /api/scan/identify` — multipart image
- `POST /api/scan/confirm` — weight/length/bait/… + collection unlock  
  **AI çəki təyin etmir** — çəki istifadəçi daxil edir.

## Architecture (AI)

```
services/ai/
  base.py      # FishIdentifier ABC
  gemini.py    # GeminiFishIdentifier (GEMINI_API_KEY set)
  mock.py      # MockFishIdentifier (filename/hash → realistic AZ species)
  factory.py   # get_fish_identifier()
```

## API endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health + AI mode |
| POST | `/api/auth/register` | Register |
| POST | `/api/auth/login` | Login |
| GET | `/api/auth/me` | Current user |
| GET | `/api/fish-species/` | List species (`?category=&q=`) |
| GET | `/api/fish-species/{id}` | Species detail |
| GET/POST | `/api/catches/` | User catches CRUD |
| GET | `/api/collection/` | Progress + items |
| GET | `/api/collection/album` | Locked silhouettes album |
| POST | `/api/scan/identify` | AI identify |
| POST | `/api/scan/confirm` | Confirm catch + discovery |
| GET/POST | `/api/posts/` | Feed |
| POST | `/api/posts/{id}/like` | Like toggle |
| POST | `/api/posts/{id}/comments` | Comment |
| GET | `/api/users/{id}/profile` | Profile |
| POST | `/api/users/{id}/follow` | Follow toggle |
| GET | `/api/map/activity` | Approx public catches + spots |
| GET | `/api/map/spots` | Fishing spots |
| GET | `/api/recipes/` | Recipes |
| GET | `/api/tutorials/` | Tutorials |
| POST | `/api/tutorials/{id}/complete` | Mark complete |
| GET | `/api/achievements/` | Achievements |
| GET | `/api/marketplace/` | Demo products |

## Privacy

- Default catch privacy: `private`
- Map yalnız `public_approx` ovları göstərir və koordinatları jitter ilə **təxmini** edir

## MVP vs later

**MVP (indi):** JWT local auth, mock/Gemini scan, collection album, feed, map OSM, recipes/tutorials/marketplace demo.

**Later:** Supabase/Firebase auth swap (`AuthProvider` protocol), WebSockets realtime feed, native push, richer Gemini vision, payments.

## Mobile UI

Bottom nav (AZ): **Ana səhifə | Xəritə | Skan | Lent | Profil**

Theme: deep teal / water blues / soft greens — outdoor fishing aesthetic.

## Local notes (this environment)

- PostgreSQL 17 runs locally; API verified on **port 8080** (`uvicorn`).
- Docker Engine was **not** installed here — `docker-compose.yml` is ready for when Docker is available (`ports 8000:8000`).
- Flutter SDK installed at `/opt/flutter` (3.24.5); `flutter analyze` clean.
- Without `GEMINI_API_KEY`, MockFishIdentifier is used automatically.

### Demo account (after first register)

```
email: demo@balqici.az
password: secret12
```
