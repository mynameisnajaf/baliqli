"""Integration-ish tests against a running DB — run after seed."""
import io

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture(scope="module")
def client():
    with TestClient(app) as c:
        yield c


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_register_login_scan_confirm(client):
    email = "mvp_tester@balqici.az"
    # cleanup-ish: register may fail if exists
    r = client.post("/api/auth/register", json={"email": email, "username": "mvp_tester", "password": "secret12"})
    if r.status_code != 200:
        r = client.post("/api/auth/login", json={"email": email, "password": "secret12"})
    assert r.status_code == 200
    token = r.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    me = client.get("/api/auth/me", headers=headers)
    assert me.status_code == 200

    species = client.get("/api/fish-species/", headers=headers)
    assert species.status_code == 200
    assert len(species.json()) >= 40

    img = io.BytesIO(b"\xff\xd8\xff\xe0" + b"fakejpegcontent" * 50)
    scan = client.post(
        "/api/scan/identify",
        headers=headers,
        files={"image": ("sazan_test.jpg", img, "image/jpeg")},
    )
    assert scan.status_code == 200
    data = scan.json()
    assert "species" in data
    assert data["is_mock"] is True
    sid = data["species"]["id"]
    conf = data["confidence"]

    confirm = client.post(
        "/api/scan/confirm",
        headers=headers,
        json={
            "fish_species_id": sid,
            "weight_kg": 2.5,
            "length_cm": 45,
            "location_name": "Kür çayı",
            "bait": "qarğıdalı",
            "fishing_method": "olta",
            "released": False,
            "privacy": "public_approx",
            "latitude": 40.01,
            "longitude": 48.47,
            "ai_confidence": conf,
            "share": True,
            "caption": "Test ov!",
        },
    )
    assert confirm.status_code == 200
    body = confirm.json()
    assert "is_new_discovery" in body
    assert body["species"]["id"] == sid

    coll = client.get("/api/collection/", headers=headers)
    assert coll.status_code == 200
    assert coll.json()["discovered"] >= 1
