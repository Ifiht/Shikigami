#=============<[ Gems ]>=============#
require "beaneater"
#==========<[ Local Libs ]>==========#
require_relative "lib_core_config"

class BeanConn
  def initialize(beanstalk_host = "127.0.0.1", beanstalk_port = 9999)
    @beanstalk_host = beanstalk_host
    @beanstalk_port = beanstalk_port
    @beanstalk_tube = "default"
    @bstalk = Beaneater.new("#{@beanstalk_host}\:#{@beanstalk_port}")
  end #def

  def get_tube(beanstalk_tube)
    @beanstalk_tube = beanstalk_tube
    @bstalk.tubes.find(@beanstalk_tube)
    @bstalk.tubes.watch(@beanstalk_tube)
    return @bstalk.tubes[beanstalk_tube]
  end

  #def reserve(beanstalk_tube)
  #  tube = @bstalk.tubes[beanstalk_tube]
  #  job = tube.reserve
  #  if job.exists?
  #    begin
  #      eval job.body
  #    rescue SyntaxError
  #      puts "SyntaxError: #{job.body}"
  #    ensure
  #      job.delete
  #    end #begin
  #  end #if
  #end #def
end #class
