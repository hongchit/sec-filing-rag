## ADDED Requirements

### Requirement: Common retriever result contract
BM25, vector, and hybrid retrievers SHALL return normalized results containing chunk and filing identity, filing metadata, item and section, source text, overall score, strategy-specific scores, and citation metadata.

#### Scenario: Retriever substitution
- **WHEN** query orchestration selects any enabled retriever
- **THEN** downstream context building consumes the same normalized result contract

### Requirement: PostgreSQL BM25 retrieval
Lexical retrieval SHALL use the selected PostgreSQL BM25 extension with a pinned, recorded extension and strategy configuration version.

#### Scenario: Exact terminology
- **WHEN** a query contains distinctive terminology present in indexed chunks
- **THEN** BM25 returns ranked lexical matches with recorded scores

### Requirement: Pgvector retrieval
Vector retrieval SHALL use embeddings compatible with the selected embedding and index configuration and SHALL reject incompatible versions.

#### Scenario: Incompatible embedding version
- **WHEN** a query embedding does not match the corpus index configuration
- **THEN** retrieval fails safely instead of comparing incompatible vectors

#### Scenario: Concurrent embedding selection
- **WHEN** multiple embedding sets are ready for the same filings
- **THEN** the selected experiment configuration determines the exact chunk set, embedding set, dimensions, metric, and vector index used

### Requirement: Deterministic hybrid retrieval
Initial hybrid retrieval SHALL combine lexical and vector rankings using a documented deterministic fusion method with versioned candidate counts and tie-breaking.

#### Scenario: Repeated fusion
- **WHEN** identical component rankings and configuration are fused repeatedly
- **THEN** hybrid produces the same ordering and scores

### Requirement: Intentional comparison
The system SHALL run only strategies explicitly selected for comparison and SHALL persist a parent comparison with an independent child experiment for each selected strategy.

#### Scenario: Partial comparison failure
- **WHEN** one selected strategy fails and others complete
- **THEN** completed results remain available and the failed child shows its own status

### Requirement: Embedding comparison modes
Embedding comparisons SHALL identify whether they are controlled comparisons using one mutually compatible chunk set or optimized-pipeline comparisons allowing model-specific chunking, and SHALL persist every varied configuration.

#### Scenario: OpenAI and MiniLM optimized comparison
- **WHEN** the models use different chunk sizes because of token limits
- **THEN** the report attributes results to the complete chunking-plus-embedding pipelines rather than claiming an embedding-only comparison

### Requirement: Balanced multi-target retrieval
For multi-company or multi-filing questions, retrieval SHALL apply a documented deterministic allocation that preserves evidence opportunity for every target before allocating remaining global candidates.

#### Scenario: One company dominates raw scores
- **WHEN** one comparison target supplies all highest unbalanced scores
- **THEN** the context builder still receives the configured minimum eligible evidence from every target and records the allocation

### Requirement: Evidence-bound comparison summary
The system SHALL NOT declare a universal winning strategy and SHALL show qualitative conclusions only when supported by recorded evaluation evidence.

#### Scenario: No evaluation evidence
- **WHEN** comparison results have no evaluation capable of supporting a qualitative conclusion
- **THEN** the UI presents measured differences without declaring a strongest strategy
