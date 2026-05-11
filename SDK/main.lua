local AuthVaultix = require("authvaultix_windows")

local app = AuthVaultix.new(
    "", -- name of application
    "", -- owner id
    "", -- secret
    "" -- version
)

print("Connecting...")
app:Init()

while true do
    print("\n[1] Login\n[2] Register\n[3] License Login\n[4] Upgrade\n[5] Forgot Password\n[6] Exit")
    io.write("Choose option: ")
    local choice = io.read()

    if choice == "1" then
        io.write("Username: ") local u = io.read()
        io.write("Password: ") local p = io.read()
        app:Login(u, p)
    elseif choice == "2" then
        io.write("Username: ") local u = io.read()
        io.write("Password: ") local p = io.read()
        io.write("License: ") local l = io.read()
        app:Register(u, p, l, "")
    elseif choice == "3" then
        io.write("License: ") local l = io.read()
        app:LicenseLogin(l)
    elseif choice == "4" then
        io.write("Username: ") local u = io.read()
        io.write("License: ") local l = io.read()
        app:Upgrade(u, l)
    elseif choice == "5" then
        io.write("Username: ") local u = io.read()
        io.write("Email: ") local e = io.read()
        app:ForgotPassword(u, e)
    elseif choice == "6" then
        print("Goodbye!")
        break
    else
        print("Invalid option!")
    end
end
