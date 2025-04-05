# Logger.lua

`logger.lua` is a lightweight and efficient logging utility designed for Lua-based projects. It provides developers with a simple way to log messages of varying severity levels (e.g., info, warning, error) to help with debugging and monitoring application behavior. This script is particularly useful for game development or other Lua-based applications where structured logging is essential.

## Features
- **Customizable Log Levels**: Supports multiple log levels such as `INFO`, `WARN`, `ERROR`, and more.
- **Easy Integration**: Can be seamlessly integrated into any Lua project.
- **Readable Output**: Formats log messages for better readability.
- **Performance-Oriented**: Minimal performance overhead, making it suitable for real-time applications like games.

## How to Use
1. Download the raw file using the link below.
2. Include the `logger.lua` file in your Lua project.
3. Require the logger module in your script and start logging messages.

Make sure to replace the `https://raw.githubusercontent.com/your-repository/logger.lua/main/logger.lua` link with the actual URL of your [logger.lua](http://_vscodecontentref_/1) file. This will allow users to directly download the file for their projects.

### Example Usage
```lua
-- Require the logger module
local logger = require("logger")

-- Log messages
logger.info("This is an informational message.")
logger.warn("This is a warning message.")
logger.error("This is an error message.")