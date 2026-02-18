"""
Script: create_doctor.py
Role: Seed a Doctor account into the database for testing
Author: Member 3 (Backend Lead)

Usage: python -m backend.create_doctor
  (run from project root with venv active)
"""

import sqlite3
import uuid
from backend.database.models import DB_PATH, init_db


def create_doctor():
    """Insert a test doctor account into the users table."""
    # Ensure DB and tables exist
    init_db()

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Check if doctor already exists
    cursor.execute("SELECT id FROM users WHERE name = ?", ("Dr. Strange",))
    if cursor.fetchone():
        print("⚠️  Doctor account already exists. Skipping.")
        conn.close()
        return

    qr_token = str(uuid.uuid4())[:8].upper()

    cursor.execute(
        """
        INSERT INTO users (name, age, blood_type, allergies, chronic_conditions, emergency_contact, qr_token)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        (
            "Dr. Strange",    # name
            42,               # age
            "A+",             # blood_type
            "None",           # allergies
            "None",           # chronic_conditions
            "doctor@test.com",  # emergency_contact (storing email here for demo)
            qr_token,         # qr_token
        ),
    )

    conn.commit()
    conn.close()
    print(f"✅ Doctor account created!")
    print(f"   Name:  Dr. Strange")
    print(f"   Token: {qr_token}")
    print(f"   Use this token to log in as doctor.")


if __name__ == "__main__":
    create_doctor()
