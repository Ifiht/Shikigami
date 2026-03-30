$!/bin/bash

# Use this for interactive testing:
# llama-cli -m ./weights/Devstral-Small-2-24B-Instruct-2512/Devstral-Small-2-24B-Instruct-2512-Q8_0.gguf -ngl 99 --no-kv-offload -ctk q8_0 -ctv q8_0 -fa on -c 131072 -sys $1

llama-server --host $1 -m ./weights/Devstral-Small-2-24B-Instruct-2512/Devstral-Small-2-24B-Instruct-2512-Q8_0.gguf -ngl 99 --no-kv-offload -ctk q8_0 -ctv q8_0 -fa on -c 131072 -np 1
# -np 1; n_parallel = 1, this enables only one parallel slot, preventing context window split.
# -ngl 99; number of GPU layers, we should only have 40 & this will ensure they all go to GPU
# --no-kv-offload, keeps kv cache (context) on the CPU instead of offloading to GPU
# -fa on; flash_attention, optimizes attention memory usage
