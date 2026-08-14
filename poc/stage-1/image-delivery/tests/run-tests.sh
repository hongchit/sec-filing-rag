#!/usr/bin/env sh
set -eu

test_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

PYTHONDONTWRITEBYTECODE=1 python -c \
  'import pathlib; [compile(path.read_text(), str(path), "exec") for path in map(pathlib.Path, __import__("sys").argv[1:])]' \
  "${test_dir}/../probe.py" "${test_dir}/test_probe.py"
PYTHONDONTWRITEBYTECODE=1 python -m unittest discover \
  -s "$test_dir" -p 'test_*.py' -v
