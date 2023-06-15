#=============<[ Gems ]>=============#
require "beaneater"
#==========<[ Local Libs ]>==========#
require "./library/lib_core_config.rb"

class BeanLoop
  def initialize(beanstalk_host = "127.0.0.1", beanstalk_port = 9999, beanstalk_tube = "default")
    @beanstalk_host = beanstalk_host
    @beanstalk_port = beanstalk_port
    @beanstalk_tube = beanstalk_tube
  end #def

  def run
    @bstalk = Beaneater.new("#{@beanstalk_host}\:#{@beanstalk_port}")
    @bstalk.tubes.watch!(@beanstalk_tube)
    loop do
      job = @bstalk.tubes.reserve
      if job.exists?
        begin
          eval job.body
        rescue SyntaxError
          puts "SyntaxError: #{job.body}"
        ensure
          job.delete
        end #begin
      end #if
    end #loop
  end #def
end #class
