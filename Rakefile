task :default => :do_nothing

desc "Dummy task."

task :do_nothing do
  puts "Success!"
end

task :pm2_start do
  if system("pm2 start ecosystem.config.js")
    puts "PM2 launched successfully."
  else
    exit 2
  end
end

task :pm2_stop do
  if system("pm2 stop ecosystem.config.js")
    puts "PM2 stopped successfully."
  else
    exit 3
  end
end
