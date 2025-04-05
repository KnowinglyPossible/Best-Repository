-- Chat Logger for Roblox Executor (Discontinued)

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
local DiscontinuedTab = Window:CreateTab("Discontinued", "book-x")
DiscontinuedTab:CreateParagraph({
    Title = "Script Discontinued",
    Content = "This script has been discontinued. It will close in 3 seconds."
})

-- Notify the user and close the script after 3 seconds
Rayfield:Notify({
    Title = "Script Discontinued",
    Content = "This script will close in 3 seconds.",
    Duration = 3
})

-- Close the script after 3 seconds
task.delay(3, function()
    game:Shutdown()
end)

-- Initialize Rayfield UI
Rayfield:LoadConfiguration()
