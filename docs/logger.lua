-- Logger.lua
-- Make sure to include Rayfield UI library in your game from https://sirius.menu

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Rayfield UI Setup
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    error("Failed to load Rayfield UI library. Please check the URL or your internet connection.")
end

-- Create the main Rayfield window
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

-- Webhook URL (default empty, to be set via UI)
local WEBHOOK_URL = ""
local ICON_ID = 4483362458

-- Function to send message to Discord Webhook
local function sendToWebhook(username, message, isPrivate)
    if WEBHOOK_URL == "" or not WEBHOOK_URL:match("^https?://") then
        warn("Invalid or empty Webhook URL. Please set it in the Settings tab.")
        return
    end

    local gameLink = game.PlaceId and "https://www.roblox.com/games/" .. game.PlaceId or "N/A"
    local jobId = game.JobId or "N/A"
    local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- ISO 8601 format (UTC)
    local privateStatus = isPrivate and "✅ Private Chat" or "❌ Public Chat"

    local data = {
        ["content"] = "",
        ["embeds"] = { {
            ["title"] = "New Chat Message",
            ["description"] = "**Message:** " .. message,
            ["fields"] = {
                {
                    ["name"] = "Username",
                    ["value"] = username,
                    ["inline"] = true
                },
                {
                    ["name"] = "Game Link",
                    ["value"] = "[Click Here](" .. gameLink .. ")",
                    ["inline"] = true
                },
                {
                    ["name"] = "Job ID",
                    ["value"] = jobId,
                    ["inline"] = true
                },
                {
                    ["name"] = "Private Chat",
                    ["value"] = privateStatus,
                    ["inline"] = true
                },
                {
                    ["name"] = "Timestamp",
                    ["value"] = timestamp,
                    ["inline"] = true
                }
            },
            ["type"] = "rich",
            ["color"] = tonumber(0x7289DA) -- Discord blue
        } }
    }

    local jsonData = HttpService:JSONEncode(data)
    local success, err = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("Failed to send data to webhook: " .. tostring(err))
    end
end

-- Main Tab
local MainTab = Window:CreateTab("Main", ICON_ID)
MainTab:CreateLabel("Welcome to Chat Logger!")
MainTab:CreateParagraph({
    Title = "Instructions",
    Content = "Use the Settings tab to configure the webhook URL and enable logging. Chat messages will be logged and sent to the configured webhook."
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", ICON_ID)
SettingsTab:CreateSection("Webhook Settings")

SettingsTab:CreateInput({
    Name = "Set Webhook URL",
    PlaceholderText = "Enter your webhook URL",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        if not Value:match("^https?://") then
            Rayfield:Notify({
                Title = "Invalid URL",
                Content = "Please enter a valid webhook URL.",
                Duration = 5
            })
            return
        end
        WEBHOOK_URL = Value
        Rayfield:Notify({
            Title = "Webhook URL Updated",
            Content = "The webhook URL has been updated successfully.",
            Duration = 5
        })
    end
})

SettingsTab:CreateToggle({
    Name = "Enable Webhook Logging",
    CurrentValue = true,
    Flag = "EnableWebhookLogging",
    Callback = function(Value)
        _G.WebhookLoggingEnabled = Value
    end
})

-- Updates Tab
local UpdatesTab = Window:CreateTab("Updates", ICON_ID)
UpdatesTab:CreateLabel("Version: 1.0.0")
UpdatesTab:CreateLabel("Last Updated: 2023-10-01")
UpdatesTab:CreateParagraph({
    Title = "Changelog",
    Content = "- Added webhook logging\n- Improved UI\n- Fixed minor bugs"
})

-- Chat Logging Functionality
local function onPlayerChatted(player, message, recipient)
    if not _G.WebhookLoggingEnabled then
        return
    end

    local isPrivate = recipient ~= nil
    sendToWebhook(player.Name, message, isPrivate)
end

-- Connect chat events for all players
local function setupChatLogging()
    for _, player in pairs(Players:GetPlayers()) do
        player.Chatted:Connect(function(message, recipient)
            onPlayerChatted(player, message, recipient)
        end)
    end

    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message, recipient)
            onPlayerChatted(player, message, recipient)
        end)
    end)
end

-- Initialize Chat Logging
setupChatLogging()

-- Cleanup Rayfield UI on Game Close
game:BindToClose(function()
    Rayfield:Destroy()
end)
