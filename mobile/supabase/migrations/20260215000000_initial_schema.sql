-- Initial schema for Us MVP
-- This migration creates all core tables and RLS policies
-- Phase 2 Task: T011-T017

-- ===========================
-- Enable Extensions
-- ===========================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ===========================
-- User Table
-- ===========================

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  display_name TEXT NOT NULL CHECK (LENGTH(display_name) <= 50),
  push_token TEXT,
  notifications_enabled BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE users IS 'User accounts with authentication credentials';

-- ===========================
-- Space Table
-- ===========================

CREATE TYPE space_status AS ENUM ('pending', 'active', 'archived');

CREATE TABLE IF NOT EXISTS spaces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  status space_status NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  archived_at TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE spaces IS 'Relationship spaces - exactly one per user pair';

-- ===========================
-- Space Members
-- ===========================

CREATE TYPE space_role AS ENUM ('owner', 'partner');

CREATE TABLE IF NOT EXISTS space_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  space_id UUID NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role space_role NOT NULL,
  joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(space_id, user_id)
);

COMMENT ON TABLE space_members IS 'Join table: users to spaces (max 2 per space)';

-- ===========================
-- Invitation Table
-- ===========================

CREATE TYPE invitation_status AS ENUM ('pending', 'accepted', 'declined', 'revoked', 'expired');

CREATE TABLE IF NOT EXISTS invitations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  space_id UUID NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
  inviter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  status invitation_status NOT NULL DEFAULT 'pending',
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  consumed_at TIMESTAMP WITH TIME ZONE,
  responded_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE invitations IS 'Invitation links with single-use and expiration enforcement';

-- ===========================
-- Note Table
-- ===========================

CREATE TYPE note_status AS ENUM ('draft', 'delivered');

CREATE TABLE IF NOT EXISTS notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  space_id UUID NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT CHECK (LENGTH(title) <= 100),
  body TEXT NOT NULL CHECK (LENGTH(body) <= 10000),
  status note_status NOT NULL DEFAULT 'draft',
  delivered_at TIMESTAMP WITH TIME ZONE,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE notes IS 'Permanent notes - immutable after delivery';

-- ===========================
-- Event Table
-- ===========================

CREATE TYPE event_status AS ENUM ('proposed', 'agreed', 'declined', 'modified');

CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  space_id UUID NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
  proposer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL CHECK (LENGTH(title) <= 100),
  description TEXT CHECK (LENGTH(description) <= 2000),
  event_date TIMESTAMP WITH TIME ZONE NOT NULL,
  location TEXT CHECK (LENGTH(location) <= 200),
  status event_status NOT NULL DEFAULT 'proposed',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE events IS 'Event proposals with partner response tracking';

-- ===========================
-- Event Response Table
-- ===========================

CREATE TYPE event_response_type AS ENUM ('agree', 'decline', 'preference');

CREATE TABLE IF NOT EXISTS event_responses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  responder_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type event_response_type NOT NULL,
  message TEXT CHECK (LENGTH(message) <= 500),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE event_responses IS 'Responses to event proposals (agree/decline/preference)';

-- ===========================
-- Preference Table
-- ===========================

CREATE TYPE preference_category AS ENUM ('desire', 'mood', 'boundary');

CREATE TABLE IF NOT EXISTS preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  space_id UUID NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category preference_category NOT NULL,
  content TEXT NOT NULL CHECK (LENGTH(content) <= 500),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE preferences IS 'Low-pressure preference sharing - no obligation to respond';

-- ===========================
-- Memory Table
-- ===========================

CREATE TABLE IF NOT EXISTS memories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  space_id UUID NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
  uploader_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  photo_url TEXT NOT NULL,
  photo_key TEXT NOT NULL,
  caption TEXT CHECK (LENGTH(caption) <= 500),
  memory_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE memories IS 'Curated memories with photos and context';

-- ===========================
-- Reflection Table
-- ===========================

CREATE TABLE IF NOT EXISTS reflections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  memory_id UUID NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL CHECK (LENGTH(content) <= 1000),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE reflections IS 'Partner reflections on shared memories';

-- ===========================
-- Notification Table
-- ===========================

CREATE TYPE notification_type AS ENUM ('note_delivered', 'event_proposed', 'event_responded', 'memory_added', 'partner_joined', 'partner_left');

CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  space_id UUID NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
  type notification_type NOT NULL,
  reference_id UUID,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT false,
  is_pushed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE notifications IS 'Care-justified notifications only - no engagement patterns';

