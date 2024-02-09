-- Add migration script here
-- Create Subscriptions table

CREATE TABLE subscriptions(
    id uuid not null,
    PRIMARY KEY (id),
    email TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    subscribed_at timestamptz NOT NULL
);