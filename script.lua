-- ============================================================
-- SCRIPT WEBHOOK FISH IT - VERSI SEDERHANA DENGAN DROPDOWN
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SERVER_URL = "https://fish-it-webhook.onrender.com/webhook"
local selectedRarity = "Common" -- Default rarity

-- Fungsi pengirim data
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
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = jsonBody
                })
                Rayfield:Notify({
                    Title = "Webhook Terkirim",
                    Content = fishName .. " (" .. fishRarity .. ")",
                    Duration = 3,
                })
            end)
        end)
    end
end

-- Membuat Window UI Sederhana
local Window = Rayfield:CreateWindow({
   Name = "Fish It! Webhook Test",
   LoadingTitle = "Loading Menu...",
   LoadingSubtitle = "by Creator",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Webhook Test", 4483362458)

-- Dropdown Rarity
MainTab:CreateDropdown({
   Name = "Pilih Rarity Ikan",
   Options = {"Uncommon", "Common", "Epic", "Legend", "Mythic", "Secret", "Forgotten"},
   CurrentOption = "Common",
   Flag = "RarityDropdown",
   Callback = function(Option)
      selectedRarity = Option
   end,
})

-- Tombol Kirim Tes Manual Berdasarkan Dropdown
MainTab:CreateButton({
   Name = "Kirim Tes Sesuai Rarity",
   Callback = function()
      sendToMyServer("Ikan Uji Coba", selectedRarity, 50.0, "Normal")
      Rayfield:Notify({
         Title = "Berhasil Dikirim",
         Content = "Mengirim ikan dengan rarity: " .. selectedRarity,
         Duration = 3,
      })
   end,
})

Rayfield:Notify({
   Title = "UI Berhasil Dimuat!",
   Content = "Pilih rarity di dropdown lalu klik tombol kirim.",
   Duration = 5,
})
