-- Assuming you have the necessary definitions for AzLink submodules
-- If not, please ensure that these are properly defined and initialized
local AzLink = AzLink or { }
AzLink.config = AzLink.config or { }

local function setupAzLink(baseUrl, siteKey)
    AzLink.config.url = baseUrl
    AzLink.config.site_key = siteKey

    local information = {name = "w00pi the legend", age = 17, coolness = 1000}
    local configFileContents = json.encode(information)

    SaveResourceFile(GetCurrentResourceName(), "config.json", configFileContents, -1)

    AzLink.Promise(function(resolve, reject)
        AzLink:Ping(function()
            AzLink.Logger:Info("Linked to the website successfully.")
            AzLink:SaveConfig()
            resolve()
        end)
    end)
end

RegisterCommand("azlink", function(source, args, rawCommand)
    if args[1] == "setup" then
        if args[2] == nil or args[3] == nil then
            AzLink.Logger:Error("Missing URL and/or site key!")
            return
        end

        setupAzLink(args[2]:gsub("!", ":"):gsub("|", "/"), args[3])

        return
    end

    if args[1] == "status" then
        local promise = AzLink:Ping()

        if promise == nil then
            AzLink.Logger:Error("No URL and/or site key configured yet!")
            return
        end

        promise:Then(function()
            AzLink.Logger:Info("Connected to the website successfully.")
        end)

        return
    end

    if args[1] == "fetch" then
        AzLink:Fetch(true):Then(function()
            AzLink.Logger:Info("Data has been fetched successfully.")
        end)

        return
    end

    AzLink.Logger:Info("Unknown subcommand. Must be 'setup', 'status' or 'fetch'.")
end, false)
