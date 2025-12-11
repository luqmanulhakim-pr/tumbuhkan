import cv2
from flask import Flask, Response, request, jsonify
import os
from datetime import datetime

app = Flask(__name__)

# Folder untuk menyimpan foto yang dikirim
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# 0 biasanya adalah ID untuk webcam default laptop
camera = cv2.VideoCapture(0)

def generate_frames():
    while True:
        ## Baca frame dari kamera
        success, frame = camera.read()
        if not success:
            break
        
        ## Encode frame ke format JPEG
        ret, buffer = cv2.imencode('.jpg', frame)
        frame = buffer.tobytes()
        
        ## Yield frame dalam format multipart (MJPEG standard)
        ## Format ini PERSIS sama dengan yang dikirim ESP32-CAM
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

@app.route('/stream')
def video_feed():
    ## Route ini yang nanti akan dipanggil oleh Flutter
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/upload', methods=['POST'])
def upload_image():
    """Endpoint untuk menerima foto dari Flutter"""
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'}), 400
        
        file = request.files['image']
        
        if file.filename == '':
            return jsonify({'error': 'No selected file'}), 400
        
        # Generate unique filename dengan timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'photo_{timestamp}.jpg'
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        
        # Simpan file
        file.save(filepath)
        
        return jsonify({
            'success': True,
            'message': 'Image uploaded successfully',
            'filename': filename,
            'filepath': filepath
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/images')
def list_images():
    try:
        images = os.listdir(UPLOAD_FOLDER)
        images.sort(reverse=True)  # Urutkan dari yang terbaru
        return jsonify({
            'success': True,
            'count': len(images),
            'images': images
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)