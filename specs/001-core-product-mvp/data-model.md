# Data Model: Us Core Product MVP

**Source**: [spec.md](./spec.md) Key Entities + Clarifications
**Date**: 2026-02-14
**Backend**: Supabase (PostgreSQL with Row-Level Security)

## Entity Relationship Overview

```text
User 1──* Invitation (as inviter)
User 1──1 SpaceMember ──1 Space (max 2 members per space)
Space 1──* Note
Space 1──* Event
Space 1──* Preference
Space 1──* Memory
Memory 1──* Reflection
User 1──* Notification
Note *──1 User (author)
Event *──1 User (proposer)
Event 0..1──* EventResponse
Preference *──1 User (author)
Memory *──1 User (uploader)
Reflection *──1 User (author)
```

## Entities

### User

| Field                | Type      | Constraints            | Notes                                 |
| -------------------- | --------- | ---------------------- | ------------------------------------- |
| id                   | UUID      | PK, auto-generated     |                                       |
| email                | String    | Unique, not null       | Used for login                        |
| passwordHash         | String    | Not null               | bcrypt hashed                         |
| displayName          | String    | Not null, max 50 chars | Shown to partner                      |
| pushToken            | String?   | Nullable               | Expo push notification token          |
| notificationsEnabled | Boolean   | Default: true          | Global notification toggle            |
| createdAt            | DateTime  | Auto-set               |                                       |
| updatedAt            | DateTime  | Auto-updated           |                                       |
| deletedAt            | DateTime? | Nullable               | Soft delete — triggers space archival |

**Constraints**:

- A user participates in at most one active space at a time.
- Soft-deleted users retain their content in the space as read-only.

### Space

| Field      | Type      | Constraints        | Notes                           |
| ---------- | --------- | ------------------ | ------------------------------- |
| id         | UUID      | PK, auto-generated |                                 |
| status     | Enum      | Not null           | `pending`, `active`, `archived` |
| createdAt  | DateTime  | Auto-set           |                                 |
| updatedAt  | DateTime  | Auto-updated       |                                 |
| archivedAt | DateTime? | Nullable           | Set when space becomes archived |

**State Transitions**:

```text
pending → active     (when invited partner accepts)
pending → archived   (when inviter revokes or invitation expires)
active  → archived   (when either partner leaves or deletes account)
```

**Constraints**:

- Exactly 2 SpaceMember records when active.
- No new content can be created in an archived space.

### SpaceMember

| Field    | Type     | Constraints          | Notes              |
| -------- | -------- | -------------------- | ------------------ |
| id       | UUID     | PK, auto-generated   |                    |
| spaceId  | UUID     | FK → Space, not null |                    |
| userId   | UUID     | FK → User, not null  |                    |
| role     | Enum     | Not null             | `owner`, `partner` |
| joinedAt | DateTime | Auto-set             |                    |

**Constraints**:

- Unique(spaceId, userId) — a user can only be in a space once.
- Max 2 members per space (enforced at application layer).
- A user can have at most one SpaceMember record with an active Space.

### Invitation

| Field       | Type      | Constraints          | Notes                                                   |
| ----------- | --------- | -------------------- | ------------------------------------------------------- |
| id          | UUID      | PK, auto-generated   |                                                         |
| spaceId     | UUID      | FK → Space, not null | Links to the pending space                              |
| inviterId   | UUID      | FK → User, not null  | Who created the invitation                              |
| token       | String    | Unique, not null     | Unique token for the shareable link                     |
| status      | Enum      | Not null             | `pending`, `accepted`, `declined`, `revoked`, `expired` |
| expiresAt   | DateTime  | Not null             | Default: 7 days from creation                           |
| consumedAt  | DateTime? | Nullable             | When link was first opened                              |
| respondedAt | DateTime? | Nullable             | When accept/decline occurred                            |
| createdAt   | DateTime  | Auto-set             |                                                         |

**State Transitions**:

```text
pending  → accepted  (partner opens link and accepts)
pending  → declined  (partner opens link and declines)
pending  → revoked   (inviter manually revokes)
pending  → expired   (expiresAt passes without action)
```

**Constraints**:

