task :default => :do_nothing

desc "Dummy task."

task :do_nothing do
  puts "Success!"
end

task :pm2_start do
  %x(pm2 start ecosystem.config.js)
end

task :pm2_stop do
  %x(pm2 stop ecosystem.config.js)
end
