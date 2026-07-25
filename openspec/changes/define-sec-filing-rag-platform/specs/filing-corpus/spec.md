## ADDED Requirements

### Requirement: Selected 10-K corpus
The initial corpus SHALL support Items 1, 1A, 1C, 3, 5, 7, 7A, 8, and 9A and SHALL retain submitted ticker, CIK, company name, form, filing date, SEC acceptance time when available, reporting quarter when applicable, accession number, fiscal year, fiscal month, fiscal/reporting-period date, source URL, ingestion timestamp, parser version, item, title, source text, extraction metadata, corpus version, and ingestion version.

#### Scenario: Section inspection
- **WHEN** a stored source passage is inspected
- **THEN** it can be traced to its CIK, company, submitted ticker, filing accession, fiscal/reporting period, source URL, item, parser/extraction version, and ingestion timestamp

### Requirement: Explicit filing resolution
The query system SHALL normalize a ticker to a durable CIK and SHALL resolve and persist an explicit filing accession, selection-policy version, and corpus version even when the user selects the default latest available 10-K.

#### Scenario: Latest filing query
- **WHEN** a user submits a query with the latest-10-K default
- **THEN** the experiment records the exact CIK, accession, and corpus version selected under the documented filing-selection policy

### Requirement: Latest original 10-K policy
For the MVP, latest available 10-K SHALL mean the most recently accepted SEC filing whose form is exactly `10-K`, ordered by SEC acceptance time.

#### Scenario: Original and amended forms exist
- **WHEN** both `10-K` and `10-K/A` records exist for a company
- **THEN** default filing selection considers only the original `10-K`

### Requirement: Amendments deferred
The MVP SHALL exclude `10-K/A` amendments from ingestion, default selection, retrieval, and automatic corpus merging, and project documentation SHALL identify amendment-aware filing support as a future enhancement.

#### Scenario: Amendment requested
- **WHEN** a user attempts to query an amendment in the MVP
- **THEN** the system returns a clear unsupported-scope response and does not silently substitute it for the original filing

### Requirement: Versioned readiness
The system SHALL mark a corpus build ready only after all required stages and completeness checks succeed, and SHALL allow a prior ready version to remain queryable while a replacement builds.

#### Scenario: Partial extraction failure
- **WHEN** a required section fails extraction without qualifying as legitimately absent
- **THEN** the new corpus build is not marked ready

### Requirement: Stable citation lineage
Chunks and citations SHALL retain stable lineage through corpus, filing, section, chunk-set, source character offsets or element anchors where available, accession references, and preserved source excerpts without exposing raw database identifiers.

#### Scenario: Citation opened
- **WHEN** a user opens an answer citation
- **THEN** the system displays the correct source excerpt and filing metadata for the experiment's immutable corpus version

### Requirement: Canonical and observed section titles
Each extracted section SHALL store its item number and versioned canonical Form 10-K title separately from the exact observed filer heading, normalized display title, heading source, extraction evidence, and parser-produced confidence when available.

#### Scenario: Filer heading differs from canonical title
- **WHEN** a filing uses an abbreviated, stylized, or company-specific heading for a recognized item
- **THEN** the system preserves the observed heading, maps it to the canonical item taxonomy, and does not claim the canonical title was observed verbatim

#### Scenario: Table-of-contents heading repeats
- **WHEN** the parser encounters the same item heading in a table of contents and the document body
- **THEN** extraction evidence identifies the body section boundary rather than treating the table-of-contents entry as section content

### Requirement: Qualified optional page coordinates
Page coordinates SHALL be optional and, when present, SHALL include a scheme identifying them as filer-printed, source-PDF, EDGAR-rendered-PDF, or another explicitly versioned coordinate system; the primary citation SHALL remain accession, source URL, item, excerpt, and stable source anchor or offset.

#### Scenario: HTML filing has no reliable page
- **WHEN** an extracted passage has no reliable source pagination
- **THEN** its citation omits page number and remains resolvable through accession, item, excerpt, and source anchor or offset

#### Scenario: Filer-supplied printed page exists
- **WHEN** extraction reliably associates a passage with a filer-supplied printed page label
- **THEN** the citation stores and displays it as a qualified printed-page label rather than an unqualified canonical page number

### Requirement: Retrieval metadata projection
Authoritative company, ticker-alias, filing, and section metadata SHALL remain normalized, while chunks SHALL carry immutable projections of the identifiers and filing attributes required for indexed retrieval filters.

#### Scenario: Filtered retrieval
- **WHEN** retrieval filters by multiple companies, form, fiscal period, and item
- **THEN** the search can filter compatible chunks without treating denormalized metadata as independently editable source data

### Requirement: Concurrent embedding sets
The corpus SHALL support multiple ready embedding sets concurrently, each referencing an exact chunk set, embedding configuration, vector dimensions, distance metric, model/runtime revision, and compatible vector index.

#### Scenario: Different vector dimensions
- **WHEN** OpenAI 1,536-dimensional and MiniLM 384-dimensional sets are both ready
- **THEN** each set is queried only through its own compatible index and neither vector space is mixed with the other

### Requirement: Model-specific chunk sets
An embedding pipeline SHALL reference its exact chunk set and MAY use a model-specific chunking configuration when token limits differ.

#### Scenario: MiniLM truncation limit
- **WHEN** the MiniLM pipeline cannot safely represent the active OpenAI-sized chunks
- **THEN** it creates a distinct versioned chunk set rather than silently truncating content under the existing chunk-set identity

### Requirement: Derived artifact cleanup
An administrator SHALL be able to retire and purge eligible embedding sets, compatible vector indexes, and exclusively owned chunk sets after receiving dependency and estimated-resource impact, while active/default, running, shared, or otherwise protected artifacts remain undeletable.

#### Scenario: Test embedding set purged
- **WHEN** an administrator confirms cleanup of an inactive unshared test embedding set
- **THEN** the platform removes eligible derived storage, retains immutable metadata and experiment evidence, and records an audit event

### Requirement: Extensible collections
Every document, chunk, query, and experiment SHALL reference a collection or corpus identifier so later filing types and approved sources can be added without changing core ownership semantics.

#### Scenario: Unsupported form requested
- **WHEN** a user requests a filing type not enabled for the selected collection
- **THEN** the system rejects it with a clear supported-scope response
