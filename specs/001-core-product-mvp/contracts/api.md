# API Contract: Us Core Product MVP

> **⚠️ DEPRECATED**: This API contract document was created during initial planning but was superseded by the decision to use Supabase JS client directly (see [research.md](research.md) Section 1). The mobile app communicates with Supabase PostgreSQL, Auth, Storage, and Realtime services via `@supabase/supabase-js` client library, not through a custom REST API backend.
>
> **For actual data operations**, see:
>
> - Database schema: [data-model.md](data-model.md)
> - Supabase services: `mobile/src/services/`
> - Type definitions: `mobile/src/types/database.types.ts` (auto-generated)
>
> This document is retained for historical reference only.

---

# Historical API Contract (Not Implemented)

**Base URL**: `/api/v1` _(Not used - Supabase direct client used instead)_
**Auth**: Bearer JWT (access token) on all endpoints except auth routes
**Content-Type**: `application/json` (unless multipart for uploads)
**Date**: 2026-02-09

## Authentication

### POST /auth/register

Create a new user account.

**Request**:

```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "displayName": "Alex"
}
```

**Response** `201 Created`:

```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "displayName": "Alex",
    "createdAt": "2026-02-09T00:00:00Z"
  },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token"
}
```

**Errors**: `409 Conflict` (email taken), `422 Unprocessable Entity` (validation)

---

### POST /auth/login

Authenticate and receive tokens.

**Request**:

