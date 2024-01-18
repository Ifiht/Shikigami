require "beaneater"
require "shiki_gram"
require "app_settings"

class BeanTalker
  tube.put ARGV[0]

  def initialize(mod_name)
    @mod_name = mod_name # Declare the name of the module, NOTE:
    # Module names MUST match their parent folder inside the 'modules' subdir
    # Any module should be able to talk to any other by referencing this name
    # All modules may talk to the 'core' via the tube of the same name ("core")
    core_config = AppSettings.new
    beanstalk_host = core_config.get("beanstalk_host")
    beanstalk_port = core_config.get("beanstalk_port")
    @beanstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
    @all_tubes = @beanstalk.tubes.all
    @tube = @beanstalk.tubes[@mod_name]
  end

  def send_msg(msg, to)
    postman = ShikiGram.new
    mail = postman.wrap_msg(msg)
    if @all_tubes.route = @beanstalk.tubes[to]
      route.put(mail)
    end
  end

  def recv_msg(msg)
    puts "not implemented"
  end

  def shut_up
    @beanstalk.close
  end
end
