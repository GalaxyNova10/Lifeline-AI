"""
Script: maps.py
Role: Nearby Hospitals API (Mock Data for Hackathon)
Author: Member 3 (Backend Lead)
"""

import random
from fastapi import APIRouter, Depends
from backend.app.routers.auth_dep import get_current_user

router = APIRouter(prefix="/hospitals", tags=["Maps"])

# Static list of hospitals near Chennai (hackathon demo data)
HOSPITALS = [
    {
        "name": "Apollo Hospitals, Greams Road",
        "lat": 13.0604,
        "lng": 80.2496,
        "address": "21 Greams Lane, Off Greams Road, Chennai",
        "type": "Multi-Specialty",
    },
    {
        "name": "MIOT International",
        "lat": 13.0105,
        "lng": 80.1700,
        "address": "4/112 Mount Poonamallee Rd, Manapakkam, Chennai",
        "type": "Super-Specialty",
    },
    {
        "name": "Fortis Malar Hospital",
        "lat": 13.0370,
        "lng": 80.2575,
        "address": "52 1st Main Rd, Gandhi Nagar, Adyar, Chennai",
        "type": "Multi-Specialty",
    },
    {
        "name": "Sri Ramachandra Medical Centre",
        "lat": 13.0432,
        "lng": 80.1424,
        "address": "1 Ramachandra Nagar, Porur, Chennai",
        "type": "Teaching Hospital",
    },
    {
        "name": "Kauvery Hospital",
        "lat": 13.0359,
        "lng": 80.2410,
        "address": "199 Luz Church Rd, Mylapore, Chennai",
        "type": "Multi-Specialty",
    },
]


@router.get("/nearby")
async def get_nearby_hospitals(user: dict = Depends(get_current_user)):
    """
    Returns a list of 5 nearby hospitals with dynamic wait times.
    Wait times are randomized per request to simulate live ER data.
    """
    result = []
    for h in HOSPITALS:
        result.append(
            {
                "name": h["name"],
                "lat": h["lat"],
                "lng": h["lng"],
                "address": h["address"],
                "type": h["type"],
                "wait_time_min": random.randint(5, 45),
            }
        )

    return {"status": "success", "count": len(result), "hospitals": result}
