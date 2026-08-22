-- ============================================================
-- SCRIPT WEBHOOK FISH IT - SECURE REMOTE HOOK
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SERVER_URL = "https://fish-it-webhook.onrender.com/webhook"
local API_KEY = "TalonRahasiaBanget123" -- Harus sama persis dengan di Flask/Render!
local autoObserverActive = false

-- Fungsi pengirim data aman ke Server Flask kamu
local function sendRealDataToServer(catcherName, fishName, fishRarity)
    local payload = {
        nickname = catcherName,
        fishName = fishName,
        fishRarity = fishRarity,
        fishWeight = 0.0,
        fishMutation = "Normal"
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
                        ["X-API-Key"] = API_KEY -- Menyertakan kunci keamanan
                    },
                    Body = jsonBody
                })
                Rayfield:Notify({
                    Title = "Webhook Terkirim!",
                    Content = fishRarity .. " - " .. fishName,
                    Duration = 4,
                })
            end)
        end)
    end
end

-- Membuat Window UI Rayfield
local Window = Rayfield:CreateWindow({
   Name = "Webhook Kesayangan Talon",
   LoadingTitle = "Loading Secure Hook...",
   LoadingSubtitle = "by Akihito_",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Auto Monitor", 4483362458)

MainTab:CreateToggle({
   Name = "Aktifkan Secure Remote Hook",
   CurrentValue = false,
   Flag = "SecureHookToggle",
   Callback = function(Value)
      autoObserverActive = Value
      if Value then
          Rayfield:Notify({
              Title = "Hook Aktif",
              Content = "Memantau jaringan secara pasif & aman...",
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
-- BACKGROUND SYSTEM: SUPER LIGHTWEIGHT EVENT LISTENER
-- ============================================================
for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
    if descendant:IsA("RemoteEvent") then
        descendant.OnClientEvent:Connect(function(...)
            if not autoObserverActive then return end
            
            local args = {...}
            for _, v in ipairs(args) do
                if type(v) == "table" then
                    local fishName = v.Name or v.FishName or v.Item
                    local rarity = v.Rarity or v.Tier or "Secret"
                    
                    if fishName and type(fishName) == "string" then
                        local catcher = v.Player or v.Username or LocalPlayer.Name
                        sendRealDataToServer(tostring(catcher), tostring(fishName), tostring(rarity))
                        break
                    end
                end
            end
        end)
    end
end

Rayfield:Notify({
   Title = "UI Berhasil Dimuat!",
   Content = "Sistem aman siap digunakan.",
   Duration = 5,
})
