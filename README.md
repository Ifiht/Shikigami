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
        eval()     ┌─────────┐
    ┌──────────────┤ core.rb │
    │              └─────────┘                    ┌─────┐
    │                ▲     ▲   ruby code as text  │     │
    │          ┌─────┘     └──────────────────────┤     │
    │          │                                  │     │
    │       ┌──┴──┐           ┌───────┐           │  b  │
    │       │     ├──────►┌──►│evt_one├──────────►│  e  │
    │       │  l  │       │   └───────┘           │  a  │
    │       │  i  │       │                       │  n  │
    │       │  b  │       │                       │  s  │
    │       │  r  │       │   ┌───────┐           │  t  │
    │       │  a  ├──────►├──►│evt_two├──────────►│  a  │
    │       │  r  │       │   └───────┘           │  l  │
    │       │  y  │       │                       │  k  │
    │       │  /  │       │                       │  d  │
    │       │  *  │       │   ┌───────┐           │     │
    │       │     ├──────►├──►│evt_N  ├──────────►│     │
    │       └─────┘       │   └───────┘           │     │
    │                     │                       └─────┘
    ▼                     │
 ┌────────────────────────┴─────────────────────────────┐
 │                                                      │
 │                    External                          │
 │                                                      │
 │                    Environment                       │
 │                                                      │
 └──────────────────────────────────────────────────────┘
```
_Events from external resources (chat clients, databases, filesystems) are queued into `beanstalkd` as raw lines of ruby code. For each message in the queue, `core.rb` spawns a new thread and executes `eval()` on the message body. All code beyond the single line for execution should be written into a single file, consisting of a single class, in the library directory, and will automatically be included in `core.rb` at runtime. Classes must be initialized in `core.rb` for use, as well as any sensitive tokens or ids from config.yml._  
_When run, core.rb is started by PM2 followed by event listener ruby file. Libraries never get run by PM2._
