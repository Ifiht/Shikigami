require 'pp'
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
    puts PP.pp(JSON.parse(http.body)) if http.status == 200
  end

  def cron
    http = HTTPX.post("https://habitica.com/api/v3/cron", headers: {"x-api-user" => @habId, "x-api-key" => @habToken})
    if http.status == 200
      puts PP.pp(JSON.parse(http.body))
    else
      puts "Error: #{http.status}"
    end
  end

  def msgParty(msg)
    http = HTTPX.post("https://habitica.com/api/v3/groups/party/chat",
      headers: {"x-api-user" => @habId, "x-api-key" => @habToken},
      form: {"message" => msg})
    if http.status == 200
      puts PP.pp(JSON.parse(http.body))
    else
      puts "Error: #{http.status}"
    end
  end

  def getTasks
    http = HTTPX.get("https://habitica.com/api/v3/tasks/user", headers: {"x-api-user" => @habId, "x-api-key" => @habToken})
    if http.status == 200
      puts PP.pp(JSON.parse(http.body))
    else
      puts "Error: #{http.status}"
    end
  end

  def upCheckTask(taskId)
    http = HTTPX.get("https://habitica.com/api/v3/tasks/#{taskId}/score/up", headers: {"x-api-user" => @habId, "x-api-key" => @habToken})
    if http.status == 200
      puts PP.pp(JSON.parse(http.body))
    else
      puts "Error: #{http.status}"
    end
  end

  def downCheckTask(taskId)
    http = HTTPX.get("https://habitica.com/api/v3/tasks/#{taskId}/score/down", headers: {"x-api-user" => @habId, "x-api-key" => @habToken})
    if http.status == 200
      puts PP.pp(JSON.parse(http.body))
    else
      puts "Error: #{http.status}"
    end
  end

end