-- Chat Logger with Discord Webhook and Rayfield UI

-- Load Rayfield UI
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    error("Failed to load Rayfield UI library. Please check the URL or your internet connection.")
end

-- Variables
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local WEBHOOK_URL = ""
local LogUserID = true
local LogGameID = true
local LogPrivateChats = true
local LogJobID = true
local EmbedColor = Color3.fromRGB(114, 137, 218) -- Default Discord blue
local ChatHistory = {}
local MapEnabled = true

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "Chat Logger with Webhook",
    LoadingTitle = "Chat Logger UI",
    LoadingSubtitle = "by ChatGPT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ChatLogger",
        FileName = "Config"
    },
    KeySystem = false
})

-- Function to send message to Discord Webhook
local function sendToWebhook(username, message, isPrivate, position)
    if WEBHOOK_URL == "" then
        warn("Webhook URL is not set.")
        return
    end

    local embed = {
        ["title"] = "New Chat Message",
        ["description"] = "**Message:** " .. message,
        ["color"] = tonumber(EmbedColor:ToHex(), 16),
        ["fields"] = {}
    }

    if LogUserID then
        table.insert(embed.fields, { ["name"] = "User ID", ["value"] = tostring(Players:GetUserIdFromNameAsync(username)), ["inline"] = true })
    end

    if LogGameID then
        table.insert(embed.fields, { ["name"] = "Game Link", ["value"] = "https://www.roblox.com/games/" .. game.PlaceId, ["inline"] = true })
    end

    if LogJobID then
        table.insert(embed.fields, { ["name"] = "Job ID", ["value"] = game.JobId, ["inline"] = true })
    end

    if position then
        table.insert(embed.fields, { ["name"] = "Position", ["value"] = string.format("X: %.2f, Y: %.2f, Z: %.2f", position.X, position.Y, position.Z), ["inline"] = true })
    end

    local data = {
        ["embeds"] = { embed }
    }

    local jsonData = HttpService:JSONEncode(data)
    local success, err = pcall(function()
        syn.request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = jsonData
        })
    end)

    if not success then
        warn("Failed to send webhook: " .. tostring(err))
    end
end

-- Webhook Tester & Customization Tab
local WebhookTab = Window:CreateTab("Webhook Tester & Customization", 4483362458)
WebhookTab:CreateInput({
    Name = "Set Webhook URL",
    PlaceholderText = "Enter your webhook URL",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        WEBHOOK_URL = Value
    end
})

WebhookTab:CreateToggle({
    Name = "Log User ID",
    CurrentValue = true,
    Callback = function(Value)
        LogUserID = Value
    end
})

WebhookTab:CreateToggle({
    Name = "Log Game ID/Game Link",
    CurrentValue = true,
    Callback = function(Value)
        LogGameID = Value
    end
})

WebhookTab:CreateToggle({
    Name = "Log Private Chats",
    CurrentValue = true,
    Callback = function(Value)
        LogPrivateChats = Value
    end
})

WebhookTab:CreateToggle({
    Name = "Log Job ID",
    CurrentValue = true,
    Callback = function(Value)
        LogJobID = Value
    end
})

WebhookTab:CreateColorPicker({
    Name = "Embed Color",
    Default = EmbedColor,
    Callback = function(Value)
        EmbedColor = Value
    end
})

WebhookTab:CreateButton({
    Name = "Send Test Webhook",
    Callback = function()
        sendToWebhook("TestUser", "This is a test message.", false)
    end
})

-- Chat History Tab
local ChatHistoryTab = Window:CreateTab("Chat History", 4483362458)
local ChatHistoryParagraph = ChatHistoryTab:CreateParagraph({
    Title = "Chat History",
    Content = "No messages yet."
})

local function updateChatHistory()
    local content = table.concat(ChatHistory, "\n")
    ChatHistoryParagraph:Set({
        Title = "Chat History",
        Content = content
    })
end

-- Map Tab
local MapTab = Window:CreateTab("Map", 4483362458)
MapTab:CreateToggle({
    Name = "Enable Map",
    CurrentValue = true,
    Callback = function(Value)
        MapEnabled = Value
    end
})

-- Function to log chat messages
local function onPlayerChatted(player, message, recipient)
    local isPrivate = recipient ~= nil
    if not LogPrivateChats and isPrivate then
        return
    end

    local position = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or nil
    table.insert(ChatHistory, string.format("[%s] %s: %s", isPrivate and "Private" or "Public", player.Name, message))
    if #ChatHistory > 50 then
        table.remove(ChatHistory, 1)
    end
    updateChatHistory()
    sendToWebhook(player.Name, message, isPrivate, position)
end

-- Connect chat events
for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(message, recipient)
        onPlayerChatted(player, message, recipient)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message, recipient)
        onPlayerChatted(player, message, recipient)
    end)
end)

-- Initialize Rayfield UI
Rayfield:LoadConfiguration()