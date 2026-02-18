"""
Script: auth_dep.py
Role: FastAPI dependency for token-based authentication
Author: Member 3 (Backend Lead)
"""

from fastapi import Query, HTTPException
from backend.database.auth import get_user_by_token


async def get_current_user(token: str = Query(..., description="User's QR token")):
    """
    Dependency that validates a user token and returns the user dict.
    Usage: user = Depends(get_current_user)
    """
    user = get_user_by_token(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    return user
