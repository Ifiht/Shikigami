#=============<[ Gems ]>=============#
require "spriggan"
require "redfairy"

#=============<[ Local Vars ]>================#
core_config = RedFairy.new("shikigami")

#=============<[ Instance Vars ]>=============#
@cwd = %x(pwd).chomp
@modules1 = []
@modules2 = []
@beanstalk_host = core_config.get("beanstalk_host")
@beanstalk_port = core_config.get("beanstalk_port")

@sprig = Spriggan.new(
  beanstalk_host: @beanstalk_host,
  beanstalk_port: @beanstalk_port,
  module_name: "core",
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
@sprig.add_thread {
  loop do
    @modules2 = %x[ ls #{@cwd}/src/modules ].split
    if @modules1 != @modules2
      @modules1 = @modules2
      pm2_proclist = @sprig.pm2_procs
      @modules1.each do |m|
        if pm2_proclist.include? m
          @sprig.pm2_log("Skipping running module: #{m}")
        else
          if %x[ ls #{@cwd}/src/modules/#{m} ].split.include? "wrapper.sh"
            %x[ cd #{@cwd}/src/modules/#{m} && pm2 start #{@cwd}/src/modules/#{m}/wrapper.sh --name #{m}]
            @sprig.pm2_log("Starting module: #{m}")
          else
            @sprig.pm2_log("No wrapper for module: #{m}")
          end #if
        end #if
      end #do
    end #if
    sleep 4
  end #loop
}

#[[[[[[ RUN THREADS ]]]]]]
@sprig.run
