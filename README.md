## The initial structure of this README.md was generated with assistance from DeepSeek AI using the following Julia code:
```julia
 using DeepSeek;client = DeepSeekClient();response = chat(client, "Make the Vivrant README.jl for my DeepSeek.jl ");println(response.choices[1].message.content)
```
## AI use is common these days—no need to be shy, but don't get too cocky about it either. 😉 (Lessons Learned by making this very code.) 

```markdown
# 🤖 DeepSeek.jl

> *Powerful AI models, now in Julia!* 

[![Julia](https://img.shields.io/badge/Julia-9558B2?style=for-the-badge&logo=julia&logoColor=white)](https://julialang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

```julia
using DeepSeek
client = DeepSeekClient()
response = chat(client, "Why is Julia great for AI?")
println(response.choices[1].message.content)
# ... Blazing fast performance with elegant syntax! 🚀
```

## 📋 Table of Contents
- [Prerequisites](#-prerequisites)
- [Features](#-features)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
  - [API Key Setup](#setting-up-your-api-key)
  - [Basic Chat](#basic-usage)
  - [Advanced Features](#advanced-usage)
- [Model Guide](#-model-guide)
- [Examples](#-examples)
- [API Reference](#-api-reference)
- [Error Handling](#-error-handling)
- [Contributing](#-contributing)

## 📋 Prerequisites
- Julia 1.6+
- DeepSeek API key ([Sign up here](https://platform.deepseek.com))
- HTTP.jl and JSON3.jl

## ✨ Features
- ⚡ **Low-Latency** - Optimized for responsive AI interactions
- 📝 **Conversation Memory** - Built-in multi-turn context management
- 🔧 **Parameter Control** - Fine-tune temperature, top_p, etc.
- 🔐 **Secure** - ENV variable support for API keys
- 🧩 **Modular** - Easy to extend with new models

## 📦 Installation

**From Julia REPL:**
```julia
] add DeepSeek
```

## 🚀 Quick Start

### Setting Up Your API Key

#### 🐧 Linux/macOS
```bash
# Temporary session
export DEEPSEEK_API_KEY='your_key_here'

# Permanent (add to ~/.bashrc/zshrc)
echo 'export DEEPSEEK_API_KEY="your_key_here"' >> ~/.bashrc
source ~/.bashrc
```

#### 🪟 Windows
```cmd
:: Temporary
set DEEPSEEK_API_KEY=your_key_here

:: Permanent via GUI:
:: 1. Win + Search "Environment Variables"
:: 2. Add new User Variable
```

### Basic Usage
```julia
using DeepSeek

client = DeepSeekClient()  # Auto-loads API key from ENV

# Single message
response = chat(client, "Explain quantum computing simply")
println(response.choices[1].message.content)

# With metadata
function print_response(resp)
    println("\n🤖 Response:")
    println("------------")
    println(resp.choices[1].message.content)
    println("\n📊 Metadata:")
    println("Model: ", resp.model)
    println("Tokens: ", resp.usage.total_tokens)
end
```

### Advanced Usage
**Multi-turn conversation:**
```julia
messages = [
    Message("system", "You are a helpful physics tutor."),
    Message("user", "What is superconductivity?"),
    Message("assistant", "Zero electrical resistance below critical temperature."),
    Message("user", "How does this relate to Meissner effect?")
]

response = chat(client, messages)
```

**Streaming (if supported):**
```julia
stream = chat_stream(client, "Describe the ocean in real-time")
for chunk in stream
    print(String(chunk))  # Process streaming chunks
end
```

## 🧠 Model Guide
| Model Name          | Best For                  | Max Tokens |
|---------------------|---------------------------|------------|
| `deepseek-chat`     | General-purpose           | 128K       |
| `deepseek-coder`    | Programming tasks         | 128K       |
| `deepseek-math`     | Mathematical reasoning    | 128K       |

```julia
# Custom model selection
client = DeepSeekClient(model="deepseek-coder")
```

## 📚 API Reference

### DeepSeekClient
```julia
DeepSeekClient(;
    api_key::Union{String,Nothing}=nothing,
    model::String="deepseek-chat",
    max_tokens::Int=1024,
    temperature::Float64=0.7,
    top_p::Float64=1.0,
    base_url::String="https://api.deepseek.com/v1"
)
```

### Message Struct
```julia
Message(role::String, content::String)
```

### Response Structure
```julia
struct DeepSeekResponse
    id::String
    model::String
    choices::Vector{Dict}  # Contains message content
    usage::Dict  # Input/output tokens
end
```

## ⚠️ Error Handling
```julia
try
    response = chat(client, "Test")
catch e
    if occursin("401", string(e))
        println("Invalid API key!")
    elseif occursin("429", string(e))
        println("Rate limit exceeded!")
    else
        println("Unknown error: ", e)
    end
end
```

## 🤝 Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Submit a Pull Request

## 📜 License
MIT License - Free for academic and commercial use.

---

<div align="center">
Built with <img src="https://julialang.org/assets/infra/logo.svg" height="20"/> · Need help? Open an issue!
</div>
```
