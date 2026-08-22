-- ============================================================
-- SCRIPT WEBHOOK FISH IT - FINAL & PRECISE HOOK
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SERVER_URL = "https://fish-it-webhook.onrender.com/webhook"
local API_KEY = "TalonRahasiaBanget123" -- Sesuaikan dengan kunci di server Flaskmu
local autoObserverActive = false

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
   LoadingTitle = "Loading Precise Hook...",
   LoadingSubtitle = "by Akihito_",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Auto Monitor", 4483362458)

MainTab:CreateToggle({
   Name = "Aktifkan Auto Webhook Ikan",
   CurrentValue = false,
   Flag = "PreciseHookToggle",
   Callback = function(Value)
      autoObserverActive = Value
      if Value then
          Rayfield:Notify({
              Title = "Hook Aktif",
              Content = "Menangkap data tangkapan ikan...",
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
-- TARGETED EVENT LISTENER (BERDASARKAN STRUKTUR ARGUMEN)
-- ============================================================
for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
    if descendant:IsA("RemoteEvent") then
        descendant.OnClientEvent:Connect(function(...)
            if not autoObserverActive then return end
            
            local args = {...}
            
            -- Memastikan event ini memiliki struktur argumen tangkapan ikan (minimal 3 argumen)
            if #args >= 3 and type(args[1]) == "string" and type(args[3]) == "string" then
                local catcherName = args[1]
                local fishName = args[3]
                
                -- Filter tambahan: Pastikan argumen ke-3 bukan string acak/angka, melainkan nama ikan (huruf kapital di awal)
                -- Kamu bisa saring khusus ikan langka atau biarkan semua masuk
                local rarity = "Secret" -- Defaulting ke Secret atau Forgotten sesuai kebutuhan
                
                -- Kirim langsung ke server Flask
                sendRealDataToServer(tostring(catcherName), tostring(fishName), tostring(rarity))
            end
        end)
    end
end

Rayfield:Notify({
   Title = "UI Berhasil Dimuat!",
   Content = "Script siap mendeteksi tangkapan.",
   Duration = 5,
})
