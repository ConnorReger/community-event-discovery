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

@app.route("/events", methods=["GET"])
def list_events():
    """Return all upcoming events as JSON for the frontend map and list."""
    try:
        conn = mysql.connector.connect(**get_db_config())
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                e.event_id        AS id,
                e.title,
                e.visibility      AS type,
                e.start_time,
                e.end_time,
                l.latitude        AS lat,
                l.longitude       AS lng,
                cat.category_name AS category
            FROM Events e
            JOIN Location l   ON e.fk_location_id = l.location_id
            JOIN Categories cat ON e.fk_category_id = cat.category_id
            WHERE e.status IN ('scheduled', 'active')
            ORDER BY e.start_time ASC
        """)
        rows = cursor.fetchall()

        # Format for frontend (it expects "time" as a display string, lat/lng as floats)
        for row in rows:
            start = row["start_time"]
            row["time"] = start.strftime("%a, %b %-d · %-I:%M %p")
            row["start_time"] = start.isoformat()
            row["end_time"] = row["end_time"].isoformat()
            row["lat"] = float(row["lat"]) if row["lat"] is not None else None
            row["lng"] = float(row["lng"]) if row["lng"] is not None else None

        cursor.close()
        conn.close()
        return jsonify({"status": "ok", "events": rows})

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route("/events", methods=["POST"])
def create_event():
    data = request.get_json()
    if not data:
        return jsonify({"status": "error", "message": "No JSON body provided."}), 400

    title = data.get("title")
    type_ = data.get("type", "public")
    lat = data.get("lat")
    lng = data.get("lng")
    raw_time = data.get("start_time") or data.get("time")

    if not all([title, lat, lng, raw_time]):
        return jsonify({
            "status": "error",
            "message": "Missing required field: title, lat, lng, or time."
        }), 400

    from datetime import datetime, timedelta
    try:
        start_time = datetime.fromisoformat(raw_time)
    except (ValueError, TypeError):
        start_time = datetime.now()
    end_time = start_time + timedelta(hours=2)

    DEFAULT_ORGANIZER_ID = 1
    DEFAULT_CATEGORY_ID = 1

    try:
        conn = mysql.connector.connect(**get_db_config())
        cursor = conn.cursor()

        # Insert a Location row for the dropped pin
        cursor.execute("""
            INSERT INTO Location (location_name, address, fk_city_id, zipcode, latitude, longitude)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (title, "Unknown address", 1, "00000", lat, lng))
        location_id = cursor.lastrowid

        # Insert the Event itself
        cursor.execute("""
            INSERT INTO Events
                (organizer_id, fk_location_id, fk_category_id, title, descript,
                 start_time, end_time, status, visibility)
            VALUES (%s, %s, %s, %s, %s, %s, %s, 'scheduled', %s)
        """, (
            DEFAULT_ORGANIZER_ID,
            location_id,
            DEFAULT_CATEGORY_ID,
            title,
            data.get("description", ""),
            start_time,
            end_time,
            type_,
        ))
        new_id = cursor.lastrowid

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"status": "ok", "message": "Event created.", "event_id": new_id}), 201

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)