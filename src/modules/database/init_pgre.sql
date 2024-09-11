/*
 * shikigami.sql	skeleton database
 */
 -- give access to the shikigami user:
 -- ALTER DATABASE shikigami OWNER TO <user_name>;

BEGIN;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS conversation_participants;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS platform_identities;
DROP TABLE IF EXISTS personas;
DROP TABLE IF EXISTS conversations;

-- Create conversations table
CREATE TABLE conversations (
    id SERIAL PRIMARY KEY, -- Use SERIAL for auto-incrementing IDs
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- DATETIME == TIMESTAMP for PostgreSQL
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    title TEXT,
    platform TEXT NOT NULL
);

-- Create personas table
CREATE TABLE personas (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL
);

-- Create platform_identities table
CREATE TABLE platform_identities (
    id SERIAL PRIMARY KEY,
    participant_id INTEGER NOT NULL,
    platform TEXT NOT NULL,
    platform_id TEXT NOT NULL,
    FOREIGN KEY (participant_id) REFERENCES personas(id) ON DELETE CASCADE,  -- Enforce foreign key constraint
    UNIQUE (platform, platform_id)
);

-- Create messages table
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER NOT NULL,
    persona_platform_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,  -- ON DELETE CASCADE ensures consistency
    FOREIGN KEY (persona_platform_id) REFERENCES PlatformIdentities(id) ON DELETE CASCADE
);

-- Create conversation_participants table
-- + many-to-many junction table
-- + tracks who is involved in which conversations
CREATE TABLE conversation_participants (
    conversation_id INTEGER NOT NULL,
    participant_id INTEGER NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (participant_id) REFERENCES platform_identities(id) ON DELETE CASCADE,
    PRIMARY KEY (conversation_id, participant_id)
);

-- Create Indexes for Foreign Keys to improve query perf:
CREATE INDEX idx_conversation_id ON messages(conversation_id);
CREATE INDEX idx_persona_platform_id ON messages(persona_platform_id);
CREATE INDEX idx_conversation_participants_conversation ON conversation_participants(conversation_id);
CREATE INDEX idx_conversation_participants_participant ON conversation_participants(participant_id);

-- Function to update each conversation according to latest activity:
CREATE OR REPLACE FUNCTION update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations
    SET updated_at = NOW()
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Latest activity trigger for messages table
CREATE TRIGGER update_conversation_on_new_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_conversation_timestamp();

-- Latest activity trigger for conversation_participants table
CREATE TRIGGER update_conversation_on_new_participant
AFTER INSERT ON conversation_participants
FOR EACH ROW
EXECUTE FUNCTION update_conversation_timestamp();

COMMIT;
-- .quit
