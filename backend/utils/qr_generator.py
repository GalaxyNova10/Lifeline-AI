"""
Script: qr_generator.py
Role: Emergency QR Code Image Generator
Author: Member 3 (Backend Lead)
"""
import qrcode
import os

# Create a folder to store the generated QR images
QR_STORAGE = os.path.join(os.getcwd(), "backend/static/qr_codes")
os.makedirs(QR_STORAGE, exist_ok=True)

def generate_emergency_qr(token):
    """
    Takes a unique token and generates a QR code image.
    The QR code will eventually point to the API endpoint for that user.
    """
    # For now, the QR contains the token itself. 
    # In a full deployment, this would be a URL like: https://lifeline.ai/emergency/{token}
    qr_data = f"LIFELINE_EMERGENCY_{token}"
    
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(qr_data)
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")
    
    file_name = f"qr_{token}.png"
    file_path = os.path.join(QR_STORAGE, file_name)
    
    img.save(file_path)
    print(f"✅ Emergency QR Code generated: {file_path}")
    return file_path

if __name__ == "__main__":
    # Test with your recently generated Emergency ID
    # Note: Using the ID from the previous step's output (authentication test)
    test_token = "6B438529" 
    generate_emergency_qr(test_token)
