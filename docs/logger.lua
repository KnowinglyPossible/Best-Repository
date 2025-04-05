-- Logger.lua
-- Make sure to include Rayfield UI library in your game from https://sirius.menu

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

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

-- Function to check for duplicate tabs
local function createUniqueTab(window, tabName, icon)
    for _, tab in pairs(window.Tabs) do
        if tab.Name == tabName then
            return tab -- Return the existing tab if found
        end
    end
    return window:CreateTab(tabName, icon) -- Create a new tab if not found
end

-- Webhook URL (default empty, to be set via UI)
local WEBHOOK_URL = ""

-- Settings Tab for Webhook Behavior
local SettingsTab = createUniqueTab(Window, "Settings", 4483362458)
local SettingsSection = SettingsTab:CreateSection("Webhook Settings")

SettingsTab:CreateInput({
    Name = "Set Webhook URL",
    PlaceholderText = "Enter your webhook URL",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
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

-- Function to send message to Discord Webhook
local function sendToWebhook(username, message, isPrivate)
    if WEBHOOK_URL == "" then
        warn("Webhook URL is not set. Please set it in the Settings tab.")
        return
    end

    local gameLink = "https://www.roblox.com/games/" .. game.PlaceId
    local jobId = game.JobId
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
        warn("Failed to send data to webhook: " .. err)
    end
end

-- Example of creating tabs without duplicates
local MainTab = createUniqueTab(Window, "Main", 4483362458)
local UpdatesTab = createUniqueTab(Window, "Updates", 4483362458)

-- Add other logic here (e.g., chat logging, update checking, etc.)
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

-- Updates Tab Content
UpdatesTab:CreateLabel("Version: 1.0.0")
UpdatesTab:CreateLabel("Last Updated: 2023-10-01")
UpdatesTab:CreateParagraph({
    Title = "Changelog",
    Content = "- Added webhook logging\n- Improved UI\n- Fixed minor bugs"
})

---- Close the Rayfield UI when the game is closed ----

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == Players.LocalPlayer then
        Rayfield:Destroy()
    end
end)
-- End of Logger.lua script
