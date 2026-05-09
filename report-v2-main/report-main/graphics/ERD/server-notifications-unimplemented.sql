-- ERD: server-notifications-unimplemented
-- Database: PostgreSQL

CREATE TABLE notifications (
    id UUID,
    recipient_id UUID NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON COLUMN notifications.recipient_id IS 'references identities.id';
COMMENT ON COLUMN notifications.type IS 'achievement, report, system, etc.';
COMMENT ON COLUMN notifications.data IS 'additional context payload';
COMMENT ON TABLE notifications IS 'UNIMPLEMENTED: UC-0045 to UC-0046';

CREATE TABLE notification_preferences (
    id UUID,
    identity_id UUID NOT NULL,
    email_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    push_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    achievement_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    report_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    system_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (identity_id)
);

COMMENT ON COLUMN notification_preferences.identity_id IS 'references identities.id';
COMMENT ON TABLE notification_preferences IS 'UNIMPLEMENTED: per-user notification settings';
