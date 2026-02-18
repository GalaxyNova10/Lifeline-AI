




import cv2
import sys
import time

# Ensure we can import from backend
try:
    from backend.rppg_engine import RPPGHeartRateEngine
except ImportError:
    # If running from root, this should work. If not, add current dir to path
    sys.path.append(".")
    from backend.rppg_engine import RPPGHeartRateEngine

def main():
    print("Initializing rPPG Engine...")
    # Initialize the engine
    rppg = RPPGHeartRateEngine(buffer_size=150, fps=30) # Using smaller buffer for faster initial reading
    
    print("Opening Webcam...")
    cap = cv2.VideoCapture(0)
    
    if not cap.isOpened():
        print("Error: Could not open webcam.")
        return

    print("Press 'q' to quit.")
    print("Look at the camera and keep your head still.")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Error: Failed to capture frame.")
            break

        # Process the frame
        bpm = rppg.process_frame(frame)
        
        # Display the result on the frame
        if bpm is not None:
            text = f"Heart Rate: {bpm:.1f} BPM"
            color = (0, 255, 0) # Green
            print(f"\r{text}", end="")
        else:
            text = "Calibrating/No Face..."
            color = (0, 0, 255) # Red
            print(f"\r{text}", end="")
            
        cv2.putText(frame, text, (20, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2)
        
        # Draw face landmarks (optional, just for strict visual feedback that it's working)
        # We won't draw full mesh here to keep it simple, but the text proves it's running.

        cv2.imshow('rPPG Heart Rate Monitor', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
    print("\nExiting.")

if __name__ == "__main__":
    main()
