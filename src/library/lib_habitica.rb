require 'uri'
require 'json'
require 'httpx'

class HabActions
  def initialize(habId="fffff", habToken="fffff")
    @habId = habId
    @habToken = habToken
  end

  def joinQuest
    http = HTTPX.post("https://habitica.com/api/v3/groups/party/quests/accept",
      headers: {"x-api-user" => @habId, "x-api-key" => @habToken})
    puts http.body if http.status == 200
  end

  def cron
    http = HTTPX.post("https://habitica.com/api/v3/cron", headers: {"x-api-user" => @habId, "x-api-key" => @habToken})
    if http.status == 200
      puts JSON.parse(http.body)
    else
      puts "Error: #{http.status}"
    end
  end

end
