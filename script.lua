-- ============================================================
-- SCRIPT WEBHOOK FISH IT - FULL DETAIL EXTRACTOR
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SERVER_URL = "https://fish-it-webhook.onrender.com/webhook"
local API_KEY = "TalonRahasiaBanget123" -- Ganti sesuai key kamu
local autoObserverActive = false

local function sendFullDataToServer(data)
    local jsonBody = HttpService:JSONEncode(data)
    local httpRequest = http_request or request or syn.request

    if httpRequest then
        task.spawn(function()
            pcall(function()
                httpRequest({
                    Url = SERVER_URL,
                    Method = "POST",
                    Headers = { 
                        ["Content-Type"] = "application/json",
                        ["X-API-Key"] = API_KEY
                    },
                    Body = jsonBody
                })
                Rayfield:Notify({
                    Title = "Webhook Terkirim!",
                    Content = tostring(data.fishName) .. " (" .. tostring(data.fishWeight) .. ")",
                    Duration = 4,
                })
            end)
        end)
    end
end

-- Membuat Window UI Rayfield
local Window = Rayfield:CreateWindow({
   Name = "Webhook Kesayangan Talon",
   LoadingTitle = "Loading Detailed Hook...",
   LoadingSubtitle = "by Akihito_",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Auto Monitor", 4483362458)

MainTab:CreateToggle({
   Name = "Aktifkan Full Detail Webhook",
   CurrentValue = false,
   Flag = "DetailHookToggle",
   Callback = function(Value)
      autoObserverActive = Value
      if Value then
          Rayfield:Notify({
              Title = "Hook Aktif",
              Content = "Menangkap data lengkap ikan...",
              Duration = 4,
          })
      else
          Rayfield:Notify({
              Title = "Hook Mati",
              Content = "Pemantauan dihentikan.",
              Duration = 3,
          })
      end
   end,
})

-- ============================================================
-- DEEP TABLE EXTRACTOR (MENGESTREK VARIANT, TIER, BERAT, DLL)
-- ============================================================
for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
    if descendant:IsA("RemoteEvent") then
        descendant.OnClientEvent:Connect(function(...)
            if not autoObserverActive then return end
            
            local args = {...}
            for _, v in ipairs(args) do
                if type(v) == "table" then
                    -- Mencari indikasi objek ikan berdasarkan key yang biasa dipakai game
                    local fishName = v.Name or v.FishName or v.Item or v.Title
                    if fishName and type(fishName) == "string" and #fishName > 2 then
                        
                        local payload = {
                            nickname = v.Player or v.Username or LocalPlayer.Name,
                            fishName = fishName,
                            fishTier = v.Tier or v.Rarity or "SECRET",
                            fishWeight = tostring(v.Weight or v.Size or "0") .. " kg",
                            fishVariant = v.Variant or v.Mutation or nil,
                            fishChance = v.Chance or v.Odds or "1 in 3M"
                        }
                        
                        sendFullDataToServer(payload)
                        break
                    end
                end
            end
        end)
    end
end

Rayfield:Notify({
   Title = "UI Berhasil Dimuat!",
   Content = "Siap memantau ikan dengan detail.",
   Duration = 5,
})
