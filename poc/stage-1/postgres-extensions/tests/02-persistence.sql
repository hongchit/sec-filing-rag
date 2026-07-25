\set ON_ERROR_STOP on

DO $$
BEGIN
    IF (SELECT count(*) FROM filing_chunks) <> 120 THEN
        RAISE EXCEPTION 'fixture rows did not persist';
    END IF;
    IF current_setting('shared_preload_libraries') <> 'pg_textsearch' THEN
        RAISE EXCEPTION 'pg_textsearch preload did not persist';
    END IF;
    IF (
        SELECT count(*) FROM pg_indexes
        WHERE indexname IN (
            'filing_chunks_embedding_hnsw',
            'filing_chunks_source_text_bm25',
            'filing_chunks_metadata'
        )
    ) <> 3 THEN
        RAISE EXCEPTION 'one or more indexes did not persist';
    END IF;
END
$$;

SELECT chunk_id
FROM filing_chunks
ORDER BY embedding <=> '[0.25,0.50,0.75]'::vector
LIMIT 1;

SELECT chunk_id
FROM filing_chunks
ORDER BY source_text <@> 'revenue recognition liquidity'
LIMIT 1;
