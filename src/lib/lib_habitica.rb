require "pp"
require "uri"
require "json"
require "httpx"

class HabActions
  def initialize(habId = "fffff", habToken = "fffff")
    @habId = habId
    @habToken = habToken
  end

  def joinQuest
    http = HTTPX.post("https://habitica.com/api/v3/groups/party/quests/accept",
                      headers: { "x-api-user" => @habId, "x-api-key" => @habToken })
    puts PP.pp(JSON.parse(http.body)) if http.status == 200
  end #def

  def cron
    http = HTTPX.post("https://habitica.com/api/v3/cron",
                      headers: { "x-api-user" => @habId, "x-api-key" => @habToken })
    if http.status == 200
      puts PP.pp(JSON.parse(http.body))
    else
      puts "Error: #{http.status}"
    end #if
  end #def

  def msgParty(msg)
    http = HTTPX.post("https://habitica.com/api/v3/groups/party/chat",
                      headers: { "x-api-user" => @habId, "x-api-key" => @habToken },
                      form: { "message" => msg })
    if http.status == 200
      puts PP.pp(JSON.parse(http.body))
    else
      puts "Error: #{http.status}"
    end #if
  end #def

  def getTasks
    http = HTTPX.get("https://habitica.com/api/v3/tasks/user",
                     headers: { "x-api-user" => @habId, "x-api-key" => @habToken })
    if http.status == 200
      puts PP.pp(JSON.parse(http.body))
    else
      puts "Error: #{http.status}"
    end #if
  end #def

  def upCheckTask(taskId)
    http = HTTPX.get("https://habitica.com/api/v3/tasks/#{taskId}/score/up",
                     headers: { "x-api-user" => @habId, "x-api-key" => @habToken })
    if http.status == 200
      puts PP.pp(JSON.parse(http.body))
    else
      puts "Error: #{http.status}"
    end #if
  end #def

  def downCheckTask(taskId)
    http = HTTPX.get("https://habitica.com/api/v3/tasks/#{taskId}/score/down",
                     headers: { "x-api-user" => @habId, "x-api-key" => @habToken })
    if http.status == 200
      puts PP.pp(JSON.parse(http.body))
    else
      puts "Error: #{http.status}"
    end #if
  end #def

  def healParty
    http = HTTPX.get("https://habitica.com/api/v3/user/class/cast/healAll",
                     headers: { "x-api-user" => @habId, "x-api-key" => @habToken })
    if http.status == 200
      puts PP.pp(JSON.parse(http.body))
    else
      puts "Error: #{http.status}"
    end #if
  end #def

  def getPartyMembers
    http = HTTPX.get("https://habitica.com/api/v3/groups/party/members?includeAllPublicFields=true",
                     headers: { "x-api-user" => @habId, "x-api-key" => @habToken })
    if http.status == 200
      members = JSON.parse(http.body)
      if members.class == Hash && members["data"].any?
        member_array = members["data"]
        puts PP.pp(member_array)
        return member_array
      end #if
    else
      puts "Error: #{http.status}"
    end #if
    return nil
  end #def

  def doesPartyNeedHealing
    party = getPartyMembers
    healingNeeded = false
    fullyHealedMembers = false
    if party.nil? == false
      party.each do |member|
        if member["stats"]["hp"].round < (member["stats"]["maxHealth"] / 2)
          healingNeeded = true
        elsif member["stats"]["hp"].round == member["stats"]["maxHealth"]
          fullyHealedMembers = true
        end #if
      end #do
    end #if
    if healingNeeded || fullyHealedMembers == false
      healingNeeded = true
    end #if
    return healingNeeded
  end #def
end #class
