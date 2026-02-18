import cv2
import numpy as np
import mediapipe as mp
import scipy.signal as signal
from collections import deque

class RPPGHeartRateEngine:
    """
    A production-grade, modular Remote Photoplethysmography (rPPG) engine.
    
    This class processes video frames to estimate heart rate by analyzing the 
    green channel intensity variations in the forehead region. It uses MediaPipe 
    Face Mesh for robust ROI extraction and signal processing techniques (bandpass 
    filtering, FFT) to isolate the pulse signal.
    """
    
    def __init__(self, buffer_size=300, fps=30):
        """
        Initialize the RPPG engine.
        
        Args:
            buffer_size (int): The size of the signal buffer (number of frames).
                               Default is 300 (approx. 10 seconds at 30 FPS).
            fps (int): The expected frame rate of the input video stream.
                       Default is 30.
        """
        self.buffer_size = buffer_size
        self.fps = fps
        self.signal_buffer = deque(maxlen=buffer_size)
        
        # Initialize MediaPipe Face Mesh
        self.mp_face_mesh = mp.solutions.face_mesh
        self.face_mesh = self.mp_face_mesh.FaceMesh(
            static_image_mode=False,
            max_num_faces=1,
            refine_landmarks=True,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        
        # Forehead landmarks indices (MediaPipe Face Mesh)
        # These indices cover the central forehead region, which is rich in blood perfusion 
        # and generally less affected by facial expressions than other areas.
        self.forehead_indices = [10, 338, 297, 332, 284, 251, 389, 356]
        
        # Optimization & Robustness
        self.calc_interval = 15  # Calculate BPM every 15 frames (approx 0.5s at 30fps)
        self.frame_counter = 0
        self.last_bpm = None
        self.no_face_frames = 0
        self.max_no_face_frames = 30 # Clear buffer after 1 second of no face

    def process_frame(self, frame_bgr):
        """
        Process a single BGR frame to estimate heart rate.
        
        Args:
            frame_bgr (numpy.ndarray): Input video frame in BGR format.
            
        Returns:
            float or None: Estimated Heart Rate in BPM (Beats Per Minute), 
                           or None if the buffer is not full or no face is detected.
        """
        if frame_bgr is None:
            return self.last_bpm

        # Convert BGR to RGB for MediaPipe
        frame_rgb = cv2.cvtColor(frame_bgr, cv2.COLOR_BGR2RGB)
        results = self.face_mesh.process(frame_rgb)
        
        if not results.multi_face_landmarks:
            self.no_face_frames += 1
            if self.no_face_frames > self.max_no_face_frames:
                self.signal_buffer.clear()
                self.last_bpm = None
                self.no_face_frames = 0 # Reset counter after clearing
            return self.last_bpm
            
        # Face found, reset counter
        self.no_face_frames = 0
            
        # Get the first detected face
        face_landmarks = results.multi_face_landmarks[0]
        h, w, _ = frame_bgr.shape
        
        # Extract forehead ROI points
        roi_points = []
        for idx in self.forehead_indices:
            lm = face_landmarks.landmark[idx]
            x, y = int(lm.x * w), int(lm.y * h)
            roi_points.append([x, y])
            
        roi_points = np.array(roi_points, dtype=np.int32)
        
        # Create a mask for the ROI
        mask = np.zeros((h, w), dtype=np.uint8)
        cv2.fillConvexPoly(mask, roi_points, 1)
        
        # Extract the green channel and compute the mean intensity within the ROI
        # storage order is BGR, so Green is at index 1
        green_channel = frame_bgr[:, :, 1]
        mean_green = cv2.mean(green_channel, mask=mask)[0]
        
        # Add to buffer
        self.signal_buffer.append(mean_green)
        self.frame_counter += 1
        
        # Check if buffer is full enough to process
        if len(self.signal_buffer) < self.buffer_size:
            return None
            
        # Optimization: Only calculate BPM every `calc_interval` frames
        if self.frame_counter % self.calc_interval == 0:
            bpm = self._calculate_heart_rate()
            if bpm is not None:
                self.last_bpm = bpm
                
        return self.last_bpm

    def _calculate_heart_rate(self):
        """
        Perform signal processing to extract heart rate from the buffered signal.
        
        Returns:
            float or None: Calculated BPM, or None if signal is too noisy/invalid.
        """
        # Convert buffer to numpy array
        raw_signal = np.array(self.signal_buffer)
        
        # 1. Detrending: Subtract the mean to center the signal
        detrended_signal = raw_signal - np.mean(raw_signal)
        
        # 2. Filtration: Apply Bandpass Filter (0.7 Hz - 4.0 Hz)
        # This range corresponds to 42 BPM - 240 BPM
        nyquist = 0.5 * self.fps
        low = 0.7 / nyquist
        high = 4.0 / nyquist
        
        # Use a 2nd order Butterworth filter
        b, a = signal.butter(2, [low, high], btype='band')
        filtered_signal = signal.filtfilt(b, a, detrended_signal)
        
        # 3. FFT: Find dominant frequency
        # Use rfft for real-valued input, which is faster and returns positive frequencies
        fft_spectrum = np.abs(np.fft.rfft(filtered_signal))
        freqs = np.fft.rfftfreq(len(filtered_signal), 1.0 / self.fps)
        
        # Find the peak frequency in the valid range
        # Note: The filter already dampened frequencies outside 0.7-4.0 Hz, 
        # but we strictly check the bounds for the peak selection as well.
        valid_idx = np.where((freqs >= 0.7) & (freqs <= 4.0))
        valid_spectrum = fft_spectrum[valid_idx]
        valid_freqs = freqs[valid_idx]
        
        if len(valid_spectrum) == 0:
            return None
            
        peak_idx = np.argmax(valid_spectrum)
        dominant_freq = valid_freqs[peak_idx]
        
        # Convert to BPM
        bpm = dominant_freq * 60.0
        
        # 4. Sanity Check
        if 40 <= bpm <= 200:
            return float(bpm)
        else:
            return None