- Single-use: once consumedAt is set, the link cannot be used by another person.
- Automatically expires after 7 days (per FR-030 clarification).
- Inviter can generate a new invitation if the previous one expires or is revoked.

### Note

| Field       | Type      | Constraints                | Notes                             |
| ----------- | --------- | -------------------------- | --------------------------------- |
| id          | UUID      | PK, auto-generated         |                                   |
| spaceId     | UUID      | FK → Space, not null       |                                   |
| authorId    | UUID      | FK → User, not null        |                                   |
| title       | String?   | Nullable, max 100 chars    | Optional title                    |
| body        | String    | Not null, max 10,000 chars | The note content                  |
| status      | Enum      | Not null                   | `draft`, `delivered`              |
| deliveredAt | DateTime? | Nullable                   | Set when status becomes delivered |
| readAt      | DateTime? | Nullable                   | Set when partner first opens it   |
| createdAt   | DateTime  | Auto-set                   |                                   |
| updatedAt   | DateTime  | Auto-updated               | Only meaningful in draft state    |

**State Transitions**:

```text
draft     → delivered  (author sends the note)
delivered → (terminal) (immutable — no edits, no deletions)
draft     → (deleted)  (author discards draft — hard delete)
```

**Constraints**:

- Delivered notes are immutable: no UPDATE on body/title allowed after delivery.
- Drafts are visible only to the author.
- Delivered notes are visible to both partners.

### Event

| Field       | Type     | Constraints               | Notes                                        |
| ----------- | -------- | ------------------------- | -------------------------------------------- |
| id          | UUID     | PK, auto-generated        |                                              |
| spaceId     | UUID     | FK → Space, not null      |                                              |
| proposerId  | UUID     | FK → User, not null       |                                              |
| title       | String   | Not null, max 100 chars   | What the event is                            |
| description | String?  | Nullable, max 2,000 chars | Additional details                           |
| eventDate   | DateTime | Not null                  | When the event is proposed for               |
| location    | String?  | Nullable, max 200 chars   | Where (optional)                             |
| status      | Enum     | Not null                  | `proposed`, `agreed`, `declined`, `modified` |
| createdAt   | DateTime | Auto-set                  |                                              |
| updatedAt   | DateTime | Auto-updated              |                                              |

**State Transitions**:

```text
proposed → agreed    (partner accepts)
proposed → declined  (partner declines)
proposed → modified  (partner suggests a change)
modified → agreed    (proposer accepts modification)
modified → proposed  (proposer updates and re-proposes)
```

### EventResponse

| Field       | Type     | Constraints             | Notes                            |
| ----------- | -------- | ----------------------- | -------------------------------- |
| id          | UUID     | PK, auto-generated      |                                  |
| eventId     | UUID     | FK → Event, not null    |                                  |
| responderId | UUID     | FK → User, not null     |                                  |
| type        | Enum     | Not null                | `agree`, `decline`, `preference` |
| message     | String?  | Nullable, max 500 chars | Optional: reason or suggestion   |
| createdAt   | DateTime | Auto-set                |                                  |

**Constraints**:

- Records the history of responses for an event.
- When type is `preference`, message contains the suggestion.

### Preference

| Field     | Type     | Constraints             | Notes                                    |
| --------- | -------- | ----------------------- | ---------------------------------------- |
| id        | UUID     | PK, auto-generated      |                                          |
| spaceId   | UUID     | FK → Space, not null    |                                          |
| authorId  | UUID     | FK → User, not null     |                                          |
| category  | Enum     | Not null                | `desire`, `mood`, `boundary`             |
| content   | String   | Not null, max 500 chars | The preference text                      |
| isActive  | Boolean  | Default: true           | False when user removes it               |
| createdAt | DateTime | Auto-set                |                                          |
| updatedAt | DateTime | Auto-updated            | Silent updates — no partner notification |

**Constraints**:

- Updates and removals do not generate notifications for the partner.
- Partner sees only active preferences.

### Memory

