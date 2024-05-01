![Ubuntu build](https://github.com/Ifiht/Shikigami/actions/workflows/ubuntu.yml/badge.svg)
![MacOS build](https://github.com/Ifiht/Shikigami/actions/workflows/macos.yml/badge.svg)
![Formatting Check](https://github.com/Ifiht/Shikigami/actions/workflows/syntax.yml/badge.svg)

<img src="https://raw.githubusercontent.com/Ifiht/Shikigami/main/resources/Ice_Spirit_by_Rasgar.png" width="109" height="109">

# Shikigami
Personal conjured assistant template for fellow onmyōji :bookmark:

## Setup:
Start by running `init.sh` after you create your own `config.yml` file.

shikigami is meant to be run in parallel as a series of ruby scripts under [pm2](https://pm2.keymetrics.io/) (if you need another process, add it as another ruby script for pm2. Ruby files here respect the GIL).

This is currently the system I use to automate my life, sharing here in case anyone else finds it useful. Recommended to use with [nvm](https://github.com/nvm-sh/nvm) and [rvm](https://github.com/rvm/rvm) under a dedicated user account.

## Architecture:
```
                                            
 ┌────────────────────────────────────────┐ 
 │               PM2 Daemon               │ 
 └─────┬───────────────────────────┬──────┘ 
       │                           │        
       ▼                           ▼        
  ┌─────────┐                   ┌─────┐     
  │ core.rb ├───────────────────┤     │     
  └────┬────┘                   │     │     
       │                        │     │     
       ▼                        │     │     
     ┌───┐                      │  B  │     
     │   │     ┌───────────┐    │  e  │     
     │   ├────►│ module 00 ├────┤  a  │     
     │   │     └───────────┘    │  n  │     
     │ M │                      │  s  │     
     │ o │     ┌───────────┐    │  t  │     
     │ d ├────►│ module 01 ├────┤  a  │     
     │ u │     └───────────┘    │  l  │     
     │ l │                      │  k  │     
     │ e │     ┌───────────┐    │  d  │     
     │ s ├────►│ module 02 ├────┤     │     
     │   │     └───────────┘    │     │     
     │   │                      │     │     
     │   │     ┌───────────┐    │     │     
     │   ├────►│ module NN ├────┤     │     
     └───┘     └───────────┘    └─────┘     
                                            
```
_Events from external resources (chat clients, databases, filesystems) are processed by the appropriate module, or queued into `beanstalkd` as raw lines of ruby code. Each module is responsible for routing its events, which can be sent to another module or `core.rb`, which will spawn a new thread and executes `eval()` on the message body.
Every directory under `modules` with a valid `wrapper.sh` file will automatically be detected by `core.rb` and sent to PM2 for startup and persistence._

## Resources:
- [llama.cpp](https://github.com/ggerganov/llama.cpp/tree/master)
- [Llama Family](https://huggingface.co/meta-llama)
- [Discordrb](https://github.com/shardlab/discordrb/tree/main)
- [Spriggan](https://github.com/Ifiht/Spriggan/blob/main)
- [RedFairyBook](https://github.com/Ifiht/RedFairyBook/tree/main)

## Training Data:
The Large Language Model (LLM) used in this project is currently Llama 3, which is trained on the following:
- 67.0% CommonCrawl
- 15.0% C4
- 4.5% GitHub
- 4.5% Wikipedia
- 4.5% Books
- 2.5% ArXiv
- 2.0% StackExchange


*** VERY MUCH A WORK IN PROGRESS ***
