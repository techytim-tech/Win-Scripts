# Windows Package & Terminals Installer

**Author:** TechyTim  
**Version:** 1.0  
**Last Updated:** November 24, 2025

## Overview

`win-package-and-terminals-installer.ps1` is a comprehensive PowerShell script that simplifies the installation and management of popular package managers and terminal emulators on Windows. It provides a beautiful, interactive menu-driven interface with Microsoft brand colors for an elegant user experience.

## Features

✨ **Key Features:**
- 🎯 **Interactive menu system** - Beautiful TUI with color-coded options
- 🏢 **Microsoft branding** - Uses official Microsoft brand colors throughout
- 📦 **Package Manager Support** - Install/manage Winget, Chocolatey, Scoop, and UniGetUI
- 💻 **Terminal Emulator Support** - Install popular terminals: Alacritty, WezTerm, Windows Terminal, Warp
- 🔍 **Auto-detection** - Automatically detects installed package managers and terminals
- 🎨 **Rich UI** - Unicode box-drawing characters, status indicators, color-coded messages
- ⚡ **Smart installation** - Uses available package managers intelligently
- 📊 **Status display** - Shows which tools are already installed
- 🔧 **Environment integration** - Updates PATH and system environment
- 🛡️ **Safe execution** - Proper error handling and user confirmations

## System Requirements

- **OS:** Windows 10 or Windows 11
- **PowerShell:** 5.1+ or PowerShell 7.x
- **Network:** Internet connection (for downloading packages)
- **Permissions:** Administrator privileges required for package installation

## Installation

1. **Download the script** from the Win-Scripts repository:
   ```powershell
   git clone https://github.com/techytim-tech/Win-Scripts.git
   cd Win-Scripts
   ```

2. **Run with bypass execution policy**:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File win-package-and-terminals-installer.ps1
   ```

3. **Or enable execution policy**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   & '.\win-package-and-terminals-installer.ps1'
   ```

## Usage

When you run the script, you'll see the main menu with beautiful Microsoft-branded styling:

```
╔════════════════════════════════════════════════════╗
║   Windows Package Manager Installer                ║
╚════════════════════════════════════════════════════╝
```

### Main Menu Options

The script provides access to:

1. **Package Managers** - View and manage package management tools
2. **Terminals** - View and manage terminal emulators
3. **Information** - Get system information and status
4. **Settings** - Configure script behavior
5. **Exit** - Close the application

### Package Managers

#### Supported Package Managers

##### 1. Winget (Microsoft)
- **Description:** Microsoft's official Windows Package Manager
- **Status Indicator:** Shows `[+]` if installed
- **Admin Required:** Yes (for some installations)
- **Best For:** Users who want official Windows support

**How to Install:**
- Available by default on Windows 11
- Can be installed via Microsoft Store on Windows 10
- Or via `Get-AppxPackage -name "DesktopAppInstaller"` | ForEach-Object {Add-AppxPackage -AppxBundle $_.InstallLocation\AppxBundleManifest.xml -ForceApplicationShutdown}

##### 2. Chocolatey
- **Description:** The classic package manager for Windows (ChocoPM)
- **Status Indicator:** Shows `[+]` if installed
- **Admin Required:** Yes
- **Best For:** Developers who need traditional package management

**Features:**
- Huge package repository (5000+ packages)
- Scripted installations with custom logic
- Supports creating custom packages

##### 3. Scoop
- **Description:** Lightweight command-line installer (no admin required)
- **Status Indicator:** Shows `[+]` if installed
- **Admin Required:** No (single-user installation)
- **Best For:** Users without admin rights or portable installations

**Features:**
- No admin rights needed
- Installs to user directory
- Great for development tools
- Minimal system impact

##### 4. UniGetUI
- **Description:** Beautiful GUI for managing all package managers
- **Status Indicator:** Shows `[+]` if installed
- **Admin Required:** Depends on underlying PM
- **Best For:** Users who prefer graphical interfaces

