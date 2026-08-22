import os
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# Ambil URL Webhook asli dan Secret Key dari Environment Variables Render
DISCORD_WEBHOOK_URL = os.environ.get("DISCORD_WEBHOOK_URL")
# Buat kunci rahasia sendiri (bebas, asal sama dengan yang di Roblox)
SECRET_API_KEY = os.environ.get("SECRET_API_KEY", "TalonRahasiaBanget123")

@app.route("/webhook", methods=["POST"])
def webhook():
    # 1. Validasi Kunci Keamanan dari Roblox
    client_key = request.headers.get("X-API-Key")
    if client_key != SECRET_API_KEY:
        return jsonify({"error": "Unauthorized! Kunci salah."}), 403

    # 2. Ambil data JSON yang dikirim Roblox
    data = request.json
    if not data:
        return jsonify({"error": "No data provided"}), 400

    nickname = data.get("nickname", "Unknown Player")
    fish_name = data.get("fishName", "Unknown Fish")
    fish_rarity = data.get("fishRarity", "Secret")
    fish_weight = data.get("fishWeight", 0.0)
    fish_mutation = data.get("fishMutation", "Normal")

    # 3. Tentukan Warna Embed Discord Berdasarkan Rarity
    embed_color = 0x00FFCC  # Default Hijau Tosca untuk Secret
    if fish_rarity.lower() == "forgotten":
        embed_color = 0xFF0055  # Merah/Pink untuk Forgotten

    # 4. Format pesan ke Discord
    discord_payload = {
        "embeds": [
            {
                "title": f"🎣 Tangkapan Langka Baru!",
                "color": embed_color,
                "fields": [
                    {"name": "👤 Pemain", "value": f"`{nickname}`", "inline": True},
                    {"name": "🐟 Nama Ikan", "value": f"**{fish_name}**", "inline": True},
                    {"name": "⭐ Rarity", "value": f"`{fish_rarity}`", "inline": True},
                    {"name": "⚖️ Berat", "value": f"{fish_weight} kg", "inline": True},
                    {"name": "✨ Mutation", "value": f"{fish_mutation}", "inline": True}
                ],
                "footer": {"text": "Fish It! Auto Webhook Monitor"}
            }
        ]
    }

    # 5. Teruskan ke Webhook Discord Asli
    response = requests.post(DISCORD_WEBHOOK_URL, json=discord_payload)

    if response.status_code == 204 or response.status_code == 200:
        return jsonify({"status": "success", "message": "Sent to Discord"}), 200
    else:
        return jsonify({"status": "error", "message": "Failed to reach Discord"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
