-- ERD: server-live-chat
-- Database: PostgreSQL

CREATE TABLE rooms (
    id UUID,
    name VARCHAR(255) NOT NULL,
    created_by UUID NOT NULL,
    scheduled_live_url TEXT,
    scheduled_date TIMESTAMPTZ,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN rooms.created_by IS 'references identities.id';
COMMENT ON TABLE rooms IS 'Unmerged: feat/live-chat-rooms';

CREATE TABLE logs (
    id UUID,
    room_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    from_id UUID NOT NULL,
    content TEXT NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN logs.from_id IS 'references identities.id';
COMMENT ON TABLE logs IS 'Unmerged: feat/live-chat-rooms — renamed from Log';

-- Foreign Keys
ALTER TABLE logs ADD CONSTRAINT fk_logs_room_id FOREIGN KEY (room_id) REFERENCES rooms(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
