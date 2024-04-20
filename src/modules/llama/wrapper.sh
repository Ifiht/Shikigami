#!/bin/env bash

echo "Starting llama server..."
./server -t 12 --threads-http 1 -c 512 --model models/Llama-2-13b-chat-hf/ggml-model-Q4_K_M.gguf --host 127.0.0.1 --port 4242 -spf startup.json
