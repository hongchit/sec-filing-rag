## ADDED Requirements

### Requirement: Trigger-dependent EDGAR identity
User-attributable ingestion SHALL use the initiating user's verified email as the SEC contact identity; scheduled, maintenance, recovery, and administrator-controlled backfill workflows SHALL use the configured operational email while retaining the human actor separately.

#### Scenario: User-triggered missing filing
- **WHEN** an authenticated user's query triggers a new ingestion job
- **THEN** the job stores the user, trigger, selected contact identity, application User-Agent, initiation time, filing target, and workflow reference

### Requirement: Contact identity privacy
The selected SEC contact email SHALL NOT appear in public logs, ordinary traces, frontend progress, or user-visible job details, and users SHALL be informed before initiating eligible retrieval.

#### Scenario: Progress event emitted
- **WHEN** an ingestion progress event is sent
- **THEN** it contains no contact email or sensitive connection detail

### Requirement: Application-owned jobs
Long-running work SHALL be represented by application-owned jobs with durable status, progress, stable stage, public-safe message, provenance, workflow reference, attempts, timestamps, errors, cost, and budget state.

#### Scenario: Browser reconnect
- **WHEN** a user returns after disconnecting
- **THEN** the REST job endpoint returns the current authorized application job state without requiring Kestra structures

### Requirement: Deduplicated ingestion
Concurrent compatible requests for the same filing and corpus build SHALL share one active ingestion job while retaining separate requester and pending-query records.

#### Scenario: Concurrent missing-filing queries
- **WHEN** two users concurrently request the same unavailable filing build
- **THEN** transactional enforcement creates one workflow execution and associates both requests with it

### Requirement: Durable progress
The platform SHALL provide authenticated SSE progress and persistent REST job state using stable stages from validation through ready.

#### Scenario: SSE disconnect
- **WHEN** a progress stream disconnects and reconnects
- **THEN** the client resumes from events where supported or reconciles from persistent job state

### Requirement: Safe retry and continuation
Ingestion SHALL be idempotent, distinguish retriable from terminal failures, tolerate repeated callbacks, and automatically resume eligible pending queries after readiness only after authorization and budget revalidation.

#### Scenario: Duplicate ready callback
- **WHEN** the workflow publishes the ready state more than once
- **THEN** each pending query executes at most once

### Requirement: Shared-job cancellation
A normal user SHALL be able to cancel or detach only their own pending request; only an authorized administrator MAY cancel a shared ingestion job.

#### Scenario: Joined user cancels
- **WHEN** one joined user cancels their pending query
- **THEN** the shared job continues for other requesters

