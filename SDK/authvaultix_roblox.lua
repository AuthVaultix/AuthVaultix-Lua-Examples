local HttpService = game:GetService("HttpService")
local BASE_URL = "https://authvaultix.com/api/1.0/"

local NetworkAgent = {}
function NetworkAgent.post(url, payload)
    local success, response = pcall(function()
        return HttpService:PostAsync(url, payload, Enum.HttpContentType.ApplicationUrlEncoded)
    end)
    if not success then
        warn("HTTP Error: " .. tostring(response))
        return nil
    end
    local ok, json = pcall(function() return HttpService:JSONDecode(response) end)
    if ok then return json else
        warn("JSON Decode Error")
        return nil
    end
end

local PayloadBuilder = {}
PayloadBuilder.__index = PayloadBuilder
function PayloadBuilder.new(action_type)
    return setmetatable({ payload = { type = action_type } }, PayloadBuilder)
end
function PayloadBuilder:with_context(app_name, owner_id, session_id)
    self.payload.name = app_name
    self.payload.ownerid = owner_id
    if session_id and session_id ~= "" then self.payload.sessionid = session_id end
    return self
end
function PayloadBuilder:with_value(key, value)
    if value then self.payload[key] = tostring(value) end
    return self
end
function PayloadBuilder:compile()
    local str = ""
    for k, v in pairs(self.payload) do str = str .. k .. "=" .. HttpService:UrlEncode(tostring(v)) .. "&" end
    return string.sub(str, 1, -2)
end

local SystemInfoCollector = {}

function SystemInfoCollector.get_os_version()
    return "Roblox Server"
end

function SystemInfoCollector.get_platform()
    return "roblox"
end

function SystemInfoCollector.get_device_type()
    return "Server"
end

function SystemInfoCollector.get_architecture()
    return "X64"
end

function SystemInfoCollector.get_cpu_cores()
    return "Virtual CPU"
end

function SystemInfoCollector.get_ram_gb()
    return "0"
end

local AuthVaultixCore = {}
AuthVaultixCore.__index = AuthVaultixCore
function AuthVaultixCore.new(app_name, owner_id, secret, version)
    if not app_name or not owner_id or not secret or not version then
        warn("Application not setup correctly.")
        return nil
    end
    return setmetatable({
        app_name = app_name, owner_id = owner_id, secret = secret,
        version = version, session_id = nil, initialized = false, current_user = nil
    }, AuthVaultixCore)
end

function AuthVaultixCore:ensure_ready()
    if not self.initialized then
        warn("SDK not initialized. Call init before using any API.")
        return false
    end
    return true
end

function AuthVaultixCore:hwid()
    local player = game.Players.LocalPlayer
    return player and ("Roblox-" .. tostring(player.UserId)) or "UNKNOWN_HWID"
end

function AuthVaultixCore:init()
    if self.initialized then return true end
    local payload = PayloadBuilder.new("init"):with_value("ver", self.version):with_value("name", self.app_name):with_value("ownerid", self.owner_id):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        self.session_id = resp.sessionid
        self.initialized = true
        print("Initialized Successfully!")
        return true
    else
        warn("Init Failed: " .. (resp and resp.message or "Unknown"))
        return false
    end
end

function AuthVaultixCore:authenticate_user(username, password)
    if not self:ensure_ready() then return false end
    local payload = PayloadBuilder.new("login")
        :with_context(self.app_name, self.owner_id, self.session_id)
        :with_value("username", username)
        :with_value("pass", password)
        :with_value("hwid", self:hwid(src))
	    :with_value("version", self.version)
        :with_value("os", SystemInfoCollector.get_os_version())
        :with_value("platform", SystemInfoCollector.get_platform())
        :with_value("device", SystemInfoCollector.get_device_type())
        :with_value("architecture", SystemInfoCollector.get_architecture())
        :with_value("cpu_cores", SystemInfoCollector.get_cpu_cores())
        :with_value("ram", SystemInfoCollector.get_ram_gb())
        :compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        self.current_user = resp.info
        self.session_id = resp.sessionid or self.session_id
        print("Logged in!")
        self:print_user_info()
        return true
    else
        warn("Login Failed: " .. (resp and resp.message or "Unknown"))
        return false
    end
end

function AuthVaultixCore:validate_session()
    if not self:ensure_ready() then return false end
    if not self.session_id then return false end
    local payload = PayloadBuilder.new("check"):with_context(self.app_name, self.owner_id, self.session_id):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        print("Session Valid!")
        return true
    else
        warn("Session Invalid: " .. (resp and resp.message or "Unknown"))
        return false
    end
end

