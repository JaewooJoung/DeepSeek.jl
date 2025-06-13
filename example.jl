# ==============================================
# HOW TO IMPORT THE MODULE:
# - Use `using .DeepSeek` if testing locally (module in same dir)
# - Use `using DeepSeek` if installed as a package
# ==============================================

# Local development (comment out if installed as package):
include("DeepSeek.jl")
using DeepSeek

# Installed package (uncomment if registered):
# using DeepSeek

# ==============================================
# AVAILABLE MODELS (check DeepSeek's latest docs):
# - "deepseek-chat" (default general-purpose)
# - "deepseek-coder" (code-specific)
# - "deepseek-math" (mathematics-focused)
# - Others may be available via API
# ==============================================

# Initialize client with environment API key
client = DeepSeekClient(
    model = "deepseek-chat",  # Try alternate models here
    max_tokens = 1024,
    temperature = 0.7  # Balance creativity (0.0-1.0)
    )

# ==============================================
# API HEALTH CHECK
# ==============================================
function check_api_health(client)
    try
        resp = chat(client, "Ping!")
        println("✓ API Connected | Model: $(resp.model)")
        return true
        catch e
        println("✗ API Error: ", sprint(showerror, e))
        return false
    end
end

# ==============================================
# ENHANCED ERROR HANDLER
# ==============================================
function handle_error(e)
    msg = string(e)
    if occursin("401", msg)
        println("ERROR: Invalid API key (check DEEPSEEK_API_KEY)")
        elseif occursin("429", msg)
        println("ERROR: Rate limit exceeded")
        elseif occursin("model", msg)
        println("ERROR: Model unavailable - try 'deepseek-chat' or check docs")
        else
            println("ERROR: ", msg)
        end
    end

    # ==============================================
    # MAIN EXECUTION
    # ==============================================
    println("\n🔍 DeepSeek API Test")
    println("---------------------")

    # Phase 1: Verify connection
    if !check_api_health(client)
        exit(1)  # Halt if API unreachable
    end

    # Phase 2: Sample query
    try
        println("\n💡 Asking: Explain quantum computing like I'm 10")
        resp = chat(client, "Explain quantum computing like I'm 10")

        println("\n🔮 Response:")
        println("-----------")
        println(resp.choices[1].message.content)
        println("\nℹ️ Metadata: $(resp.model) | Tokens: $(resp.usage.total_tokens)")

        # Phase 3: Follow-up question
        println("\n🔍 Follow-up: Why is this different from normal computers?")
        messages = [
            Message("user", "Explain quantum computing like I'm 10"),
            Message("assistant", resp.choices[1].message.content),
            Message("user", "Why is this different from normal computers?")
            ]
        follow_up = chat(client, messages)
        println(follow_up.choices[1].message.content)

        catch e
        handle_error(e)
    end
