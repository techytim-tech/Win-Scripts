# PowerShell Profile Installer - Documentation

## Overview

The PowerShell Profile Installer is an automated script that sets up a custom PowerShell profile with enhanced visual features, personalized greetings, and a colorful command prompt. It works across Windows 10 and Windows 11 with PowerShell 6 and 7.

## Features

### Custom Profile Features
- ✨ **Personalized Greeting Box** - Displays a stylized welcome message with:
  - Time-based greetings (Good Morning/Afternoon/Evening)
  - Current hostname
  - Current directory
  - Current date and time
  - Beautiful box-drawing characters

- 🎨 **Custom Colored Prompt** - Enhanced command prompt showing:
  - Username (Green)
  - Hostname (Yellow)
  - Current path (Cyan)
  - Git branch when in a repository (Magenta)
  - Format: `username@hostname:path (git_branch)>`

- 🔧 **Automatic Shortcut Configuration** - Optionally updates PowerShell shortcuts to use `-NoLogo` flag

### Installer Features
- 🔍 **Auto-Detection** - Automatically finds all installed PowerShell versions
- 💾 **Automatic Backups** - Creates timestamped backups of existing profiles
- 📁 **Directory Creation** - Creates profile directories if they don't exist
- 🎯 **Selective Installation** - Install to one or all detected PowerShell versions
- ✅ **Error Handling** - Comprehensive error checking and user feedback

## System Requirements

- **Operating System**: Windows 10 or Windows 11
- **PowerShell Version**: PowerShell 6.0 or later (PowerShell 7 recommended)
- **Permissions**: Standard user permissions (no admin required for profile installation)
- **Optional**: Git (for Git branch display feature in prompt)

## Installation

### Quick Start

1. **Download the script**
   ```powershell
   # Save as: powershell-profile-installer.ps1
   ```

2. **Run the installer**
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File powershell-profile-installer.ps1
   ```

3. **Follow the on-screen menu** to select your installation options

4. **Restart PowerShell** or reload your profile:
   ```powershell
   . $PROFILE
   ```

### Installation Options

When you run the script, you'll see a menu with detected PowerShell installations:

```
Detected PowerShell installations:

  1) PowerShell 7 (v7.4.0)
     C:\Users\YourName\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

  A) Install for ALL detected versions
  Q) Quit
```

**Options:**
- **1, 2, 3...** - Install to a specific PowerShell version
- **A** - Install to all detected versions
- **Q** - Quit without installing

### Shortcut Configuration

After successful installation, you'll be prompted:

```
Configure PowerShell shortcuts to use -NoLogo? (Y/n)
```

- **Y** (default) - Updates Desktop and Start Menu shortcuts to hide the PowerShell banner
- **N** - Skip shortcut configuration

## File Locations

### Profile Locations

The installer creates profiles at:

**PowerShell 7:**
```
C:\Users\<YourUsername>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

**PowerShell 6:**
```
C:\Users\<YourUsername>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

**Windows PowerShell 5.1:**
```
C:\Users\<YourUsername>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

### Backup Files

Backups are created with timestamp format:
```
Microsoft.PowerShell_profile.ps1.backup_YYYYMMDD_HHMMSS
```

Example:
```
Microsoft.PowerShell_profile.ps1.backup_20241130_143052
```

## Customization

### Changing Your Name

The default greeting shows "Techy Tim". To personalize it:

1. Open your profile:
   ```powershell
   notepad $PROFILE
   ```

2. Find this line in the `Show-Greeting` function:
   ```powershell
   $fullGreeting = "$timeOfDayGreetingPrefix, Techy Tim!"
   ```

3. Change "Techy Tim" to your name:
   ```powershell
   $fullGreeting = "$timeOfDayGreetingPrefix, Your Name!"
   ```

4. Save and reload:
   ```powershell
   . $PROFILE
   ```

### Customizing Colors

Colors can be customized in the `prompt` function. Available variables:

```powershell
$usernameColor = "Green"      # Color for username
$hostnameColor = "Yellow"     # Color for hostname
$pathColor = "Cyan"           # Color for current path
$gitBranchColor = "Magenta"   # Color for Git branch
$promptSymbolColor = "White"  # Color for symbols (@, :, >)
```