function AuthVaultixCore:register_account(username, password, license, email)
    if not self:ensure_ready() then return false end
        local payload = PayloadBuilder.new("register")
        :with_context(self.app_name, self.owner_id, self.session_id)
        :with_value("username", username)
        :with_value("pass", password)
        :with_value("key", license)
        :with_value("email", email or "")
        :with_value("hwid", self:hwid(src))
    	:with_value("version", self.version)
        :with_value("os", SystemInfoCollector.get_os_version())
        :with_value("platform", SystemInfoCollector.get_platform())
        :with_value("device", SystemInfoCollector.get_device_type())
        :with_value("architecture", SystemInfoCollector.get_architecture())
        :with_value("cpu_cores", SystemInfoCollector.get_cpu_cores())
        :with_value("ram", SystemInfoCollector.get_ram_gb())
        :compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        self.current_user = resp.info
        self.session_id = resp.sessionid or self.session_id
        print("Registered Successfully!")
        self:print_user_info()
        return true
    else
        warn("Register Failed: " .. (resp and resp.message or "Unknown"))
        return false
    end
end

function AuthVaultixCore:license_access(license)
    if not self:ensure_ready() then return false end
        local payload = PayloadBuilder.new("license")
        :with_context(self.app_name, self.owner_id, self.session_id)
        :with_value("key", license)
        :with_value("hwid", self:hwid(src))
	    :with_value("version", self.version)
        :with_value("os", SystemInfoCollector.get_os_version())
        :with_value("platform", SystemInfoCollector.get_platform())
        :with_value("device", SystemInfoCollector.get_device_type())
        :with_value("architecture", SystemInfoCollector.get_architecture())
        :with_value("cpu_cores", SystemInfoCollector.get_cpu_cores())
        :with_value("ram", SystemInfoCollector.get_ram_gb())
        :compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        self.current_user = resp.info
        self.session_id = resp.sessionid or self.session_id
        print("License Login Successful!")
        self:print_user_info()
        return true
    else
        warn("License Login Failed: " .. (resp and resp.message or "Unknown"))
        return false
    end
end

function AuthVaultixCore:send_log(message)
    if not self:ensure_ready() then return false end
    local payload = PayloadBuilder.new("log"):with_context(self.app_name, self.owner_id, self.session_id):with_value("message", message):with_value("pcuser", "RobloxPlayer"):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then return true else
        warn("Log Failed: " .. (resp and resp.message or "Unknown"))
        return false
    end
end

function AuthVaultixCore:retrieve_file(fileid)
    if not self:ensure_ready() then return nil end
    local payload = PayloadBuilder.new("file"):with_context(self.app_name, self.owner_id, self.session_id):with_value("fileid", fileid):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        print("Download successful")
        return resp.contents
    else
        warn("Download Failed: " .. (resp and resp.message or "Unknown"))
        return nil
    end
end

function AuthVaultixCore:get_online_clients()
    if not self:ensure_ready() then return nil end
    local payload = PayloadBuilder.new("fetchonline"):with_context(self.app_name, self.owner_id, self.session_id):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then return resp.users else
        warn("Fetch Online Failed: " .. (resp and resp.message or "Unknown"))
        return nil
    end
end

function AuthVaultixCore:enforce_ban(reason)
    if not self:ensure_ready() then return false end
    local payload = PayloadBuilder.new("ban"):with_context(self.app_name, self.owner_id, self.session_id):with_value("reason", reason):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        print("Banned successfully")
        return true
    else
        warn("Ban Failed: " .. (resp and resp.message or "Unknown"))
        return false
    end
end

function AuthVaultixCore:terminate_session()
    if not self:ensure_ready() then return end
    local payload = PayloadBuilder.new("logout"):with_context(self.app_name, self.owner_id, self.session_id):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        self.session_id = nil
        self.initialized = false
        print("Logged out successfully")
    else
        warn("Logout Error")
    end
end

function AuthVaultixCore:update_username(new_username)
    if not self:ensure_ready() then return end
    local payload = PayloadBuilder.new("changeusername"):with_context(self.app_name, self.owner_id, self.session_id):with_value("newUsername", new_username):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        self.session_id = nil
        self.initialized = false
        print("Username changed successfully. Please login again.")
    else
        warn("Change Username Error")
    end
end

function AuthVaultixCore:verify_blacklist()
    if not self:ensure_ready() then return false end
    local payload = PayloadBuilder.new("checkblacklist"):with_context(self.app_name, self.owner_id, self.session_id):with_value("hwid", self:hwid()):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then return true else
        warn("Client is blacklisted: " .. (resp and resp.message or "Unknown"))
        return false
    end
end

function AuthVaultixCore:trigger_password_reset(username, email)
    if not self:ensure_ready() then return false end
    local payload = PayloadBuilder.new("forgot"):with_context(self.app_name, self.owner_id, self.session_id):with_value("username", username):with_value("email", email):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        print("Reset email sent successfully")
        return true
    else
        warn("Forgot Password Failed: " .. (resp and resp.message or "Unknown"))
        return false
    end
end

function AuthVaultixCore:apply_upgrade(username, license)
    if not self:ensure_ready() then return false end
    local payload = PayloadBuilder.new("upgrade"):with_context(self.app_name, self.owner_id, self.session_id):with_value("username", username):with_value("key", license):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        print("Upgrade successful")
        return true
    else
        warn("Upgrade Failed: " .. (resp and resp.message or "Unknown"))
        return false
    end
end

