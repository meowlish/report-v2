-- ERD: server-file-service
-- Database: PostgreSQL

CREATE TABLE files (
    id UUID,
    name VARCHAR(255) NOT NULL,
    size INTEGER NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    ref_count INTEGER NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL,
    is_public BOOLEAN NOT NULL,
    PRIMARY KEY (id)
);

