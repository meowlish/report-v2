-- ERD: engapp-v2-core
-- Database: PostgreSQL

CREATE TABLE users (
    id SERIAL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    avatar_url TEXT,
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (email),
    UNIQUE (phone)
);

COMMENT ON COLUMN users.role IS 'enum: student, parent, teacher, mentor, admin';

CREATE TABLE students (
    id SERIAL,
    user_id INTEGER NOT NULL,
    grade VARCHAR(50),
    cefr_level VARCHAR(10),
    assigned_inperson_teacher_id INTEGER,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (user_id)
);


CREATE TABLE parents (
    id SERIAL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (user_id)
);


CREATE TABLE teachers (
    id SERIAL,
    user_id INTEGER NOT NULL,
    teacher_type VARCHAR(20) NOT NULL,
    bio TEXT,
    specialties TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (user_id)
);

COMMENT ON COLUMN teachers.teacher_type IS 'enum: in_person, video_call, both';
COMMENT ON COLUMN teachers.specialties IS 'JSON string';

CREATE TABLE account_links (
    id SERIAL,
    student_id INTEGER NOT NULL,
    linked_user_id INTEGER NOT NULL,
    link_type VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN account_links.link_type IS 'enum: parent, teacher';

CREATE TABLE login_sessions (
    id SERIAL,
    user_id INTEGER NOT NULL,
    logged_in_at TIMESTAMPTZ NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    PRIMARY KEY (id)
);


CREATE TABLE teacher_google_tokens (
    id SERIAL,
    teacher_id INTEGER NOT NULL,
    access_token TEXT NOT NULL,
    refresh_token TEXT NOT NULL,
    token_type VARCHAR(20) NOT NULL DEFAULT 'Bearer',
    expires_at TIMESTAMPTZ NOT NULL,
    scope TEXT,
    google_email VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (teacher_id)
);


CREATE TABLE chat_conversations (
    id SERIAL,
    user_id INTEGER NOT NULL,
    admin_id INTEGER,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN chat_conversations.status IS 'enum: open, closed';

CREATE TABLE chat_messages (
    id SERIAL,
    conversation_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE notifications (
    id SERIAL,
    user_id INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    data TEXT,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN notifications.type IS 'enum: connection_request, connection_accepted, booking_reminder, general';
COMMENT ON COLUMN notifications.data IS 'JSON string';

CREATE TABLE inaugural_registrations (
    id SERIAL,
    parent_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    primary_goal VARCHAR(255),
    wants_to_signup BOOLEAN NOT NULL,
    interest_reason TEXT,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);


-- Foreign Keys
ALTER TABLE students ADD CONSTRAINT fk_students_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE students ADD CONSTRAINT fk_students_assigned_inperson_teacher_id FOREIGN KEY (assigned_inperson_teacher_id) REFERENCES teachers(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE parents ADD CONSTRAINT fk_parents_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE teachers ADD CONSTRAINT fk_teachers_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE account_links ADD CONSTRAINT fk_account_links_student_id FOREIGN KEY (student_id) REFERENCES students(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE account_links ADD CONSTRAINT fk_account_links_linked_user_id FOREIGN KEY (linked_user_id) REFERENCES users(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE login_sessions ADD CONSTRAINT fk_login_sessions_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE teacher_google_tokens ADD CONSTRAINT fk_teacher_google_tokens_teacher_id FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE chat_conversations ADD CONSTRAINT fk_chat_conversations_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE chat_conversations ADD CONSTRAINT fk_chat_conversations_admin_id FOREIGN KEY (admin_id) REFERENCES users(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE chat_messages ADD CONSTRAINT fk_chat_messages_conversation_id FOREIGN KEY (conversation_id) REFERENCES chat_conversations(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE chat_messages ADD CONSTRAINT fk_chat_messages_sender_id FOREIGN KEY (sender_id) REFERENCES users(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE notifications ADD CONSTRAINT fk_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE NO ACTION ON DELETE CASCADE;
