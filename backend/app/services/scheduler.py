"""
Script: scheduler.py (Gold Master)
Role: Dynamic Queuing & Hospital Specialization
"""
from datetime import datetime, timedelta

def calculate_appointment_time(priority_score, queue_length, predicted_condition):
    # Base wait time logic
    now = datetime.now()
    
    # Load Balancing: Check if the condition matches hospital specialization 
    # In a full app, this would query different hospital APIs
    specialization_match = False
    
    # Updated to include potential ML outputs AND manual overrides
    cardiac_conditions = [
        "Potential Cardiac Event", 
        "Hypertension Crisis", 
        "Cardiac Arrest", 
        "Stroke", 
        "Heart Attack"
    ]
    
    # String partial matching to be safe
    if any(c.lower() in predicted_condition.lower() for c in cardiac_conditions):
        specialization_match = True
        wait_multiplier = 0.5  # Faster processing at a Cardiac Center
    else:
        wait_multiplier = 1.0

    # Calculate wait [cite: 25]
    if priority_score >= 90:
        wait_mins = 0
    elif priority_score >= 70:
        wait_mins = 15 + (queue_length * 2 * wait_multiplier)
    else:
        wait_mins = 45 + (queue_length * 5 * wait_multiplier)

    recommendation = "Specialized Care: Cardiac Wing" if specialization_match else "General ER"

    return {
        "severity": "Critical" if priority_score >= 90 else "Standard",
        "estimated_wait_minutes": int(wait_mins),
        "appointment_time": (now + timedelta(minutes=wait_mins)).strftime("%I:%M %p"),
        "recommendation": recommendation
    }
