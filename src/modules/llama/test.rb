require 'openai'

@client = OpenAI::Client.new( uri_base: "http://localhost:4242" )
@history = ""

def chat(client, msg)
	@history += "User: #{msg}\n"
	client.chat(
    parameters: {
        model: "llama3.1",
        messages: [{ role: "user", name: "Pillowy", content: @history}],
        temperature: 0.1,
        stream: proc do |chunk, _bytesize|
            nibble = chunk.dig("choices", 0, "delta", "content")
			if nibble
				print nibble
				@history += nibble
			end
        end
    })
	@history += "\n"
end

PROMPT = "\n=> "
print PROMPT
LOGIC_QUEST = "I have 10 apples. I find 3 gold coins in the bottom of a river. The river runs near a big city that has something to do with what I can spend the coins on. I then lose 4 apples but gain a gold coin. Three birds run into my path and drop 6 apples each. I play an online game and win 6 gold coins but I have to share them equally with my 2 teammates. I buy apples for all the coins I have. The price of an apple is 0.5 coins. How many apples do I have? And where is the river?"
FORM_TEST = 'Create 9 sentences that begin with "You" and end with "believe". Remember, the word "believe" MUST be at the end.'

while input = gets.chomp
	case input
	when "exit", "quit"
		break
	when "test logic"
		puts LOGIC_QUEST + " (expect correct answer 36 apples)"
		chat(@client, LOGIC_QUEST)
		print PROMPT
	when "test form"
		puts FORM_TEST
		chat(@client, FORM_TEST)
		print PROMPT
	else
		chat(@client, input)
		print PROMPT
	end
end

exit(0)
