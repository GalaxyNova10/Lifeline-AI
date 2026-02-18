"""
Script: profile.py
Role: User Medical Profile API
Author: Member 3 (Backend Lead)
"""

from fastapi import APIRouter, Depends
from backend.app.routers.auth_dep import get_current_user

router = APIRouter(prefix="/users", tags=["Profile"])


@router.get("/profile/medical")
async def get_medical_profile(user: dict = Depends(get_current_user)):
    """
    Returns the user's full medical profile from the database.
    Includes: name, age, blood_type, allergies, chronic_conditions,
              emergency_contact, qr_token, heart_rate (latest).
    """
    # user dict already fetched by get_current_user (includes latest vital)
    return {
        "status": "success",
        "profile": {
            "name": user.get("name"),
            "age": user.get("age"),
            "blood_type": user.get("blood_type"),
            "allergies": user.get("allergies"),
            "chronic_conditions": user.get("chronic_conditions"),
            "emergency_contact": user.get("emergency_contact"),
            "qr_token": user.get("qr_token"),
            "heart_rate": user.get("heart_rate"),
            "last_vital_time": user.get("last_vital_time"),
        },
    }
