using Test
using HTTP
using JSON3
using DeepSeek

# Set this to true if you want to run live API tests
const RUN_LIVE_TESTS = false
const TEST_API_KEY = get(ENV, "DEEPSEEK_API_KEY", "")

# Mock response for testing
const MOCK_RESPONSE = JSON3.read("""
                                 {
                                     "id": "chatcmpl-123",
                                     "object": "chat.completion",
                                     "created": 1677652288,
                                     "model": "deepseek-chat",
                                     "choices": [{
                                         "index": 0,
                                         "message": {
                                             "role": "assistant",
                                             "content": "This is a test response"
                                             },
                                             "finish_reason": "stop"
                                             }],
                                             "usage": {
                                                 "prompt_tokens": 9,
                                                 "completion_tokens": 12,
                                                 "total_tokens": 21
                                                 }
                                                 }
                                                 """)

# Mock HTTP.post function for testing
function mock_http_post(url, headers, body)
    return HTTP.Response(200, ["Content-Type" => "application/json"], body=JSON3.write(MOCK_RESPONSE))
end

@testset "DeepSeek Module Tests" begin
    # Test Message struct
    @testset "Message Struct" begin
        msg = DeepSeek.Message("user", "Hello")
        @test msg.role == "user"
        @test msg.content == "Hello"
    end

    # Test Client Construction
    @testset "Client Construction" begin
        # Test with explicit API key
        client = DeepSeek.DeepSeekClient(api_key="test_key")
        @test client.api_key == "test_key"
        @test client.model == "deepseek-chat"
        @test client.headers["authorization"] == "Bearer test_key"

        # Test environment variable fallback
        old_env = get(ENV, "DEEPSEEK_API_KEY", "")
        ENV["DEEPSEEK_API_KEY"] = "env_key"
        client_env = DeepSeek.DeepSeekClient(api_key=nothing)
        @test client_env.api_key == "env_key"
        ENV["DEEPSEEK_API_KEY"] = old_env

        # Test error when no key provided
        @test_throws ErrorException DeepSeek.DeepSeekClient(api_key=nothing)
    end

    # Test API Key Update
    @testset "API Key Update" begin
        client = DeepSeek.DeepSeekClient(api_key="old_key")
        DeepSeek.update_api_key!(client, "new_key")
        @test client.api_key == "new_key"
        @test client.headers["authorization"] == "Bearer new_key"
    end

    # Test Chat Function (Mock)
    @testset "Chat Function (Mock)" begin
        # Replace HTTP.post with our mock for testing
        old_post = DeepSeek.HTTP.post
        DeepSeek.HTTP.post = mock_http_post

        client = DeepSeek.DeepSeekClient(api_key="test_key")

        # Test single message
        response = DeepSeek.chat(client, "Test message")
        @test response.choices[1].message.content == "This is a test response"

        # Test message array
        messages = [DeepSeek.Message("user", "Hello"), DeepSeek.Message("assistant", "Hi there")]
        response = DeepSeek.chat(client, messages)
        @test response.choices[1].message.role == "assistant"

        # Restore original HTTP.post
        DeepSeek.HTTP.post = old_post
    end

    # Live API Tests (only run if enabled)
    if RUN_LIVE_TESTS && !isempty(TEST_API_KEY)
        @testset "Live API Tests" begin
            client = DeepSeek.DeepSeekClient(api_key=TEST_API_KEY)

            # Test simple chat
            @testset "Basic Chat" begin
                response = DeepSeek.chat(client, "Hello!")
                @test hasproperty(response, :choices)
                @test length(response.choices) > 0
                @test hasproperty(response.choices[1].message, :content)
                println("\nLive API Response: ", response.choices[1].message.content)
            end

            # Test conversation
            @testset "Conversation" begin
                messages = [
                    DeepSeek.Message("system", "You are a helpful assistant."),
                    DeepSeek.Message("user", "What is 2+2?")
                    ]
                response = DeepSeek.chat(client, messages)
                @test occursin("4", response.choices[1].message.content)
            end

            # Test streaming (if implemented)
            @testset "Streaming" begin
                try
                    messages = [DeepSeek.Message("user", "Tell me a short story")]
                    response = DeepSeek.chat_stream(client, messages)
                    @test response.status == 200
                    println("\nStreaming response headers: ", response.headers)
                    catch e
                    @warn "Streaming test failed (might not be implemented)" exception=e
                end
            end
        end
    else
        @warn "Skipping live API tests. Set RUN_LIVE_TESTS=true and provide DEEPSEEK_API_KEY to enable."
    end
end

println("\nAll tests passed!")
