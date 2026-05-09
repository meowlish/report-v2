-- ERD: server-resources
-- Database: PostgreSQL

CREATE TABLE blogs (
    id UUID,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author_id UUID NOT NULL,
    tags TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN blogs.author_id IS 'references identities.id';
COMMENT ON COLUMN blogs.tags IS 'PostgreSQL text array';
COMMENT ON TABLE blogs IS 'Unmerged: feat/user-resources';

CREATE TABLE flash_card_lists (
    id UUID,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    author_id UUID NOT NULL,
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    tags TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN flash_card_lists.author_id IS 'references identities.id';
COMMENT ON COLUMN flash_card_lists.tags IS 'PostgreSQL text array';
COMMENT ON TABLE flash_card_lists IS 'Unmerged: feat/user-resources';

CREATE TABLE flash_cards (
    id UUID,
    word VARCHAR(255) NOT NULL,
    definition TEXT NOT NULL,
    image TEXT,
    part_of_speech VARCHAR(50),
    pronunciation VARCHAR(255),
    examples TEXT NOT NULL,
    notes TEXT,
    author_id UUID NOT NULL,
    tags TEXT NOT NULL,
    list_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN flash_cards.examples IS 'PostgreSQL text array';
COMMENT ON COLUMN flash_cards.author_id IS 'references identities.id';
COMMENT ON COLUMN flash_cards.tags IS 'PostgreSQL text array';
COMMENT ON TABLE flash_cards IS 'Unmerged: feat/user-resources';

-- Foreign Keys
ALTER TABLE flash_cards ADD CONSTRAINT fk_flash_cards_list_id FOREIGN KEY (list_id) REFERENCES flash_card_lists(id) ON UPDATE NO ACTION ON DELETE CASCADE;
