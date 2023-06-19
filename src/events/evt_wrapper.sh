#!/usr/bin/env bash
##&% Change to current script directory
cd "${0%/*}"
##&% Source ruby environment script from rvm
source $HOME/.rvm/wrappers/default
##&% Execute the event of choice (manual here):
ruby evt_manual.rb "log_to_pm2 'Hello, Dave.'"
