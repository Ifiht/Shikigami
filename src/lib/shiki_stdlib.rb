require "beaneater"     # MPI Library
require "require_all"
#==========<[ Local Libs ]>==========#
require_rel "./shiki_gram"    # Send messages between modules
require_rel "./pm2_helper"    # Functions for PM2 interaction
require_rel "./app_settings"  # Retrieve application settings

class Shiki
  def initialize(module_name)
    @module_name = module_name
  end

  pm2 = Pm2Helper.new
  sgram = ShikiGram.new
  config = AppSettings.new
  beanstalk_host = config.get("beanstalk_host")
  beanstalk_port = config.get("beanstalk_port")
  
  def eval_string(str)
    begin
      eval str
    rescue SyntaxError
      pm2.log("SyntaxError: #{str}")
    rescue NameError
      pm2.log("NameError: #{str}")
    end #begin
  end #def
  
  def run(proc)
    bstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
    bstalk.tubes.find(@module_name) # also creates the tube
    bstalk.tubes.watch!(@module_name)
    
    core_threads << Thread.new {
      loop do
        job = bstalk.tubes.reserve
        if job.exists?
          str = sgram.open_msg(job.body)
          pm2.log("Received job: #{str}")
          begin
            eval_string(str)
          rescue Exception => e
            pm2.log("Rescued job: #{e}")
          end
          job.delete
        end #if
        sleep 0.00024 # prevent 100% CPU utilization
      end #loop
    }
    core_threads << Thread.new {
      proc.call
    }
    #[[[[[[ CATCH INTERRUPT ]]]]]]
    Signal.trap("INT") {
      i = 0
      core_threads.each { |t|
        pm2.log "killing core thread #{i}.."
        t.kill
        i += 1
      }
      pm2.log "Exiting gracefully."
      exit
    }
    #[[[[[[ JOIN THREADS ]]]]]]
    core_threads.each { |thr| thr.join }
  end #def
end
