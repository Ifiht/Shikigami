class EmailParser
  def ingest (input_str)
  #==============[ VARIABLES ]========================================/////////////////
  #==============[ UTF-8 BYTE ENCODED EMOJIS: https://apps.timwhitlock.info/emoji/tables/unicode
    s_arr = []
    s_err = ""

    s_from_match = input_str.match(/From:\s+[a-z]+@[a-z]+\.[a-z]+/i)
    s_subject_match = input_str.match(/Subject:\s+.*/i)

    s_from_match != nil ? s_from = s_from_match[0] : s_from = nil
    s_subject_match != nil ? s_subject = s_subject_match[0] : s_subject = nil
  #==============[ PARSE SUBJECT ]====================================/////////////////
    if s_subject != nil && s_from != nil
      case s_subject
      when /Daily Report/ #:::::::::::::::::::::::::///> DAILY REPORT /////////////////
        puts "Daily Report Email Detected"
        s_r1 = input_str.scan(/::1:.+/i)
        s_r2 = input_str.scan(/::2:.+/i)
        s_r3 = input_str.scan(/::3:.+/i)
        s_r4 = input_str.scan(/::4:.+/i)
        s_arr.push("\xF0\x9F\x94\x85 #{s_subject[9..-1]}")
        s_arr.push(s_from)
        if s_r1.empty? #====================///> PARSE UPTIME DATA
          s_arr.push("\xE2\x8C\x9A \xE2\x9D\x93 Missing Docker Data.")
        else
          s_uptime = s_r1.first # There should only be one line for uptime..
          s_arr.push("\xE2\x8C\x9A #{s_uptime[4..-1]}")
        end#if
        if s_r2.empty? #====================///> PARSE DOCKER DATA
          s_arr.push("\xF0\x9F\x90\xB3 \xE2\x9D\x93 Missing Docker Data.")
        else
          docker_count = s_r2.count
          docker_countup = s_r2.join('\n').scan(/: Up /).count
          docker_countexit = s_r2.join('\n').scan(/: Exited /).count
          docker_countrestart = s_r2.join('\n').scan(/: Restarting /).count
          docker_countbad = docker_countexit + docker_countrestart
          s_arr.push("\xF0\x9F\x90\xB3 #{docker_countup} UP and #{docker_countbad} BAD of #{docker_count} containers.")
        end#if
        if s_r3.empty? #====================///> PARSE CPU DATA
          s_arr.push("\xF0\x9F\x93\x88 \xE2\x9D\x93 Missing CPU Data.")
        else
          begin
            cpu_usr = s_r3[0].split[2].to_f
            cpu_nice = s_r3[0].split[3].to_f
            cpu_sys = s_r3[0].split[4].to_f
            cpu_total = cpu_usr + cpu_nice + cpu_sys
            s_arr.push("\xF0\x9F\x93\x88 #{cpu_total.round(2)}% Average CPU Usage.")
          rescue => e
            puts e
            s_arr.push("\xF0\x9F\x93\x88 \xE2\x9D\x8C Exception in CPU Parsing.")
          end#begin
        end#if
        if s_r4.empty? #====================///> PARSE MEM DATA
          s_arr.push("\xF0\x9F\x93\x8A \xE2\x9D\x93 Missing MEM Data.")
        else
          begin
            mem_total = s_r4[0].split[4].to_f
            s_arr.push("\xF0\x9F\x93\x8A #{mem_total.round(2)}% Average Memory Usage.")
          rescue => e
            puts e
            s_arr.push("\xF0\x9F\x93\x8A \xE2\x9D\x8C Exception in MEM Parsing.")
          end#begin
        end#if
      when /New Login/ #::::::::::::::::::::::::;;;;;;:///> NEW LOGIN /////////////////
        puts "Login Alert"
        s_r1 = input_str.scan(/::1:.+/i).first
        s_arr.push("\xF0\x9F\x8E\xAD #{s_subject[9..-1]}")
        s_arr.push(s_from)
        s_arr.push(s_r1[4..-1])
      when /unattended-upgrades/ #::::::::::::::;;;;;;:///> UNATTENDED UPGRADE ////////
        puts "Unattended Upgrade Run"
        s_arr.push("\xF0\x9F\x93\xA5 #{s_subject[9..-1]}")
        s_arr.push(s_from)
  #==============[ BAD SUBJECT ]======================================/////////////////
      else
        s_err = "Can't handle unknown subject '#{s_subject}'"
        puts s_err
        s_arr.push(s_err)
        input_str.lines.each.first(20) do |line|
            s_arr.push(line.strip)
        end#do
      end#case
  #==============[ MISSING SUBJECT ]==================================/////////////////
    else
      s_err = "Email is missing subject[#{s_subject}], or from[#{s_from}], fields."
      puts s_err
      s_arr.push(s_err)
      input_str.lines.each.first(20) do |line|
        s_arr.push(line.strip)
      end#do
    end#if
    return s_arr.join("\n")
  end#def
end#class
