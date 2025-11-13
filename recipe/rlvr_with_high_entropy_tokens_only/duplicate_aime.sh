#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PYTHON_SCRIPT="${SCRIPT_DIR}/duplicate_aime.py"

DEFAULT_INPUT="${PROJECT_ROOT}/data/math__aime_repeated_8x_240.parquet"
DEFAULT_REPEAT=4

show_usage() {
  cat <<EOF
Usage: $(basename "$0") [input_path] [repeat_times] [output_path]

Defaults:
  input_path   -> ${DEFAULT_INPUT}
  repeat_times -> ${DEFAULT_REPEAT}
  output_path  -> inferred from input_path and repeat_times

Examples:
  $(basename "$0")
  $(basename "$0") /path/to/input.parquet 3
  $(basename "$0") /path/to/input.parquet 5 /path/to/output.parquet
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_usage
  exit 0
fi

INPUT_PATH="${1:-${DEFAULT_INPUT}}"
REPEAT_TIMES="${2:-${DEFAULT_REPEAT}}"

if [[ ! "${REPEAT_TIMES}" =~ ^[0-9]+$ ]] || [[ "${REPEAT_TIMES}" -le 0 ]]; then
  echo "repeat_times must be a positive integer, got '${REPEAT_TIMES}'." >&2
  exit 1
fi

if [[ $# -ge 3 ]]; then
  SAVE_PATH="$3"
else
  INPUT_DIR="$(dirname "${INPUT_PATH}")"
  INPUT_NAME="$(basename "${INPUT_PATH}" .parquet)"
  if [[ "${INPUT_NAME}" =~ ^(.+_)?repeated_([0-9]+)x_([0-9]+)$ ]]; then
    PREFIX="${BASH_REMATCH[1]}"
    PREFIX="${PREFIX:-}"
    ORIGINAL_MULTIPLIER="${BASH_REMATCH[2]}"
    ORIGINAL_COUNT="${BASH_REMATCH[3]}"
    NEW_MULTIPLIER=$((ORIGINAL_MULTIPLIER * REPEAT_TIMES))
    NEW_COUNT=$((ORIGINAL_COUNT * REPEAT_TIMES))
    BASE_PREFIX="${INPUT_NAME%repeated_*}"
    SAVE_BASENAME="${BASE_PREFIX}repeated_${NEW_MULTIPLIER}x_${NEW_COUNT}.parquet"
    SAVE_PATH="${INPUT_DIR}/${SAVE_BASENAME}"
  else
    SAVE_PATH="${INPUT_DIR}/${INPUT_NAME}_x${REPEAT_TIMES}.parquet"
    echo "Warning: Unable to infer output filename pattern from '${INPUT_NAME}'. Using '${SAVE_PATH}'." >&2
  fi
fi

echo "Input path:  ${INPUT_PATH}"
echo "Repeat:      ${REPEAT_TIMES}"
echo "Output path: ${SAVE_PATH}"

python3 "${PYTHON_SCRIPT}" \
  --input_path "${INPUT_PATH}" \
  --save_path "${SAVE_PATH}" \
  --repeat_times "${REPEAT_TIMES}"