function AuthVaultixCore:fetch_global_variable(var_id)
    if not self:ensure_ready() then return nil end
    local payload = PayloadBuilder.new("var"):with_context(self.app_name, self.owner_id, self.session_id):with_value("varid", var_id):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then return resp.message else
        warn("Fetch Global Var Failed: " .. (resp and resp.message or "Unknown"))
        return nil
    end
end

function AuthVaultixCore:fetch_user_variable(var_name)
    if not self:ensure_ready() then return nil end
    local payload = PayloadBuilder.new("getvar"):with_context(self.app_name, self.owner_id, self.session_id):with_value("var", var_name):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then return resp.response else
        warn("Fetch User Var Failed: " .. (resp and resp.message or "Unknown"))
        return nil
    end
end

function AuthVaultixCore:update_user_variable(var_name, value)
    if not self:ensure_ready() then return false end
    local payload = PayloadBuilder.new("setvar"):with_context(self.app_name, self.owner_id, self.session_id):with_value("var", var_name):with_value("data", value):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and not resp.success then warn("Set User Var Failed: " .. resp.message) end
    return resp and resp.success
end

function AuthVaultixCore:transmit_chat_message(message, channel)
    if not self:ensure_ready() then return false end
    local payload = PayloadBuilder.new("chatsend"):with_context(self.app_name, self.owner_id, self.session_id):with_value("message", message):with_value("channel", channel):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then
        print("Message sent.")
        return true
    elseif resp and resp.code == 403 and resp.remaining_seconds and resp.remaining_seconds > 0 then
        warn("Muted till " .. tostring(resp.muted_until) .. " (wait " .. tostring(resp.remaining_human) .. ")")
    else
        warn("Chat Send Failed: " .. (resp and resp.message or "Unknown"))
    end
    return false
end

function AuthVaultixCore:retrieve_chat_history(channel)
    if not self:ensure_ready() then return nil end
    local payload = PayloadBuilder.new("chatfetch"):with_context(self.app_name, self.owner_id, self.session_id):with_value("channel", channel):compile()
    local resp = NetworkAgent.post(BASE_URL, payload)
    if resp and resp.success then return resp.messages else
        warn("Chat Fetch Failed: " .. (resp and resp.message or "Unknown"))
        return nil
    end
end

function AuthVaultixCore:print_user_info()
    local info = self.current_user
    if not info then return end
    print("\n=== User Data ===")
    print("Username:", info.username)
    if info.ip then print("IP:", info.ip) end
    if info.hwid then print("HWID:", info.hwid) end
    if info.createdate then print("Created:", os.date("%Y-%m-%d %H:%M:%S", tonumber(info.createdate))) end
    if info.lastlogin then print("Last Login:", os.date("%Y-%m-%d %H:%M:%S", tonumber(info.lastlogin))) end
    if info.subscriptions and #info.subscriptions > 0 then
        print("\nSubscriptions:")
        for i, sub in ipairs(info.subscriptions) do
            local left = sub.timeleft or 0
            local d = math.floor(left / 86400)
            local h = math.floor((left % 86400) / 3600)
            local m = math.floor((left % 3600) / 60)
            print(string.format("[%d] %s | Expiry: %s | Timeleft: %dd %dh %dm", i, sub.subscription, os.date("%Y-%m-%d %H:%M:%S", tonumber(sub.expiry)), d, h, m))
        end
    end
    print()
end

local AuthVaultix = {}
AuthVaultix.__index = AuthVaultix
function AuthVaultix.new(app_name, owner_id, secret, version)
    return setmetatable({ core = AuthVaultixCore.new(app_name, owner_id, secret, version) }, AuthVaultix)
end

function AuthVaultix:Init() return self.core:init() end
function AuthVaultix:Login(u, p) return self.core:authenticate_user(u, p) end
function AuthVaultix:Check() return self.core:validate_session() end
function AuthVaultix:Register(u, p, l, e) return self.core:register_account(u, p, l, e or "") end
function AuthVaultix:LicenseLogin(l) return self.core:license_access(l) end
function AuthVaultix:Log(m) return self.core:send_log(m) end
function AuthVaultix:Download(f) return self.core:retrieve_file(f) end
function AuthVaultix:FetchOnline() return self.core:get_online_clients() end
function AuthVaultix:Ban(r) return self.core:enforce_ban(r) end
function AuthVaultix:Logout() return self.core:terminate_session() end
function AuthVaultix:ChangeUsername(u) return self.core:update_username(u) end
function AuthVaultix:CheckBlacklist() return self.core:verify_blacklist() end
function AuthVaultix:Upgrade(u, l) return self.core:apply_upgrade(u, l) end
function AuthVaultix:ForgotPassword(u, e) return self.core:trigger_password_reset(u, e) end
function AuthVaultix:GetGlobalVar(v) return self.core:fetch_global_variable(v) end
function AuthVaultix:GetVar(v) return self.core:fetch_user_variable(v) end
function AuthVaultix:SetVar(v, d) return self.core:update_user_variable(v, d) end
function AuthVaultix:ChatSend(m, c) return self.core:transmit_chat_message(m, c) end
function AuthVaultix:ChatFetch(c) return self.core:retrieve_chat_history(c) end

return AuthVaultix
