#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
stage_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
scope_file="$stage_dir/scope.conf"

fail() {
  printf '%s\n' "PoC harness validation failed: $1" >&2
  exit 1
}

[ -f "$scope_file" ] || fail "missing scope.conf"

assert_line() {
  expected=$1
  grep -Fqx -- "$expected" "$scope_file" || fail "missing scope value: $expected"
}

assert_line 'TARGET_PLATFORM=linux/amd64'
assert_line 'DATA_CLASSIFICATION=public_or_synthetic_non_production'
assert_line 'RESOURCE_PREFIX=sec-filing-rag-poc-'
assert_line 'DECISION_OUTCOMES=accept,constrain,replace,defer'
assert_line 'MIN_MEASURED_RUNS=5'

for required in \
  "$stage_dir/README.md" \
  "$stage_dir/fixtures/README.md" \
  "$stage_dir/templates/evidence.md" \
  "$stage_dir/templates/decision.md" \
  "$stage_dir/evidence/README.md"; do
  [ -f "$required" ] || fail "missing ${required#"$stage_dir/"}"
done

if find "$stage_dir" -type f \
  ! -path "$stage_dir/raw/*" \
  ! -path "$stage_dir/scripts/validate-harness.sh" \
  -exec grep -EIl '(BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|AKIA[0-9A-Z]{16})' {} + | grep -q .; then
  fail 'possible private key or AWS access key in tracked PoC material'
fi

printf '%s\n' 'PoC harness valid: target=linux/amd64 data=public-or-synthetic decisions=accept|constrain|replace|defer'