| Field      | Type      | Constraints             | Notes                               |
| ---------- | --------- | ----------------------- | ----------------------------------- |
| id         | UUID      | PK, auto-generated      |                                     |
| spaceId    | UUID      | FK → Space, not null    |                                     |
| uploaderId | UUID      | FK → User, not null     |                                     |
| photoUrl   | String    | Not null                | S3 object URL                       |
| photoKey   | String    | Not null                | S3 object key (for deletion/export) |
| caption    | String?   | Nullable, max 500 chars |                                     |
| memoryDate | DateTime? | Nullable                | When the moment happened            |
| createdAt  | DateTime  | Auto-set                |                                     |

**Constraints**:

- One photo per memory entry (encourages curation over bulk).
- Photo size capped at 10MB (enforced at upload).
- Maximum 500 memories per space (enforced by CHECK constraint to satisfy FR-017).

### Reflection

| Field     | Type     | Constraints               | Notes               |
| --------- | -------- | ------------------------- | ------------------- |
| id        | UUID     | PK, auto-generated        |                     |
| memoryId  | UUID     | FK → Memory, not null     |                     |
| authorId  | UUID     | FK → User, not null       |                     |
| content   | String   | Not null, max 1,000 chars | The reflection text |
| createdAt | DateTime | Auto-set                  |                     |

**Constraints**:

- Both partners can add reflections to any memory.
- Multiple reflections per user per memory are allowed.

### Notification

| Field       | Type     | Constraints          | Notes                                                                                                   |
| ----------- | -------- | -------------------- | ------------------------------------------------------------------------------------------------------- |
| id          | UUID     | PK, auto-generated   |                                                                                                         |
| recipientId | UUID     | FK → User, not null  |                                                                                                         |
| spaceId     | UUID     | FK → Space, not null |                                                                                                         |
| type        | Enum     | Not null             | `note_delivered`, `event_proposed`, `event_responded`, `memory_added`, `partner_joined`, `partner_left` |
| referenceId | UUID?    | Nullable             | ID of the triggering entity                                                                             |
| title       | String   | Not null             | Short notification title                                                                                |
| body        | String   | Not null             | Notification body text                                                                                  |
| isRead      | Boolean  | Default: false       |                                                                                                         |
| isPushed    | Boolean  | Default: false       | Whether push was sent                                                                                   |
| createdAt   | DateTime | Auto-set             |                                                                                                         |

**Constraints**:

- Only care-justified types allowed (enum enforced).
- No engagement-driven notification types exist in the enum.
- Batching/throttling logic lives in the notification service, not the data model.

## Indexes

| Table        | Index                            | Type      | Purpose                         |
| ------------ | -------------------------------- | --------- | ------------------------------- |
| User         | email                            | Unique    | Login lookup                    |
| SpaceMember  | (spaceId, userId)                | Unique    | Prevent duplicate membership    |
| Invitation   | token                            | Unique    | Link lookup                     |
| Invitation   | expiresAt                        | B-tree    | Expiration cleanup queries      |
| Note         | (spaceId, status, createdAt)     | Composite | List delivered notes in a space |
| Event        | (spaceId, status, eventDate)     | Composite | List upcoming events            |
| Preference   | (spaceId, authorId, isActive)    | Composite | Active preferences per user     |
| Memory       | (spaceId, createdAt)             | Composite | Album browsing                  |
| Notification | (recipientId, isRead, createdAt) | Composite | Unread notification listing     |

## Data Retention & Export

- **Soft delete**: Users are soft-deleted (deletedAt set). Their content remains in the space as read-only.
- **Space archival**: When a space becomes archived, all content is preserved but no new writes are allowed.
- **Export**: Either partner can export full space content (all notes, events, preferences, memories with photo URLs) as a structured data package.
- **Durability**: Zero content loss requirement — Supabase provides automated daily backups and point-in-time recovery on paid tier; Supabase Storage has built-in redundancy.

## Row-Level Security (RLS) Policies

Supabase's Row-Level Security enforces data isolation at the database level. Every table has RLS enabled, and policies ensure users can only access data from their relationship space.

### Users Table

**Policy: Users can read their own profile**

```sql
CREATE POLICY "Users can read their own profile"
ON users FOR SELECT
USING (auth.uid() = id);
```

**Policy: Users can update their own profile**

```sql
CREATE POLICY "Users can update their own profile"
ON users FOR UPDATE
USING (auth.uid() = id);
```

### Spaces Table

**Policy: Users can read spaces they belong to**

