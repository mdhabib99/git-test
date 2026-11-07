from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/")
def home():
    return jsonify(
        message="Hello from DevOps Intern Task!",
        status="running",
    ), 200

@app.get("/health")
def health():
    return jsonify(status="healthy"), 200

if __name__ == "__main__":
    # Local development only. Production runs with Gunicorn in the container.
    app.run(host="0.0.0.0", port=8080)
