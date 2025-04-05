-- Logger.lua
-- Make sure to include Rayfield UI library in your game from https://sirius.menu

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Replace with your Discord Webhook URL
local WEBHOOK_URL = "YOUR_WEBHOOK_URL"

-- Rayfield UI Setup
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Chat Logger",
    LoadingTitle = "Chat Logger UI",
    LoadingSubtitle = "by GitHub Copilot",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ChatLogger",
        FileName = "Config"
    },
    KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458) -- Tab with an icon
local Section = Tab:CreateSection("Logger Settings")

local Toggle = Tab:CreateToggle({
    Name = "Enable Logging",
    CurrentValue = true,
    Flag = "EnableLogging",
    Callback = function(Value)
        _G.LoggingEnabled = Value
    end,
})

_G.LoggingEnabled = true -- Default state

-- Function to send message to Discord Webhook
local function sendToWebhook(username, message)
    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "New Chat Message",
            ["description"] = "**" .. username .. "**: " .. message,
            ["type"] = "rich",
            ["color"] = tonumber(0x7289DA) -- Discord blue
        }}
    }

    local jsonData = HttpService:JSONEncode(data)

    HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
end

-- Listen for player chats
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if _G.LoggingEnabled then
            sendToWebhook(player.Name, message)
        end
    end)
end)

Rayfield:Notify({
    Title = "Chat Logger",
    Content = "Script loaded successfully!",
    Duration = 5,
    Image = 4483362458
})

-- Cleanup when the script is unloaded
game.Players.PlayerRemoving:Connect(function(player)
    player.Chatted:Disconnect()
end)

-- End of Logger.lua