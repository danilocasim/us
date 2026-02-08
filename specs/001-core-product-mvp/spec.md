# Feature Specification: Us Core Product MVP

**Feature Branch**: `001-core-product-mvp`
**Created**: 2026-02-08
**Status**: Draft
**Input**: User description: "Us — a private, one-to-one digital space for notes, events, preferences, photos, and memories between two people"

## Clarifications

### Session 2026-02-08

- Q: What happens to shared content when one partner deletes their account? → A: Archive — departing user's content remains visible to the remaining partner as read-only; space becomes inactive.
- Q: How does the invitation reach the other person? → A: Shareable link — the inviter generates a unique link and shares it via any channel they choose. The system does not need the partner's contact info upfront.
- Q: Can users export their shared data? → A: Yes — either partner can independently export the full shared content (all notes, events, memories, etc.) without requiring the other's approval.
- Q: How is the invitation link secured against misuse? → A: Single-use with expiration — the link becomes invalid after one person opens it and automatically expires after a set period (e.g., 48 hours).
- Q: What are the availability and data recovery expectations? → A: High durability — no user content loss is acceptable under any circumstance; standard uptime expectations (no enterprise-grade SLA required).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create a Private Relationship Space (Priority: P1)

A person opens Us and creates a private space for their relationship. They invite one other person by sharing an invitation. The invited person accepts, and both parties now share a private, isolated space that no one else can see or access.

No space exists without both people explicitly consenting. The invitation is clear about what is being shared and what it means to accept.

**Why this priority**: Without a relationship space, no other feature can function. Mutual consent is the foundational trust contract of the entire product. This is the single most critical capability.

**Independent Test**: Can be fully tested by one user creating a space, sending an invitation, and a second user accepting it. Delivers a private, two-person space ready for use.

**Acceptance Scenarios**:

1. **Given** a new user with no existing space, **When** they create a relationship space and generate an invitation, **Then** the system creates a pending space and produces a unique shareable link that the inviter can send through any channel (text, email, in person, etc.). The link clearly describes what acceptance means.
2. **Given** a pending invitation, **When** the invited person accepts it, **Then** both users gain access to a shared private space and are notified that the space is active.
3. **Given** a pending invitation, **When** the invited person declines it, **Then** the pending space is removed and the inviting user is informed without revealing the reason for decline.
4. **Given** an active relationship space, **When** any third party attempts to access it, **Then** the system denies access entirely with no indication the space exists.
5. **Given** a user who already has an active space, **When** they attempt to create a second space, **Then** the system prevents it (one space per user pair).

---

### User Story 2 - Write and Deliver a Note (Priority: P2)

A user writes an intentional note or letter to their partner within their shared space. The note is composed thoughtfully — the product does not rush the writing experience. Once the user sends the note, it is delivered to their partner and preserved without edits. The partner receives it as something meaningful, not as a quick chat message.

Delivered notes are permanent. They cannot be unsent or edited after delivery, reflecting the weight of intentional written expression.

**Why this priority**: Notes and letters are the primary expression of care in Us. They are the heart of the product — enabling people to say things that matter in a way that lasts.

**Independent Test**: Can be fully tested by one user composing a note, sending it, and the partner opening and reading it. Delivers a complete cycle of intentional written communication.

**Acceptance Scenarios**:

1. **Given** a user in an active relationship space, **When** they compose and send a note, **Then** the note is delivered to their partner and becomes permanently preserved.
2. **Given** a delivered note, **When** the sender attempts to edit or delete it, **Then** the system prevents modification (permanence is enforced).
3. **Given** a delivered note, **When** the partner opens the space, **Then** they see the note presented in a calm, letter-like reading experience — not as a chat bubble.
4. **Given** a note in progress (draft), **When** the author has not yet sent it, **Then** the draft is visible only to the author and can be edited or discarded.

---

### User Story 3 - Propose and Respond to an Event (Priority: P3)

A user proposes an event or plan — a date, an outing, a shared experience — within the relationship space. The proposal includes what, when, and optionally where. The partner can agree, decline, or express a preference. The system treats planning as a form of care: asking is better than assuming.

**Why this priority**: Intentional planning is the second core pillar of the product. It transforms vague intentions into clear, considered proposals that respect both people's time and preferences.

**Independent Test**: Can be fully tested by one user creating an event proposal and the partner responding with acceptance, decline, or a preference. Delivers a complete planning cycle.

**Acceptance Scenarios**:

1. **Given** a user in an active space, **When** they create an event proposal with a description and date, **Then** the proposal is visible to their partner with clear options to agree, decline, or suggest a preference.
2. **Given** an event proposal, **When** the partner agrees, **Then** both users see the event as confirmed and it appears in their shared view.
3. **Given** an event proposal, **When** the partner declines, **Then** the proposer is informed without pressure or guilt-inducing language.
4. **Given** an event proposal, **When** the partner expresses a preference (e.g., different time, different activity), **Then** the preference is communicated back and the proposer can update or accept the suggestion.

---

### User Story 4 - Share Preferences (Priority: P4)

