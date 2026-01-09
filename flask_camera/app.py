import cv2
from flask import Flask, Response, request, jsonify
from flask_cors import CORS, cross_origin  # 🆕 Import cross_origin
import os
from datetime import datetime

app = Flask(__name__)

# ✅ FIX: CORS configuration yang lebih permissive
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type"],
        "expose_headers": ["Content-Type"],
        "supports_credentials": False
    }
})

# Folder untuk menyimpan foto
UPLOAD_FOLDER = 'uploads'        # Foto dari Flutter (deteksi penyakit)
GROWTH_FOLDER = 'growth'         # Foto dari ESP32-CAM (monitoring pertumbuhan)

# Buat folder jika belum ada
for folder in [UPLOAD_FOLDER, GROWTH_FOLDER]:
    if not os.path.exists(folder):
        os.makedirs(folder)
        print(f"✅ Created folder: {folder}")

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
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

@app.route('/stream')
@cross_origin()  # ✅ TAMBAHKAN INI
def video_feed():
    """Route untuk streaming video (laptop webcam)"""
    print("🟢 [FLASK] /stream endpoint hit")
    
    # ✅ FIX: Tambahkan custom headers
    response = Response(
        generate_frames(),
        mimetype='multipart/x-mixed-replace; boundary=frame'
    )
    
    # ✅ CRITICAL: Tambahkan headers untuk mencegah buffering
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    response.headers['Access-Control-Allow-Origin'] = '*'
    
    return response

@app.route('/upload', methods=['POST'])
def upload_image():
    """Endpoint untuk menerima foto dari Flutter (Deteksi Penyakit)"""
    print("🟡 [FLASK] /upload endpoint hit (Disease Detection)")
    print(f"🟡 [FLASK] Request method: {request.method}")
    print(f"🟡 [FLASK] Request files: {request.files}")
    
    try:
        if 'image' not in request.files:
            print("🔴 [FLASK] No image file in request")
            return jsonify({'error': 'No image file provided'}), 400
        
        file = request.files['image']
        
        if file.filename == '':
            print("🔴 [FLASK] Empty filename")
            return jsonify({'error': 'No selected file'}), 400
        
        # Generate unique filename dengan timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'disease_{timestamp}.jpg'
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        
        print(f"🟢 [FLASK] Saving file to: {filepath}")
        
        # Simpan file
        file.save(filepath)
        
        print(f"🟢 [FLASK] File saved successfully: {filename}")
        
        return jsonify({
            'success': True,
            'message': 'Image uploaded successfully (Disease Detection)',
            'filename': filename,
            'filepath': filepath,
            'type': 'disease_detection'
        }), 200
        
    except Exception as e:
        print(f"🔴 [FLASK] Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/uploadGrowth', methods=['POST'])
def upload_growth_image():  # 🆕 Ubah nama fungsi agar tidak duplikat
    """Endpoint untuk menerima foto dari ESP32-CAM (Growth Monitoring)"""
    print("🟡 [FLASK] /uploadGrowth endpoint hit (Growth Monitoring)")
    print(f"🟡 [FLASK] Request method: {request.method}")
    print(f"🟡 [FLASK] Request files: {request.files}")
    
    try:
        if 'image' not in request.files:
            print("🔴 [FLASK] No image file in request")
            return jsonify({'error': 'No image file provided'}), 400
        
        file = request.files['image']
        
        if file.filename == '':
            print("🔴 [FLASK] Empty filename")
            return jsonify({'error': 'No selected file'}), 400
        
        # Generate unique filename dengan timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'growth_{timestamp}.jpg'
        filepath = os.path.join(GROWTH_FOLDER, filename)
        
        print(f"🟢 [FLASK] Saving file to: {filepath}")
        
        # Simpan file
        file.save(filepath)
        
        print(f"🟢 [FLASK] File saved successfully: {filename}")
        
        return jsonify({
            'success': True,
            'message': 'Image uploaded successfully (Growth Monitoring)',
            'filename': filename,
            'filepath': filepath,
            'type': 'growth_monitoring'
        }), 200
        
    except Exception as e:
        print(f"🔴 [FLASK] Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/images')
def list_images():
    """List semua gambar disease detection"""
    print("🟡 [FLASK] /images endpoint hit (Disease Images)")
    try:
        images = os.listdir(UPLOAD_FOLDER)
        images.sort(reverse=True)  # Urutkan dari yang terbaru
        return jsonify({
            'success': True,
            'count': len(images),
            'images': images,
            'folder': 'disease_detection'
        }), 200
    except Exception as e:
        print(f"🔴 [FLASK] Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/imagesGrowth')
def list_growth_images():
    """List semua gambar growth monitoring"""
    print("🟡 [FLASK] /imagesGrowth endpoint hit (Growth Images)")
    try:
        images = os.listdir(GROWTH_FOLDER)
        images.sort(reverse=True)  # Urutkan dari yang terbaru
        return jsonify({
            'success': True,
            'count': len(images),
            'images': images,
            'folder': 'growth_monitoring'
        }), 200
    except Exception as e:
        print(f"🔴 [FLASK] Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/test', methods=['GET', 'POST'])
def test():
    """Simple test endpoint"""
    return jsonify({
        'status': 'ok',
        'message': 'Flask server is running',
        'method': request.method,
        'endpoints': {
            'stream': '/stream (GET)',
            'upload_disease': '/upload (POST)',
            'upload_growth': '/uploadGrowth (POST)',
            'list_disease_images': '/images (GET)',
            'list_growth_images': '/imagesGrowth (GET)',
        }
    }), 200

if __name__ == '__main__':
    print("🚀 [FLASK] Starting server...")
    print(f"🚀 [FLASK] Disease detection folder: {os.path.abspath(UPLOAD_FOLDER)}")
    print(f"🚀 [FLASK] Growth monitoring folder: {os.path.abspath(GROWTH_FOLDER)}")
    app.run(host='0.0.0.0', port=5000, debug=True)