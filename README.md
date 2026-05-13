# AuthVaultix Lua - Multi-Platform Integration

![AuthVaultix](https://img.shields.io/badge/AuthVaultix-Lua-blue?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Windows%20|%20FiveM%20|%20Roblox-orange?style=for-the-badge)

A powerful and lightweight Lua wrapper for [AuthVaultix](https://authvaultix.com), providing secure authentication and licensing for your Lua-based projects. 

## ✨ Features

- **Multi-Platform Support:** Ready-to-use scripts for Windows (Standalone), FiveM, and Roblox.
- **HWID Protection:** Built-in hardware ID locking to prevent account sharing.
- **Session Management:** Secure initialization and session tracking.
- **Easy Integration:** Simple functions for Login, Registration, and License Key activation.
- **No Dependencies (Windows):** Uses PowerShell for HTTPS requests, so you don't need `LuaSec` or `Socket`.

---

## 🚀 Getting Started

### 1. Configuration & Initialization
Open the corresponding Lua file for your platform and initialize your application credentials. Every session must be initialized before performing any actions:

```lua
local AuthVaultix = require("authvaultix_windows")

local app = AuthVaultix.new(
    "YourAppName",
    "YourOwnerID",
    "YourAppSecret",
    "1.0"
)

app:Init()
```

---

## 💻 Platform Usage

### 🪟 Windows (Standalone)
Requires `dkjson.lua` in the same directory (you can download it from [GitHub](https://github.com/BertrandMansiet/dkjson)). It uses PowerShell to handle HTTPS requests natively.

```lua
local AuthVaultix = require("authvaultix_windows")
local app = AuthVaultix.new(...)
app:Init()

-- Example Login
app:Login("username", "password")
```

### 🚗 FiveM (Server-side)
Uses `PerformHttpRequest` for seamless integration into your GTA V resources.

```lua
local AuthVaultix = require("authvaultix_fivem")
local app = AuthVaultix.new(...)
app:Init()

-- Example Login (Server-side)
app:Login(source, "username", "password")
```

### 🟥 Roblox (Script)
Uses `HttpService` for game scripts.

```lua
local AuthVaultix = require("authvaultix_roblox")
local app = AuthVaultix.new(...)
app:Init()

-- Example Login
app:Login("username", "password")
```

---

## ⚙️ API Reference

### Authentication & Session
| Method | Description |
| :--- | :--- |
| `app:Init()` | Initializes the secure session with the API. |
| `app:Login(user, pass)` | Authenticates the user and binds HWID. |
| `app:Register(user, pass, key, email?)` | Creates a new user with a license key. |
| `app:LicenseLogin(license)` | Authenticates directly via license key. |
| `app:Check()` | Validates if the current session is still active. |
| `app:Logout()` | Invalidates current session and logs out. |

### Account Management
| Method | Description |
| :--- | :--- |
| `app:Upgrade(username, license)` | Upgrades user's account/subscription. |
| `app:ForgotPassword(username, email)` | Triggers a password reset email. |
| `app:ChangeUsername(new_username)` | Changes the current user's username. |

### Security & Blacklist
| Method | Description |
| :--- | :--- |
| `app:Ban(reason)` | Bans the currently authenticated user. |
| `app:CheckBlacklist()` | Checks if the machine HWID is blacklisted. |
| `app:Log(message)` | Sends a log to the AuthVaultix dashboard. |

### Variables & Data
| Method | Description |
| :--- | :--- |
| `app:GetGlobalVar(varid)` | Fetches a global server-side variable. |
| `app:GetVar(var_name)` | Fetches a user-specific server-side variable. |
| `app:SetVar(var_name, value)` | Sets a user-specific variable. |
| `app:Download(fileid)` | Securely downloads a file (returns decoded data). |

### Communication
| Method | Description |
| :--- | :--- |
| `app:FetchOnline()` | Gets a list of currently online users. |
| `app:ChatSend(message, channel)` | Sends a chat message to a specific channel. |
| `app:ChatFetch(channel)` | Retrieves chat history. |

---

## 📋 Requirements

- **Windows:** PowerShell must be enabled (default on Win 10/11).
- **FiveM:** Ensure you have a JSON library (usually built-in).
- **Roblox:** `HttpService` must be enabled in Game Settings.

## ⚖️ Disclaimer
This project is intended for use with the AuthVaultix.com authentication service. Ensure you comply with their Terms of Service.

---

