require "json"
require "io/console"

class Pm2Helper
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
