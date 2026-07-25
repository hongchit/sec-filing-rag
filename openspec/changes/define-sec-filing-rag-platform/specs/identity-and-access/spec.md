## ADDED Requirements

### Requirement: Verified Google authentication
The platform SHALL require Google authentication for all MVP users and SHALL accept only identities whose email is verified by the configured identity provider.

#### Scenario: Unverified identity
- **WHEN** an identity lacks a verified-email assertion
- **THEN** the platform rejects login and does not create an authenticated application session

### Requirement: Stable application identity
The platform SHALL map the stable Google subject to an application-owned user record and SHALL not use a mutable email address as the sole identity key.

#### Scenario: Returning user
- **WHEN** the same Google subject authenticates again
- **THEN** the platform resolves the existing application user and current application role

### Requirement: FastAPI-owned opaque session
FastAPI SHALL own a revocable server-side session represented by a random opaque token whose stored representation is hashed and whose browser representation uses a `Secure`, `HttpOnly`, `SameSite=Lax` cookie.

#### Scenario: Authenticated API request
- **WHEN** the browser sends a valid unexpired session cookie
- **THEN** FastAPI resolves the current user and role without exposing Google or application bearer tokens to frontend JavaScript

### Requirement: Session lifetime and revocation
The default session policy SHALL enforce a seven-day absolute lifetime and twelve-hour idle timeout, rotate identifiers after login and privilege changes, and revoke all sessions when the account is deactivated.

#### Scenario: User deactivated
- **WHEN** an administrator deactivates a user
- **THEN** all of that user's active sessions become invalid while durable jobs and records remain owned by the user

### Requirement: Request-forgery protection
State-changing browser requests SHALL require a session-bound CSRF token, an allowlisted request origin, and an approved content type; read-only SSE MAY authenticate with the session cookie.

#### Scenario: Missing CSRF token
- **WHEN** an otherwise authenticated cross-site state-changing request lacks a valid CSRF token
- **THEN** FastAPI rejects it without performing the operation

### Requirement: Backend role enforcement
FastAPI SHALL enforce the `user` and `admin` roles on every protected operation; frontend visibility SHALL NOT be treated as authorization.

#### Scenario: User calls admin API
- **WHEN** an authenticated `user` calls an administrative endpoint
- **THEN** FastAPI returns a forbidden response without performing the operation

### Requirement: User data isolation
Users SHALL access only their own private queries, experiments, pending requests, usage, and job associations, while administrators MAY access platform-wide records through audited admin operations.

#### Scenario: Cross-user history request
- **WHEN** a user requests another user's private experiment identifier
- **THEN** the platform denies access without disclosing private experiment content

### Requirement: Audited administration
The platform SHALL provide a documented initial-admin bootstrap and SHALL audit role changes and security-sensitive administrative actions.

#### Scenario: Role assignment
- **WHEN** an administrator changes a user's role
- **THEN** the system records the actor, target, old role, new role, and timestamp
