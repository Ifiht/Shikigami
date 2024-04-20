require "yaml"
require "base64"

class ShikiGram
  def wrap_msg(msg)
    msg_str = msg.to_yaml
    msg64 = Base64.encode64(msg_str)
    return msg64
  end

  def open_msg(msg64)
    msg_str = Base64.decode64(msg64)
    msg = YAML.load(msg_str)
    return msg
  end
end

#3.1.4 :021 > job = @beanstalk.tubes.reserve
# => #<Beaneater::Job id=297 body="Hello world">
#3.1.4 :022 > job.stats
# => #<Beaneater::StatStruct id=297, tube="test", state="reserved", pri=65536, age=140, delay=0,\
# ttr=120, time_left=115, file=0, reserves=1, timeouts=0, releases=0, buries=0, kicks=0>
