#!/bin/env bash

echo "Starting llama server..."

#./server -t 12 --threads-http 2 -c 512 -ngl 11 --model ./models/Meta-Llama-3.1-70B-Instruct/ggml-model-Q4_K_M.gguf --host 127.0.0.1 --port 4242 -spf startup.json
#./server -t 12 --threads-http 2 -c 512 -ngl 32 --model ./models/Meta-Llama-3-8B-Instruct/ggml-model-Q4_K_M.gguf --host 127.0.0.1 --port 4242 -spf startup.json
#./server -t 12 --threads-http 2 -c 512 -ngl 32 --model ./models/Meta-Llama-3.1-8B-Instruct/ggml-model-Q4_K_M.gguf --host 127.0.0.1 --port 4242 -spf startup.json
#./llama-server -t 12 --threads-http 2 -c 1024 -ngl 33 -mg 0 -m ./models/Meta-Llama-3.1-8B-Instruct/ML31_8BI-Q5KS.gguf --host 127.0.0.1 --port 4242
./llama-server -t 12 --threads-http 2 -c 1200 -ngl 33 -mg 0 -m ./models/Meta-Llama-3.1-8B-Instruct/ML31_8BI-Q5KM.gguf --host 127.0.0.1 --port 4242
