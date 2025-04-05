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

-- Update Checker
local CURRENT_VERSION = "1.0.0" -- Update this version as needed
local VERSION_URL = "https://github.com/KnowinglyPossible/Best-Repository/raw/4ff78e0c80dd5db9aad807b842a162480b3e2c07/version.json" -- Replace with your [version.json](http://_vscodecontentref_/1) URL
local SCRIPT_URL = "https://github.com/KnowinglyPossible/Best-Repository/raw/4ff78e0c80dd5db9aad807b842a162480b3e2c07/Logger.lua" -- Replace with your [Logger.lua](http://_vscodecontentref_/2) raw URL

local function checkForUpdates()
    local success, response = pcall(function()
        return HttpService:GetAsync(VERSION_URL)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        if data.version and data.version ~= CURRENT_VERSION then
            Rayfield:Notify({
                Title = "Update Available",
                Content = "A new version (" .. data.version .. ") is available. Updating now...",
                Duration = 10,
                Image = 4483362458
            })

            -- Fetch and execute the updated script
            local newScript, fetchSuccess = pcall(function()
                return game:HttpGet(SCRIPT_URL)
            end)

            if fetchSuccess then
                loadstring(newScript)() -- Execute the updated script
            else
                Rayfield:Notify({
                    Title = "Update Failed",
                    Content = "Failed to download the updated script. Please try again later.",
                    Duration = 10,
                    Image = 4483362458
                })
            end
        else
            Rayfield:Notify({
                Title = "No Updates",
                Content = "You are using the latest version (" .. CURRENT_VERSION .. ").",
                Duration = 5,
                Image = 4483362458
            })
        end
    else
        Rayfield:Notify({
            Title = "Update Check Failed",
            Content = "Unable to check for updates. Please try again later.",
            Duration = 5,
            Image = 4483362458
        })
    end
end

-- Add a button to manually check for updates
local UpdateTab = Window:CreateTab("Updates", 4483362458)
local UpdateSection = UpdateTab:CreateSection("Update Checker")

UpdateTab:CreateButton({
    Name = "Check for Updates",
    Callback = function()
        checkForUpdates()
    end
})

-- Automatically check for updates on script load
checkForUpdates()

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