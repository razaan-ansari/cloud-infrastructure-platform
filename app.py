from flask import Flask, Response
# 1. ADD 'Counter' HERE
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# 2. DEFINE THE COUNTER HERE
REQUEST_COUNT = Counter(
    'http_requests_total', 
    'Total HTTP Requests', 
    ['method', 'endpoint']
)

@app.route('/health')
def health():
    return {"status": "healthy"}, 200

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

@app.route('/')
def index():
    # 3. INCREMENT THE COUNTER HERE
    REQUEST_COUNT.labels(method='GET', endpoint='/').inc()
    return {"message": "Hello Razan! App is running."}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)



