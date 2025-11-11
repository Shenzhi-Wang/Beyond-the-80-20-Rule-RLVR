#!/usr/bin/env bash
set -uxo pipefail

export VERL_HOME=${VERL_HOME:-"${HOME}/verl"}
export TRAIN_FILE=${TRAIN_FILE:-"${VERL_HOME}/data/math__combined_54.4k.parquet"}
export TEST_FILE=${TEST_FILE:-"${VERL_HOME}/data/aime-2024.parquet"}
export OVERWRITE=${OVERWRITE:-0}

mkdir -p "${VERL_HOME}/data"

if [ ! -f "${TRAIN_FILE}" ] || [ "${OVERWRITE}" -eq 1 ]; then
  wget -O "${TRAIN_FILE}" "https://huggingface.co/datasets/LLM360/guru-RL-92k/resolve/main/train/math__combined_54.4k.parquet"
fi

if [ ! -f "${TEST_FILE}" ] || [ "${OVERWRITE}" -eq 1 ]; then
  wget -O "${TEST_FILE}" "https://huggingface.co/datasets/BytedTsinghua-SIA/AIME-2024/resolve/main/data/aime-2024.parquet"
fi