**Available Colors:**
- `Black`, `DarkBlue`, `DarkGreen`, `DarkCyan`, `DarkRed`, `DarkMagenta`, `DarkYellow`
- `Gray`, `DarkGray`
- `Blue`, `Green`, `Cyan`, `Red`, `Magenta`, `Yellow`, `White`

### Example Customization

```powershell
function prompt {
    $usernameColor = "Blue"        # Changed from Green
    $hostnameColor = "Magenta"     # Changed from Yellow
    $pathColor = "Green"           # Changed from Cyan
    $gitBranchColor = "Yellow"     # Changed from Magenta
    $promptSymbolColor = "White"   # Unchanged
    
    # ... rest of the function remains the same
}
```

## Troubleshooting

### Profile Not Loading

**Problem**: Profile doesn't load when opening PowerShell

**Solutions:**
1. Check execution policy:
   ```powershell
   Get-ExecutionPolicy
   ```
   
2. If it's "Restricted", change it:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. Manually reload profile:
   ```powershell
   . $PROFILE
   ```

### Script Won't Run

**Problem**: "Cannot be loaded because running scripts is disabled"

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\powershell-profile-installer.ps1
```

### Git Branch Not Showing

**Problem**: Git branch doesn't appear in prompt when in repository

**Solutions:**
1. Install Git: https://git-scm.com/download/win
2. Ensure Git is in PATH:
   ```powershell
   git --version
   ```

### Characters Display Incorrectly

**Problem**: Box-drawing characters (╔══╗) show as squares or question marks

**Solutions:**
1. Use a font that supports Unicode (recommended: Cascadia Code, Consolas)
2. In WezTerm, set:
   ```lua
   config.font = wezterm.font('Cascadia Code')
   ```
3. In Windows Terminal, use Settings → Profile → Appearance → Font face

### PowerShell 7 Not Detected

**Problem**: Installer doesn't find PowerShell 7

**Solutions:**
1. Install PowerShell 7:
   ```powershell
   winget install Microsoft.PowerShell
   ```
   Or download from: https://aka.ms/powershell

2. Verify installation:
   ```powershell
   pwsh --version
   ```

## Usage Examples

### Basic Installation

```powershell
# Run the installer
.\powershell-profile-installer.ps1

# Select option 1 for PowerShell 7
Select an option: 1

# Configure shortcuts
Configure PowerShell shortcuts to use -NoLogo? (Y/n): Y

# Restart PowerShell to see changes
```

### Install to All Versions

```powershell
# Run the installer
.\powershell-profile-installer.ps1

# Select option A for all versions
Select an option: A

# Skip shortcuts
Configure PowerShell shortcuts to use -NoLogo? (Y/n): N
```

### Manual Profile Reload

```powershell
# After editing your profile
. $PROFILE

# Or use this alias
& $PROFILE
```

### View Current Profile Location

```powershell
# Show profile path
$PROFILE

# Check if profile exists
Test-Path $PROFILE

# Open profile in editor
notepad $PROFILE
```

### Restore from Backup

```powershell
# List backups
Get-ChildItem "$PROFILE.backup_*"

# Restore a specific backup
Copy-Item "$PROFILE.backup_20241130_143052" -Destination $PROFILE -Force

# Reload profile
. $PROFILE
```

## Advanced Configuration

### Multiple Profile Types

PowerShell supports different profile types:

```powershell
# Current user, current host (most common)
$PROFILE.CurrentUserCurrentHost

# Current user, all hosts
$PROFILE.CurrentUserAllHosts

# All users, current host (requires admin)
$PROFILE.AllUsersCurrentHost

# All users, all hosts (requires admin)
$PROFILE.AllUsersAllHosts
```

This installer uses `CurrentUserCurrentHost` by default.

### Conditional Profile Loading

Add conditional logic to your profile:

```powershell
# Only show greeting on interactive sessions
if ($Host.UI.RawUI) {
    Show-Greeting
}

