"""Unit tests for the /health endpoint."""

from __future__ import annotations

import time
from datetime import datetime, timezone
from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.routers import health as health_module

FIXED_VERSION = "1.2.3"
FIXED_MONOTONIC_START = 1_000.0
FIXED_MONOTONIC_NOW = 1_045.678
EXPECTED_UPTIME = round(FIXED_MONOTONIC_NOW - FIXED_MONOTONIC_START, 3)


@pytest.fixture()
def client() -> TestClient:
    return TestClient(app)


def _patch_health(version: str = FIXED_VERSION):
    """Context manager that patches time and settings for deterministic tests."""
    return (
        patch.object(health_module, "_START_TIME", FIXED_MONOTONIC_START),
        patch("app.routers.health.time.monotonic", return_value=FIXED_MONOTONIC_NOW),
        patch("app.routers.health.settings", **{"app_version": version}),
    )


class TestHealthEndpoint:
    """Tests for GET /health."""

    def test_status_code_is_200(self, client: TestClient) -> None:
        response = client.get("/health")
        assert response.status_code == 200

    def test_response_contains_required_keys(self, client: TestClient) -> None:
        response = client.get("/health")
        body = response.json()
        assert {"status", "version", "uptime_seconds", "timestamp"} <= body.keys()

    def test_status_is_ok(self, client: TestClient) -> None:
        response = client.get("/health")
        assert response.json()["status"] == "ok"

    def test_version_matches_settings(self, client: TestClient) -> None:
        with patch("app.routers.health.settings") as mock_settings:
            mock_settings.app_version = FIXED_VERSION
            response = client.get("/health")
        assert response.json()["version"] == FIXED_VERSION

    def test_uptime_is_non_negative(self, client: TestClient) -> None:
        response = client.get("/health")
        assert response.json()["uptime_seconds"] >= 0

    def test_uptime_calculation(self, client: TestClient) -> None:
        with (
            patch.object(health_module, "_START_TIME", FIXED_MONOTONIC_START),
            patch("app.routers.health.time.monotonic", return_value=FIXED_MONOTONIC_NOW),
        ):
            response = client.get("/health")
        assert response.json()["uptime_seconds"] == pytest.approx(EXPECTED_UPTIME)

    def test_timestamp_is_valid_iso8601(self, client: TestClient) -> None:
        response = client.get("/health")
        ts = response.json()["timestamp"]
        # Should parse without raising.
        parsed = datetime.fromisoformat(ts)
        assert parsed.tzinfo is not None, "Timestamp must be timezone-aware"

    def test_timestamp_is_recent(self, client: TestClient) -> None:
        before = datetime.now(timezone.utc)
        response = client.get("/health")
        after = datetime.now(timezone.utc)
        ts = datetime.fromisoformat(response.json()["timestamp"])
        assert before <= ts <= after

    def test_content_type_is_json(self, client: TestClient) -> None:
        response = client.get("/health")
        assert "application/json" in response.headers["content-type"]

    def test_uptime_increases_over_time(self, client: TestClient) -> None:
        """Two consecutive calls should yield a non-decreasing uptime."""
        first = client.get("/health").json()["uptime_seconds"]
        time.sleep(0.01)
        second = client.get("/health").json()["uptime_seconds"]
        assert second >= first
