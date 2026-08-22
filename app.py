import os
import requests

from flask import Flask, request, jsonify
from dotenv import load_dotenv

# =========================================================
# LOAD ENV
# =========================================================

load_dotenv()

app = Flask(__name__)

DISCORD_WEBHOOK_URL = os.getenv("DISCORD_WEBHOOK_URL")

if not DISCORD_WEBHOOK_URL:
    raise RuntimeError(
        "DISCORD_WEBHOOK_URL tidak ditemukan di file .env"
    )


# =========================================================
# HOME
# =========================================================

@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "status": "online",
        "service": "Fish It Webhook Server"
    }), 200


# =========================================================
# WEBHOOK
# =========================================================

@app.route("/webhook", methods=["POST"])
def webhook():

    # -----------------------------------------------------
    # AMBIL DATA JSON
    # -----------------------------------------------------

    data = request.get_json(silent=True)

    print("\n========================================")
    print("DATA MASUK:")
    print(data)
    print("========================================")

    if not data:
        return jsonify({
            "success": False,
            "message": "JSON tidak valid"
        }), 400


    # -----------------------------------------------------
    # AMBIL DATA
    # -----------------------------------------------------

    nickname = data.get("nickname")
    fish_name = data.get("fishName")
    fish_rarity = data.get("fishRarity")
    fish_weight = data.get("fishWeight")
    fish_mutation = data.get("fishMutation")


    # -----------------------------------------------------
    # DEFAULT VALUES
    # -----------------------------------------------------

    if not nickname:
        nickname = "Unknown"

    if not fish_mutation:
        fish_mutation = "None"

    if fish_weight is None:
        fish_weight = 0.0  # Default aman jika berat tidak terkirim


    # -----------------------------------------------------
    # VALIDASI FIELD UTAMA
    # -----------------------------------------------------

    if not fish_name:
        return jsonify({
            "success": False,
            "message": "fishName tidak ditemukan"
        }), 400

    if not fish_rarity:
        return jsonify({
            "success": False,
            "message": "fishRarity tidak ditemukan"
        }), 400


    # =====================================================
    # DATA UNTUK DISCORD
    # =====================================================

    discord_data = {
        "username": "Caught Fish",
        "content": (
            f"👤 Pemancing: {nickname}\n"
            f"🧬 Mutasi: {fish_mutation}"
        ),
        "embeds": [
            {
                "title": "🎣 Fish It! - Catch Notification",
                "description": "Tangkapan baru terdeteksi.",
                "color": 3447003,
                "fields": [
                    {
                        "name": "🐟 Nama Ikan",
                        "value": str(fish_name),
                        "inline": True
                    },
                    {
                        "name": "⭐ Rarity",
                        "value": str(fish_rarity),
                        "inline": True
                    },
                    {
                        "name": "⚖️ Berat",
                        "value": f"{fish_weight} kg",
                        "inline": True
                    },
                    {
                        "name": "👤 Pemancing",
                        "value": str(nickname),
                        "inline": True
                    },
                    {
                        "name": "🧬 Mutasi",
                        "value": str(fish_mutation),
                        "inline": True
                    }
                ]
            }
        ]
    }


    # =====================================================
    # KIRIM KE DISCORD
    # =====================================================

    try:
        response = requests.post(
            DISCORD_WEBHOOK_URL,
            json=discord_data,
            timeout=10
        )

        print("\n========================================")
        print("DISCORD RESPONSE")
        print("STATUS:", response.status_code)
        print("========================================")

        if response.status_code not in (200, 204):
            print("RESPONSE:", response.text)
            return jsonify({
                "success": False,
                "message": "Gagal mengirim ke Discord",
                "discord_status": response.status_code
            }), 502

    except requests.RequestException as e:
        print("\n========================================")
        print("REQUEST ERROR")
        print(e)
        print("========================================")

        return jsonify({
            "success": False,
            "message": "Discord tidak dapat dihubungi"
        }), 502


    # =====================================================
    # LOG BERHASIL
    # =====================================================

    print("\n========================================")
    print("CATCH BERHASIL DIKIRIM KE DISCORD")
    print("========================================")
    print(f"👤 Pemancing : {nickname}")
    print(f"🐟 Ikan      : {fish_name}")
    print(f"⭐ Rarity    : {fish_rarity}")
    print(f"⚖️ Berat     : {fish_weight} kg")
    print(f"🧬 Mutasi    : {fish_mutation}")
    print("========================================")


    # =====================================================
    # RESPONSE KE ROBLOX
    # =====================================================

    return jsonify({
        "success": True,
        "message": "Data berhasil dikirim ke Discord",
        "data": {
            "nickname": nickname,
            "fishName": fish_name,
            "fishRarity": fish_rarity,
            "fishWeight": fish_weight,
            "fishMutation": fish_mutation
        }
    }), 200


# =========================================================
# RUN SERVER (OTOMATIS MENYESUAIKAN RENDER PORT)
# =========================================================

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    
    print("========================================")
    print("🎣 FISH IT WEBHOOK SERVER")
    print("========================================")
    print("Status   : ONLINE")
    print(f"Port     : {port}")
    print("Endpoint : /webhook")
    print("========================================")

    app.run(
        host="0.0.0.0",
        port=port,
        debug=False
    )
