#!/usr/bin/env ruby
#/===============================================================\\
#|              Manual Event - Example Script                    ||
#| Usage: ./evt_manual.rb "tube_name" "puts 'Hello, PM2'"        ||
#| This script takes one argument, which should be a valid line  ||
#| of Ruby code. that code is then passed on to core.rb via      ||
#| beanstalkd, and evaluated. Running the example above will     ||
#| log the message "Hello, PM2" to the PM2 daemon log. For use   ||
#| mainly with ad-hoc tasks, or schedulers like cron.            ||
#\===============================================================//
require "beaneater"
require_relative "lib/shiki_gram"
require_relative "lib/app_settings"

# Get user settings
core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")

# Connect to beanstalkd
beanstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
args = ARGV
if args.length != 2
tube = beanstalk.tubes[ARGV[0]]
arg = ARGV[1]
skg = ShikiGram.new
msg = skg.wrap_msg(arg)
tube.put msg
beanstalk.close
