from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
import os

app = Flask(__name__)
CORS(app)


def get_db_config():
    """Load DB config from environment variables."""
    return {
        "host": os.environ.get("DB_HOST", "localhost"),
        "port": int(os.environ.get("DB_PORT", 3306)),
        "database": os.environ.get("DB_NAME", "droppin_db"),
        "user": os.environ.get("DB_USER", "droppin"),
        "password": os.environ.get("DB_PASSWORD", "droppin"),
    }


@app.route("/")
def index():
    return "Community Event Discovery API is running."


@app.route("/health", methods=["GET"])
def health_check():
    """Health check that verifies both API and database connectivity."""
    db_status = "ok"
    try:
        conn = mysql.connector.connect(**get_db_config())
        conn.ping(reconnect=False)
        conn.close()
    except Exception as e:
        db_status = f"error: {str(e)}"

    return jsonify({
        "status": "ok" if db_status == "ok" else "degraded",
        "database": db_status,
        "message": "Community Event Discovery backend is live."
    })


@app.route("/events", methods=["POST"])
def create_event():
    data = request.get_json()

    title = data.get("title")
    type_ = data.get("type")
    time = data.get("time")
    lat = data.get("lat")
    lng = data.get("lng")

    try:
        conn = mysql.connector.connect(**get_db_config())
        cursor = conn.cursor()

        # TODO: write insert query here, refer to app.js line 296

        cursor.close()
        conn.close()
        return jsonify({"status": "ok", "message": "Event created."})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)