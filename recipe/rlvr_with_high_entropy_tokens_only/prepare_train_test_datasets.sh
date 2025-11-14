#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

VERL_HOME="${VERL_HOME:-${PROJECT_ROOT}}"
DATA_DIR="${DATA_DIR:-${VERL_HOME}/data}"

TRAIN_FILE="${TRAIN_FILE:-${DATA_DIR}/math__combined_54.4k.parquet}"
AIME_TEST_FILE="${AIME_TEST_FILE:-${DATA_DIR}/math__aime_repeated_8x_240.parquet}"
MATH_500_TEST_FILE="${MATH_500_TEST_FILE:-${DATA_DIR}/math__math_500.parquet}"
OVERWRITE="${OVERWRITE:-0}"

export VERL_HOME DATA_DIR TRAIN_FILE AIME_TEST_FILE MATH_500_TEST_FILE OVERWRITE

mkdir -p "${DATA_DIR}"

if [[ ! -f "${TRAIN_FILE}" || "${OVERWRITE}" -eq 1 ]]; then
  wget -O "${TRAIN_FILE}" "https://huggingface.co/datasets/LLM360/guru-RL-92k/resolve/main/train/math__combined_54.4k.parquet"
fi

if [[ ! -f "${AIME_TEST_FILE}" || "${OVERWRITE}" -eq 1 ]]; then
  wget -O "${AIME_TEST_FILE}" "https://huggingface.co/datasets/LLM360/guru-RL-92k/resolve/main/offline_eval/math__aime_repeated_8x_240.parquet"
fi

if [[ ! -f "${MATH_500_TEST_FILE}" || "${OVERWRITE}" -eq 1 ]]; then
  wget -O "${MATH_500_TEST_FILE}" "https://huggingface.co/datasets/LLM360/guru-RL-92k/resolve/main/offline_eval/math__math_500.parquet"
fi

# Filter test datasets to keep only required keys
FILTER_SCRIPT="${SCRIPT_DIR}/filter_test_dataset_keys.py"
if [[ -f "${AIME_TEST_FILE}" ]]; then
  echo "Filtering AIME test file..."
  python3 "${FILTER_SCRIPT}" --input_file "${AIME_TEST_FILE}"
fi

if [[ -f "${MATH_500_TEST_FILE}" ]]; then
  echo "Filtering MATH500 test file..."
  python3 "${FILTER_SCRIPT}" --input_file "${MATH_500_TEST_FILE}"
fi

chmod +x "${SCRIPT_DIR}/duplicate_aime.sh"
"${SCRIPT_DIR}/duplicate_aime.sh" "${AIME_TEST_FILE}" 4

# Filter the duplicated AIME file as well
AIME_DUPLICATED_FILE="${DATA_DIR}/math__aime_repeated_32x_960.parquet"
if [[ -f "${AIME_DUPLICATED_FILE}" ]]; then
  echo "Filtering duplicated AIME file..."
  python3 "${FILTER_SCRIPT}" --input_file "${AIME_DUPLICATED_FILE}"
fi