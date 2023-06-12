require 'beaneater'

core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_host = core_config.get("beanstalk_port")

# Connect to beanstalkd
beanstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
tube = beanstalk.tubes["tb_manual"]
tube.put ARGV[0]
beanstalk.close
