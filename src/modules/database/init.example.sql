/*
 * shikigami.sql	skeleton database
 */

PRAGMA foreign_keys=ON;
BEGIN TRANSACTION;

-- .tables
-- PRAGMA table_info(Personas)
CREATE TABLE Personas(
	PersonID INTEGER NOT NULL PRIMARY KEY,
    FamilyName          TEXT,
    GivenName           TEXT,
    AddtnlName          TEXT,
    HonPrefix           TEXT,
    HonSuffix           TEXT,
    Addr                TEXT,
    BDay                TEXT,
    Gender              TEXT,
    DataDir             TEXT,
    Socials             TEXT
);

CREATE TABLE Conversations(
    ConvoID     INTEGER NOT NULL PRIMARY KEY,
    PersonID    INTEGER NOT NULL,
	BodyText    TEXT,
	TimeStamp   TEXT DEFAULT CURRENT_TIMESTAMP,
    Reactions   TEXT,
    FOREIGN KEY(PersonID) REFERENCES Personas(PersonID)
);

INSERT INTO Personas (FamilyName,GivenName,AddtnlName)
VALUES("Halsey","Cortana","Elizabeth"); -- this is the name of your shikigami, and any ids

COMMIT;
-- .quit
