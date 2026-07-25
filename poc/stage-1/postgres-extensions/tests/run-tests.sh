#!/bin/sh
set -eu

: "${POSTGRES_DB:?POSTGRES_DB is required}"
: "${POSTGRES_USER:?POSTGRES_USER is required}"

psql_cmd="psql -X -v ON_ERROR_STOP=1 -U ${POSTGRES_USER} -d ${POSTGRES_DB}"

sh /poc/tests/generate-fixture.sh /tmp/sec-fixture.jsonl
${psql_cmd} -f /poc/tests/00-load-fixture.sql
${psql_cmd} -f /poc/tests/01-functional.sql

vector_plan=$(${psql_cmd} -Atc \
  "SET enable_seqscan=off; EXPLAIN (COSTS OFF) SELECT chunk_id FROM filing_chunks ORDER BY embedding <=> '[0.25,0.50,0.75]'::vector LIMIT 5;")
printf '%s\n' "${vector_plan}" | grep -q 'filing_chunks_embedding_hnsw'

bm25_plan=$(${psql_cmd} -Atc \
  "SET enable_seqscan=off; EXPLAIN (COSTS OFF) SELECT chunk_id FROM filing_chunks ORDER BY source_text <@> 'revenue recognition liquidity' LIMIT 5;")
printf '%s\n' "${bm25_plan}" | grep -q 'filing_chunks_source_text_bm25'

metadata_plan=$(${psql_cmd} -Atc \
  "SET enable_seqscan=off; EXPLAIN (COSTS OFF) SELECT chunk_id FROM filing_chunks WHERE ticker='ALFA' AND form='10-K' AND filing_date >= DATE '2023-01-01';")
printf '%s\n' "${metadata_plan}" | grep -q 'filing_chunks_metadata'

if ${psql_cmd} -c "SELECT '[1,2]'::vector <=> embedding FROM filing_chunks LIMIT 1;" \
    >/tmp/invalid-vector.out 2>&1; then
  echo "dimension-mismatch vector input unexpectedly succeeded" >&2
  exit 1
fi
grep -q 'different vector dimensions' /tmp/invalid-vector.out

if ${psql_cmd} -c "SELECT source_text <@> to_bm25query('revenue', 'missing_index') FROM filing_chunks LIMIT 1;" \
    >/tmp/invalid-bm25.out 2>&1; then
  echo "missing BM25 index input unexpectedly succeeded" >&2
  exit 1
fi
grep -Eq 'does not exist|not found' /tmp/invalid-bm25.out

i=1
while [ "${i}" -le 5 ]; do
  ${psql_cmd} -Atc \
    "EXPLAIN (ANALYZE, FORMAT JSON) SELECT chunk_id FROM filing_chunks ORDER BY source_text <@> 'revenue recognition liquidity' LIMIT 5;" \
    | grep -E '"Execution Time"'
  i=$((i + 1))
done

echo "all functional, plan, invalid-input, and latency-sample checks passed"
