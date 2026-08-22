-- ============================================================
-- SCRIPT WEBHOOK FISH IT - AUTO CAPTURE REAL CHAT & COLOR
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local SERVER_URL = "https://fish-it-webhook.onrender.com/webhook"
local autoObserverActive = false

-- Fungsi untuk mengekstrak Nickname pemancing dan Nama Ikan murni dari chat
local function parseFishDataFromChat(rawText)
    local catcherName = LocalPlayer.Name -- Default cadangan jika gagal parsing
    local fishName = rawText
    local fishMutation = "Normal"
    
    -- 1. Ekstrak Nickname pemancing dari awal kalimat sebelum " obtained a"
    -- Contoh: "Faan648 obtained a Shark..." -> "Faan648"
    local _, _, extractedName = string.find(rawText, "^(.-)%s+obtained a")
    if extractedName then
        catcherName = extractedName
    end
    
    -- 2. Ekstrak Nama Ikan dari teks di antara "obtained a " dan " with a" (atau akhir kalimat)
    local _, _, extractedFish = string.find(rawText, "obtained a%s+(.-)%s+with a")
    if not extractedFish then
        _, _, extractedFish = string.find(rawText, "obtained a%s+(.+)")
    end
    
    if extractedFish then
        fishName = extractedFish
    end
    
    return catcherName, fishName, fishMutation
end

-- Fungsi pengirim data real ke Server Flask kamu
local function sendRealDataToServer(rawText, fishRarity)
    local catcherName, fishName, fishMutation = parseFishDataFromChat(rawText)
    
    local payload = {
        nickname = catcherName, -- Mengambil nickname murni dari chat game
        fishName = fishName,
        fishRarity = fishRarity,
        fishWeight = 0.0,
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
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = jsonBody
                })
                Rayfield:Notify({
                    Title = catcherName .. " Dapat " .. fishRarity .. "!",
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
   LoadingTitle = "Loading Observer...",
   LoadingSubtitle = "by Akihito_",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Auto Monitor", 4483362458)

-- Toggle Utama untuk Menyalakan/Mematikan Auto Observer
MainTab:CreateToggle({
   Name = "Aktifkan Auto-Capture (Secret & Forgotten)",
   CurrentValue = false,
   Flag = "AutoObserverToggle",
   Callback = function(Value)
      autoObserverActive = Value
      if Value then
          Rayfield:Notify({
              Title = "Auto Observer Aktif",
              Content = "Memantau layar untuk Secret & Forgotten...",
              Duration = 4,
          })
      else
          Rayfield:Notify({
              Title = "Auto Observer Mati",
              Content = "Pemantauan layar dihentikan.",
              Duration = 3,
          })
      end
   end,
})

-- ============================================================
-- BACKGROUND SYSTEM: AUTO-OBSERVER BERBASIS WARNA RGB ASLI
-- ============================================================
local lastSentText = ""

task.spawn(function()
    while true do
        task.wait(0.4)
        if autoObserverActive then
            pcall(function()
                for _, descendant in ipairs(CoreGui:GetDescendants()) do
                    if descendant:IsA("TextLabel") then
                        local text = descendant.Text
                        
                        if string.find(text, "obtained a") and text ~= lastSentText then
                            local color = descendant.TextColor3
                            local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
                            
                            local detectedRarity = nil
                            
                            -- 1. SECRET: Biru Tosca (R rendah, G & B tinggi)
                            if r < 100 and g > 150 and b > 150 then
                                detectedRarity = "Secret"
                                
                            -- 2. FORGOTTEN: Hitam / Abu Gelap (R, G, B rendah)
                            elseif r < 80 and g < 80 and b < 80 then
                                detectedRarity = "Forgotten"
                            end
                            
                            if detectedRarity then
                                lastSentText = text
                                sendRealDataToServer(text, detectedRarity)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

Rayfield:Notify({
   Title = "UI Berhasil Dimuat!",
   Content = "Aktifkan toggle untuk mulai merekam data real.",
   Duration = 5,
})
