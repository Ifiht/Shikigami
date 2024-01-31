require "json"
require "io/console"
require "app_settings"

class Pm2Helper
  core_config = AppSettings.new
  beanstalk_host = core_config.get("beanstalk_host")
  beanstalk_port = core_config.get("beanstalk_port")

  def log(message)
    $stdout.puts message
    $stdout.flush
  end

  def processes
    proc_list = JSON.parse(%x(pm2 jlist))
    proc_names = Array.new
    proc_list.each { |e| proc_names << e["name"] }
    return proc_names
  end
end
