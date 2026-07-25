## ADDED Requirements

### Requirement: Authenticated query execution
The platform SHALL allow an authenticated user to submit a validated ticker, question, filing scope, permitted section filter, retrieval strategy, and evaluation profile.

#### Scenario: Ready filing
- **WHEN** a valid query resolves to a ready corpus version
- **THEN** the system retrieves context, generates a grounded answer, and persists the execution

### Requirement: Grounded answer
Generated answers SHALL rely on supplied filing context, cite supporting passages, identify insufficient evidence, distinguish source facts from interpretation, and avoid presenting financial advice.

#### Scenario: Insufficient context
- **WHEN** retrieved context does not support an answer
- **THEN** the answer explicitly states that evidence is insufficient and does not invent a filing claim

### Requirement: Source presentation
The query result SHALL include readable inline citations and source cards containing company, form, filing date, reporting year, item, section title, relevant excerpt, and accession or source link.

#### Scenario: Answer with citations
- **WHEN** a grounded answer is returned
- **THEN** every citation resolves to a displayed or inspectable passage used in that execution

### Requirement: Operational metrics
Every query execution SHALL record retrieval, generation, and total latency; retrieved chunk count; citation count; tokens; categorized cost; errors; and retries without requiring an additional evaluation call.

#### Scenario: Generation failure
- **WHEN** retrieval succeeds but generation fails
- **THEN** the failed execution retains completed retrieval metrics and a normalized error state

