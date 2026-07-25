## ADDED Requirements

### Requirement: Immutable configuration versions
Configuration changes SHALL create immutable version records with logical identity, creator, timestamp, safe values, and an independently managed active-version pointer.

#### Scenario: Default model changes
- **WHEN** an administrator selects a new default generation model
- **THEN** a new configuration version becomes active without modifying historical versions

### Requirement: Secret separation
Configuration records and experiment snapshots SHALL reference but SHALL NOT contain provider credentials, database passwords, operational contact emails, or other secrets.

#### Scenario: Configuration inspected
- **WHEN** an authorized user retrieves an experiment configuration snapshot
- **THEN** reproducibility metadata is present and secret values are absent

### Requirement: Reproducible experiment run
Every query execution SHALL persist its corpus and filing scope, question, retrieval and generation configuration, models, prompt, evaluation profile, execution strategy, retrieved results, answer, citations, latency, usage, costs, evaluations, and trace identifiers.

#### Scenario: Historical run reopened
- **WHEN** a user opens a run after active configurations have changed
- **THEN** the run displays the exact immutable versions used originally

### Requirement: Typed analytical dimensions
Experiments SHALL store commonly analyzed configuration references, status, latency, token, source-count, and cost metrics in typed fields while retaining immutable JSON snapshots for full configuration and uncommon provider-specific details.

#### Scenario: Embedding performance report
- **WHEN** an administrator groups benchmark runs by embedding and chunking configuration
- **THEN** the database can aggregate typed quality, latency, usage, and cost metrics without parsing the complete configuration JSON for every run

### Requirement: Multiple resolved query targets
A query SHALL support one or more target records that resolve company, filing, form, fiscal period, and section scope to immutable identifiers before execution.

#### Scenario: Cross-company comparison
- **WHEN** a query compares two companies
- **THEN** the experiment retains both exact filing scopes and each retrieved result retains its source target

### Requirement: Purged derived artifacts
When an administrator purges an eligible derived embedding or chunk set, experiments SHALL retain configuration, metrics, retrieved-evidence snapshots, citations, and an explicit purged-artifact state.

#### Scenario: Historical purged run opened
- **WHEN** a user opens an experiment whose derived embedding set was purged
- **THEN** the stored run remains inspectable and clearly indicates that exact rerun is unavailable until artifacts are regenerated

### Requirement: History and feedback
Users SHALL be able to filter and inspect their own stored runs, bookmark or label a run, and submit answer feedback without mutating the original execution record.

#### Scenario: Feedback submitted
- **WHEN** a user marks an answer helpful or not helpful
- **THEN** the system stores a linked feedback record and preserves the original experiment