```sql
CREATE POLICY "Users can read spaces they belong to"
ON spaces FOR SELECT
USING (
  id IN (
    SELECT space_id FROM space_members WHERE user_id = auth.uid()
  )
);
```

### Space_Members Table

**Policy: Users can read membership of their spaces**

```sql
CREATE POLICY "Users can read membership of their spaces"
ON space_members FOR SELECT
USING (
  space_id IN (
    SELECT space_id FROM space_members WHERE user_id = auth.uid()
  )
);
```

### Notes Table

**Policy: Users can read notes in their space**

```sql
CREATE POLICY "Users can read notes in their space"
ON notes FOR SELECT
USING (
  space_id IN (
    SELECT space_id FROM space_members WHERE user_id = auth.uid()
  )
  AND (status = 'delivered' OR (status = 'draft' AND author_id = auth.uid()))
);
```

**Policy: Users can insert drafts in their space**

```sql
CREATE POLICY "Users can insert drafts in their space"
ON notes FOR INSERT
WITH CHECK (
  space_id IN (
    SELECT space_id FROM space_members WHERE user_id = auth.uid()
  )
  AND author_id = auth.uid()
);
```

**Policy: Users can update their own drafts**

```sql
CREATE POLICY "Users can update their own drafts"
ON notes FOR UPDATE
USING (author_id = auth.uid() AND status = 'draft');
```

**Policy: Users can delete their own drafts**

```sql
CREATE POLICY "Users can delete their own drafts"
ON notes FOR DELETE
USING (author_id = auth.uid() AND status = 'draft');
```

### Events Table

**Policy: Users can read events in their space**

```sql
CREATE POLICY "Users can read events in their space"
ON events FOR SELECT
USING (
  space_id IN (
    SELECT space_id FROM space_members WHERE user_id = auth.uid()
  )
);
```

**Policy: Users can create events in their space**

```sql
CREATE POLICY "Users can create events in their space"
ON events FOR INSERT
WITH CHECK (
  space_id IN (
    SELECT space_id FROM space_members WHERE user_id = auth.uid()
  )
  AND proposer_id = auth.uid()
);
```

**Policy: Proposers can update their own events**

```sql
CREATE POLICY "Proposers can update their own events"
ON events FOR UPDATE
USING (proposer_id = auth.uid());
```

### Preferences Table

**Policy: Users can read preferences in their space**

```sql
CREATE POLICY "Users can read preferences in their space"
ON preferences FOR SELECT
USING (
  space_id IN (
    SELECT space_id FROM space_members WHERE user_id = auth.uid()
  )
  AND is_active = true
);
```

**Policy: Users can manage their own preferences**

```sql
CREATE POLICY "Users can manage their own preferences"
ON preferences FOR ALL
USING (author_id = auth.uid());
```

### Memories Table

**Policy: Users can read memories in their space**

```sql
CREATE POLICY "Users can read memories in their space"
ON memories FOR SELECT
USING (
  space_id IN (
    SELECT space_id FROM space_members WHERE user_id = auth.uid()
  )
);
```

**Policy: Users can upload memories to their space**

```sql
CREATE POLICY "Users can upload memories to their space"
ON memories FOR INSERT
WITH CHECK (
  space_id IN (
    SELECT space_id FROM space_members WHERE user_id = auth.uid()
  )
  AND uploader_id = auth.uid()
);
```

### Reflections Table

**Policy: Users can read reflections on memories in their space**

```sql
CREATE POLICY "Users can read reflections on memories in their space"
ON reflections FOR SELECT
USING (
  memory_id IN (
    SELECT id FROM memories WHERE space_id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
  )
);
```

**Policy: Users can add reflections to memories in their space**

```sql
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
```

### Notifications Table

**Policy: Users can read their own notifications**

```sql
CREATE POLICY "Users can read their own notifications"
ON notifications FOR SELECT
USING (recipient_id = auth.uid());
```

**Policy: Users can update their own notifications**

```sql
CREATE POLICY "Users can update their own notifications"
ON notifications FOR UPDATE
USING (recipient_id = auth.uid());
```

### Invitations Table

**Policy: Anyone can read pending invitations by token**