```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response** `200 OK`:

```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "displayName": "Alex"
  },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token"
}
```

**Errors**: `401 Unauthorized` (invalid credentials)

---

### POST /auth/refresh

Refresh an expired access token.

**Request**:

```json
{
  "refreshToken": "jwt-refresh-token"
}
```

**Response** `200 OK`:

```json
{
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token"
}
```

**Errors**: `401 Unauthorized` (invalid/expired refresh token)

---

## User

### GET /users/me

Get the authenticated user's profile.

**Response** `200 OK`:

```json
{
  "id": "uuid",
  "email": "user@example.com",
  "displayName": "Alex",
  "notificationsEnabled": true,
  "hasActiveSpace": true,
  "createdAt": "2026-02-09T00:00:00Z"
}
```

---

### PATCH /users/me

Update user profile or notification preferences.

**Request**:

```json
{
  "displayName": "Alex Updated",
  "notificationsEnabled": false
}
```

**Response** `200 OK`: Updated user object.

---

### PUT /users/me/push-token

Register or update the Expo push notification token.

**Request**:

```json
{
  "pushToken": "ExponentPushToken[xxxxx]"
}
```

**Response** `204 No Content`

---

### DELETE /users/me

Soft-delete the user account. Archives any active space.

**Response** `204 No Content`

**Side effects**: Active space transitions to `archived`; partner is notified.

---

## Space

### POST /spaces

Create a new relationship space (status: pending) and generate an invitation.

**Request**:

```json
{}
```

**Response** `201 Created`:

```json
{
  "space": {
    "id": "uuid",
    "status": "pending",
    "createdAt": "2026-02-09T00:00:00Z"
  },
  "invitation": {
    "id": "uuid",
    "token": "unique-token",
    "inviteLink": "https://us.app/invite/unique-token",
    "expiresAt": "2026-02-11T00:00:00Z",
    "status": "pending"
  }
}
```

**Errors**: `409 Conflict` (user already has an active space)

---

### GET /spaces/current

Get the authenticated user's current active or archived space.

**Response** `200 OK`:

```json
{
  "id": "uuid",
  "status": "active",
  "partner": {
    "id": "uuid",
    "displayName": "Jordan"
  },
  "createdAt": "2026-02-09T00:00:00Z"
}
```

**Errors**: `404 Not Found` (no space)

---

### DELETE /spaces/current

Leave the current space. Space transitions to archived.

**Response** `204 No Content`

**Side effects**: Partner is notified; space becomes read-only.

---

### POST /spaces/export

Export all content from the current space.

**Response** `200 OK`:

```json
{
  "exportUrl": "https://s3.example.com/exports/uuid.json",
  "expiresAt": "2026-02-09T01:00:00Z"
}
```

**Notes**: Returns a presigned URL to download a JSON export of all space content (notes, events, preferences, memories with photo URLs).

---

## Invitation

### GET /invitations/current

Get the current pending invitation for the user's pending space.

**Response** `200 OK`:

```json
{
  "id": "uuid",
  "token": "unique-token",
  "inviteLink": "https://us.app/invite/unique-token",
  "status": "pending",
  "expiresAt": "2026-02-11T00:00:00Z",
  "createdAt": "2026-02-09T00:00:00Z"
}
```

**Errors**: `404 Not Found` (no pending invitation)

---

### POST /invitations/regenerate

Revoke the current pending invitation and generate a new one.

**Response** `201 Created`:

```json
{
  "id": "uuid",
  "token": "new-unique-token",
  "inviteLink": "https://us.app/invite/new-unique-token",
  "status": "pending",
  "expiresAt": "2026-02-11T00:00:00Z"
}
```

**Errors**: `404 Not Found` (no pending space), `409 Conflict` (space already active)

---

### DELETE /invitations/current

Revoke the current pending invitation and cancel the pending space.

**Response** `204 No Content`

---

### GET /invitations/accept/:token

View invitation details before accepting (public — no auth required).

**Response** `200 OK`:

```json
{
  "inviterDisplayName": "Alex",
  "status": "pending",
  "expiresAt": "2026-02-11T00:00:00Z",
  "consentMessage": "By accepting, you and Alex will share a private space..."
}
```

**Errors**: `404 Not Found` (invalid/expired/consumed token)

---

### POST /invitations/accept/:token

Accept the invitation and join the space (auth required — accepting user must be logged in).

**Request**:

```json
{}
```

**Response** `200 OK`:

```json
{
  "space": {
    "id": "uuid",
    "status": "active",
    "partner": {
      "id": "uuid",
      "displayName": "Alex"
    }
  }
}
```

**Errors**: `404 Not Found` (invalid token), `409 Conflict` (user already has a space), `410 Gone` (expired/consumed)

**Side effects**: Space transitions to `active`; inviter is notified.

---

### POST /invitations/decline/:token

Decline the invitation (auth required).

**Response** `204 No Content`

**Side effects**: Space transitions to `archived`; inviter is notified without reason.

---

## Notes

### GET /spaces/current/notes

List all delivered notes in the current space, newest first.

**Query params**: `?cursor=uuid&limit=20`

**Response** `200 OK`:

```json
{
  "notes": [
    {
      "id": "uuid",
      "authorId": "uuid",
      "authorDisplayName": "Alex",
      "title": "For you",
      "body": "I've been thinking about...",
      "status": "delivered",
      "deliveredAt": "2026-02-09T00:00:00Z",
      "readAt": null
    }
  ],
  "nextCursor": "uuid"
}
```

---

### GET /spaces/current/notes/drafts

List the authenticated user's drafts.

**Response** `200 OK`:

```json
{
  "drafts": [
    {
      "id": "uuid",
      "title": "Working title",
      "body": "Draft content...",
      "status": "draft",
      "createdAt": "2026-02-09T00:00:00Z",
      "updatedAt": "2026-02-09T00:00:00Z"
    }
  ]
}
```

---

### POST /spaces/current/notes

Create a new note (draft or deliver immediately).

**Request**:

```json
{
  "title": "For you",
  "body": "I've been thinking about...",
  "deliver": false
}
```

**Response** `201 Created`: Note object with status `draft` or `delivered`.

**Side effects**: If `deliver: true`, partner is notified.

---

### PATCH /spaces/current/notes/:id

Update a draft note (only if status is `draft`).

**Request**:

```json
{
  "title": "Updated title",
  "body": "Updated content..."
}
```

**Response** `200 OK`: Updated note object.

**Errors**: `403 Forbidden` (not the author), `409 Conflict` (already delivered)

---

### POST /spaces/current/notes/:id/deliver

Deliver a draft note. Transitions to immutable.

**Response** `200 OK`:

```json
{
  "id": "uuid",
  "status": "delivered",
  "deliveredAt": "2026-02-09T12:00:00Z"
}
```

**Errors**: `409 Conflict` (already delivered)

**Side effects**: Partner is notified.

---

### DELETE /spaces/current/notes/:id

Delete a draft note (only drafts — hard delete).

**Response** `204 No Content`

**Errors**: `403 Forbidden` (not the author), `409 Conflict` (delivered notes cannot be deleted)

---

### POST /spaces/current/notes/:id/read

Mark a delivered note as read by the partner.

**Response** `204 No Content`

**Errors**: `403 Forbidden` (author cannot mark their own note as read)

---

## Events

### GET /spaces/current/events

List events in the current space.

**Query params**: `?status=proposed,agreed&cursor=uuid&limit=20`

**Response** `200 OK`:

```json
{
  "events": [
    {
      "id": "uuid",
      "proposerId": "uuid",
      "proposerDisplayName": "Alex",
      "title": "Dinner at our favorite place",
      "description": "That Italian restaurant we love",
      "eventDate": "2026-02-14T19:00:00Z",
      "location": "Osteria Roma",
      "status": "proposed",
      "createdAt": "2026-02-09T00:00:00Z",
      "latestResponse": null
    }
  ],
  "nextCursor": "uuid"
}
```

---

### POST /spaces/current/events

Create a new event proposal.

**Request**:

```json
{
  "title": "Dinner at our favorite place",
  "description": "That Italian restaurant we love",
  "eventDate": "2026-02-14T19:00:00Z",
  "location": "Osteria Roma"
}
```

**Response** `201 Created`: Event object with status `proposed`.

**Side effects**: Partner is notified.

---

### PATCH /spaces/current/events/:id

Update an event (only by proposer, only if `proposed` or `modified`).

**Request**:

```json
{
  "title": "Updated dinner plan",
  "eventDate": "2026-02-15T19:00:00Z"
}
```

**Response** `200 OK`: Updated event. Status resets to `proposed` if it was `modified`.

**Errors**: `403 Forbidden` (not proposer), `409 Conflict` (already agreed/declined)

---

### POST /spaces/current/events/:id/respond

Respond to an event proposal.

**Request**:

```json
{
  "type": "agree",
  "message": null
}
```

Or for a preference:

```json
{
  "type": "preference",
  "message": "Could we do Saturday instead?"
}
```

**Response** `200 OK`: Updated event with new status + response record.

**Errors**: `403 Forbidden` (proposer cannot respond to own event)

**Side effects**: Proposer is notified.

---

## Preferences

### GET /spaces/current/preferences

List active preferences in the current space.

**Query params**: `?authorId=uuid`

**Response** `200 OK`:

```json
{
  "preferences": [
    {
      "id": "uuid",
      "authorId": "uuid",
      "authorDisplayName": "Jordan",
      "category": "desire",
      "content": "I'd love to try that new Thai place",
      "createdAt": "2026-02-09T00:00:00Z",
      "updatedAt": "2026-02-09T00:00:00Z"
    }
  ]
}
```

---

### POST /spaces/current/preferences

Create a new preference.

**Request**:

```json
{
  "category": "desire",
  "content": "I'd love to try that new Thai place"
}
```

**Response** `201 Created`: Preference object.

**Side effects**: None — preferences do not trigger notifications.

---

### PATCH /spaces/current/preferences/:id

Update a preference (silent — no partner notification).

**Request**:

```json
{
  "content": "Actually, I'm in the mood for sushi"
}
```

**Response** `200 OK`: Updated preference.

**Errors**: `403 Forbidden` (not the author)

---

### DELETE /spaces/current/preferences/:id

Remove a preference (sets isActive to false — silent).

**Response** `204 No Content`

**Errors**: `403 Forbidden` (not the author)

---

## Memories

### GET /spaces/current/memories

List memories in the current space, newest first.

**Query params**: `?cursor=uuid&limit=20`

**Response** `200 OK`:

```json
{
  "memories": [
    {
      "id": "uuid",
      "uploaderId": "uuid",
      "uploaderDisplayName": "Alex",
      "photoUrl": "https://s3.example.com/photos/uuid.jpg",
      "caption": "Our first sunset together",
      "memoryDate": "2026-01-15T00:00:00Z",
      "reflections": [
        {
          "id": "uuid",
          "authorId": "uuid",
          "authorDisplayName": "Jordan",
          "content": "I remember this so clearly",
          "createdAt": "2026-02-09T00:00:00Z"
        }
      ],
      "createdAt": "2026-02-09T00:00:00Z"
    }
  ],
  "nextCursor": "uuid"
}
```

---

### POST /spaces/current/memories/upload-url

Get a presigned S3 upload URL for a photo.

**Request**:

```json
{
  "contentType": "image/jpeg",
  "fileSize": 2048576
}
```

**Response** `200 OK`:

```json
{
  "uploadUrl": "https://s3.example.com/presigned-upload-url",
  "photoKey": "photos/uuid.jpg",
  "expiresAt": "2026-02-09T00:15:00Z"
}
```

**Errors**: `422 Unprocessable Entity` (file too large — max 10MB, unsupported type)

---

### POST /spaces/current/memories

Create a memory entry after the photo has been uploaded to S3.

**Request**:

```json
{
  "photoKey": "photos/uuid.jpg",
  "caption": "Our first sunset together",
  "memoryDate": "2026-01-15T00:00:00Z"
}
```

**Response** `201 Created`: Memory object.

**Side effects**: Partner is notified.

**Notes**: Requires `caption` or `memoryDate` — at least one contextual field must be provided (encourages curation).

---

### POST /spaces/current/memories/:id/reflections

Add a reflection to a memory.

**Request**:

```json
{
  "content": "I remember this so clearly"
}
```

**Response** `201 Created`: Reflection object.

---

## Notifications

### GET /notifications

List notifications for the authenticated user.

**Query params**: `?unreadOnly=true&cursor=uuid&limit=20`

**Response** `200 OK`:

```json
{
  "notifications": [
    {
      "id": "uuid",
      "type": "note_delivered",
      "referenceId": "uuid",
      "title": "New note from Jordan",
      "body": "You have a new note waiting",
      "isRead": false,
      "createdAt": "2026-02-09T00:00:00Z"
    }
  ],
  "nextCursor": "uuid"
}
```

---

### POST /notifications/read

Mark notifications as read.

**Request**:

```json
{
  "notificationIds": ["uuid1", "uuid2"]
}
```

**Response** `204 No Content`

---

## Error Response Format

All errors follow this structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description",
    "details": {}
  }
}
```

**Standard error codes**:

- `VALIDATION_ERROR` (422)
- `UNAUTHORIZED` (401)
- `FORBIDDEN` (403)
- `NOT_FOUND` (404)
- `CONFLICT` (409)
- `GONE` (410)
- `RATE_LIMITED` (429)
- `INTERNAL_ERROR` (500)
