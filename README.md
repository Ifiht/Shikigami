<img src="https://raw.githubusercontent.com/Ifiht/Shikigami/main/resources/Ice_Spirit_by_Rasgar.png" width="109" height="109">

# Shikigami
Personal conjured assistant template for fellow onmyōji :bookmark:

## Setup:
Start by running `init.sh` after you create your own `config.yml` file.

shikigami is meant to be run in parallel as a series of ruby scripts under [pm2](https://pm2.keymetrics.io/) (if you need another process, add it as another ruby script for pm2. Ruby files here respect the GIL).

This is currently the system I use to automate my life, sharing here in case anyone else finds it useful. Recommended to use with [nvm](https://github.com/nvm-sh/nvm) and [rvm](https://github.com/rvm/rvm).

## Architecture:
```
                       ┌──────────────────────────────────┐
                       ▼                                  │
                  ┌─────────┐                             │
   ┌─────────────►│         │◄─────────────┐          ┌───┴───┐
   │              │ core.rb │              │          │       │
   │  ┌───────────┤         ├───────────┐  │          │   L   │
   │  │           └──────┬──┘           │  │          │   i   │
   │  │              ▲   │              │  │          │   b   │
   │  ▼              │   ▼              ▼  │          │   r   │
┌──┴────────┐    ┌───┴───────┐    ┌────────┴──┐       │   a   │
│Connector 1│    │Connector 2│    │Connector N│◄──────┤   r   │
└──────────┬┘    └───────┬───┘    └┬──────────┘       │   i   │
       ▲   │         ▲   │         │    ▲             │   e   │
       │   │         │   │         │    │             │   s   │
       │   ▼         │   ▼         ▼    │             │       │
       │ ┌───────────┴────────────────┐ │             └───────┘
       │ │                            │ │
       └─┤     External Resources     ├─┘
         │                            │
         └────────────────────────────┘
```
_External resources (chat clients, databases, filesystems) are accessed through **Connectors**. Each connector passes messages to **core.rb**, which handles them either with internal logic, or by passing to another connector. Connectors NEVER talk to each other. Libraries contain class logic to be called by connectors and core.rb, nothing else._
_When run, core.rb is started by PM2 followed by each connector ruby file. Libraries never get run by PM2._
