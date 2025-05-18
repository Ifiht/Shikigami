import discord
from discord.ext import commands
import asyncio
import subprocess

TOKEN = 'YOUR_BOT_TOKEN'
GUILD_ID = 'YOUR_GUILD_ID'  # numeric ID, not name

intents = discord.Intents.default()
intents.voice_states = True
intents.guilds = True

bot = commands.Bot(command_prefix='!', intents=intents)

@bot.event
async def on_voice_state_update(member, before, after):
    if member.bot:
        return

    # User joined a voice channel
    if before.channel is None and after.channel is not None:
        voice_channel = after.channel
        vc = await voice_channel.connect()

        # ffmpeg process to stream system audio
        ffmpeg_cmd = [
            'ffmpeg',
            '-f', 'dshow',  # For Windows. Use 'pulse' or 'avfoundation' on Linux/macOS
            '-i', 'audio="CABLE Output (VB-Audio Virtual Cable)"',
            '-f', 's16le',
            '-ar', '48000',
            '-ac', '2',
            'pipe:1'
        ]

        ffmpeg_proc = subprocess.Popen(ffmpeg_cmd, stdout=subprocess.PIPE)

        audio_source = discord.PCMAudio(ffmpeg_proc.stdout)
        vc.play(audio_source)

        # Disconnect after playback ends
        while vc.is_playing():
            await asyncio.sleep(1)
        await vc.disconnect()

bot.run(TOKEN)