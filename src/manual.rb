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
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)
require "bundler/setup"
require "spriggan"
require "redfairy"

#=============<[ Local Vars ]>================#
args = ARGV
tube = ARGV[0]
core_config = RedFairy.new("shikigami")
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")

sprig = Spriggan.new(
  beanstalk_host: beanstalk_host,
  beanstalk_port: beanstalk_port,
  module_name: tube,
)

alltubes = sprig.bean_tubes

#============================================#
#+++-----      <[ Main Body ]>       -----+++#
#============================================#
# Check user input
if args.length != 2
  puts "this script requires two arguments."
elsif not alltubes.include? tube
  puts "tube #{tube} does not exist."
else
  arg = ARGV[1]
  sprig.send_msg(arg, tube)
end
