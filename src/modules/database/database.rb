#=============<[ Gems ]>=============#
require "pg"
require "redfairy"

#=============<[ Local Vars ]>================#
core_config = RedFairy.new("shikigami")

#=============<[ Experimental ]>=============#
@db_user = core_config.get("db_user")
@db_pass = core_config.get("db_pass")

query = File.read('./init_pgre.sql')

conn = PG.connect( host: 'localhost', port: '5435', dbname: 'test1', user: @db_user )
conn.exec( query ) do |results|
  results.each do |row|
    puts row.inspect
  end
end
