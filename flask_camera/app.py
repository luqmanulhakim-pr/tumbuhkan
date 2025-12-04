import cv2
from flask import Flask, Response

app = Flask(__name__)

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

if __name__ == '__main__':
    # host='0.0.0.0' artinya server bisa diakses oleh device lain di jaringan (HP)
    print("=================================================")
    print("🎥 KAMERA SIMULATOR BERJALAN!")
    print("📡 Akses stream di browser via: http://<IP_LAPTOP_ANDA>:5000/stream")
    print("=================================================")
    app.run(host='0.0.0.0', port=5000, debug=False)