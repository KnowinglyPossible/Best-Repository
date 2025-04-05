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

-- Function to validate webhook URL
local function isValidWebhookURL(url)
    return url:match("^https?://")
end

-- Function to send message to Discord Webhook
local function sendToWebhook(username, message, isPrivate)
    if WEBHOOK_URL == "" or not isValidWebhookURL(WEBHOOK_URL) then
        warn("Invalid or empty Webhook URL. Please set it in the Settings tab.")
        return
    end

    -- Rate limiting: Ensure at least 1 second between messages
    local currentTime = os.time()
    if currentTime - lastMessageTime < 1 then
        warn("Rate limit exceeded. Please wait before sending another message.")
        return
    end
    lastMessageTime = currentTime

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
    local response = syn.request or http_request or request -- Use executor's HTTP request API
    local success, err = pcall(function()
        response({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = jsonData
        })
    end)

    if not success then
        warn("Failed to send data to webhook: " .. tostring(err))
    else
        print("Webhook message sent successfully.")
    end
end

-- Function to log chat messages
local function onPlayerChatted(player, message, recipient)
    if not WebhookLoggingEnabled then
        return
    end

    if table.find(ExcludedPlayers, player.Name) then
        return
    end

    local isPrivate = recipient ~= nil
    local chatType = isPrivate and "[Private]" or "[Public]"

    -- Check for keyword filter
    local shouldLog = #KeywordFilter == 0
    for _, keyword in ipairs(KeywordFilter) do
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

    -- Update analytics
    analytics.total = analytics.total + 1
    if isPrivate then
        analytics.private = analytics.private + 1
    else
        analytics.public = analytics.public + 1
    end
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

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)
MainTab:CreateLabel("Welcome to Chat Logger!")

MainTab:CreateInput({
    Name = "Set Webhook URL",
    PlaceholderText = "Enter your webhook URL",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        if isValidWebhookURL(Value) then
            WEBHOOK_URL = Value
            Rayfield:Notify({
                Title = "Webhook URL Updated",
                Content = "The webhook URL has been updated successfully.",
                Duration = 5
            })
        else
            Rayfield:Notify({
                Title = "Invalid Webhook URL",
                Content = "Please enter a valid webhook URL.",
                Duration = 5
            })
        end
    end
})

MainTab:CreateToggle({
    Name = "Enable Webhook Logging",
    CurrentValue = true,
    Flag = "EnableWebhookLogging",
    Callback = function(Value)
        WebhookLoggingEnabled = Value
    end
})

MainTab:CreateInput({
    Name = "Set Keyword Filter",
    PlaceholderText = "Enter keywords separated by commas",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        KeywordFilter = {}
        for keyword in Value:gmatch("[^,]+") do
            table.insert(KeywordFilter, keyword:lower():gsub("^%s*(.-)%s*$", "%1")) -- Trim and lowercase
        end
        Rayfield:Notify({
            Title = "Keyword Filter Updated",
            Content = "Messages containing specified keywords will now be logged.",
            Duration = 5
        })
    end
})

MainTab:CreateInput({
    Name = "Exclude Player from Logging",
    PlaceholderText = "Enter player name",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        table.insert(ExcludedPlayers, Value)
        Rayfield:Notify({
            Title = "Player Excluded",
            Content = Value .. " will no longer be logged.",
            Duration = 5
        })
    end
})

MainTab:CreateButton({
    Name = "Test Webhook",
    Callback = function()
        sendToWebhook("TestUser", "This is a test message from Chat Logger.", false)
    end
})

MainTab:CreateButton({
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

-- Initialize Rayfield UI
Rayfield:LoadConfiguration()
