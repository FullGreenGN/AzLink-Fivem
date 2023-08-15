local AZLINK_VERSION = "0.1.0" -- TODO
AzLink = AzLink or { }
AzLink.lastSent = 0
AzLink.lastFullSent = 0
AzLink.config = { }
AzLink.Version = AZLINK_VERSION

function AzLink:Fetch(force)
    local siteKey = AzLink.config.site_key
    local baseUrl = AzLink.config.url
    if siteKey == nil or baseUrl == nil or not force and GetGameTimer() - AzLink.lastSent < 15000 then
        return
    end
    local sendFull = os.date("*t").min % 15 == 0 and GetGameTimer() - AzLink.lastFullSent > 60000
    AzLink.lastSent = GetGameTimer()

    if sendFull then
        AzLink.lastFullSent = GetGameTimer()
    end

    -- TODO: Implement AzLink.Fetcher:Run(sendFull) in your FiveM environment
end

function AzLink:Ping()
    local siteKey = AzLink.config.site_key
    local baseUrl = AzLink.config.url

    if siteKey == nil or baseUrl == nil then
        return nil
    end

    print("[AzLink] Pinging " .. baseUrl .. "...")
    print("[AzLink] Site key: " .. siteKey)

    -- TODO: Implement AzLink.HttpClient:Request("GET", "") in your FiveM environment
    return AzLink.HttpClient:Request("GET", "", data):Then(function(responseData, code)
        if code >= 300 then
            local errorMessage = (responseData.message or responseData) .. " (" .. code .. ")"
            print("[AzLink] An HTTP error occurred during ping: " .. errorMessage)
        else
            print("[AzLink] Ping successful!")
            print("[AzLink] Response: " .. responseData)
        end
    end)
end


function AzLink:GetServerData(full)
    local players = { }

    for _, player in ipairs(GetPlayers()) do
        table.insert(players, {
            ["name"] = GetPlayerName(player),
            ["uid"] = tostring(player),
        })
    end

    local baseData = {
        ["platform"] = {
            ["type"] = "FIVEM",
            ["name"] = "FiveM",
            ["version"] = GetResourceMetadata(GetCurrentResourceName(), "version", 0),
        },
        ["version"] = AZLINK_VERSION,
        ["players"] = players,
        ["maxPlayers"] = GetConvarInt("sv_maxclients", 32), -- Adjust as needed
        ["full"] = full,
    }

    if full then
        baseData.worlds = {
            ["entities"] = #GetAllEntities(),
        }

        -- TODO: Obtain server system data in your FiveM environment
        baseData.system = {
            ["cpu"] = GetServerCpuUsage(), -- Adjust as needed
            ["ram"] = GetServerRamUsage(), -- Adjust as needed
        }
    end

    return baseData
end

function AzLink:SaveConfig()
    -- TODO: Save configuration data in your FiveM environment
    local configData = json.encode(AzLink.config)
    -- Save configData to a file
end

print("[AzLink] Starting AzLink v" .. AZLINK_VERSION .. "...")

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Wait 60 seconds
        AzLink:Fetch()
    end
end)

-- Load configuration from file
-- TODO: Read configuration data from a file in your FiveM environment
local rawConfig = LoadResourceFile(GetCurrentResourceName(), "config.json")

if rawConfig ~= nil then
    AzLink.config = json.decode(rawConfig)
end

-- Print a warning if the serverstat module is not available
-- Adjust this part based on your FiveM environment
local serverstat = nil
if not serverstat then
    print("[AzLink] Unable to load serverstat, please install the module by following...")
end

print("[AzLink] AzLink successfully enabled.")
