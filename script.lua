-- ============================================================
-- SCRIPT WEBHOOK FISH IT - STABLE & FLEXIBLE HOOK
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SERVER_URL = "https://fish-it-webhook.onrender.com/webhook"
local API_KEY = "TalonRahasiaBanget123" -- Pastikan sama dengan di Flask
local autoObserverActive = false

-- Fungsi pengirim data aman ke Server Flask
local function sendDataToServer(catcherName, fishName, fishTier, fishWeight, fishVariant, fishChance)
    local payload = {
        nickname = catcherName,
        fishName = fishName,
        fishTier = fishTier or "SECRET",
        fishWeight = fishWeight or "0 kg",
        fishVariant = fishVariant or "Normal",
        fishChance = fishChance or "1 in 3M"
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
                        ["Content-Type"] = "application/json",
                        ["X-API-Key"] = API_KEY
                    },
                    Body = jsonBody
                })
                Rayfield:Notify({
                    Title = "Webhook Terkirim!",
                    Content = fishName,
                    Duration = 4,
                })
            end)
        end)
    end
end

-- Membuat Window UI Rayfield
local Window = Rayfield:CreateWindow({
   Name = "Webhook Kesayangan Talon",
   LoadingTitle = "Loading Stable Hook...",
   LoadingSubtitle = "by Akihito_",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Auto Monitor", 4483362458)

MainTab:CreateToggle({
   Name = "Aktifkan Auto Webhook",
   CurrentValue = false,
   Flag = "StableHookToggle",
   Callback = function(Value)
      autoObserverActive = Value
      if Value then
          Rayfield:Notify({
              Title = "Hook Aktif",
              Content = "Memantau tangkapan ikan...",
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
-- EVENT LISTENER FLEKSIBEL (TABEL & STRING)
-- ============================================================
for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
    if descendant:IsA("RemoteEvent") then
        descendant.OnClientEvent:Connect(function(...)
            if not autoObserverActive then return end
            
            local args = {...}
            for _, v in ipairs(args) do
                -- Jika data dikirim dalam bentuk tabel
                if type(v) == "table" then
                    local fishName = v.Name or v.FishName or v.Item or v.Title
                    if fishName and type(fishName) == "string" and #fishName > 2 then
                        local catcher = v.Player or v.Username or LocalPlayer.Name
                        local tier = v.Tier or v.Rarity or "SECRET"
                        local weight = tostring(v.Weight or v.Size or "0") .. " kg"
                        local variant = v.Variant or v.Mutation or "Normal"
                        local chance = v.Chance or v.Odds or "1 in 3M"
                        
                        sendDataToServer(tostring(catcher), tostring(fishName), tostring(tier), weight, tostring(variant), tostring(chance))
                        break
                    end
                -- Jika data dikirim dalam bentuk string teks mentah
                elseif type(v) == "string" then
                    if string.find(v, "obtained") or (#v > 3 and #v < 30 and not string.find(v, "http")) then
                        local catcher = LocalPlayer.Name
                        local fishName = v
                        
                        sendDataToServer(catcher, fishName, "SECRET", "0 kg", "Normal", "1 in 3M")
                        break
                    end
                end
            end
        end)
    end
end

Rayfield:Notify({
   Title = "UI Berhasil Dimuat!",
   Content = "Sistem siap dijalankan.",
   Duration = 5,
})
