-- Chat Logger for Roblox Executor
-- Ensure your executor supports `syn.request` or `http_request`

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Webhook URL (set locally to avoid global exposure)
local WEBHOOK_URL = ""
local WebhookLoggingEnabled = true
local ExcludedPlayers = {}
local KeywordFilter = {}

-- Message History Table
local messageHistory = {}
local analytics = { total = 0, private = 0, public = 0 }
local lastMessageTime = 0 -- For rate limiting

-- Load Rayfield UI
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    error("Failed to load Rayfield UI library. Please check the URL or your internet connection.")
end

-- Create the main Rayfield window
local Window = Rayfield:CreateWindow({
    Name = "Chat Logger (Discontinued)",
    LoadingTitle = "Chat Logger UI",
    LoadingSubtitle = "by Carlos277415",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ChatLogger",
        FileName = "Config"
    },
    KeySystem = false
})

-- Discontinued Tab
local DiscontinuedTab = Window:CreateTab("Discontinued", book-check)
DiscontinuedTab:CreateParagraph({
    Title = "Script Discontinued",
    Content = "This script has been discontinued. Please use the updated Logger (ChatGPT).lua file instead."
})

DiscontinuedTab:CreateButton({
    Name = "Launch Logger (ChatGPT)",
    Callback = function()
        loadstring(game:HttpGet("https://knowinglypossible.github.io/Best-Repository/Logger%20(ChatGPT).lua"))()
    end
})

-- Initialize Rayfield UI
Rayfield:LoadConfiguration()
