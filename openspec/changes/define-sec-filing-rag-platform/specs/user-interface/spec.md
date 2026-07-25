## ADDED Requirements

### Requirement: Task-centered Tailwind interface
The frontend SHALL use Tailwind CSS and SHALL center the normal experience on asking a filing question, monitoring missing-data ingestion in place, and intentionally comparing retrieval or evaluation results.

#### Scenario: User opens Ask
- **WHEN** an authenticated user opens the primary page
- **THEN** the ticker, latest-10-K filing selector, question, defaults summary, and primary ask action are prominent without administrative workflow detail

### Requirement: Progressive disclosure
The default query form SHALL use Hybrid retrieval and None evaluation and SHALL place section filters, strategy explanations, evaluation, top-results control, permitted model selection, scores, detailed metrics, and cost details behind Advanced Settings or collapsed Run Details.

#### Scenario: Default query
- **WHEN** a user asks a question without opening Advanced Settings
- **THEN** the system uses documented defaults and does not run an unrequested comparison or evaluation

### Requirement: Validated filing inputs
The UI SHALL uppercase and validate ticker input, resolve it to a company, show the company name, offer only supported filing types, and explain unsupported or ambiguous securities clearly.

#### Scenario: Supported ticker resolved
- **WHEN** a user enters `aapl`
- **THEN** the UI displays normalized `AAPL` and the resolved company name before execution

### Requirement: In-place ingestion experience
When data is missing, the query result region SHALL transition to meaningful persistent ingestion progress with elapsed time, cost state, leave-and-return behavior, and concise failure guidance without exposing Kestra.

#### Scenario: Ingestion completes
- **WHEN** the missing filing becomes ready and the pending query remains eligible
- **THEN** the UI announces readiness and automatically transitions to running the original question

### Requirement: Answer and source experience
The result SHALL present cited readable prose, inspectable source cards, collapsed run details with separated cost categories, and feedback, evaluation, comparison, and bookmark actions.

#### Scenario: User opens source
- **WHEN** a user selects an inline citation
- **THEN** the corresponding filing excerpt and human-readable filing metadata are displayed without raw database identifiers

### Requirement: Responsive comparison
Comparison results SHALL use parallel columns when space permits and stacked cards on small screens, followed by a common metrics table.

#### Scenario: Mobile comparison
- **WHEN** a comparison is viewed at a mobile breakpoint
- **THEN** every selected strategy remains readable as a stacked result card with accessible controls

### Requirement: History usage and admin separation
The UI SHALL provide Ask, Compare, History, Jobs, and Usage navigation and SHALL display a separate role-gated Admin area only to administrators.

#### Scenario: Normal user navigation
- **WHEN** a `user` views navigation
- **THEN** administrative navigation is absent and direct admin API access remains forbidden

### Requirement: Minimal Stage 0 page
Stage 0 SHALL provide one small infrastructure verification page populated from safe FastAPI status and version responses and SHALL NOT become a general observability dashboard.

#### Scenario: Stage 0 healthy deployment
- **WHEN** the infrastructure proof is healthy
- **THEN** the page identifies deployment, frontend, API, application database, required extension, Kestra, and Kestra database status at the approved disclosure level

