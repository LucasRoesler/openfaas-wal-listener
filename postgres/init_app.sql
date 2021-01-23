CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS "users" (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at timestamptz NOT NULL DEFAULT NOW(),
    updated_at timestamptz NOT NULL DEFAULT NOW(),
    name text,
    email text UNIQUE
);

CREATE UNIQUE INDEX IF NOT EXISTS users_email_idx ON users (email);

INSERT INTO users (name, email)
    VALUES 
        ('John Wick', 'wick@trouble.com'),
        ('James Bond', 'bond@mi6.com'),
        ('Elim Garak', 'garak@ds9.com'),
        ('Sarah Walker', 'walker@nerdherd.com')
    ON CONFLICT (email) DO 
    UPDATE SET name = EXCLUDED.name
    RETURNING *;