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
    LoadingSubtitle = "by Carlos277415",
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

-- Message History Table
local messageHistory = {}
local analytics = { total = 0, private = 0, public = 0 }
local excludedPlayers = {}
local keywordFilter = {}

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
        ["content"] = "", -- Leave this empty for embeds
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
    else
        print("Webhook message sent successfully.")
    end
end

-- Main Tab
local MainTab = Window:CreateTab("Main", ICON_ID)
MainTab:CreateLabel("Welcome to Chat Logger!")
MainTab:CreateParagraph({
    Title = "Instructions",
    Content = "Use the Settings tab to configure the webhook URL and enable logging. Chat messages will be logged and sent to the configured webhook."
})

-- Message History Section
local messageHistoryParagraph = MainTab:CreateParagraph({
    Title = "Message History",
    Content = "No messages yet..."
})

-- Real-Time Analytics Section
local analyticsParagraph = MainTab:CreateParagraph({
    Title = "Real-Time Analytics",
    Content = "Messages Logged: 0\nPrivate Messages: 0\nPublic Messages: 0"
})

local function updateAnalytics(isPrivate)
    analytics.total = analytics.total + 1
    if isPrivate then
        analytics.private = analytics.private + 1
    else
        analytics.public = analytics.public + 1
    end
    analyticsParagraph:Set({
        Title = "Real-Time Analytics",
        Content = string.format("Messages Logged: %d\nPrivate Messages: %d\nPublic Messages: %d", analytics.total, analytics.private, analytics.public)
    })
end

-- Function to update the message history in the UI
local function updateMessageHistory()
    local content = ""
    for _, msg in ipairs(messageHistory) do
        content = content .. msg .. "\n"
    end
    messageHistoryParagraph:Set({
        Title = "Message History",
        Content = content
    })
end

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

SettingsTab:CreateInput({
    Name = "Set Keyword Filter",
    PlaceholderText = "Enter keywords separated by commas",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        keywordFilter = {}
        for keyword in Value:gmatch("[^,]+") do
            table.insert(keywordFilter, keyword:lower():gsub("^%s*(.-)%s*$", "%1")) -- Trim and lowercase
        end
        Rayfield:Notify({
            Title = "Keyword Filter Updated",
            Content = "Messages containing specified keywords will now be logged.",
            Duration = 5
        })
    end
})

SettingsTab:CreateInput({
    Name = "Exclude Player from Logging",
    PlaceholderText = "Enter player name",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        table.insert(excludedPlayers, Value)
        Rayfield:Notify({
            Title = "Player Excluded",
            Content = Value .. " will no longer be logged.",
            Duration = 5
        })
    end
})

SettingsTab:CreateButton({
    Name = "Export Chat History",
    Callback = function()
        local fileName = "ChatHistory_" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".txt"
        local fileContent = table.concat(messageHistory, "\n")
        writefile(fileName, fileContent)
        Rayfield:Notify({
            Title = "Export Successful",
            Content = "Chat history has been exported to " .. fileName,
            Duration = 5
        })
    end
})

SettingsTab:CreateButton({
    Name = "Test Webhook",
    Callback = function()
        if WEBHOOK_URL == "" or not WEBHOOK_URL:match("^https?://") then
            Rayfield:Notify({
                Title = "Invalid Webhook URL",
                Content = "Please set a valid webhook URL first.",
                Duration = 5
            })
            return
        end

        -- Send a test message to the webhook
        sendToWebhook("TestUser", "This is a test message from Chat Logger.", false)

        Rayfield:Notify({
            Title = "Webhook Test Sent",
            Content = "A test message has been sent to the webhook.",
            Duration = 5
        })
    end
})

-- Chat Logging Functionality
local function onPlayerChatted(player, message, recipient)
    if not _G.WebhookLoggingEnabled then
        return
    end

    if table.find(excludedPlayers, player.Name) then
        return
    end

    local isPrivate = recipient ~= nil
    local chatType = isPrivate and "[Private]" or "[Public]"

    -- Check for keyword filter
    local shouldLog = #keywordFilter == 0
    for _, keyword in ipairs(keywordFilter) do
        if message:lower():find(keyword) then
            shouldLog = true
            break
        end
    end

    if not shouldLog then
        return
    end

    sendToWebhook(player.Name, message, isPrivate)

    -- Add message to history
    table.insert(messageHistory, string.format("%s %s: %s", chatType, player.Name, message))

    -- Limit history to the last 50 messages
    if #messageHistory > 50 then
        table.remove(messageHistory, 1)
    end

    -- Update the UI
    updateMessageHistory()
    updateAnalytics(isPrivate)
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
