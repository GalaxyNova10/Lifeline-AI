"""
Script: appointments.py
Role: Queue Management API
Author: Member 4 (Coordinator)
"""

from fastapi import APIRouter
from backend.app.services.scheduler import calculate_appointment_time

router = APIRouter(prefix="/appointments", tags=["Scheduling"])

# Mock database for current queue (Member 3 will eventually link real DB)
MOCK_QUEUE_COUNT = 4 

@router.get("/calculate")
async def get_wait_time(score: int):
    """Returns the dynamic appointment slot based on AI priority score."""
    schedule = calculate_appointment_time(score, MOCK_QUEUE_COUNT)
    return schedule
