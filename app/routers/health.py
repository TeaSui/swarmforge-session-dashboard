"""Health check router exposing GET /health."""

from __future__ import annotations

import time
from datetime import datetime, timezone

from fastapi import APIRouter
from pydantic import BaseModel

from app.config import settings

router = APIRouter(tags=["health"])

# Module-level start time so uptime is measured from import (application start).
_START_TIME: float = time.monotonic()


class HealthResponse(BaseModel):
    """Schema returned by the /health endpoint."""

    status: str
    version: str
    uptime_seconds: float
    timestamp: str


@router.get("/health", response_model=HealthResponse, summary="System health check")
def get_health() -> HealthResponse:
    """Return system status, version, uptime, and current UTC timestamp."""
    uptime = round(time.monotonic() - _START_TIME, 3)
    return HealthResponse(
        status="ok",
        version=settings.app_version,
        uptime_seconds=uptime,
        timestamp=datetime.now(timezone.utc).isoformat(),
    )
