task :default => :do_nothing

desc "Dummy task."

task :do_nothing do
  puts "Success!"
end

task :build_beanstalk do
  Dir.chdir("beanstalkd") { %x(make) }
end

task :list_pm2 do
  %x(pm2 list)
end
