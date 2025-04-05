# Logger.lua
`logger.lua` is a lightweight and efficient logging utility designed for Lua-based projects. It provides developers with a simple way to log messages of varying severity levels (e.g., info, warning, error) to help with debugging and monitoring application behavior. This script is particularly useful for game development or other Lua-based applications where structured logging is essential.

## Usage Examples

Here are some examples of how the `logger.lua` script can be used in a game environment:

### Example 1: Info Log
```lua
Logger:Info("This is an informational message.")
```

### Example 2: Warning Log
```lua
Logger:Warn("This is a warning message.")
```

### Example 3: Error Log
```lua
Logger:Error("This is an error message.")
```

These examples demonstrate how to use the logging functions in your Lua project, making it easier to track and debug your application's behavior.

## Features
- **Customizable Log Levels**: Supports multiple log levels such as `INFO`, `WARN`, `ERROR`, and more.
- **Easy Integration**: Can be seamlessly integrated into any Lua project.
- **Readable Output**: Formats log messages for better readability.
- **Performance-Oriented**: Minimal performance overhead, making it suitable for real-time applications like games.

## How to Use
1. Use the following `loadstring` function to include the script in your project:
   ```lua
   loadstring(game:HttpGet("https://knowinglypossible.github.io/Best-Repository/logger.lua"))()
   ```
   This will automatically load and execute the `Logger.lua` script in your game environment.

2. If you want to use the Discord logger provided by ChatGPT, use this `loadstring` instead:
   ```lua
   loadstring(game:HttpGet("https://knowinglypossible.github.io/Best-Repository/Logger%20(ChatGPT).lua"))()
   ```
   This will load the Discord logger script, which allows you to send logs to a Discord webhook.

3. Start using the logging features provided by the script.

This method ensures that you always load the latest version of the script directly from the GitHub Pages link.
