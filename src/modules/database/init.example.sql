/*
 * shikigami.sql	skeleton database
 */

PRAGMA foreign_keys=ON;
BEGIN TRANSACTION;

-- .tables
-- PRAGMA table_info(Personas)
CREATE TABLE Personas(
	PersonID INTEGER NOT NULL PRIMARY KEY,
    FirstNameAtBirth    TEXT,
    LastNameAtBirth     TEXT,
    MidNameAtBirth      TEXT,
    discordID           TEXT,
	githubID            TEXT
);

CREATE TABLE Conversations2(
    ConvoID INTEGER NOT NULL PRIMARY KEY,
    PersonID INTEGER NOT NULL,
	BodyText            TEXT,
	TimeStamp TEXT DEFAULT CURRENT_TIMESTAMP,
    Reactions           TEXT,
    FOREIGN KEY(PersonID) REFERENCES Personas(PersonID)
);

INSERT INTO Personas (FirstNameAtBirth,LastNameAtBirth,MidNameAtBirth,discordID,githubID)
VALUES("Cortana","Elizabeth","Halsey",NULL,NULL); -- this is the name of your shikigami, and any ids

COMMIT;
