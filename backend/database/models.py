"""
Script: models.py
Role: Database Schema for Health Passport
Author: Member 3 (Backend Lead)
"""
import sqlite3
import os

# Define the database path in the root directory for easy access
DB_PATH = os.path.join(os.getcwd(), "lifeline_identity.db")

def init_db():
    """Initializes the SQLite database and creates the User table."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # We store name, age, blood type, and critical medical alerts
    # qr_token is a unique string used to fetch this data during emergencies
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER,
            blood_type TEXT,
            allergies TEXT,
            chronic_conditions TEXT,
            emergency_contact TEXT,
            qr_token TEXT UNIQUE
        );
    ''')
    
    # Create Vitals Table for rPPG History
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS vitals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_token TEXT NOT NULL,
            bpm REAL NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_token) REFERENCES users(qr_token)
        )
    ''')
    
    conn.commit()
    conn.close()
    print(f"✅ Database initialized at: {DB_PATH}")

if __name__ == "__main__":
    init_db()
