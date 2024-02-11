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
