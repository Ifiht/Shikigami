#!/usr/bin/env bash
##&% Change to current script directory
cd "${0%/*}"
##&% Source ruby environment script from rvm
source $HOME/.rvm/environments/ruby-3.1.4@shikigami
##&% Execute the event of choice (manual here):
$HOME/.rvm/wrappers/ruby-3.1.4@shikigami/ruby evt_manual.rb "log_to_pm2 'Hello, Dave.'"