**Features:**
- Visual interface for Winget/Scoop/Chocolatey
- See installed/available packages at a glance
- One-click install/update/remove
- Search functionality

### Terminals

#### Supported Terminal Emulators

##### 1. Alacritty
- **Description:** Fast, cross-platform, OpenGL terminal emulator
- **Installation:** Via Winget
- **Requires:** Rust for development, or pre-built binary
- **Best For:** Performance-focused users

**Features:**
- GPU-accelerated rendering
- Minimal latency
- Simple YAML configuration
- Cross-platform (Windows, macOS, Linux)

##### 2. WezTerm ⭐ (Recommended)
- **Description:** GPU-accelerated terminal written in Rust
- **Installation:** Via Winget/Chocolatey
- **Best For:** Feature-rich terminal with modern capabilities

**Features:**
- Lua-based configuration
- Multiplexing and panes
- Modern color support
- Tab management
- See companion script: `Wezterm-Config-for-Win.ps1`

##### 3. Windows Terminal
- **Description:** Modern Microsoft terminal with tabs and panes
- **Installation:** Via Winget/Microsoft Store
- **Best For:** Users wanting Microsoft's latest terminal

**Features:**
- Official Microsoft support
- Integrated with Windows 11
- Modern UI
- Multiple tab and pane support
- JSON configuration

##### 4. Warp
- **Description:** Modern Rust-based terminal with AI features
- **Installation:** Via Winget
- **Requires:** Internet for some features
- **Best For:** Users wanting cutting-edge features

**Features:**
- AI-powered command suggestions
- Modern interface
- Command palette
- Built-in collaboration features

### Installation Process

1. **Select Package Manager or Terminal** from the menu
2. **View Details** - See description and installation options
3. **Install** - Choose to install (or uninstall if present)
4. **Confirm** - Approve installation with administrator prompts
5. **Status Update** - See immediate confirmation of installation
6. **Return to Menu** - Continue with other selections

### Status Indicators

- `[+]` - Package is installed and ready
- `   ` - Package is not installed
- `[OK]` - Operation successful
- `[X]` - Error occurred
- `[!]` - Warning message
- `[i]` - Information message

## Color Scheme

The script uses Microsoft brand colors throughout:

| Color | RGB | Usage |
|-------|-----|-------|
| Microsoft Blue | 0, 120, 215 | Headers, titles, primary UI |
| Light Blue | 80, 160, 240 | Secondary UI elements |
| Green | 16, 124, 16 | Success messages, installed items |
| Red | 232, 17, 35 | Errors, critical information |
| Yellow | 255, 185, 0 | Warnings, attention-needed items |
| Orange | 247, 99, 12 | Special operations, featured items |
| Cyan | 0, 183, 195 | Status indicators, secondary actions |
| White/Gray | Various | Text and contrast |

## Auto-Detection

The script automatically detects:

- **Installed Package Managers:**
  - Winget (via PATH, command lookup, or AppxPackage)
  - Chocolatey (via choco command)
  - Scoop (via scoop command)
  - PowerShell 7 (via pwsh command or installation paths)

- **Installed Terminals:**
  - Alacritty
  - WezTerm
  - Windows Terminal
  - Warp

- **System Information:**
  - OS version
  - PowerShell version
  - Available package managers
  - Network connectivity

## Workflow Examples

### Scenario 1: Complete New Setup

1. **Install Winget** (if not already installed)
   - Script detects it's not installed
   - Offers installation path
   - Confirms after installation

2. **Install Package Manager**
   - Choose Chocolatey or Scoop
   - Script uses Winget to install the chosen PM

3. **Install Terminals**
   - Select Windows Terminal or WezTerm
   - Install via available package manager

### Scenario 2: Upgrade Terminal

1. Select a terminal from the Terminals menu
2. Script checks if it's installed
3. If installed, offers upgrade option
4. Updates via package manager with latest version

### Scenario 3: View System Status

1. Open Information menu
2. See:
   - Installed package managers
   - Installed terminals
   - PowerShell version
   - System information

