-- ============================================================================
-- FILE 1: Database DDL (Data Definition Language)
-- DESCRIPTION: Physical schema creation, constraints, and relationships.
-- ============================================================================

-- Enable pgcrypto extension for UUID generation and data encryption

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Users Table (Core Identity)
CREATE TABLE Users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    referred_by_id UUID REFERENCES Users(user_id) ON DELETE SET NULL
);

-- 2. Subscription_Plans Table (Dictionary Table - 3NF Resolution)
CREATE TABLE Subscription_Plans (
    plan_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    monthly_price DECIMAL(10, 2) NOT NULL,
    concurrent_streams INT NOT NULL
);

-- 3. Subscriptions Table (User Memberships)
CREATE TABLE Subscriptions (
    subscription_id VARCHAR(50) PRIMARY KEY,
    user_id UUID REFERENCES Users(user_id) ON DELETE CASCADE,
    plan_id VARCHAR(50) REFERENCES Subscription_Plans(plan_id) ON DELETE RESTRICT,
    is_active BOOLEAN DEFAULT FALSE,
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL
);

-- 4. Payment_Methods Table (Financial Security)
CREATE TABLE Payment_Methods (
    payment_id VARCHAR(50) PRIMARY KEY,
    user_id UUID REFERENCES Users(user_id) ON DELETE CASCADE,
    payment_type VARCHAR(50) NOT NULL,
    encrypted_pan BYTEA NOT NULL,
    billing_country VARCHAR(100) NOT NULL
);

-- 5. Invoices Table (Immutable Ledger)
CREATE TABLE Invoices (
    invoice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id VARCHAR(50) REFERENCES Subscriptions(subscription_id) ON DELETE RESTRICT,
    payment_id VARCHAR(50) REFERENCES Payment_Methods(payment_id) ON DELETE RESTRICT,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL
);

-- 6. Movies Table (Catalog with JSONB for unstructured data)
CREATE TABLE Movies (
    movie_id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_year INT NOT NULL CHECK (release_year >= 1888),
    metadata_jsonb JSONB
);

-- 7. Genres Table (Taxonomy)
CREATE TABLE Genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

-- 8. Movie_Genre_Relations Table (M:N Associative Entity)
CREATE TABLE Movie_Genre_Relations (
    movie_id VARCHAR(50) REFERENCES Movies(movie_id) ON DELETE CASCADE,
    genre_id INT REFERENCES Genres(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, genre_id)
);

-- 9. Watchlists Table (User Curation)
CREATE TABLE Watchlists (
    watchlist_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES Users(user_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    is_public BOOLEAN DEFAULT FALSE
);

-- 10. Watchlist_Items Table (M:N Associative Entity)
CREATE TABLE Watchlist_Items (
    watchlist_id INT REFERENCES Watchlists(watchlist_id) ON DELETE CASCADE,
    movie_id VARCHAR(50) REFERENCES Movies(movie_id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (watchlist_id, movie_id)
);

-- 11. Watch_Histories Table (Append-only Telemetry)
CREATE TABLE Watch_Histories (
    history_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES Users(user_id) ON DELETE CASCADE,
    movie_id VARCHAR(50) REFERENCES Movies(movie_id) ON DELETE CASCADE,
    duration_watched INT NOT NULL,
    stopped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Reviews Table (Subscription-gated Interaction)
CREATE TABLE Reviews (
    review_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES Users(user_id) ON DELETE CASCADE,
    movie_id VARCHAR(50) REFERENCES Movies(movie_id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, movie_id)
);