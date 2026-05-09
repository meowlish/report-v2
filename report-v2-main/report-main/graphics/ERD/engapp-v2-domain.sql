-- ERD: engapp-v2-domain
-- Database: PostgreSQL

CREATE TABLE programs (
    id SERIAL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE cohorts (
    id SERIAL,
    name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    program_id INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN cohorts.status IS 'enum: upcoming, active, completed';

CREATE TABLE courses (
    id SERIAL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_open_date DATE NOT NULL,
    registration_close_date DATE NOT NULL,
    price INTEGER NOT NULL,
    status VARCHAR(30) NOT NULL,
    class_day VARCHAR(20) NOT NULL DEFAULT 'monday',
    class_start_time VARCHAR(10) NOT NULL DEFAULT '08:00',
    class_end_time VARCHAR(10) NOT NULL DEFAULT '09:30',
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN courses.status IS 'enum: upcoming, registration_open, in_progress, completed';

CREATE TABLE modules (
    id SERIAL,
    course_id INTEGER NOT NULL,
    module_number INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    learning_outcomes TEXT,
    week_start_date DATE,
    week_end_date DATE,
    monday_content JSONB,
    ai_practice_content JSONB,
    teacher_session_content JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN modules.monday_content IS 'vocabulary, grammar, activities, notes, imageUrl';
COMMENT ON COLUMN modules.ai_practice_content IS 'topics, exercises, notes, imageUrl';
COMMENT ON COLUMN modules.teacher_session_content IS 'goals, focus, notes, imageUrl';

CREATE TABLE cohort_courses (
    id SERIAL,
    cohort_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    teacher_id INTEGER,
    level VARCHAR(20) NOT NULL,
    display_name VARCHAR(255),
    description TEXT,
    enrolled_students INTEGER NOT NULL DEFAULT 0,
    max_students INTEGER NOT NULL DEFAULT 20,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN cohort_courses.teacher_id IS 'FK -> teachers.id, SET NULL on delete';
COMMENT ON COLUMN cohort_courses.level IS 'enum: basic, advanced';

CREATE TABLE enrollments (
    id SERIAL,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    enrolled_at TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) NOT NULL,
    current_module_number INTEGER NOT NULL DEFAULT 1,
    paid BOOLEAN NOT NULL DEFAULT FALSE,
    paid_at TIMESTAMPTZ,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN enrollments.student_id IS 'FK -> students.id';
COMMENT ON COLUMN enrollments.status IS 'enum: active, completed, dropped';

CREATE TABLE student_cohort_enrollments (
    id SERIAL,
    student_id INTEGER NOT NULL,
    cohort_course_id INTEGER NOT NULL,
    paid BOOLEAN NOT NULL DEFAULT FALSE,
    paid_at DATE,
    enrolled_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN student_cohort_enrollments.student_id IS 'FK -> students.id, Cascade delete';

CREATE TABLE bookings (
    id SERIAL,
    student_id INTEGER NOT NULL,
    teacher_id INTEGER NOT NULL,
    module_id INTEGER NOT NULL,
    booking_date DATE NOT NULL,
    slot_start_time VARCHAR(10) NOT NULL,
    slot_end_time VARCHAR(10) NOT NULL,
    status VARCHAR(20) NOT NULL,
    meeting_status VARCHAR(20) NOT NULL,
    meeting_link TEXT,
    google_event_id VARCHAR(255),
    ended_at DATE,
    teacher_feedback TEXT,
    student_rating INTEGER,
    student_comment TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN bookings.student_id IS 'FK -> students.id';
COMMENT ON COLUMN bookings.teacher_id IS 'FK -> teachers.id';
COMMENT ON COLUMN bookings.status IS 'enum: confirmed, completed, cancelled, no_show';
COMMENT ON COLUMN bookings.meeting_status IS 'enum: pending, in_progress, ended';

CREATE TABLE learning_history (
    id SERIAL,
    student_id INTEGER NOT NULL,
    module_id INTEGER NOT NULL,
    activity_type VARCHAR(20) NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    booking_id INTEGER,
    status VARCHAR(20) NOT NULL DEFAULT 'completed',
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN learning_history.student_id IS 'FK -> students.id';
COMMENT ON COLUMN learning_history.activity_type IS 'enum: in_person_class, ai_practice, video_call';
COMMENT ON COLUMN learning_history.status IS 'enum: in_progress, completed';

CREATE TABLE teacher_feedback (
    id SERIAL,
    learning_history_id INTEGER NOT NULL,
    teacher_id INTEGER NOT NULL,
    feedback_text TEXT NOT NULL,
    confidence_notes TEXT,
    improvement_suggestions TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN teacher_feedback.teacher_id IS 'FK -> teachers.id';

CREATE TABLE ai_feedback (
    id SERIAL,
    learning_history_id INTEGER NOT NULL,
    feedback_text TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE weekly_focus (
    id SERIAL,
    module_id INTEGER NOT NULL,
    teacher_id INTEGER NOT NULL,
    week_topic VARCHAR(255) NOT NULL,
    speaking_goals TEXT NOT NULL,
    teacher_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN weekly_focus.teacher_id IS 'FK -> teachers.id';
COMMENT ON COLUMN weekly_focus.speaking_goals IS 'text array, default empty';

CREATE TABLE student_videos (
    id SERIAL,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    video_type VARCHAR(10) NOT NULL,
    file_url TEXT NOT NULL,
    file_name VARCHAR(255),
    file_size INTEGER,
    duration INTEGER,
    uploaded_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN student_videos.student_id IS 'FK -> students.id';
COMMENT ON COLUMN student_videos.video_type IS 'enum: before, after';

CREATE TABLE payments (
    id SERIAL,
    parent_id INTEGER,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255),
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN payments.parent_id IS 'FK -> parents.id';
COMMENT ON COLUMN payments.student_id IS 'FK -> students.id';
COMMENT ON COLUMN payments.status IS 'enum: pending, completed, failed, refunded';

-- Foreign Keys
ALTER TABLE cohorts ADD CONSTRAINT fk_cohorts_program_id FOREIGN KEY (program_id) REFERENCES programs(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE modules ADD CONSTRAINT fk_modules_course_id FOREIGN KEY (course_id) REFERENCES courses(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE cohort_courses ADD CONSTRAINT fk_cohort_courses_cohort_id FOREIGN KEY (cohort_id) REFERENCES cohorts(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE cohort_courses ADD CONSTRAINT fk_cohort_courses_course_id FOREIGN KEY (course_id) REFERENCES courses(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE enrollments ADD CONSTRAINT fk_enrollments_course_id FOREIGN KEY (course_id) REFERENCES courses(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE student_cohort_enrollments ADD CONSTRAINT fk_student_cohort_enrollments_cohort_course_id FOREIGN KEY (cohort_course_id) REFERENCES cohort_courses(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE bookings ADD CONSTRAINT fk_bookings_module_id FOREIGN KEY (module_id) REFERENCES modules(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE learning_history ADD CONSTRAINT fk_learning_history_module_id FOREIGN KEY (module_id) REFERENCES modules(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE learning_history ADD CONSTRAINT fk_learning_history_booking_id FOREIGN KEY (booking_id) REFERENCES bookings(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE teacher_feedback ADD CONSTRAINT fk_teacher_feedback_learning_history_id FOREIGN KEY (learning_history_id) REFERENCES learning_history(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE ai_feedback ADD CONSTRAINT fk_ai_feedback_learning_history_id FOREIGN KEY (learning_history_id) REFERENCES learning_history(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE weekly_focus ADD CONSTRAINT fk_weekly_focus_module_id FOREIGN KEY (module_id) REFERENCES modules(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE student_videos ADD CONSTRAINT fk_student_videos_course_id FOREIGN KEY (course_id) REFERENCES courses(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE payments ADD CONSTRAINT fk_payments_course_id FOREIGN KEY (course_id) REFERENCES courses(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
