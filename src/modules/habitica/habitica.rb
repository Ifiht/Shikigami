#=============<[ Gems ]>=============#
require "redfairy"
require "spriggan"
#==========<[ Local Libs ]>==========#
require_relative "lib_habitica"

#=============<[ Local Vars ]>================#
core_config = RedFairy.new("shikigami")
habitica_usrid = core_config.get("api_habitica_usrid")
habitica_token = core_config.get("api_habitica_token")

#=============<[ Instance Vars ]>=============#
@beanstalk_host = core_config.get("beanstalk_host")
@beanstalk_port = core_config.get("beanstalk_port")
@habitica = HabActions.new(habitica_usrid, habitica_token)

@sprig = Spriggan.new(
  beanstalk_host: @beanstalk_host,
  beanstalk_port: @beanstalk_port,
  module_name: "habitica",
)

#=============<[ Methods ]>==================#
# Evaluates a string and logs to PM2 on error
def eval_string(str)
  begin
    eval str
  rescue SyntaxError
    @sprig.pm2_log("SyntaxError: #{str}")
  rescue NameError
    @sprig.pm2_log("NameError: #{str}")
  end #begin
end #def

#============================================#
#+++-----      <[ Main Body ]>       -----+++#
#============================================#
@sprig.add_thread {
  loop do
    msg_hash = @sprig.get_msg
    begin
      eval_string(msg_hash["msg"])
    rescue Exception => e
      @sprig.pm2_log("Rescued job: #{e}")
    end #begin
  end #loop
}

#[[[[[[ JOIN THREADS ]]]]]]
core_threads.each { |thr| thr.join }
