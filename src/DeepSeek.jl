module DeepSeek

using HTTP
using JSON3
using Base.Iterators

export DeepSeekClient, chat, Message, update_api_key!

# Types
struct Message
    role::String
    content::String
end

mutable struct DeepSeekClient
    api_key::String
    model::String
    max_tokens::Int
    temperature::Float64
    top_p::Float64
    base_url::String
    headers::Dict{String,String}

    function DeepSeekClient(;
                            api_key::Union{String,Nothing}=nothing,
                            model::String="deepseek-chat",
                            max_tokens::Int=1024,
                            temperature::Float64=0.7,
                            top_p::Float64=1.0,
                            base_url::String="https://api.deepseek.com/v1"
                            )
        if api_key === nothing
            api_key = get(ENV, "DEEPSEEK_API_KEY", "")
            if isempty(api_key)
                error("API key must be provided or set in DEEPSEEK_API_KEY environment variable")
            end
        end

        headers = Dict{String,String}(
            "content-type" => "application/json",
            "authorization" => "Bearer $api_key"
            )

        new(api_key, model, max_tokens, temperature, top_p, base_url, headers)
    end
end

# Helper Functions
function update_api_key!(client::DeepSeekClient, new_key::String)
    client.api_key = new_key
    client.headers["authorization"] = "Bearer $new_key"
    return client
end

# Main Functions
function chat(client::DeepSeekClient, messages::Vector{Message}; stream::Bool=false)
    url = "$(client.base_url)/chat/completions"

    body = Dict{String,Any}(
        "model" => client.model,
        "messages" => [Dict("role" => m.role, "content" => m.content) for m in messages],
            "max_tokens" => client.max_tokens,
            "temperature" => client.temperature,
            "top_p" => client.top_p,
            "stream" => stream
            )

    response = HTTP.post(
        url,
        client.headers,
        JSON3.write(body)
        )

    if response.status == 200
        return JSON3.read(response.body)
    else
        error("API request failed with status $(response.status): $(String(response.body))")
    end
        end

        # Streaming chat function
        function chat_stream(client::DeepSeekClient, messages::Vector{Message})
            url = "$(client.base_url)/chat/completions"

            body = Dict{String,Any}(
                "model" => client.model,
                "messages" => [Dict("role" => m.role, "content" => m.content) for m in messages],
                    "max_tokens" => client.max_tokens,
                    "temperature" => client.temperature,
                    "top_p" => client.top_p,
                    "stream" => true
                    )

            response = HTTP.post(
                url,
                client.headers,
                JSON3.write(body),
                stream=true
                )

            if response.status != 200
                error("API request failed with status $(response.status): $(String(response.body))")
            end

            return response
                end

                # Convenience method for single message
                chat(client::DeepSeekClient, message::String) = chat(client, [Message("user", message)])

        end # module
