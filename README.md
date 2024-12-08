![Ubuntu build](https://github.com/Ifiht/Shikigami/actions/workflows/ubuntu.yml/badge.svg)
![MacOS build](https://github.com/Ifiht/Shikigami/actions/workflows/macos.yml/badge.svg)
![Formatting Check](https://github.com/Ifiht/Shikigami/actions/workflows/syntax.yml/badge.svg)

<img src="https://raw.githubusercontent.com/Ifiht/Shikigami/main/resources/Ice_Spirit_by_Rasgar.png" width="109" height="109">

# Shikigami
Personal conjured assistant template for fellow onmyōji :bookmark:

### Vision
A self-contained, learning, fully offline virtual assistant.

### Setup:
1. Start by running `init.sh` after you create your own `config.yml` file.
2. Run `git submodule update --init --recursive` to pull down beanstalkd, then `cd beanstalkd` and `make`.
3. Run `start.sh` once `ecosystem.config.js` is created.

Requires [pm2](https://pm2.keymetrics.io/), [nvm](https://github.com/nvm-sh/nvm), and [rvm](https://github.com/rvm/rvm) under a dedicated user account.

### Architecture:
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

### Resources:
- [llama.cpp](https://github.com/ggerganov/llama.cpp/tree/master)
- [Llama Family](https://huggingface.co/meta-llama)
- [NVidia CUDA](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=24.04&target_type=runfile_local)
- [Discordrb Ruby Gem](https://github.com/shardlab/discordrb/tree/main)
- [Spriggan Ruby Gem](https://github.com/Ifiht/Spriggan/blob/main)
- [RedFairyBook Ruby Gem](https://github.com/Ifiht/RedFairyBook/tree/main)
## AI
```
Llama 3.1 8B Instruct
Quantization: Q5_K_M
llama_model_quantize_internal: model size  = 30633.02 MB
llama_model_quantize_internal: quant size  =  5459.93 MB
context size: 1200
```
### Size
"Context Size" = defines the maximum sequence length the model can process during inference or training. The context size determines how much text the model can "see" at once when generating predictions or understanding the input.  
`Q4_K_S`, `Q4_K_M`, `Q4_K_L`  
In 4-bit quantization, each parameter now requires only 0.5 bytes. For a 70 billion parameter model, the memory footprint becomes:

    Memory for model weights:
    70B params×0.5 bytes/param=35 GB of VRAM
    
### Fine-Tuning
** Coming Soon **

### Training
- [Optimal Tokens](https://arxiv.org/abs/2203.15556)
- [Avoid AI sources](https://arxiv.org/abs/2305.17493)
- [Llama 3 Paper](https://scontent-iad3-1.xx.fbcdn.net/v/t39.2365-6/468347782_9231729823505907_4580471254289036098_n.pdf?_nc_cat=110&ccb=1-7&_nc_sid=3c67a6&_nc_ohc=Gou09yQLZqwQ7kNvgHlphYw&_nc_zt=14&_nc_ht=scontent-iad3-1.xx&_nc_gid=AWr4p5C4Ebxrs7DbkH5-qon&oh=00_AYDsB9QkEUQRv5gMpkQkcBRMK7COVfO5tiEo0mUwNIOU_g&oe=675A3A80)

### Training Data:
The Large Language Model (LLM) used in this project is currently Llama 3.1, which is trained on the following:
- 67.0% CommonCrawl
- 15.0% C4
- 4.5% GitHub
- 4.5% Wikipedia
- 4.5% Books
- 2.5% ArXiv
- 2.0% StackExchange


*** VERY MUCH A WORK IN PROGRESS ***
