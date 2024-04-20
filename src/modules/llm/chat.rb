require "http"
require 'json'

prompt = "Hello world."

req_json = {
    "stream"=> false,
    "n_predict"=> 400,
    "temperature"=> 0,
    "stop"=> [
        "</s>",
    ],
    "repeat_last_n"=> 256,
    "repeat_penalty"=> 1,
    "top_k"=> 20,
    "top_p"=> 0.75,
    "tfs_z"=> 1,
    "typical_p"=> 1,
    "presence_penalty"=> 0,
    "frequency_penalty"=> 0,
    "mirostat"=> 0,
    "mirostat_tau"=> 5,
    "mirostat_eta"=> 0.1,
    "grammar"=> "",
    "n_probs"=> 0,
    "prompt"=> prompt
}

response = HTTP.post("http://localhost:4242/completion", :json => req_json)

puts response.inspect
my_hash = JSON.parse(response.body)
puts my_hash["content"]
