-- ============================================================
-- SCRIPT WEBHOOK FISH IT - FINAL (PLAYERGUI & HIGH RARITY ONLY)
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SERVER_URL = "https://fish-it-webhook.onrender.com/webhook"
local autoObserverActive = false

-- Fungsi untuk mengekstrak Nickname, Mutasi, dan Nama Ikan secara presisi
local function parseFishDataFromChat(rawText)
    local catcherName = LocalPlayer.Name 
    local fishMutation = "Normal"
    local fishName = rawText
    
    -- 1. Ekstrak Nickname pemancing dari awal kalimat sebelum " obtained a"
    local _, _, extractedName = string.find(rawText, "^(.-)%s+obtained a")
    if extractedName then
        catcherName = extractedName
    end
    
    -- 2. Ekstrak teks setelah "obtained a " sampai sebelum tanda kurung berat "("
    local _, _, middleText = string.find(rawText, "obtained a%s+(.-)%s+%(")
    if not middleText then
        _, _, middleText = string.find(rawText, "obtained a%s+(.+)")
    end
    
    if middleText then
        -- 3. Pisahkan Mutasi (Kata pertama, contoh: "STONE") dari Nama Ikan
        local firstSpacePos = string.find(middleText, "%s")
        if firstSpacePos then
            fishMutation = string.sub(middleText, 1, firstSpacePos - 1)
            fishName = string.sub(middleText, firstSpacePos + 1)
        else
            fishName = middleText
            fishMutation = "Normal"
        end
    end
    
    return catcherName, fishName, fishMutation
end

-- Fungsi pengirim data real ke Server Flask kamu
local function sendRealDataToServer(rawText, fishRarity)
    local catcherName, fishName, fishMutation = parseFishDataFromChat(rawText)
    
    local payload = {
        nickname = catcherName,
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
                    Title = catcherName .. " (" .. fishMutation .. ")",
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
   LoadingTitle = "Loading Observer...",
   LoadingSubtitle = "by Akihito_",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Auto Monitor", 4483362458)

MainTab:CreateToggle({
   Name = "Aktifkan Auto-Capture (Secret & Forgotten)",
   CurrentValue = false,
   Flag = "AutoObserverToggle",
   Callback = function(Value)
      autoObserverActive = Value
      if Value then
          Rayfield:Notify({
              Title = "Auto Observer Aktif",
              Content = "Memantau PlayerGui (Secret & Forgotten)...",
              Duration = 4,
          })
      else
          Rayfield:Notify({
              Title = "Auto Observer Mati",
              Content = "Pemantauan dihentikan.",
              Duration = 3,
          })
      end
   end,
})

-- ============================================================
-- BACKGROUND SYSTEM: AUTO-OBSERVER (PLAYERGUI VERSION)
-- ============================================================
local lastSentText = ""

task.spawn(function()
    while true do
        task.wait(0.4)
        if autoObserverActive then
            pcall(function()
                -- Menggunakan PlayerGui agar aman dari blokir executor
                for _, descendant in ipairs(PlayerGui:GetDescendants()) do
                    if descendant:IsA("TextLabel") then
                        local text = descendant.Text
                        
                        if string.find(text, "obtained a") and text ~= lastSentText then
                            local color = descendant.TextColor3
                            local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
                            
                            local detectedRarity = nil
                            
                            -- Filter warna RGB (Hanya Secret & Forgotten)
                            if r < 100 and g > 150 and b > 150 then
                                detectedRarity = "Secret"
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
   Content = "Siap memantau ikan ultra-langka.",
   Duration = 5,
})
