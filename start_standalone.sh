#!/usr/bin/env bash

if [ -z "${MODEL+x}" ]; then
  MODEL="TheBloke/Wizard-Vicuna-13B-Uncensored-SuperHOT-8K-GPTQ"
fi

# Replace slashes with underscores
MODEL="${MODEL//\//_}"
echo "Model: ${MODEL}"

if [ -d "/workspace/text-generation-webui/models/${MODEL}" ]; then
  echo "Starting Oobabooga Text Generation Server"
  cd /workspace/text-generation-webui
  mkdir -p /workspace/logs
  nohup python3 server.py \
    --listen \
    --api \
    --loader ExLlama \
    --model ${MODEL} \
    --max_seq_len 4096 \
    --compress_pos_emb 2 \
    --listen-port 3000 \
    --api-port 5001 \
    --api-blocking-port 5000 \
    --api-streaming-port 5005 &> /workspace/logs/textgen.log &

  echo "Starting RunPod Handler"
  export PYTHONUNBUFFERED=1
  python3 -u /rp_handler.py
else
  echo "Model directory not found!"
fi
