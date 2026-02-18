"""
Script: doctor.py
Role: Doctor Dashboard API — Patient list sorted by urgency
Author: Member 3 (Backend Lead)
"""

import sqlite3
from fastapi import APIRouter, Depends
from backend.database.models import DB_PATH
from backend.app.routers.auth_dep import get_current_user

router = APIRouter(prefix="/doctor", tags=["Doctor"])


@router.get("/patients")
async def get_patients(user: dict = Depends(get_current_user)):
    """
    Returns all registered patients sorted by their latest heart rate
    (descending — higher BPM = higher urgency).

    Each patient includes: id, name, age, blood_type, chronic_conditions,
    latest_bpm, latest_vital_time, urgency_score (derived).
    """
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Left-join users with their latest vital reading
    # Urgency score: BPM deviation from normal (72) + age factor
    cursor.execute(
        """
        SELECT
            u.id,
            u.name,
            u.age,
            u.blood_type,
            u.chronic_conditions,
            u.qr_token,
            v.bpm     AS latest_bpm,
            v.timestamp AS latest_vital_time
        FROM users u
        LEFT JOIN (
            SELECT user_token, bpm, timestamp,
                   ROW_NUMBER() OVER (PARTITION BY user_token ORDER BY id DESC) AS rn
            FROM vitals
        ) v ON v.user_token = u.qr_token AND v.rn = 1
        ORDER BY v.bpm DESC NULLS LAST
        """
    )

    patients = []
    for row in cursor.fetchall():
        p = dict(row)
        # Derive urgency score: abs BPM deviation from 72 + age weight
        bpm = p.get("latest_bpm")
        age = p.get("age") or 30
        if bpm is not None:
            urgency = min(int(abs(bpm - 72) * 1.5 + (age / 5)), 100)
        else:
            urgency = 0
        p["urgency_score"] = urgency
        patients.append(p)

    conn.close()

    # Re-sort by urgency_score descending (in case BPM ordering differs)
    patients.sort(key=lambda x: x["urgency_score"], reverse=True)

    return {"status": "success", "count": len(patients), "patients": patients}