## Troubleshooting

### "Package Manager Not Found"
- **Issue:** Neither Winget nor Chocolatey is installed
- **Solution:** 
  1. Run the script with administrator privileges
  2. Install Winget first (usually available on Windows 11)
  3. Or install Chocolatey from https://chocolatey.org/install

### "Admin Rights Required"
- **Issue:** Script shows error about administrator permissions
- **Solution:**
  1. Right-click PowerShell → "Run as Administrator"
  2. Run the installation script again
  3. For Scoop, no admin rights are required

### Installation Hangs
- **Issue:** Package installation appears to freeze
- **Solution:**
  1. Wait 30+ seconds (sometimes network is slow)
  2. Press Ctrl+C to cancel
  3. Check internet connection
  4. Try installing via Winget directly:
     ```powershell
     winget install PackageName
     ```

### "Package Already Installed"
- **Issue:** Script shows package is already installed
- **Action:** 
  1. Script will offer to uninstall/reinstall
  2. Choose update if available
  3. Or use the package manager's update command

### Terminal Won't Launch
- **Issue:** Terminal launches but shows error
- **Solution:**
  - Check if dependencies are installed
  - For terminals, ensure PATH is updated (may need restart)
  - Check terminal's configuration file

## Script Functions Reference

### Display Functions

- **`print_header($Text)`** - Displays header with borders
- **`print_section($Text)`** - Displays section dividers
- **`print_status($Text)`** - Status message (cyan >)
- **`print_success($Text)`** - Success message (green [OK])
- **`print_error($Text)`** - Error message (red [X])
- **`print_warning($Text)`** - Warning message (yellow [!])
- **`print_info($Text)`** - Info message (cyan [i])

### Menu Functions

- **`Show-PackageManagers`** - Main package manager menu
- **`Show-Terminals`** - Main terminals menu
- **`Show-PMDetails($id)`** - Details for specific package manager
- **`Show-TerminalDetails($id)`** - Details for specific terminal

### Utility Functions

- **`Get-SingleKey`** - Get single key press without Enter
- **`Get-IsPMInstalled($id)`** - Check if package manager is installed
- **`Install-PackageManager($id)`** - Install specific package manager
- **`Install-Terminal($id)`** - Install specific terminal
- **`Uninstall-PackageManager($id)`** - Remove package manager

## Advanced Usage

### Installing Specific Package Versions

After installation, you can use the package managers directly:

```powershell
# Winget - specific version
winget install --id OpenJS.NodeJS --version 18.0.0

# Chocolatey - specific version
choco install nodejs --version=18.0.0

# Scoop - specific version
scoop install nodejs@18.0.0
```

### Creating Custom Installation Scripts

```powershell
# Install multiple packages
$packages = @("git", "nodejs", "python", "vscode")
foreach ($package in $packages) {
    winget install --id $package
}
```

## Contributing

Found a bug or want to add a new terminal? Please open an issue or pull request on the [GitHub repository](https://github.com/techytim-tech/Win-Scripts).

## Known Limitations

- Winget may not be available on older Windows 10 versions
- Scoop requires Git to be pre-installed in some cases
- Some terminals may have additional dependencies not automatically installed
- Network access is required for downloading packages

## Related Scripts

- **`Wezterm-Config-for-Win.ps1`** - Comprehensive WezTerm configuration tool
  - See [Wezterm-Config-for-Win.md](Wezterm-Config-for-Win.md) for details

## License

This script is provided as-is for educational and personal use.

## Support

For issues with specific package managers or terminals:
- **Winget:** https://github.com/microsoft/winget-cli
- **Chocolatey:** https://chocolatey.org/
- **Scoop:** https://scoop.sh/
- **WezTerm:** https://wezfurlong.org/wezterm/
- **Windows Terminal:** https://github.com/microsoft/terminal
- **Alacritty:** https://github.com/alacritty/alacritty
- **Warp:** https://www.warp.dev/

For issues with this script, please check the repository or create an issue.