-- ===========================
-- Indexes for Performance
-- ===========================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_space_members_space_id ON space_members(space_id);
CREATE INDEX idx_space_members_user_id ON space_members(user_id);
CREATE INDEX idx_invitations_token ON invitations(token);
CREATE INDEX idx_invitations_expires_at ON invitations(expires_at);
CREATE INDEX idx_notes_space_id_status ON notes(space_id, status, created_at);
CREATE INDEX idx_events_space_id_status ON events(space_id, status, event_date);
CREATE INDEX idx_preferences_space_id_author ON preferences(space_id, author_id, is_active);
CREATE INDEX idx_memories_space_id_created ON memories(space_id, created_at);
CREATE INDEX idx_notifications_recipient_read ON notifications(recipient_id, is_read, created_at);

-- ===========================
-- Enable RLS
-- ===========================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE spaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE space_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE memories ENABLE ROW LEVEL SECURITY;
ALTER TABLE reflections ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ===========================
-- RLS Policies - Users
-- ===========================

CREATE POLICY "Users can read their own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- ===========================
-- RLS Policies - Spaces
-- ===========================

CREATE POLICY "Users can read spaces they belong to"
  ON spaces FOR SELECT
  USING (
    id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
  );

-- ===========================
-- RLS Policies - Space Members
-- ===========================

CREATE POLICY "Users can read membership of their spaces"
  ON space_members FOR SELECT
  USING (
    space_id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
  );

-- ===========================
-- RLS Policies - Notes
-- ===========================

CREATE POLICY "Users can read notes in their space"
  ON notes FOR SELECT
  USING (
    space_id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
    AND (status = 'delivered' OR (status = 'draft' AND author_id = auth.uid()))
  );

CREATE POLICY "Users can insert drafts in their space"
  ON notes FOR INSERT
  WITH CHECK (
    space_id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
    AND author_id = auth.uid()
  );

CREATE POLICY "Users can update their own drafts"
  ON notes FOR UPDATE
  USING (author_id = auth.uid() AND status = 'draft');

CREATE POLICY "Users can delete their own drafts"
  ON notes FOR DELETE
  USING (author_id = auth.uid() AND status = 'draft');

-- ===========================
-- RLS Policies - Events
-- ===========================

CREATE POLICY "Users can read events in their space"
  ON events FOR SELECT
  USING (
    space_id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create events in their space"
  ON events FOR INSERT
  WITH CHECK (
    space_id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
    AND proposer_id = auth.uid()
  );

CREATE POLICY "Proposers can update their own events"
  ON events FOR UPDATE
  USING (proposer_id = auth.uid());

-- ===========================
-- RLS Policies - Preferences
-- ===========================

CREATE POLICY "Users can read preferences in their space"
  ON preferences FOR SELECT
  USING (
    space_id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
    AND is_active = true
  );

CREATE POLICY "Users can manage their own preferences"
  ON preferences FOR ALL
  USING (author_id = auth.uid());

-- ===========================
-- RLS Policies - Memories
-- ===========================

CREATE POLICY "Users can read memories in their space"
  ON memories FOR SELECT
  USING (
    space_id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can upload memories to their space"
  ON memories FOR INSERT
  WITH CHECK (
    space_id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
    AND uploader_id = auth.uid()
  );

-- ===========================
-- RLS Policies - Reflections
-- ===========================

CREATE POLICY "Users can read reflections on memories in their space"
  ON reflections FOR SELECT
  USING (
    memory_id IN (
      SELECT id FROM memories WHERE space_id IN (
        SELECT space_id FROM space_members WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Users can add reflections to memories in their space"
  ON reflections FOR INSERT
  WITH CHECK (
    memory_id IN (
      SELECT id FROM memories WHERE space_id IN (
        SELECT space_id FROM space_members WHERE user_id = auth.uid()
      )
    )
    AND author_id = auth.uid()
  );

-- ===========================
-- RLS Policies - Notifications
-- ===========================

CREATE POLICY "Users can read their own notifications"
  ON notifications FOR SELECT
  USING (recipient_id = auth.uid());

CREATE POLICY "Users can update their own notifications"
  ON notifications FOR UPDATE
  USING (recipient_id = auth.uid());

-- ===========================
-- RLS Policies - Invitations
-- ===========================

CREATE POLICY "Anyone can read pending invitations by token"
  ON invitations FOR SELECT
  USING (status = 'pending');

CREATE POLICY "Inviters can manage their own invitations"
  ON invitations FOR ALL
  USING (inviter_id = auth.uid());
