## ADDED Requirements

### Requirement: Selected 10-K corpus
The initial corpus SHALL support Items 1, 1A, 1C, 3, 5, 7, 7A, 8, and 9A and SHALL retain filing, company, ticker, form, dates, item, title, source text, extraction metadata, accession or source reference, corpus, and ingestion version metadata.

#### Scenario: Section inspection
- **WHEN** a stored source passage is inspected
- **THEN** it can be traced to its company, filing accession, reporting period, item, extraction version, and source reference

### Requirement: Explicit filing resolution
The query system SHALL resolve and persist an explicit filing accession and corpus version even when the user selects the default latest available 10-K.

#### Scenario: Latest filing query
- **WHEN** a user submits a query with the latest-10-K default
- **THEN** the experiment records the exact filing selected under the documented filing-selection policy

### Requirement: Versioned readiness
The system SHALL mark a corpus build ready only after all required stages and completeness checks succeed, and SHALL allow a prior ready version to remain queryable while a replacement builds.

#### Scenario: Partial extraction failure
- **WHEN** a required section fails extraction without qualifying as legitimately absent
- **THEN** the new corpus build is not marked ready

### Requirement: Stable citation lineage
Chunks and citations SHALL retain stable lineage through corpus, filing, section, chunk-set, source offsets where available, and accession references without exposing raw database identifiers.

#### Scenario: Citation opened
- **WHEN** a user opens an answer citation
- **THEN** the system displays the correct source excerpt and filing metadata for the experiment's immutable corpus version

### Requirement: Extensible collections
Every document, chunk, query, and experiment SHALL reference a collection or corpus identifier so later filing types and approved sources can be added without changing core ownership semantics.

#### Scenario: Unsupported form requested
- **WHEN** a user requests a filing type not enabled for the selected collection
- **THEN** the system rejects it with a clear supported-scope response

