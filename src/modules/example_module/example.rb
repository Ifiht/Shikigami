#=============<[ Gems ]>=============#
require "require_all"
#==========<[ Local Libs ]>==========#
require_rel "../../lib/shiki_stdlib"
#==/ Create a new instance of the standard lib /==#
shiki = Shiki.new

#==/ This proc will run inside a thread of the standard lib,
#==/ any functions your module needs to implement should go here
hello_world = Proc.new {
  loop do # this code will print "hello world!" to the pm2 logs until stopped
    shiki.pm2.log("hello world!")
  end #loop
}

#==/ This proc will run inside a thread of the standard lib,
#==/ any functions your module needs to implement should go here
send_hello_world = Proc.new {
  loop do # this code will print "hello world!" to the pm2 logs until stopped
    shiki.pm2.log("hello world!")
    sleep 1
  end #loop
}

shiki.run(hello_world)
