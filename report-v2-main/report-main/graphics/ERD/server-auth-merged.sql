-- ERD: server-auth-merged
-- Database: PostgreSQL

CREATE TABLE identities (
    id UUID,
    version INTEGER NOT NULL DEFAULT 1,
    username VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    bio VARCHAR(500),
    avatar_file_id UUID,
    phone_number VARCHAR(20),
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,
    locked_at TIMESTAMPTZ,
    locked_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL,
    deleted_at TIMESTAMPTZ,
    PRIMARY KEY (id),
    UNIQUE (username),
    UNIQUE (phone_number)
);

COMMENT ON COLUMN identities.phone_number IS 'MERGED: from engapp-v2 for connection system';
COMMENT ON COLUMN identities.is_locked IS 'MERGED: from engapp-v2 admin lock/unlock';
COMMENT ON COLUMN identities.locked_at IS 'MERGED: audit trail';
COMMENT ON COLUMN identities.locked_by IS 'MERGED: admin who locked';

CREATE TABLE credentials (
    id UUID,
    identity_id UUID NOT NULL,
    identifier VARCHAR(255) NOT NULL,
    secret_hash VARCHAR(255),
    login_type VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE identity_roles (
    identity_id UUID,
    role_id UUID,
    PRIMARY KEY (identity_id, role_id)
);


CREATE TABLE roles (
    id UUID,
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE roles_permissions (
    role_id UUID,
    permission_id UUID,
    PRIMARY KEY (role_id, permission_id)
);


CREATE TABLE permissions (
    id UUID,
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE google_calendar_tokens (
    id UUID,
    identity_id UUID NOT NULL,
    access_token TEXT NOT NULL,
    refresh_token TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    scopes TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (identity_id)
);

COMMENT ON COLUMN google_calendar_tokens.access_token IS 'encrypted at rest';
COMMENT ON COLUMN google_calendar_tokens.refresh_token IS 'encrypted at rest';
COMMENT ON TABLE google_calendar_tokens IS 'NEW: from auth merge plan for teacher Google Calendar integration';

CREATE TABLE deleted_files (
    file_id UUID,
    count INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (file_id)
);


-- Foreign Keys
ALTER TABLE credentials ADD CONSTRAINT fk_credentials_identity_id FOREIGN KEY (identity_id) REFERENCES identities(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE identity_roles ADD CONSTRAINT fk_identity_roles_identity_id FOREIGN KEY (identity_id) REFERENCES identities(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE identity_roles ADD CONSTRAINT fk_identity_roles_role_id FOREIGN KEY (role_id) REFERENCES roles(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE roles_permissions ADD CONSTRAINT fk_roles_permissions_role_id FOREIGN KEY (role_id) REFERENCES roles(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE roles_permissions ADD CONSTRAINT fk_roles_permissions_permission_id FOREIGN KEY (permission_id) REFERENCES permissions(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE google_calendar_tokens ADD CONSTRAINT fk_google_calendar_tokens_identity_id FOREIGN KEY (identity_id) REFERENCES identities(id) ON UPDATE NO ACTION ON DELETE CASCADE;