A user shares a preference — a desire, a mood, a boundary — in a low-pressure way within the shared space. Preferences are not demands; they are invitations to listen. The partner sees these preferences as signals, not obligations.

**Why this priority**: Preferences make listening visible. They enable partners to understand each other without requiring direct conversation for every need, reducing friction and creating emotional safety.

**Independent Test**: Can be fully tested by one user expressing a preference and the partner viewing it. Delivers a visible, low-pressure communication of needs.

**Acceptance Scenarios**:

1. **Given** a user in an active space, **When** they express a preference (desire, mood, or boundary), **Then** the preference is visible to their partner in a gentle, non-pressuring format.
2. **Given** an expressed preference, **When** the partner views it, **Then** there is no obligation to respond or act — viewing is the primary interaction.
3. **Given** a previously expressed preference, **When** the user updates or removes it, **Then** the change is reflected without notifying the partner of what changed (to avoid pressure).

---

### User Story 5 - Capture and Curate Memories (Priority: P5)

A user uploads a photo or creates a memory entry within the shared space. Memories are selective and contextual — not every photo belongs, only the ones that matter. Both partners can contribute to a curated collection of moments they experienced together.

**Why this priority**: Memories are what accumulate over time and give the space its emotional depth. However, they depend on the space, notes, and events being functional first.

**Independent Test**: Can be fully tested by one user adding a photo with context, and the partner viewing the shared memory collection. Delivers a curated, private photo album experience.

**Acceptance Scenarios**:

1. **Given** a user in an active space, **When** they upload a photo and add context (caption, date, or reflection), **Then** the memory appears in the shared collection, visible to both partners.
2. **Given** a shared memory collection, **When** either partner browses it, **Then** memories are presented in a calm, album-like experience — not as a feed or timeline.
3. **Given** a memory in the collection, **When** a partner adds a reflection or caption to an existing memory, **Then** both perspectives are preserved alongside the photo.
4. **Given** the memory collection, **When** a user attempts to bulk-upload without individual context, **Then** the system encourages selective, intentional curation (friction by design).

---

### User Story 6 - Receive Meaningful Notifications (Priority: P6)

A user receives a notification when something meaningful happens in the shared space — a note is delivered, an event is proposed, a memory is added. Notifications are restrained: they only interrupt when the interruption is justified by care. There are no engagement loops, streaks, or dopamine-driven patterns.

**Why this priority**: Notifications are the bridge between the product and real life. They must exist for the product to function, but they must be implemented with extreme restraint to avoid becoming noise.

**Independent Test**: Can be fully tested by triggering a meaningful event (note delivery, event proposal) and verifying the partner receives exactly one calm notification. Delivers respectful, care-justified interruption.

**Acceptance Scenarios**:

1. **Given** a delivered note, **When** the partner has the app closed, **Then** they receive a single notification that conveys care, not urgency (e.g., "You have a new note" not "Don't miss this!").
2. **Given** multiple events in quick succession, **When** notifications would stack up, **Then** the system batches or throttles them to avoid overwhelming the user.
3. **Given** the notification system, **When** reviewing notification behavior, **Then** there are zero engagement-driven patterns (no streaks, no "come back" messages, no gamification).
4. **Given** user notification preferences, **When** a user chooses to reduce or disable notifications, **Then** the system fully respects that choice without dark-pattern re-enablement prompts.

---

### Edge Cases

- What happens when one partner deletes their account? The other partner MUST be notified. The departing user's content (notes, memories, reflections) MUST remain visible to the remaining partner in a read-only archived state. The space becomes inactive — no new content can be created, but the archive is preserved.
- What happens when both partners are composing notes simultaneously? Each note is independent — there is no real-time chat dynamic.
- What happens when an invitation link is shared with the wrong person? The link is single-use and expires automatically (e.g., 48 hours). If the wrong person opens it, the link is consumed and the inviter can generate a new one. The invited person MUST still explicitly consent; the inviter can also revoke a pending invitation before acceptance.
- What happens when a user tries to access a space after their partner has left? The remaining user MUST retain access to their own contributions but MUST NOT be able to create new content in the space.
- What happens when the system is unavailable? Drafts MUST be preserved locally and synced when connectivity resumes. No content loss is acceptable.

## Requirements *(mandatory)*

### Functional Requirements

**Relationship & Consent**

- **FR-001**: System MUST require explicit consent from both parties before a relationship space becomes active.
- **FR-002**: System MUST support exactly one private relationship space per user pair — no multi-party spaces.
- **FR-003**: System MUST allow either user to leave a space, with clear consequences communicated beforehand. When a user leaves or deletes their account, their content MUST remain visible to the remaining partner as a read-only archive.
- **FR-004**: System MUST allow a user to revoke a pending invitation before the other party accepts.
- **FR-030**: Invitation links MUST be single-use (invalid after one person opens it) and MUST expire automatically after a set period (e.g., 48 hours). The inviter can generate a new link if the previous one expires.

**Notes & Letters**

