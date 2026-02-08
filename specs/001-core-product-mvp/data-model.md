# Data Model: Us Core Product MVP

**Source**: [spec.md](./spec.md) Key Entities + Clarifications
**Date**: 2026-02-09

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

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| email | String | Unique, not null | Used for login |
| passwordHash | String | Not null | bcrypt hashed |
| displayName | String | Not null, max 50 chars | Shown to partner |
| pushToken | String? | Nullable | Expo push notification token |
| notificationsEnabled | Boolean | Default: true | Global notification toggle |
| createdAt | DateTime | Auto-set | |
| updatedAt | DateTime | Auto-updated | |
| deletedAt | DateTime? | Nullable | Soft delete — triggers space archival |

**Constraints**:
- A user participates in at most one active space at a time.
- Soft-deleted users retain their content in the space as read-only.

### Space

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| status | Enum | Not null | `pending`, `active`, `archived` |
| createdAt | DateTime | Auto-set | |
| updatedAt | DateTime | Auto-updated | |
| archivedAt | DateTime? | Nullable | Set when space becomes archived |

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

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| spaceId | UUID | FK → Space, not null | |
| userId | UUID | FK → User, not null | |
| role | Enum | Not null | `owner`, `partner` |
| joinedAt | DateTime | Auto-set | |

**Constraints**:
- Unique(spaceId, userId) — a user can only be in a space once.
- Max 2 members per space (enforced at application layer).
- A user can have at most one SpaceMember record with an active Space.

### Invitation

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| spaceId | UUID | FK → Space, not null | Links to the pending space |
| inviterId | UUID | FK → User, not null | Who created the invitation |
| token | String | Unique, not null | Unique token for the shareable link |
| status | Enum | Not null | `pending`, `accepted`, `declined`, `revoked`, `expired` |
| expiresAt | DateTime | Not null | Default: 48 hours from creation |
| consumedAt | DateTime? | Nullable | When link was first opened |
| respondedAt | DateTime? | Nullable | When accept/decline occurred |
| createdAt | DateTime | Auto-set | |

**State Transitions**:
```text
pending  → accepted  (partner opens link and accepts)
pending  → declined  (partner opens link and declines)
pending  → revoked   (inviter manually revokes)
pending  → expired   (expiresAt passes without action)
```

**Constraints**:
- Single-use: once consumedAt is set, the link cannot be used by another person.
- Automatically expires after the configured period (default 48h).
- Inviter can generate a new invitation if the previous one expires or is revoked.

### Note

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| spaceId | UUID | FK → Space, not null | |
| authorId | UUID | FK → User, not null | |
| title | String? | Nullable, max 100 chars | Optional title |
| body | String | Not null, max 10,000 chars | The note content |
| status | Enum | Not null | `draft`, `delivered` |
| deliveredAt | DateTime? | Nullable | Set when status becomes delivered |
| readAt | DateTime? | Nullable | Set when partner first opens it |
| createdAt | DateTime | Auto-set | |
| updatedAt | DateTime | Auto-updated | Only meaningful in draft state |

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

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| spaceId | UUID | FK → Space, not null | |
| proposerId | UUID | FK → User, not null | |
| title | String | Not null, max 100 chars | What the event is |
| description | String? | Nullable, max 2,000 chars | Additional details |
| eventDate | DateTime | Not null | When the event is proposed for |
| location | String? | Nullable, max 200 chars | Where (optional) |
| status | Enum | Not null | `proposed`, `agreed`, `declined`, `modified` |
| createdAt | DateTime | Auto-set | |
| updatedAt | DateTime | Auto-updated | |

**State Transitions**:
```text
proposed → agreed    (partner accepts)
proposed → declined  (partner declines)
proposed → modified  (partner suggests a change)
modified → agreed    (proposer accepts modification)
modified → proposed  (proposer updates and re-proposes)
```

### EventResponse

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| eventId | UUID | FK → Event, not null | |
| responderId | UUID | FK → User, not null | |
| type | Enum | Not null | `agree`, `decline`, `preference` |
| message | String? | Nullable, max 500 chars | Optional: reason or suggestion |
| createdAt | DateTime | Auto-set | |

**Constraints**:
- Records the history of responses for an event.
- When type is `preference`, message contains the suggestion.

### Preference

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| spaceId | UUID | FK → Space, not null | |
| authorId | UUID | FK → User, not null | |
| category | Enum | Not null | `desire`, `mood`, `boundary` |
| content | String | Not null, max 500 chars | The preference text |
| isActive | Boolean | Default: true | False when user removes it |
| createdAt | DateTime | Auto-set | |
| updatedAt | DateTime | Auto-updated | Silent updates — no partner notification |

**Constraints**:
- Updates and removals do not generate notifications for the partner.
- Partner sees only active preferences.

### Memory

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| spaceId | UUID | FK → Space, not null | |
| uploaderId | UUID | FK → User, not null | |
| photoUrl | String | Not null | S3 object URL |
| photoKey | String | Not null | S3 object key (for deletion/export) |
| caption | String? | Nullable, max 500 chars | |
| memoryDate | DateTime? | Nullable | When the moment happened |
| createdAt | DateTime | Auto-set | |

**Constraints**:
- One photo per memory entry (encourages curation over bulk).
- Photo size capped at 10MB (enforced at upload).

### Reflection

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| memoryId | UUID | FK → Memory, not null | |
| authorId | UUID | FK → User, not null | |
| content | String | Not null, max 1,000 chars | The reflection text |
| createdAt | DateTime | Auto-set | |

**Constraints**:
- Both partners can add reflections to any memory.
- Multiple reflections per user per memory are allowed.

### Notification

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| recipientId | UUID | FK → User, not null | |
| spaceId | UUID | FK → Space, not null | |
| type | Enum | Not null | `note_delivered`, `event_proposed`, `event_responded`, `memory_added`, `partner_joined`, `partner_left` |
| referenceId | UUID? | Nullable | ID of the triggering entity |
| title | String | Not null | Short notification title |
| body | String | Not null | Notification body text |
| isRead | Boolean | Default: false | |
| isPushed | Boolean | Default: false | Whether push was sent |
| createdAt | DateTime | Auto-set | |

**Constraints**:
- Only care-justified types allowed (enum enforced).
- No engagement-driven notification types exist in the enum.
- Batching/throttling logic lives in the notification service, not the data model.

## Indexes

| Table | Index | Type | Purpose |
|-------|-------|------|---------|
| User | email | Unique | Login lookup |
| SpaceMember | (spaceId, userId) | Unique | Prevent duplicate membership |
| Invitation | token | Unique | Link lookup |
| Invitation | expiresAt | B-tree | Expiration cleanup queries |
| Note | (spaceId, status, createdAt) | Composite | List delivered notes in a space |
| Event | (spaceId, status, eventDate) | Composite | List upcoming events |
| Preference | (spaceId, authorId, isActive) | Composite | Active preferences per user |
| Memory | (spaceId, createdAt) | Composite | Album browsing |
| Notification | (recipientId, isRead, createdAt) | Composite | Unread notification listing |

## Data Retention & Export

- **Soft delete**: Users are soft-deleted (deletedAt set). Their content remains in the space as read-only.
- **Space archival**: When a space becomes archived, all content is preserved but no new writes are allowed.
- **Export**: Either partner can export full space content (all notes, events, preferences, memories with photo URLs) as a structured data package.
- **Durability**: Zero content loss requirement — PostgreSQL with WAL archiving and regular backups; S3 with versioning enabled for photos.
