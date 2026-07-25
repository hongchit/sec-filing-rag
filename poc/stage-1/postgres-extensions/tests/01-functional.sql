\set ON_ERROR_STOP on

DO $$
BEGIN
    IF current_setting('shared_preload_libraries') <> 'pg_textsearch' THEN
        RAISE EXCEPTION 'pg_textsearch is not preloaded';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_extension
        WHERE extname = 'vector' AND extversion = '0.8.2'
    ) THEN
        RAISE EXCEPTION 'unexpected vector extension version';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_extension
        WHERE extname = 'pg_textsearch' AND extversion = '1.2.0'
    ) THEN
        RAISE EXCEPTION 'unexpected pg_textsearch extension version';
    END IF;
END
$$;

SELECT chunk_id, embedding <=> '[0.25,0.50,0.75]'::vector AS cosine_distance
FROM filing_chunks
ORDER BY embedding <=> '[0.25,0.50,0.75]'::vector
LIMIT 5;

SELECT chunk_id, ticker, source_text <@> 'revenue recognition liquidity' AS bm25_score
FROM filing_chunks
ORDER BY source_text <@> 'revenue recognition liquidity'
LIMIT 5;

SELECT chunk_id, ticker, form, filing_date,
       source_text <@> 'revenue recognition liquidity' AS bm25_score
FROM filing_chunks
WHERE ticker = 'ALFA'
  AND form = '10-K'
  AND filing_date >= DATE '2023-01-01'
ORDER BY source_text <@> 'revenue recognition liquidity'
LIMIT 5;

WITH vector_hits AS (
    SELECT chunk_id,
           row_number() OVER (
               ORDER BY embedding <=> '[0.25,0.50,0.75]'::vector
           ) AS vector_rank
    FROM filing_chunks
    WHERE ticker = 'ALFA' AND form = '10-K'
    ORDER BY embedding <=> '[0.25,0.50,0.75]'::vector
    LIMIT 20
),
lexical_hits AS (
    SELECT chunk_id,
           row_number() OVER (
               ORDER BY source_text <@> 'revenue recognition liquidity'
           ) AS lexical_rank
    FROM filing_chunks
    WHERE ticker = 'ALFA' AND form = '10-K'
    ORDER BY source_text <@> 'revenue recognition liquidity'
    LIMIT 20
)
SELECT f.chunk_id, f.ticker, f.form,
       coalesce(1.0 / (60 + v.vector_rank), 0) +
       coalesce(1.0 / (60 + l.lexical_rank), 0) AS reciprocal_rank_score
FROM filing_chunks AS f
LEFT JOIN vector_hits AS v USING (chunk_id)
LEFT JOIN lexical_hits AS l USING (chunk_id)
WHERE v.chunk_id IS NOT NULL OR l.chunk_id IS NOT NULL
ORDER BY reciprocal_rank_score DESC, f.chunk_id
LIMIT 5;

SET enable_seqscan = off;

EXPLAIN (COSTS OFF)
SELECT chunk_id
FROM filing_chunks
ORDER BY embedding <=> '[0.25,0.50,0.75]'::vector
LIMIT 5;

EXPLAIN (COSTS OFF)
SELECT chunk_id
FROM filing_chunks
ORDER BY source_text <@> 'revenue recognition liquidity'
LIMIT 5;

EXPLAIN (COSTS OFF)
SELECT chunk_id
FROM filing_chunks
WHERE ticker = 'ALFA'
  AND form = '10-K'
  AND filing_date >= DATE '2023-01-01';

RESET enable_seqscan;
