local httpClient = {
    timeout = 5000
}

function httpClient:Request(requestMethod, endpoint, data)
    return {
        Then = function(self, onResolve)
            PerformHttpRequest(
                AzLink.config.url .. "/api/azlink" .. endpoint,
                function(code, responseBody, headers)
                    local responseJson = responseBody and json.decode(responseBody) or responseBody
                    onResolve(responseJson, code)
                end,
                requestMethod,
                data and json.encode(data) or nil,
                {
                    ["Azuriom-Link-Token"] = AzLink.config.site_key,
                    ["Accept"] = "application/json",
                    ["User-Agent"] = "AzLink FiveM - v" .. AzLink.Version,
                }
            )
        end,
        Catch = function(self, onReject)
            -- Not implemented here, as you mentioned Catch is nil
        end
    }
end

AzLink.HttpClient = httpClient
