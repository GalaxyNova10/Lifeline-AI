"""
Script: history.py
Role: Vitals History & Dashboard Stats API
Author: Member 3 (Backend Lead)
"""

import sqlite3
from fastapi import APIRouter, Depends
from backend.database.models import DB_PATH
from backend.app.routers.auth_dep import get_current_user

router = APIRouter(tags=["History"])


@router.get("/vitals/history")
async def get_vitals_history(user: dict = Depends(get_current_user)):
    """
    Returns the user's past vitals records, newest first.
    Each record includes: id, bpm, timestamp.
    """
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute(
        "SELECT id, bpm, timestamp FROM vitals WHERE user_token = ? ORDER BY id DESC LIMIT 50",
        (user["qr_token"],),
    )
    rows = [dict(r) for r in cursor.fetchall()]
    conn.close()

    return {"status": "success", "count": len(rows), "records": rows}


@router.get("/dashboard/stats")
async def get_dashboard_stats(user: dict = Depends(get_current_user)):
    """
    Returns calculated averages from the user's vitals records.
    Includes: avg_bpm, min_bpm, max_bpm, total_readings, latest_bpm.
    """
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Aggregate stats
    cursor.execute(
        """
        SELECT
            COUNT(*)    AS total_readings,
            AVG(bpm)    AS avg_bpm,
            MIN(bpm)    AS min_bpm,
            MAX(bpm)    AS max_bpm
        FROM vitals
        WHERE user_token = ?
        """,
        (user["qr_token"],),
    )
    stats = dict(cursor.fetchone())

    # Latest reading
    cursor.execute(
        "SELECT bpm, timestamp FROM vitals WHERE user_token = ? ORDER BY id DESC LIMIT 1",
        (user["qr_token"],),
    )
    latest = cursor.fetchone()
    conn.close()

    # Round floats for clean JSON
    for key in ("avg_bpm", "min_bpm", "max_bpm"):
        if stats[key] is not None:
            stats[key] = round(stats[key], 1)

    stats["latest_bpm"] = latest["bpm"] if latest else None
    stats["latest_time"] = latest["timestamp"] if latest else None

    # --- HEALTH SCORE ALGORITHM ---
    # 1. Base Score
    score = 100

    # 2. Medical History Penalty
    conditions = (user.get("chronic_conditions") or "").lower()
    # "If diabetes or hypertension in list: score -= 10" (Combined penalty)
    if "diabetes" in conditions or "hypertension" in conditions:
        score -= 10
    
    # Asthma removed from requirements


    # 3. Visit Penalty (High Urgency Scans)
    # Fetch last 30 days of vitals (approximated by last 50 records)
    cursor.execute(
        "SELECT bpm FROM vitals WHERE user_token = ? ORDER BY id DESC LIMIT 50",
        (user["qr_token"],),
    )
    recent_vitals = [r["bpm"] for r in cursor.fetchall()]
    
    # High Urgency Definition: BPM > 100 or BPM < 60
    high_urgency_count = sum(1 for bpm in recent_vitals if bpm > 100 or bpm < 60)
    score -= (high_urgency_count * 5)

    # Clamp score
    score = max(0, min(100, score))

    # Determine Trend
    trend = "stable"
    if len(recent_vitals) >= 3:
        latest_3 = recent_vitals[:3]
        prev_3 = recent_vitals[3:6]
        
        if prev_3: # Ensure we have previous data
            avg_latest = sum(latest_3) / len(latest_3)
            avg_prev = sum(prev_3) / len(prev_3)
            
            if avg_latest > avg_prev * 1.05:
                trend = "declining" # BPM rising significantly
            elif avg_latest < avg_prev * 0.95:
                trend = "improving" # BPM dropping significantly

    stats["health_score"] = score
    stats["trend"] = trend

    return {"status": "success", "stats": stats}
