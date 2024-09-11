require 'sqlite3'
# OS Requirements:
#> sudo apt install -y postgresql-common
#> sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
#> sudo apt install postgresql-16

# Open a database
db = SQLite3::Database.new "XPlatform_Chat.db"

# Example: Insert a new participant
db.execute("INSERT INTO Personas (name, type) VALUES (?, ?)", ["John Doe", "human"])
participant_id = db.last_insert_row_id

# Example: Insert participant identities for different platforms
platforms = {
  "discord" => "john_doe#1234",
  "twitter" => "@john_doe",
  "speech_to_text" => "voice_profile_123"
}

platforms.each do |platform, platform_id|
  db.execute("INSERT INTO participant_identities (participant_id, platform, platform_id) VALUES (?, ?, ?)",
             [participant_id, platform, platform_id])
end

# Example: Insert an AI participant
db.execute("INSERT INTO Personas (name, type) VALUES (?, ?)", ["Claude", "ai"])
ai_participant_id = db.last_insert_row_id
db.execute("INSERT INTO participant_identities (participant_id, platform, platform_id) VALUES (?, ?, ?)",
           [ai_participant_id, "anthropic", "claude_3.5"])

# Example: Create a conversation on Discord
db.execute("INSERT INTO Conversations (title, platform) VALUES (?, ?)", ["Discord Chat", "discord"])
conversation_id = db.last_insert_row_id

# Get participant identity IDs
discord_identity_id = db.get_first_value("SELECT id FROM participant_identities WHERE participant_id = ? AND platform = ?",
                                         [participant_id, "discord"])
ai_identity_id = db.get_first_value("SELECT id FROM participant_identities WHERE participant_id = ?", [ai_participant_id])

# Link Personas to the conversation
db.execute("INSERT INTO conversation_participants (conversation_id, participant_identity_id) VALUES (?, ?)",
           [conversation_id, discord_identity_id])
db.execute("INSERT INTO conversation_participants (conversation_id, participant_identity_id) VALUES (?, ?)",
           [conversation_id, ai_identity_id])

# Example: Insert messages
db.execute("INSERT INTO messages (conversation_id, participant_identity_id, content) VALUES (?, ?, ?)", 
           [conversation_id, discord_identity_id, "Hey Claude, how's it going?"])
db.execute("INSERT INTO messages (conversation_id, participant_identity_id, content) VALUES (?, ?, ?)", 
           [conversation_id, ai_identity_id, "Hello! I'm doing well, thank you for asking. How can I assist you today?"])

# Close the database
db.close
