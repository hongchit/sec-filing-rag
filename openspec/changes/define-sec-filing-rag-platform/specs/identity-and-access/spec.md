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

