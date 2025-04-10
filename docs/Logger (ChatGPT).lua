-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Variables
local webhookURL = ""
local isLogging = false
local logPrivateMessages = false
local avatarCache = {}
local embedSettings = {
    Title = "New Chat Message Logged",
    Color = 0x7289DA,
    Footer = "Roblox Chat Logger",
    Use12hTime = false
}
local loggingKey = "LogMe123"
local ExtraFeaturesUnlocked = false
-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Discord Chat Logger",
    LoadingTitle = "Logger Loading...",
    LoadingSubtitle = "by YourName",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local UIVisible = true
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.LeftShift then
        UIVisible = not UIVisible
        Rayfield.Visible = UIVisible
    end
end)

-- Tabs
local SettingsTab = Window:CreateTab("Settings", 4483345998)
local CustomTab = Window:CreateTab("Customization", 4483345998)
local MapTab = Window:CreateTab("Map View", 4483345998)
local UpdatesTab = Window:CreateTab("Updates", 4483345998)
local ExtraTab = Window:CreateTab("Extra Features (🔒)", 4483345998)

UpdatesTab:CreateParagraph({
    Title = "Update Log",
    Content = "- Added embed customization.\n- Added map view.\n- Extra features tab with key protection.\n- Full avatar, job ID, private toggle logging."
})
-- Webhook Input
local startLoggingToggle
SettingsTab:CreateInput({
    Name = "Enter Webhook URL",
    PlaceholderText = "Paste your webhook URL",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        webhookURL = value
        startLoggingToggle:SetDisabled(webhookURL == "" or not string.match(webhookURL, "^https://discord.com/api/webhooks/"))
    end
})

-- Private Chat Toggle
SettingsTab:CreateToggle({
    Name = "Enable Private Chat Logging (/w)",
    CurrentValue = false,
    Callback = function(state)
        logPrivateMessages = state
        sendWebhookStatus("Private Chat Logging Toggled", state and "Enabled" or "Disabled")
    end
})

-- Webhook Utility Buttons
SettingsTab:CreateButton({
    Name = "Clear Webhook URL",
    Callback = function()
        webhookURL = ""
        startLoggingToggle:SetDisabled(true)
    end
})

SettingsTab:CreateButton({
    Name = "Test Webhook",
    Callback = function()
        sendWebhookStatus("Webhook Test", "This is a test message.")
    end
})
-- Function to send requests
local requestFunc = syn and syn.request or http and http.request or request
local function sendRequest(data)
    if requestFunc then
        requestFunc(data)
    else
        warn("Executor doesn't support HTTP requests.")
    end
end

-- Get Avatar URL (cached)
local function getAvatar(userId)
    if not avatarCache[userId] then
        avatarCache[userId] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
    end
    return avatarCache[userId]
end

