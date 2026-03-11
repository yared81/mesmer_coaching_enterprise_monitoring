-- MESMER Database Initialization Script
-- Usage: psql -h localhost -U postgres -f setup.sql

-- 1. Create Database (Run this manually if not using a script that supports it)
-- CREATE DATABASE database_name;

-- 2. Connect to the database
-- \c database_name;

-- 3. Create Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 4. Create Enums
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('admin', 'institution_admin', 'supervisor', 'coach');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE sector_type AS ENUM ('agriculture', 'manufacturing', 'trade', 'services', 'construction', 'other');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE assessment_status AS ENUM ('draft', 'completed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE assessment_category AS ENUM ('finance', 'marketing', 'operations', 'human_resources', 'governance');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE session_status AS ENUM ('scheduled', 'completed', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE evidence_type AS ENUM ('photo', 'document', 'video');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 5. Create Tables
CREATE TABLE IF NOT EXISTS institutions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    region VARCHAR(100),
    contact_email VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name VARCHAR(255) NOT NULL,
    role user_role NOT NULL,
    institution_id UUID REFERENCES institutions(id),
    is_active BOOLEAN DEFAULT true,
    token_version INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS enterprises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_name VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    sector sector_type NOT NULL,
    employee_count INT NOT NULL,
    location VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    coach_id UUID REFERENCES users(id),
    institution_id UUID REFERENCES institutions(id),
    registered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS assessments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    enterprise_id UUID REFERENCES enterprises(id),
    coach_id UUID REFERENCES users(id),
    status assessment_status DEFAULT 'draft',
    total_score DECIMAL(5,2),
    priority_areas TEXT[],
    conducted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS assessment_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category assessment_category NOT NULL,
    question_text TEXT NOT NULL,
    order_index INT NOT NULL,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS assessment_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assessment_id UUID REFERENCES assessments(id),
    question_id UUID REFERENCES assessment_questions(id),
    score SMALLINT CHECK (score >= 0 AND score <= 3)
);

CREATE TABLE IF NOT EXISTS coaching_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    enterprise_id UUID REFERENCES enterprises(id),
    coach_id UUID REFERENCES users(id),
    scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status session_status DEFAULT 'scheduled',
    problems_identified TEXT,
    recommendations TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS session_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES coaching_sessions(id),
    enterprise_id UUID REFERENCES enterprises(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATE,
    is_completed BOOLEAN DEFAULT false
);

CREATE TABLE IF NOT EXISTS uploaded_evidence (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES coaching_sessions(id),
    file_type evidence_type NOT NULL,
    file_url TEXT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size INT,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Indexes
CREATE INDEX IF NOT EXISTS idx_users_institution ON users(institution_id);
CREATE INDEX IF NOT EXISTS idx_enterprises_coach ON enterprises(coach_id);
CREATE INDEX IF NOT EXISTS idx_enterprises_institution ON enterprises(institution_id);
CREATE INDEX IF NOT EXISTS idx_sessions_enterprise ON coaching_sessions(enterprise_id);
CREATE INDEX IF NOT EXISTS idx_sessions_coach ON coaching_sessions(coach_id);
CREATE INDEX IF NOT EXISTS idx_assessments_enterprise ON assessments(enterprise_id);
CREATE INDEX IF NOT EXISTS idx_assessment_responses_assessment ON assessment_responses(assessment_id);
