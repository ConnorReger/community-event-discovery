from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Check that backend is running
@app.route("/")
def index():
    return "Community Event Discovery API is running."

# Check health
@app.route("/health", methods = ["GET"])
def health_check():
    response = {
        "status": "ok",
        "message": "Community Event Discovery backend is live."
    }
    return jsonify(response)

if __name__ == "__main__":
    app.run(debug=True)