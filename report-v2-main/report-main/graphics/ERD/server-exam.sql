-- ERD: server-exam
-- Database: PostgreSQL

CREATE TABLE exams (
    id UUID,
    created_by UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL,
    duration INTEGER NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN exams.duration IS 'duration in seconds';

CREATE TABLE sections (
    id UUID,
    exam_id UUID NOT NULL,
    parent_id UUID,
    name VARCHAR(255),
    directive TEXT NOT NULL,
    order INTEGER NOT NULL,
    content_type VARCHAR(50) NOT NULL DEFAULT 'SECTION',
    PRIMARY KEY (id)
);


CREATE TABLE section_closures (
    ancestor_id UUID,
    descendant_id UUID,
    depth INTEGER NOT NULL,
    PRIMARY KEY (ancestor_id, descendant_id)
);


CREATE TABLE questions (
    id UUID,
    section_id UUID NOT NULL,
    content TEXT NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'MCQ',
    points INTEGER NOT NULL DEFAULT 1,
    explanation TEXT NOT NULL,
    order INTEGER NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE choices (
    id UUID,
    key VARCHAR(10) NOT NULL,
    content TEXT,
    is_correct BOOLEAN NOT NULL,
    question_id UUID NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE attempts (
    id UUID,
    attempted_by UUID NOT NULL,
    exam_id UUID NOT NULL,
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    duration_limit INTEGER NOT NULL,
    score INTEGER,
    total_points INTEGER,
    is_strict BOOLEAN NOT NULL,
    order INTEGER NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE attempt_sections (
    attempt_id UUID,
    section_id UUID,
    PRIMARY KEY (attempt_id, section_id)
);


CREATE TABLE attempt_responses (
    id UUID,
    attempt_id UUID NOT NULL,
    question_id UUID NOT NULL,
    answers TEXT NOT NULL,
    is_correct BOOLEAN,
    is_flagged BOOLEAN NOT NULL DEFAULT FALSE,
    note TEXT,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN attempt_responses.answers IS 'PostgreSQL text array';

CREATE TABLE scorer_data (
    response_id UUID,
    comment JSONB NOT NULL,
    PRIMARY KEY (response_id)
);


CREATE TABLE tags (
    id UUID,
    name VARCHAR(255) NOT NULL,
    lft INTEGER NOT NULL,
    rgt INTEGER NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (name)
);


CREATE TABLE exam_tags (
    exam_id UUID,
    tag_id UUID,
    PRIMARY KEY (exam_id, tag_id)
);


CREATE TABLE section_tags (
    section_id UUID,
    tag_id UUID,
    PRIMARY KEY (section_id, tag_id)
);


CREATE TABLE question_tags (
    question_id UUID,
    tag_id UUID,
    PRIMARY KEY (question_id, tag_id)
);


CREATE TABLE section_files (
    section_id UUID,
    file_id UUID,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (section_id, file_id)
);


CREATE TABLE question_files (
    question_id UUID,
    file_id UUID,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (question_id, file_id)
);


CREATE TABLE goals (
    uid UUID,
    date TIMESTAMPTZ NOT NULL,
    target INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL,
    PRIMARY KEY (uid)
);


CREATE TABLE tags_table_lock (
    version INTEGER DEFAULT 1,
    PRIMARY KEY (version)
);


CREATE TABLE deleted_files (
    file_id UUID,
    count INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (file_id)
);


-- Foreign Keys
ALTER TABLE sections ADD CONSTRAINT fk_sections_exam_id FOREIGN KEY (exam_id) REFERENCES exams(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE sections ADD CONSTRAINT fk_sections_parent_id FOREIGN KEY (parent_id) REFERENCES sections(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE section_closures ADD CONSTRAINT fk_section_closures_ancestor_id FOREIGN KEY (ancestor_id) REFERENCES sections(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE section_closures ADD CONSTRAINT fk_section_closures_descendant_id FOREIGN KEY (descendant_id) REFERENCES sections(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE questions ADD CONSTRAINT fk_questions_section_id FOREIGN KEY (section_id) REFERENCES sections(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE choices ADD CONSTRAINT fk_choices_question_id FOREIGN KEY (question_id) REFERENCES questions(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE attempts ADD CONSTRAINT fk_attempts_exam_id FOREIGN KEY (exam_id) REFERENCES exams(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE attempt_sections ADD CONSTRAINT fk_attempt_sections_attempt_id FOREIGN KEY (attempt_id) REFERENCES attempts(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE attempt_sections ADD CONSTRAINT fk_attempt_sections_section_id FOREIGN KEY (section_id) REFERENCES sections(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE attempt_responses ADD CONSTRAINT fk_attempt_responses_attempt_id FOREIGN KEY (attempt_id) REFERENCES attempts(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE attempt_responses ADD CONSTRAINT fk_attempt_responses_question_id FOREIGN KEY (question_id) REFERENCES questions(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE scorer_data ADD CONSTRAINT fk_scorer_data_response_id FOREIGN KEY (response_id) REFERENCES attempt_responses(id) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE exam_tags ADD CONSTRAINT fk_exam_tags_exam_id FOREIGN KEY (exam_id) REFERENCES exams(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE exam_tags ADD CONSTRAINT fk_exam_tags_tag_id FOREIGN KEY (tag_id) REFERENCES tags(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE section_tags ADD CONSTRAINT fk_section_tags_section_id FOREIGN KEY (section_id) REFERENCES sections(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE section_tags ADD CONSTRAINT fk_section_tags_tag_id FOREIGN KEY (tag_id) REFERENCES tags(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE question_tags ADD CONSTRAINT fk_question_tags_question_id FOREIGN KEY (question_id) REFERENCES questions(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE question_tags ADD CONSTRAINT fk_question_tags_tag_id FOREIGN KEY (tag_id) REFERENCES tags(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE section_files ADD CONSTRAINT fk_section_files_section_id FOREIGN KEY (section_id) REFERENCES sections(id) ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE question_files ADD CONSTRAINT fk_question_files_question_id FOREIGN KEY (question_id) REFERENCES questions(id) ON UPDATE NO ACTION ON DELETE CASCADE;