-- Webhook message for status updates
function sendWebhookStatus(title, description)
    if webhookURL == "" then return end

    local embed = {
        title = title,
        description = description,
        color = 0xFFFF00,
        footer = { text = "Logger Notification" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    local data = {
        username = "Logger Bot",
        embeds = { embed }
    }

    sendRequest({
        Url = webhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end
-- Chat Logging Function
local function logMessage(player, msg, isPrivate)
    if msg:match("^%s*$") then return end

    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    local timestamp = embedSettings.Use12hTime and os.date("%I:%M %p") or os.date("%H:%M:%S")
    local embed = {
        title = embedSettings.Title,
        color = embedSettings.Color,
        fields = {
            { name = "Username", value = player.Name, inline = true },
            { name = "User ID", value = tostring(player.UserId), inline = true },
            { name = "Game", value = info.Name, inline = false },
            { name = "Place ID", value = tostring(game.PlaceId), inline = true },
            { name = "Job ID", value = game.JobId or "Private Server", inline = true },
            { name = "Private:", value = tostring(isPrivate), inline = true },
            { name = "Message", value = msg, inline = false },
            { name = "Timestamp", value = timestamp, inline = false }
        },
        thumbnail = { url = getAvatar(player.UserId) },
        footer = { text = embedSettings.Footer }
    }

    local data = {
        username = "Chat Logger",
        embeds = { embed }
    }

    sendRequest({
        Url = webhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end

-- Hook to player chat
local function onPlayer(player)
    player.Chatted:Connect(function(msg)
        local isPrivate = string.sub(msg, 1, 2) == "/w"
        if isPrivate and not logPrivateMessages then return end
        logMessage(player, msg, isPrivate)
    end)
end

local function startChatLogging()
    for _, p in ipairs(Players:GetPlayers()) do
        onPlayer(p)
    end
    Players.PlayerAdded:Connect(onPlayer)
end
-- Start Logging Toggle
startLoggingToggle = SettingsTab:CreateToggle({
    Name = "Enable Chat Logging",
    CurrentValue = false,
    Disabled = true,
    Callback = function(state)
        isLogging = state
        if state then
            startChatLogging()
            sendWebhookStatus("Logging Started", "Private Logging: " .. tostring(logPrivateMessages))
        else
            sendWebhookStatus("Logging Stopped", "Chat logging has been turned off.")
        end
    end
})

-- Track when user (you) leave
local function trackLocalLeave()
    local player = Players.LocalPlayer
    game:BindToClose(function()
        sendWebhookStatus("User Disconnected", player.Name .. " has left, disconnected or timed out.")
    end)
end

trackLocalLeave()
local ExtraFeaturesUnlocked = false
local extraKey = "rblx-logger-key-2024" -- You can change this key

-- Lockable Extra Features Tab
local ExtraFeaturesTab = Window:CreateTab("🔒 Extra Features", 4483345998)
ExtraFeaturesTab:CreateInput({
    Name = "Enter Key to Unlock",
    PlaceholderText = "Enter feature access key...",
    RemoveTextAfterFocusLost = false,
    Callback = function(input)
        if input == extraKey then
            ExtraFeaturesUnlocked = true
            ExtraFeaturesTab:SetName("🛠️ Extra Features")
            Rayfield:Notify({
                Title = "Unlocked!",
                Content = "Extra Features are now available.",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Invalid Key",
                Content = "Please enter the correct access key.",
                Duration = 4
            })
        end
    end
})

-- Toggle: Log when user disconnects
ExtraFeaturesTab:CreateToggle({
    Name = "Log User Leave/Timeout/Disconnect",
    CurrentValue = false,
    Callback = function(state)
        logUserLeave = state
        Rayfield:Notify({
            Title = "Leave Logging",
            Content = "Feature is now " .. (state and "Enabled" or "Disabled"),
            Duration = 4
        })

        if state then
            game:BindToClose(function()
                sendWebhookStatus("Script User Left", Players.LocalPlayer.Name .. " has left or disconnected.")
            end)
        end
    end
})
local CustomizationTab = Window:CreateTab("🎨 Customization", 4483345998)

CustomizationTab:CreateInput({
    Name = "Set Embed Title",
    PlaceholderText = embedSettings.Title,
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        embedSettings.Title = text
    end
})

CustomizationTab:CreateInput({
    Name = "Set Embed Footer Text",
    PlaceholderText = embedSettings.Footer,
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        embedSettings.Footer = text
    end
})

CustomizationTab:CreateInput({
    Name = "Set Embed Color (Hex)",
    PlaceholderText = "Example: FF9900",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local hex = tonumber("0x" .. text)
        if hex then
            embedSettings.Color = hex
        else
            Rayfield:Notify({ Title = "Invalid Color", Content = "Please enter a valid hex code.", Duration = 3 })
        end
    end
})

CustomizationTab:CreateToggle({
    Name = "Use 12-Hour Timestamp",
    CurrentValue = embedSettings.Use12hTime,
    Callback = function(state)
        embedSettings.Use12hTime = state
    end
})
local MapTab = Window:CreateTab("🗺️ Map View", 4483345998)
MapTab:CreateParagraph({
    Title = "Live Player Coordinates",
    Content = "Player positions will display below..."
})

local coordParagraph = MapTab:CreateParagraph({
    Title = "Player Coordinates",
    Content = ""
})

-- Update coordinates in real-time
task.spawn(function()
    while true do
        local coordsText = ""
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                coordsText = coordsText .. string.format("%s: (%.1f, %.1f, %.1f)\n", player.Name, pos.X, pos.Y, pos.Z)
            end
        end
        coordParagraph:SetContent(coordsText ~= "" and coordsText or "No coordinates available.")
        wait(3)
    end
end)