# Load different settings based on hostname
if ($env:COMPUTERNAME -eq "WORK-PC") {
    # Work-specific settings
} else {
    # Home-specific settings
}
```

### Adding Custom Functions

Add your own functions to the profile:

```powershell
# Add after the prompt function

# Quick directory navigation
function docs { Set-Location "$HOME\Documents" }
function projects { Set-Location "C:\Projects" }

# Git shortcuts
function gs { git status }
function ga { git add . }
function gc { param($message) git commit -m $message }

# System information
function sysinfo {
    Get-ComputerInfo | Select-Object CsName, OsVersion, OsTotalVisibleMemorySize
}
```

## Terminal Emulator Integration

### WezTerm Configuration

For optimal experience with WezTerm:

```lua
-- .wezterm.lua
config.default_prog = { 'pwsh', '-NoLogo' }
config.font = wezterm.font('Cascadia Code')
config.font_size = 13.0
```

### Windows Terminal Configuration

For Windows Terminal:

```json
{
    "profiles": {
        "defaults": {
            "font": {
                "face": "Cascadia Code",
                "size": 11
            }
        },
        "list": [
            {
                "commandline": "pwsh.exe -NoLogo",
                "name": "PowerShell 7"
            }
        ]
    }
}
```

## Security Considerations

### Execution Policy

The installer requires scripts to be enabled:

- **RemoteSigned** (Recommended) - Allows local scripts, requires signature for downloaded scripts
- **Unrestricted** - Allows all scripts (less secure)
- **Restricted** - Default, blocks all scripts

### Profile Security

Your profile runs automatically on PowerShell start:

- ⚠️ Only add trusted code to your profile
- 🔒 Review profile changes before saving
- 💾 Keep backups of working profiles
- 🔍 Regularly audit profile contents

## Uninstallation

### Remove Profile

```powershell
# Delete current profile
Remove-Item $PROFILE

# Or rename to disable
Rename-Item $PROFILE "$PROFILE.disabled"
```

### Restore Shortcuts

Shortcut changes are permanent. To restore:

1. Right-click PowerShell shortcut → Properties
2. In "Target" field, remove `-NoLogo`
3. Click OK

Or delete and recreate shortcuts from Start Menu.

## FAQ

**Q: Will this work with Windows PowerShell 5.1?**  
A: The installer requires PowerShell 6+, but you can manually copy the profile to Windows PowerShell 5.1 location.

**Q: Can I use this on multiple machines?**  
A: Yes! Copy the generated profile file to other machines at the same location.

**Q: Does this affect PowerShell ISE?**  
A: No, PowerShell ISE uses a different profile (`Microsoft.PowerShellISE_profile.ps1`).

**Q: Can I have different profiles for different terminals?**  
A: Yes, but they'll share the same `CurrentUserCurrentHost` profile. Use conditional logic based on `$env:TERM_PROGRAM` or similar.

**Q: Will this slow down PowerShell startup?**  
A: Minimally. The greeting and prompt are lightweight and execute in milliseconds.

**Q: Can I disable the greeting but keep the prompt?**  
A: Yes, comment out or remove the `Show-Greeting` call in your profile.

## Support & Contributions

### Getting Help

If you encounter issues:

1. Check the Troubleshooting section
2. Verify your PowerShell version: `$PSVersionTable`
3. Check execution policy: `Get-ExecutionPolicy`
4. Review error messages carefully

### Reporting Issues

When reporting issues, include:
- PowerShell version (`$PSVersionTable.PSVersion`)
- Windows version
- Error messages (full text)
- Steps to reproduce

## Version History

### Version 1.0
- Initial release
- Auto-detection of PowerShell installations
- Profile installation with backup
- Shortcut configuration
- Customization instructions

## License

This script is provided as-is for personal and commercial use.

## Credits

- Created for Windows PowerShell 6+ environments
- Inspired by Unix/Linux shell customizations
- Box-drawing characters: Unicode Standard
- Color scheme: Customizable by user

---

**Last Updated**: November 30, 2024  
**Compatible With**: PowerShell 6.0+, Windows 10/11
