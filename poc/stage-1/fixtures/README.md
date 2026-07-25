# Representative SEC-style fixture contract

Stage 1.2 will use 100–1,000 synthetic or public, non-production chunks. The fixture is designed to test index compatibility and filtering, not retrieval quality claims.

Each JSON Lines record must contain:

- stable fixture `chunk_id`
- `ticker`, zero-padded `cik`, and `company_name`
- exact `form`
- `filing_date`, `fiscal_year`, optional `quarter`, and reporting-period date
- accession number and source URL or fixture provenance
- item number and canonical, observed, and display section titles
- corpus-build and chunk-set identifiers
- source text containing exact financial terminology and semantic paraphrases
- a deterministic vector of the dimension selected by the PoC

Coverage must include multiple companies, years, items, exact-term matches, paraphrases, repeated-looking passages, punctuation, Unicode, and deliberately unmatched filters. No record may contain a private question, user identity, SEC contact email, credential, or proprietary filing content.

Fixture generation must be deterministic from a recorded seed. The reviewed evidence records the record count and SHA-256 checksum; the checksum verifies the fixture and is not a relational or lookup key.
