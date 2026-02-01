<img src="https://raw.githubusercontent.com/Ifiht/Shikigami/main/res/Ice_Spirit_by_Rasgar.png" width="109" height="109">

# Shikigami
A personal conjured assistant template for fellow onmyōji :bookmark:  
Just my take on Neuro-symbolic AI for personal use `¯\_(ツ)_/¯`

## Purpose
This repo exists to create the scaffolding needed for an always-on, extensible, LLM-enhanced collection of automated workflows. End goals include:

- Abstract world model for data
- Data verification within world models via [SWI-Prolog](https://www.swi-prolog.org/)
- "Idle" workflows, to expand knowledge base and engage in self-refinement

## Architecture

- [PM2](https://pm2.keymetrics.io/) for process management
- SQLite3 for data storage (all db entries should be valid assertion or axiom, globally verified)
- [Beanstalkd](https://beanstalkd.github.io/) for message passing
- Ruby for scripting and task management
- [Piper-TTS](https://github.com/OHF-Voice/piper1-gpl/tree/main) for speech
- [Mistral AI's](https://docs.mistral.ai/models/devstral-2-25-12) Devstral-2-Small
- ggerganov's fantastic [llama.cpp](https://github.com/ggml-org/llama.cpp) for inference