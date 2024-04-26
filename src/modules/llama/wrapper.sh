#!/bin/env bash

echo "Starting llama server..."
./server -t 12 --threads-http 2 -c 512 -ngl 32 --model ./models/Meta-Llama-3-8B-Instruct/ggml-model-Q4_K_M.gguf --host 127.0.0.1 --port 4242 -spf startup.json
