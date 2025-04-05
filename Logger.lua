-- Logger.lua
-- Make sure to include Rayfield UI library in your game from https://sirius.menu

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Replace with your Discord Webhook URL
local WEBHOOK_URL = "https://discord.com/api/webhooks/your_webhook_id/your_webhook_token" -- Replace with your actual webhook URL

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
    -- No need to manually disconnect Chatted connections; they are cleaned up automatically
end)
-- Chat History Tab
local ChatHistoryTab = Window:CreateTab("Chat History", 4483362458)
local ChatHistorySection = ChatHistoryTab:CreateSection("Chat Messages")
local ChatHistory = {}

local function updateChatHistory(username, message)
    table.insert(ChatHistory, "**" .. username .. "**: " .. message)
    if #ChatHistory > 50 then
        table.remove(ChatHistory, 1) -- Limit chat history to 50 messages
    end
    ChatHistorySection:Update({
        Name = "Chat Messages",
        Content = table.concat(ChatHistory, "\n")
    })
end

-- Update chat history when a player chats
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if _G.LoggingEnabled then
            updateChatHistory(player.Name, message)
        end
    end)
end)

-- Extra Features Tab
local ExtraFeaturesTab = Window:CreateTab("Extra Features", 4483362458)
local ExtraFeaturesSection = ExtraFeaturesTab:CreateSection("Game Map and Player Tracking")

-- Map of the game
local MapButton = ExtraFeaturesTab:CreateButton({
    Name = "Show Game Map",
    Callback = function()
        local map = game.Workspace:FindFirstChild("Map")
        if map then
            Rayfield:Notify({
                Title = "Game Map",
                Content = "Map found: " .. map.Name,
                Duration = 5
            })
        else
            Rayfield:Notify({
                Title = "Game Map",
                Content = "No map found in the game!",
                Duration = 5
            })
        end
    end
})

-- Log player coordinates and send a picture to the webhook
local function logPlayerCoordinates(player)
    while player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do
        local position = player.Character.HumanoidRootPart.Position
        local screenshotUrl = "https://example.com/screenshot.png" -- Replace with actual screenshot logic

        local data = {
            ["content"] = "",
            ["embeds"] = { {
                ["title"] = "Player Coordinates",
                ["description"] = "**" .. player.Name .. "** is at: " .. tostring(position),
                ["image"] = { ["url"] = screenshotUrl },
                ["type"] = "rich",
                ["color"] = tonumber(0x7289DA)
            } }
        }

        local jsonData = HttpService:JSONEncode(data)
        HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)

        wait(10) -- Log every 10 seconds
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        coroutine.wrap(logPlayerCoordinates)(player)
    end)
end)
-- End of Logger.lua