```sql
CREATE POLICY "Anyone can read pending invitations by token"
ON invitations FOR SELECT
USING (status = 'pending');
```

**Policy: Inviters can manage their own invitations**

```sql
CREATE POLICY "Inviters can manage their own invitations"
ON invitations FOR ALL
USING (inviter_id = auth.uid());
```

## Supabase Storage Policies

Photos are stored in Supabase Storage with bucket-level RLS policies.

### Bucket: memories

**Policy: Users can upload photos to their space**

```sql
CREATE POLICY "Users can upload photos to their space"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'memories'
  AND (storage.foldername(name))[1] IN (
    SELECT id::text FROM spaces WHERE id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
  )
);
```

**Policy: Users can read photos from their space**

```sql
CREATE POLICY "Users can read photos from their space"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'memories'
  AND (storage.foldername(name))[1] IN (
    SELECT id::text FROM spaces WHERE id IN (
      SELECT space_id FROM space_members WHERE user_id = auth.uid()
    )
  )
);
```

## Database Triggers & Functions

### Auto-expire Invitations

```sql
CREATE OR REPLACE FUNCTION expire_old_invitations()
RETURNS void AS $$
BEGIN
  UPDATE invitations
  SET status = 'expired'
  WHERE status = 'pending'
  AND expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Run via pg_cron every hour
SELECT cron.schedule('expire-invitations', '0 * * * *', 'SELECT expire_old_invitations()');
```

### Prevent Updates to Delivered Notes

```sql
CREATE OR REPLACE FUNCTION prevent_delivered_note_updates()
RETURNS trigger AS $$
BEGIN
  IF OLD.status = 'delivered' AND (NEW.body != OLD.body OR NEW.title != OLD.title) THEN
    RAISE EXCEPTION 'Cannot modify delivered notes (FR-006)';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER no_delivered_note_changes
BEFORE UPDATE ON notes
FOR EACH ROW
EXECUTE FUNCTION prevent_delivered_note_updates();
```

### Enforce Max 2 Members Per Space

```sql
CREATE OR REPLACE FUNCTION check_space_member_limit()
RETURNS trigger AS $$
BEGIN
  IF (SELECT COUNT(*) FROM space_members WHERE space_id = NEW.space_id) >= 2 THEN
    RAISE EXCEPTION 'A space can have at most 2 members (FR-002)';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_space_member_limit
BEFORE INSERT ON space_members
FOR EACH ROW
EXECUTE FUNCTION check_space_member_limit();
```

### Enforce Max 500 Photos Per Space

```sql
CREATE OR REPLACE FUNCTION check_memory_limit()
RETURNS trigger AS $$
BEGIN
  IF (SELECT COUNT(*) FROM memories WHERE space_id = NEW.space_id) >= 500 THEN
    RAISE EXCEPTION 'A space can have at most 500 photos (FR-017)';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_memory_limit
BEFORE INSERT ON memories
FOR EACH ROW
EXECUTE FUNCTION check_memory_limit();
```

### Archive Space When User Leaves

```sql
CREATE OR REPLACE FUNCTION archive_space_on_departure()
RETURNS trigger AS $$
BEGIN
  IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
    UPDATE spaces
    SET status = 'archived', archived_at = NOW()
    WHERE id IN (
      SELECT space_id FROM space_members WHERE user_id = NEW.id
    )
    AND status = 'active';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER archive_on_user_delete
AFTER UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION archive_space_on_departure();
```

## Type Generation

Generate TypeScript types from the database schema:

```bash
# Local development (uses local Supabase instance)
npx supabase gen types typescript --local > src/types/database.types.ts

# Production (uses remote Supabase project)
npx supabase gen types typescript --project-id <project-id> > src/types/database.types.ts
```

This creates type-safe interfaces for all tables, views, and enums, ensuring compile-time verification of queries.

**Note**: Run type generation after any migration to keep TypeScript types in sync with database schema.

## Migration Strategy

All schema changes are managed through Supabase migrations:

1. **Create migration**: `npx supabase migration new <name>`
2. **Apply locally**: `npx supabase db reset` (resets and applies all migrations)
3. **Deploy**: `npx supabase db push` (applies migrations to remote)

Migrations are version-controlled in `supabase/migrations/` directory.
