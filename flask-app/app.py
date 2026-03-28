from flask import Flask, jsonify, render_template
import random
import datetime

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "message": "Hello Garavana!",
        "status": "ok",
        "version": "1.4.2"
    })

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": str(datetime.datetime.now())
    })

@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

@app.route('/api/metrics')
def metrics():
    return jsonify({
        "builds_today": random.randint(10, 15),
        "success_rate": round(random.uniform(85, 98), 1),
        "active_pods": 6,
        "last_deploy": "v1.4.2",
        "nodes": [
            {
                "name": "k8s-master",
                "cpu": random.randint(50, 70),
                "mem": random.randint(45, 65)
            },
            {
                "name": "k8s-worker",
                "cpu": random.randint(25, 45),
                "mem": random.randint(30, 55)
            }
        ]
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
