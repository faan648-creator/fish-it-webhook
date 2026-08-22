-- ============================================================
-- SCRIPT WEBHOOK FISH IT - SMART FILTERED HOOK
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SERVER_URL = "https://fish-it-webhook.onrender.com/webhook"
local API_KEY = "TalonRahasiaBanget123" -- Sesuaikan dengan kunci di server Flaskmu
local autoObserverActive = false

-- Daftar kata/pola yang BUKAN ikan (untuk disaring/diabaikan)
local ignoredWords = {")", "(", "Head", "LoadBeat", "Set", "1", "2", "3", "4", "5"}

local function isIgnored(text)
    for _, word in ipairs(ignoredWords) do
        if text == word then return true end
    end
    -- Abaikan jika terlalu pendek atau berupa angka murni
    if #text <= 2 or tonumber(text) ~= nil then return true end
    return false
end

-- Fungsi pengirim data ke Server Flask
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
                        ["X-API-Key"] = API_KEY
                    },
                    Body = jsonBody
                })
                Rayfield:Notify({
                    Title = "Ikan Langka Tertangkap!",
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
   LoadingTitle = "Loading Smart Hook...",
   LoadingSubtitle = "by Akihito_",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Auto Monitor", 4483362458)

MainTab:CreateToggle({
   Name = "Aktifkan Smart Filter Webhook",
   CurrentValue = false,
   Flag = "SmartHookToggle",
   Callback = function(Value)
      autoObserverActive = Value
      if Value then
          Rayfield:Notify({
              Title = "Hook Aktif",
              Content = "Memantau tangkapan ikan secara cerdas...",
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
-- FILTERED EVENT LISTENER
-- ============================================================
for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
    if descendant:IsA("RemoteEvent") then
        descendant.OnClientEvent:Connect(function(...)
            if not autoObserverActive then return end
            
            local args = {...}
            
            -- Cek argumen ke-3 (karena sering jadi lokasi nama ikan)
            if #args >= 3 and type(args[1]) == "string" and type(args[3]) == "string" then
                local catcherName = args[1]
                local potentialFish = args[3]
                
                -- Pastikan bukan simbol atau teks sampah
                if not isIgnored(potentialFish) then
                    local rarity = "Secret / Rare"
                    
                    -- Kirim ke Flask server
                    sendRealDataToServer(tostring(catcherName), tostring(potentialFish), tostring(rarity))
                end
            end
        end)
    end
end

Rayfield:Notify({
   Title = "UI Berhasil Dimuat!",
   Content = "Filter cerdas siap digunakan.",
   Duration = 5,
})
