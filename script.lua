local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SERVER_URL = "https://fish-it-webhook.onrender.com/webhook"

local function sendToMyServer(fishName, fishRarity, fishWeight, fishMutation)
    local payload = {
        nickname = LocalPlayer.Name,
        fishName = fishName,
        fishRarity = fishRarity,
        fishWeight = fishWeight,
        fishMutation = fishMutation
    }

    local jsonBody = HttpService:JSONEncode(payload)
    local httpRequest = http_request or request or syn.request

    if httpRequest then
        task.spawn(function()
            pcall(function()
                httpRequest({
                    Url = SERVER_URL,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = jsonBody
                })
            end)
        end)
    end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fishEvent = ReplicatedStorage:WaitForChild("NamaFolderGame"):WaitForChild("NamaRemoteIkan")

if fishEvent then
    fishEvent.OnClientEvent:Connect(function(dataPacket)
        local name = dataPacket.Name or "Unknown"
        local rarity = dataPacket.Rarity or "Common"
        local weight = dataPacket.Weight or 0
        local mutation = dataPacket.Mutation or "None"

        sendToMyServer(name, rarity, weight, mutation)
    end)
    print("Script Fish It Webhook Berhasil Aktif & Real-Time!")
end
