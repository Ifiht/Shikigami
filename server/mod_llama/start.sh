$!/bin/bash

# Use this for interactive testing:
# llama-cli -m ./weights/Devstral-Small-2-24B-Instruct-2512/Devstral-Small-2-24B-Instruct-2512-Q8_0.gguf -ngl 99 --no-kv-offload -ctk q8_0 -ctv q8_0 -fa on -c 131072 -sys $1

llama-server --host $1 -m ./weights/Devstral-Small-2-24B-Instruct-2512/Devstral-Small-2-24B-Instruct-2512-Q8_0.gguf -ngl 99 --no-kv-offload -ctk q8_0 -ctv q8_0 -fa on -c 131072 -sys $2