- **FR-005**: System MUST allow users to compose, save as draft, and send notes within a shared space.
- **FR-006**: System MUST enforce permanence on delivered notes — no edits, no deletions after delivery.
- **FR-007**: System MUST present notes in a reading-focused format distinct from chat interfaces.

**Events & Plans**

- **FR-008**: System MUST allow users to create event proposals with at minimum a description and date.
- **FR-009**: System MUST allow the partner to respond to proposals with agreement, decline, or preference.
- **FR-010**: System MUST display confirmed events in a shared view accessible to both partners.

**Preferences**

- **FR-011**: System MUST allow users to express preferences (desires, moods, boundaries) visible to their partner.
- **FR-012**: System MUST present preferences without obligation or pressure to respond.
- **FR-013**: System MUST allow users to update or remove preferences without notifying the partner of changes.

**Memories & Photos**

- **FR-014**: System MUST allow users to upload photos with contextual information (caption, date, reflection).
- **FR-015**: System MUST present memories in a curated, album-like format — not as a social feed.
- **FR-016**: System MUST allow both partners to add reflections to shared memories.
- **FR-017**: System MUST encourage selective curation over bulk uploads.

**Notifications**

- **FR-018**: System MUST notify users only for meaningful events (note delivery, event proposal, memory addition).
- **FR-019**: System MUST NOT use engagement-driven notification patterns (streaks, "come back" prompts, gamification).
- **FR-020**: System MUST respect user choices to reduce or disable notifications without re-enablement pressure.
- **FR-021**: System MUST batch or throttle notifications when multiple events occur in quick succession.

**Privacy & Data**

- **FR-022**: System MUST NOT expose any space content to users outside the relationship.
- **FR-023**: System MUST NOT index, publicly discover, or share user content without explicit user action.
- **FR-024**: System MUST treat all content as belonging to the relationship, not the platform.
- **FR-025**: System MUST preserve drafts locally when connectivity is lost and sync when restored.
- **FR-029**: System MUST allow either partner to independently export the full shared content (notes, events, preferences, memories) without requiring the other partner's approval.
- **FR-031**: System MUST guarantee zero user content loss — all delivered notes, confirmed events, preferences, and memories MUST be durably stored and recoverable under any failure scenario.

**Boundaries**

- **FR-026**: System MUST NOT include features that encourage comparison between relationships.
- **FR-027**: System MUST NOT monetize emotional vulnerability or pressure emotional disclosure.
- **FR-028**: Analytics MUST measure system health only — never user intimacy or relationship behavior.

### Key Entities

- **User**: A person who has created an account. Has identity, authentication credentials, and notification preferences. Participates in at most one active relationship space.
- **Relationship Space**: A private, isolated container shared by exactly two consenting users. All content (notes, events, preferences, memories) exists within a space. No content leaks outside the space boundary.
- **Invitation**: A request from one user to another to form a relationship space. Delivered as a unique shareable link that the inviter distributes through any channel of their choosing. Has a status (pending, accepted, declined, revoked). Requires explicit acceptance. The system does not collect the partner's identity until they open the link and consent.
- **Note**: An intentional written message from one partner to another. Has draft and delivered states. Delivered notes are immutable.
- **Event**: A proposal for shared time or experience. Contains description, date, and optional location. Has states: proposed, agreed, declined, and modified (when a preference is expressed).
- **Preference**: A low-pressure expression of a desire, mood, or boundary. Visible to the partner but carries no obligation to respond. Can be updated or removed silently.
- **Memory**: A curated moment consisting of a photo and contextual information (caption, date, reflection). Both partners can contribute reflections. Presented as a collection, not a feed.
- **Notification**: A signal that something meaningful happened. Triggered only by care-justified events. Subject to batching, throttling, and user preference overrides.

### Assumptions

- Users register with an email address and password as the default authentication method.
- The product is a mobile-first experience, with potential for a companion web interface.
- Data is encrypted in transit and at rest as a baseline privacy measure.
- Zero content loss is the durability target — all user content must be recoverable. Standard uptime expectations apply (no enterprise-grade SLA).
- The system supports one active relationship space per user at a time; a user must leave a space before creating or joining another.
- Photos are stored with reasonable size limits to encourage curation over volume.
- Notification delivery uses the platform's native push notification system.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Both users can establish a shared space through explicit mutual consent within 3 minutes of the first user sending an invitation.
- **SC-002**: A user can compose and deliver a note in under 5 minutes, and the partner can read it within one interaction.
- **SC-003**: Event proposals receive a response (agree, decline, or preference) from the partner within the product — no external coordination required.
- **SC-004**: Users can browse their shared memory collection and find a specific memory within 30 seconds.
- **SC-005**: 100% of notifications are care-justified — zero engagement-driven or gamification-based notifications exist in the system.
- **SC-006**: No private content is accessible to anyone outside the relationship space under any circumstance.
- **SC-007**: 90% of users who complete onboarding report feeling that the product respects their privacy and emotional safety.
- **SC-008**: The product contains zero dark patterns, zero engagement loops, and zero attention-harvesting mechanisms as verified by UX audit.
