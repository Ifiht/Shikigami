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

# Variable setup
args = ARGV
tube = ARGV[0]
alltubes = []
skgram = ShikiGram.new
core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")

# Connect to beanstalkd
beanstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
beanstalk.tubes.all.each do |t|
  alltubes << t.name
end

# Check user input
if args.length != 2
  puts "this script requires two arguments."
elsif not alltubes.include? tube
  puts "tube #{tube} does not exist."
else
  bean = beanstalk.tubes[ARGV[0]]
  arg = ARGV[1]
  msg = skgram.wrap_msg(arg)
  bean.put msg
end

# Close the connection to beanstalkd
beanstalk.close
