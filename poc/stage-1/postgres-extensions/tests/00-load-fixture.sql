\set ON_ERROR_STOP on

DROP TABLE IF EXISTS fixture_lines;
DROP TABLE IF EXISTS filing_chunks;

CREATE TABLE fixture_lines (payload jsonb NOT NULL);
\copy fixture_lines(payload) FROM '/tmp/sec-fixture.jsonl'

CREATE TABLE filing_chunks (
    chunk_id text PRIMARY KEY,
    ticker text NOT NULL,
    cik text NOT NULL,
    company_name text NOT NULL,
    form text NOT NULL,
    filing_date date NOT NULL,
    fiscal_year integer NOT NULL,
    quarter integer,
    reporting_period date NOT NULL,
    accession_number text NOT NULL,
    source_url text NOT NULL,
    item_number text NOT NULL,
    canonical_section_title text NOT NULL,
    observed_section_title text NOT NULL,
    display_section_title text NOT NULL,
    corpus_build_id text NOT NULL,
    chunk_set_id text NOT NULL,
    source_text text NOT NULL,
    embedding vector(3) NOT NULL
);

INSERT INTO filing_chunks
SELECT
    payload->>'chunk_id',
    payload->>'ticker',
    payload->>'cik',
    payload->>'company_name',
    payload->>'form',
    (payload->>'filing_date')::date,
    (payload->>'fiscal_year')::integer,
    (payload->>'quarter')::integer,
    (payload->>'reporting_period')::date,
    payload->>'accession_number',
    payload->>'source_url',
    payload->>'item_number',
    payload->>'canonical_section_title',
    payload->>'observed_section_title',
    payload->>'display_section_title',
    payload->>'corpus_build_id',
    payload->>'chunk_set_id',
    payload->>'source_text',
    (payload->>'embedding')::vector
FROM fixture_lines
ORDER BY payload->>'chunk_id';

CREATE INDEX filing_chunks_embedding_hnsw
    ON filing_chunks USING hnsw (embedding vector_cosine_ops);
CREATE INDEX filing_chunks_source_text_bm25
    ON filing_chunks USING bm25 (source_text) WITH (text_config='english');
CREATE INDEX filing_chunks_metadata
    ON filing_chunks (ticker, form, filing_date);

ANALYZE filing_chunks;

DO $$
BEGIN
    IF (SELECT count(*) FROM filing_chunks) <> 120 THEN
        RAISE EXCEPTION 'fixture count mismatch';
    END IF;
END
$$;
