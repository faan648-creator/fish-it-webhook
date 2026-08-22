import os
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

DISCORD_WEBHOOK_URL = os.environ.get("DISCORD_WEBHOOK_URL")
SECRET_API_KEY = os.environ.get("SECRET_API_KEY", "TalonRahasiaBanget123")

@app.route("/webhook", methods=["POST"])
def webhook():
    client_key = request.headers.get("X-API-Key")
    if client_key != SECRET_API_KEY:
        return jsonify({"error": "Unauthorized!"}), 403

    data = request.json
    if not data:
        return jsonify({"error": "No data provided"}), 400

    nickname = data.get("nickname", "Unknown Player")
    fish_name = data.get("fishName", "Unknown Fish")
    fish_tier = data.get("fishTier", "SECRET")
    fish_weight = data.get("fishWeight", "0 kg")
    fish_variant = data.get("fishVariant", None)  # Bisa None kalau tidak ada mutasi
    fish_chance = data.get("fishChance", "Unknown")

    # Susun fields Discord mirip gaya Lynx
    fields = [
        {"name": "👤 Pemain", "value": f"`{nickname}`", "inline": True},
        {"name": "🐟 Fish Name", "value": f"**{fish_name}** ({fish_weight})", "inline": False},
        {"name": "⭐ Fish Tier", "value": f"`{fish_tier}`", "inline": True},
    ]

    # Kalau ikannya punya varian/mutasi (seperti "Stone"), masukkan field-nya
    if fish_variant and fish_variant != "Normal":
        fields.append({"name": "🧬 Variant", "value": f"`{fish_variant}`", "inline": True})

    fields.append({"name": "🎲 Chance", "value": f"`{fish_chance}`", "inline": True})

    discord_payload = {
        "content": f"New **{fish_tier}** fish caught!",
        "embeds": [
            {
                "title": "🎣 Lynx Webhook | Fish Caught",
                "color": 0x00FFFF,
                "fields": fields,
                "footer": {"text": "Fish It! Auto Webhook Monitor"}
            }
        ]
    }

    response = requests.post(DISCORD_WEBHOOK_URL, json=discord_payload)

    if response.status_code in [200, 204]:
        return jsonify({"status": "success"}), 200
    else:
        return jsonify({"status": "error"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
