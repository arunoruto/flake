import telebot
import subprocess
import re
import sys
import os

# Load configuration from systemd environment
TOKEN_PATH = os.environ.get("BOT_TOKEN_PATH")
AUTHORIZED_USER = int(os.environ.get("AUTHORIZED_USER_ID", 0))
PLEX_DIR = os.environ.get("PLEX_MUSIC_DIR")

if not TOKEN_PATH or not PLEX_DIR or not AUTHORIZED_USER:
    print("Missing required environment variables. Check NixOS config.", file=sys.stderr)
    sys.exit(1)

# Securely read the token deployed by sops
try:
    with open(TOKEN_PATH, 'r') as f:
        TOKEN = f.read().strip()
except FileNotFoundError:
    print(f"Token file not found at {TOKEN_PATH}", file=sys.stderr)
    sys.exit(1)

bot = telebot.TeleBot(TOKEN)

@bot.message_handler(func=lambda message: message.chat.id == AUTHORIZED_USER)
def handle_message(message):
    url = message.text.strip()
    
    if not re.match(r'^https?://(www\.)?(youtube\.com|youtu\.be|music\.youtube\.com)/', url):
        bot.reply_to(message, "Please send a valid YouTube link.")
        return
        
    msg = bot.reply_to(message, "Downloading and tagging...")
    
    # yt-dlp is available in the environment PATH via Nix
    cmd = [
        "yt-dlp",
        "-x", "--audio-format", "mp3", "--audio-quality", "0",
        "--embed-metadata", "--embed-thumbnail",
        "--parse-metadata", "title:%(artist)s - %(title)s|%(title)s",
        "--parse-metadata", "uploader:%(album_artist)s",
        "--outtmpl", f"{PLEX_DIR}/%(artist)s - %(title)s.%(ext)s",
        url
    ]
    
    try:
        subprocess.run(cmd, check=True)
        bot.edit_message_text("✅ Successfully added to Plex!", chat_id=message.chat.id, message_id=msg.message_id)
    except subprocess.CalledProcessError:
        bot.edit_message_text("❌ Download failed. Check journalctl.", chat_id=message.chat.id, message_id=msg.message_id)

if __name__ == "__main__":
    bot.infinity_polling()
