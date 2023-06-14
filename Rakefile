task :default => :do_nothing

desc "Dummy task."

task :do_nothing do
  puts "Success!"
end

task :pm2_updown do
  %x(pm2 start ecosystem.config.js --no-daemon)
  %x(pm2 stop ecosystem.config.js --no-daemon)
end

