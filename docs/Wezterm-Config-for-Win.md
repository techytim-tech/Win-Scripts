# Wezterm Config for Windows

**Author:** TechyTim  
**Version:** 1.0  
**Last Updated:** November 24, 2025

## Overview

`Wezterm-Config-for-Win.Ps1` is a comprehensive PowerShell script that automates the installation and configuration of [WezTerm](https://wezfurlong.org/wezterm/) on Windows systems. It provides a user-friendly menu-driven interface for managing WezTerm installations and creating customized terminal configurations.

## Features

✨ **Key Features:**
- 🎯 **Menu-driven interface** - Easy navigation with 4 main options
- 🎨 **Microsoft-branded UI** - Beautiful colored logo and themed borders using Microsoft brand colors
- 📦 **Smart package management** - Automatically detects and uses winget or Chocolatey
- 🖥️ **64-bit optimization** - Automatically detects and relaunches in 64-bit PowerShell when needed
- 🎭 **Theme support** - Choose from 5 color themes for your terminal
- 🔤 **Font selection** - Choose from Microsoft's built-in fonts (Cascadia Code, Consolas, Courier New)
- 💻 **Shell selection** - Select between PowerShell 7, PowerShell 6, or cmd.exe
- 📐 **Automatic sizing** - Configures WezTerm to display at optimal window size (40 rows × 120 columns)
- 💾 **Config backup** - Automatically backs up existing configurations before making changes
- 🔐 **Safe execution** - Uses `Start-Process` with proper error handling

## System Requirements

- **OS:** Windows 10 or Windows 11
- **PowerShell:** 5.1+ or PowerShell 7.x
- **Network:** Internet connection (for downloading WezTerm via package manager)
- **Permissions:** Administrator privileges recommended for installation

## Installation

1. **Clone or download** the script to your local machine:
   ```powershell
   git clone https://github.com/techytim-tech/Win-Scripts.git
   cd Win-Scripts
   ```

2. **Run the script** with appropriate execution policy:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File Wezterm-Config-for-Win.Ps1
   ```

3. **Or allow execution** in your profile:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   & '.\Wezterm-Config-for-Win.Ps1'
   ```

## Usage

When you run the script, you'll be presented with a main menu:

```
╔══════════════════════════════════════════════════════╗
║ Main Menu                                            ║
╠══════════════════════════════════════════════════════╣
║ 1) Install WezTerm for Windows                       ║
║ 2) Config Setup                                      ║
║ 3) Remove / Uninstall WezTerm and Config             ║
║ 4) Exit                                              ║
╚══════════════════════════════════════════════════════╝
```

### Option 1: Install WezTerm for Windows

Installs the latest version of WezTerm using your system's available package manager.

**Process:**
1. Checks if WezTerm is already installed
2. Attempts installation via winget (recommended) or Chocolatey
3. Displays success/failure messages
4. Waits for user confirmation before returning to menu

**Requirements:**
- Administrator access (for actual package installation)
- Either winget or Chocolatey must be installed

### Option 2: Config Setup

Creates or updates your WezTerm configuration file (`~/.wezterm.lua`) with customized settings.

**Configuration Steps:**

#### Step 1: Choose Your Theme (5 options)
- **Windows Blue** (default) - Microsoft-inspired blue color scheme
- **Catppuccin Mocha** - Dark, modern theme
- **Catppuccin Latte** - Light, elegant theme
- **Dracula** - Dark vampire-inspired theme
- **Gruvbox Dark** - Retro groove color scheme

#### Step 2: Choose Your Font (3 options)
- **Cascadia Code** (recommended) - Modern Microsoft font with excellent rendering
- **Consolas** - Classic Windows monospace font
- **Courier New** - Universal fallback font

#### Step 3: Choose Your Shell (3 options)
- **PowerShell 7** (recommended) - Modern, cross-platform PowerShell
  - If not installed, script will offer to download and install it
  - Uses fast startup with `-NoProfile` flag
- **PowerShell 6** - Legacy PowerShell version
- **cmd.exe** - Classic Windows Command Prompt

#### Step 4: Title Bar Option
- Choose whether to display Windows title bar (`y/N`)
- Affects window decoration settings

#### Step 5: Review & Open
- Script displays all your selections
- Offers to open the generated config in Notepad
- Configuration is automatically saved to `~/.wezterm.lua`

**Config Features:**
- Window size: 40 rows × 120 columns
- Font size: 13.0
- Line height: 1.15
- Fancy tab bar with auto-hide for single tabs
- Blinking block cursor at 600ms rate
- CTRL+A as leader key for custom keybindings
- Pane navigation with h/j/k/l (Vim-style)
- Tab splitting and management

### Option 3: Remove / Uninstall WezTerm and Config

Uninstalls WezTerm and removes all configuration files.

**Process:**
1. Asks for confirmation
2. Attempts uninstall via winget or Chocolatey
3. Backs up existing config file with timestamp
4. Removes config from user profile

### Option 4: Exit

Closes the script cleanly.

## Configuration File Location

The WezTerm configuration file is stored at:
```
~/.wezterm.lua
```

Or in full Windows path:
```
C:\Users\<YourUsername>\.wezterm.lua
```

## Available Keybindings

The script generates a WezTerm config with these default keybindings:

| Key | Action |
|-----|--------|
| `CTRL+A` | Leader key (press then use other keys) |
| `Leader -` | Split pane vertically |
| `Leader \|` | Split pane horizontally |
| `Leader h` | Navigate left pane |
| `Leader j` | Navigate down pane |
| `Leader k` | Navigate up pane |
| `Leader l` | Navigate right pane |
| `Leader c` | Create new tab |
| `Leader 1-9` | Jump to tab 1-9 |

## Troubleshooting

### WezTerm Won't Launch
- **Solution:** Ensure your shell is installed. If using PowerShell 7, run the Config Setup and select it again to trigger installation.
- **Fallback:** Switch to cmd.exe in Config Setup if PowerShell isn't working.

### 64-bit Process Warning
- **Issue:** Script detects you're running 32-bit PowerShell
- **Action:** Script automatically relaunches in 64-bit PowerShell
- **Note:** You may need to approve the new window launch

### Package Manager Not Found
- **Issue:** Neither winget nor Chocolatey is installed
- **Solution:** Install one of them first, or install WezTerm manually from https://wezfurlong.org/wezterm/

### Font Looks Wrong
- **Solution:** Ensure your selected font is installed on your system
  - Cascadia Code is available in Windows 10 Build 1903+ or via winget
  - Consolas is built-in on all Windows versions
  - Courier New is a universal Windows font

## Script Functions Reference

### Core Functions

**`Show-Logo`**
- Displays the Microsoft-branded 4-pane colored logo

**`Start-64BitProcess`**
- Detects if running in 32-bit PowerShell
- Automatically relaunches in 64-bit if available
- Sets environment guard variable to prevent loops

**`Install-Wezterm`**
- Handles WezTerm installation via package managers
- Uses Start-Process for safe execution
- Provides user feedback at each step

**`Set-WeztermConfig`**
- Main configuration workflow
- Prompts user for all preferences
- Generates and writes Lua config file
- Backs up existing configs

**`Uninstall-Wezterm`**
- Removes WezTerm binary
- Backs up and removes config file
- Confirms user intent before proceeding

**`Show-Menu`**
- Displays the themed menu interface
- Uses Unicode box-drawing characters
- Shows all available options

**`Backup-File`**
- Creates timestamped backups
- Format: `filename.bak.YYYYMMDD_HHMMSS`

**`Wait-AnyKey`**
- Pauses for user interaction
- Approved PowerShell verb

## Advanced Configuration

After running the script, you can manually edit `~/.wezterm.lua` to add advanced features:

```lua
-- Example: Custom color scheme
config.colors = {
  foreground = "#ffffff",
  background = "#0078D7",
  -- ... more colors
}

-- Example: Disable tab bar
config.use_fancy_tab_bar = false

-- Example: Custom font sizes for different monitors
if wezterm.target_triple:match("windows") then
  config.font_size = 11.0
end
```

See [WezTerm Documentation](https://wezfurlong.org/wezterm/config/) for all available options.

## Known Limitations

- PowerShell 7 auto-install only works with winget or Chocolatey available
- Config backup only backs up the config file itself (not terminal state)
- 64-bit relaunch may not work in all PowerShell environments

## Contributing

Found a bug or have a suggestion? Please open an issue on the [GitHub repository](https://github.com/techytim-tech/Win-Scripts).

## License

This script is provided as-is for educational and personal use.

## Support

For issues with WezTerm itself, see the official documentation: https://wezfurlong.org/wezterm/

For issues with this script, please check the repository issues or create a new one.
