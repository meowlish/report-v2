-- ERD: server-reports-unimplemented
-- Database: PostgreSQL

CREATE TABLE reports (
    id UUID,
    reported_by UUID NOT NULL,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    target_type VARCHAR(50),
    target_id UUID,
    resolved_by UUID,
    admin_response TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN reports.reported_by IS 'references identities.id';
COMMENT ON COLUMN reports.type IS 'bug, content, behavior';
COMMENT ON COLUMN reports.status IS 'pending, reviewed, resolved, rejected';
COMMENT ON COLUMN reports.target_type IS 'exam, question, section, user, etc.';
COMMENT ON COLUMN reports.target_id IS 'ID of the reported entity';
COMMENT ON COLUMN reports.resolved_by IS 'admin who resolved';
COMMENT ON TABLE reports IS 'UNIMPLEMENTED: UC-0041 to UC-0044';

CREATE TABLE report_files (
    report_id UUID,
    file_id UUID,
    PRIMARY KEY (report_id, file_id)
);

COMMENT ON COLUMN report_files.file_id IS 'references file-service files.id';
COMMENT ON TABLE report_files IS 'UNIMPLEMENTED: evidence attachments for reports';

CREATE TABLE deleted_files (
    file_id UUID,
    count INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (file_id)
);


-- Foreign Keys
ALTER TABLE report_files ADD CONSTRAINT fk_report_files_report_id FOREIGN KEY (report_id) REFERENCES reports(id) ON UPDATE NO ACTION ON DELETE CASCADE;
