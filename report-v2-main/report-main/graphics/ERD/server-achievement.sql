-- ERD: server-achievement
-- Database: PostgreSQL

CREATE TABLE badges (
    name VARCHAR(255),
    type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (name)
);


CREATE TABLE user_badges (
    id UUID,
    uid UUID NOT NULL,
    badge VARCHAR(255) NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE attempt_criteria (
    uid UUID,
    version INTEGER NOT NULL DEFAULT 1,
    total INTEGER NOT NULL DEFAULT 0,
    perfect INTEGER NOT NULL DEFAULT 0,
    good INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (uid)
);


CREATE TABLE login_criteria (
    uid UUID,
    version INTEGER NOT NULL DEFAULT 1,
    longest_streak INTEGER NOT NULL DEFAULT 0,
    total INTEGER NOT NULL DEFAULT 0,
    started_at TIMESTAMPTZ NOT NULL,
    last_login TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (uid)
);


-- Foreign Keys
ALTER TABLE user_badges ADD CONSTRAINT fk_user_badges_badge FOREIGN KEY (badge) REFERENCES badges(name) ON UPDATE CASCADE ON DELETE NO ACTION;
