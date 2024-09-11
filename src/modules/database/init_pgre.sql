/*
 * shikigami.sql	skeleton database
 */

BEGIN;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS ConversationParticipants;
DROP TABLE IF EXISTS Messages;
DROP TABLE IF EXISTS PlatformIdentities;
DROP TABLE IF EXISTS Personas;
DROP TABLE IF EXISTS Conversations;

-- Create Conversations table
CREATE TABLE Conversations (
    id SERIAL PRIMARY KEY, -- Use SERIAL for auto-incrementing IDs
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- DATETIME == TIMESTAMP for PostgreSQL
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    title TEXT,
    platform TEXT NOT NULL
);

-- Create Personas table
CREATE TABLE Personas (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL
);

-- Create PlatformIdentities table
CREATE TABLE PlatformIdentities (
    id SERIAL PRIMARY KEY,
    participant_id INTEGER NOT NULL,
    platform TEXT NOT NULL,
    platform_id TEXT NOT NULL,
    FOREIGN KEY (participant_id) REFERENCES Personas(id) ON DELETE CASCADE,  -- Enforce foreign key constraint
    UNIQUE (platform, platform_id)
);

-- Create Messages table
CREATE TABLE Messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER NOT NULL,
    persona_platform_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES Conversations(id) ON DELETE CASCADE,  -- ON DELETE CASCADE ensures consistency
    FOREIGN KEY (persona_platform_id) REFERENCES PlatformIdentities(id) ON DELETE CASCADE
);

-- Create ConversationParticipants table
-- + many-to-many junction table
-- + tracks who is involved in which conversations
CREATE TABLE ConversationParticipants (
    conversation_id INTEGER NOT NULL,
    participant_id INTEGER NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES Conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (participant_id) REFERENCES PlatformIdentities(id) ON DELETE CASCADE,
    PRIMARY KEY (conversation_id, participant_id)
);

-- Create Indexes for Foreign Keys to improve query perf:
CREATE INDEX idx_conversation_id ON Messages(conversation_id);
CREATE INDEX idx_persona_platform_id ON Messages(persona_platform_id);
CREATE INDEX idx_conversation_participants_conversation ON ConversationParticipants(conversation_id);
CREATE INDEX idx_conversation_participants_participant ON ConversationParticipants(participant_id);

-- Function to update each conversation according to latest activity:
CREATE OR REPLACE FUNCTION update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Conversations
    SET updated_at = NOW()
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Latest activity trigger for Messages table
CREATE TRIGGER update_conversation_on_new_message
AFTER INSERT ON Messages
FOR EACH ROW
EXECUTE FUNCTION update_conversation_timestamp();

-- Latest activity trigger for ConversationParticipants table
CREATE TRIGGER update_conversation_on_new_participant
AFTER INSERT ON ConversationParticipants
FOR EACH ROW
EXECUTE FUNCTION update_conversation_timestamp();

COMMIT;
-- .quit
