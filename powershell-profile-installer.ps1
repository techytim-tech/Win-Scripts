# PowerShell Profile Installer for Windows
# Supports Windows 10/11 and PowerShell 6/7
Set-StrictMode -Version Latest

function Show-Logo {
    $block = '████'
    for ($i = 0; $i -lt 4; $i++) {
        Write-Host -NoNewline $block -ForegroundColor Blue
        Write-Host -NoNewline $block -ForegroundColor Yellow
        Write-Host -NoNewline $block -ForegroundColor Green
        Write-Host $block -ForegroundColor Red
    }
    Write-Host "`n" -NoNewline
    Write-Host "  PowerShell Profile Installer`n" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "`n"
}

function Test-PowerShellVersion {
    $version = $PSVersionTable.PSVersion.Major
    if ($version -lt 6) {
        Write-Host "ERROR: This installer requires PowerShell 6 or later." -ForegroundColor Red
        Write-Host "Current version: PowerShell $version" -ForegroundColor Yellow
        Write-Host "`nPlease install PowerShell 7 from: https://aka.ms/powershell" -ForegroundColor Cyan
        return $false
    }
    return $true
}

function Get-ProfileContent {
    return @'
# PowerShell 7 Profile Script for Windows
# Combines a startup greeting with a custom colored prompt.

# --- Startup Greeting Function ---
function Show-Greeting {
    Clear-Host

    # Get the machine's hostname
    $hostname = $env:COMPUTERNAME

    # Get system username
    $systemUsername = $env:USERNAME
    if ([string]::IsNullOrEmpty($systemUsername)) {
        $systemUsername = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[-1]
    }

    # Get current time for time-based greeting
    $currentHour = (Get-Date).Hour
    $timeOfDayGreetingPrefix = ""

    if ($currentHour -ge 5 -and $currentHour -lt 12) {
        $timeOfDayGreetingPrefix = "Good Morning"
    } elseif ($currentHour -ge 12 -and $currentHour -lt 18) {
        $timeOfDayGreetingPrefix = "Good Afternoon"
    } else {
        $timeOfDayGreetingPrefix = "Good Evening"
    }

    $fullGreeting = "$timeOfDayGreetingPrefix, Techy Tim!"

    # Define the inner width of the box for consistent alignment
    # This width is chosen to fit common console sizes without wrapping.
    $boxInnerWidth = 55
    $boxLine = "═" * $boxInnerWidth

    # --- Enhanced Styling for Greeting ---
    Write-Host "╔$boxLine╗" -ForegroundColor DarkCyan
    Write-Host "║$(''.PadRight($boxInnerWidth))║" -ForegroundColor DarkCyan
    
    # Greeting line - centered and styled
    # Calculates padding to center the greeting within the box
    $paddingLeft = [math]::Floor(($boxInnerWidth - $fullGreeting.Length) / 2)
    $paddingRight = $boxInnerWidth - $fullGreeting.Length - $paddingLeft
    Write-Host "║$(' ' * $paddingLeft)$fullGreeting$(' ' * $paddingRight)║" -ForegroundColor Green
    
    Write-Host "║$(''.PadRight($boxInnerWidth))║" -ForegroundColor DarkCyan
    Write-Host "╠$boxLine╣" -ForegroundColor DarkCyan

    # Hostname line
    $hostnameLine = " Hostname: $hostname"
    Write-Host "║$($hostnameLine.PadRight($boxInnerWidth))║" -ForegroundColor Yellow
    
    # Current directory
    $currentDir = (Get-Location).Path
    $currentDirLine = " Current Directory: $currentDir"
    Write-Host "║$($currentDirLine.PadRight($boxInnerWidth))║" -ForegroundColor Cyan

    # Display Current Time
    $currentTime = (Get-Date -Format 'F')
    $currentTimeLine = " Current Time: $currentTime"
    Write-Host "║$($currentTimeLine.PadRight($boxInnerWidth))║" -ForegroundColor Magenta
    
    Write-Host "║$(''.PadRight($boxInnerWidth))║" -ForegroundColor DarkCyan
    Write-Host "╚$boxLine╝" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "Enjoy your PowerShell session, Techy Tim!" -ForegroundColor White
    Write-Host "" # Add an extra line for better separation before the prompt
}

# Call the greeting function when the profile loads
Show-Greeting

# --- Custom PowerShell Prompt Function ---
function prompt {
    # Define colors for different parts of the prompt
    $usernameColor = "Green"
    $hostnameColor = "Yellow"
    $pathColor = "Cyan"
    $gitBranchColor = "Magenta" # For Git repositories
    $promptSymbolColor = "White"

    # Get username and hostname
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME

    # Get current path
    $currentPath = (Get-Location).Path

    # Check for Git repository and branch (optional, requires Git to be installed and in PATH)
    $gitStatus = ""
    try {
        # Check if we are inside a Git repository
        $gitRoot = (git rev-parse --show-toplevel 2>$null).Trim()
        if ($gitRoot) {
            $branch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
            if ($branch) {
                $gitStatus = " ($($branch))"
            }
        }
    } catch {
        # Git not found or not in a repo, suppress errors
    }

    # Construct the prompt string
    # Example format: [username@hostname: path (git_branch)]>
    Write-Host "$($username)" -ForegroundColor $usernameColor -NoNewline
    Write-Host "@" -ForegroundColor $promptSymbolColor -NoNewline
    Write-Host "$($hostname)" -ForegroundColor $hostnameColor -NoNewline
    Write-Host ":" -ForegroundColor $promptSymbolColor -NoNewline
    Write-Host "$($currentPath)" -ForegroundColor $pathColor -NoNewline

    if ($gitStatus) {
        Write-Host "$gitStatus" -ForegroundColor $gitBranchColor -NoNewline
    }

    Write-Host "> " -ForegroundColor $promptSymbolColor -NoNewline

    # Return an empty string to prevent PowerShell from adding its default prompt
    return " "
}
'@
}

function Backup-ExistingProfile {
    param([string]$ProfilePath)
    
    if (Test-Path $ProfilePath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = "${ProfilePath}.backup_${timestamp}"
        Copy-Item -Path $ProfilePath -Destination $backupPath -Force
        Write-Host "✓ Backed up existing profile to:" -ForegroundColor Yellow
        Write-Host "  $backupPath`n" -ForegroundColor Gray
        return $true
    }
    return $false
}

function Install-Profile {
    param(
        [string]$ProfilePath,
        [string]$ProfileName
    )
    
    Write-Host "`nInstalling profile for: $ProfileName" -ForegroundColor Cyan
    Write-Host "Target location: $ProfilePath`n" -ForegroundColor Gray
    
    # Create directory if it doesn't exist
    $profileDir = Split-Path -Parent $ProfilePath
    if (-not (Test-Path $profileDir)) {
        Write-Host "Creating profile directory..." -ForegroundColor Gray
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    
    # Backup existing profile
    Backup-ExistingProfile -ProfilePath $ProfilePath
    
    # Get profile content
    $content = Get-ProfileContent
    
    # Write profile
    try {
        $content | Out-File -FilePath $ProfilePath -Encoding utf8 -Force
        Write-Host "✓ Profile installed successfully!" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "✗ Failed to install profile: $_" -ForegroundColor Red
        return $false
    }
}

function Get-PowerShellProfiles {
    $profiles = @()
    
    # PowerShell 7+ (pwsh)
    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        $ps7Profile = & pwsh -NoProfile -Command { $PROFILE.CurrentUserCurrentHost }
        $ps7Version = & pwsh -NoProfile -Command { $PSVersionTable.PSVersion.ToString() }
        
        $profileObj = [PSCustomObject]@{
            Name = "PowerShell 7"
            Path = $ps7Profile
            Executable = "pwsh"
            Version = $ps7Version
        }
        $profiles += $profileObj
    }
    
    # PowerShell 6 (might be pwsh6 or pwsh)
    # Note: PS6 and PS7 usually share the same profile location
    
    # Windows PowerShell 5.1 (only if user wants to install there too)
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        $profileObj = [PSCustomObject]@{
            Name = "Windows PowerShell 5.1"
            Path = $PROFILE.CurrentUserCurrentHost
            Executable = "powershell"
            Version = $PSVersionTable.PSVersion.ToString()
        }
        $profiles += $profileObj
    }
    
    return $profiles
}

function Show-Menu {
    Clear-Host
    Show-Logo
    
    Write-Host "This installer will set up a custom PowerShell profile with:" -ForegroundColor Gray
    Write-Host "  • Personalized greeting with time-based messages" -ForegroundColor White
    Write-Host "  • Colored prompt with username, hostname, and path" -ForegroundColor White
    Write-Host "  • Git branch display (when in a Git repository)" -ForegroundColor White
    Write-Host "  • Custom styling and box-drawing characters`n" -ForegroundColor White
    
    $detectedProfiles = Get-PowerShellProfiles
    
    if ($detectedProfiles.Count -eq 0) {
        Write-Host "ERROR: No compatible PowerShell installation found!" -ForegroundColor Red
        Write-Host "Please install PowerShell 7 from: https://aka.ms/powershell`n" -ForegroundColor Yellow
        return $null
    }
    
    Write-Host "Detected PowerShell installations:`n" -ForegroundColor Cyan
    
    for ($i = 0; $i -lt $detectedProfiles.Count; $i++) {
        $profileItem = $detectedProfiles[$i]
        Write-Host "  $($i + 1)) $($profileItem.Name) (v$($profileItem.Version))" -ForegroundColor White
        Write-Host "     $($profileItem.Path)" -ForegroundColor DarkGray
        Write-Host ""
    }
    
    Write-Host "  A) Install for ALL detected versions" -ForegroundColor Yellow
    Write-Host "  Q) Quit`n" -ForegroundColor Red
    
    return $detectedProfiles
}

function Wait-AnyKey {
    Write-Host "`nPress any key to continue..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

function Show-CustomizationHelp {
    Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              Customization Instructions                 ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "`nTo customize your profile:" -ForegroundColor White
    Write-Host "  1. Open the profile file in an editor:" -ForegroundColor Gray
    Write-Host "     notepad `$PROFILE" -ForegroundColor Yellow
    Write-Host "`n  2. Change 'Techy Tim' to your name in the Show-Greeting function" -ForegroundColor Gray
    Write-Host "`n  3. Customize colors by editing these variables in the prompt function:" -ForegroundColor Gray
    Write-Host "     • `$usernameColor = 'Green'" -ForegroundColor DarkGray
    Write-Host "     • `$hostnameColor = 'Yellow'" -ForegroundColor DarkGray
    Write-Host "     • `$pathColor = 'Cyan'" -ForegroundColor DarkGray
    Write-Host "     • `$gitBranchColor = 'Magenta'" -ForegroundColor DarkGray
    Write-Host "`n  Available colors:" -ForegroundColor Gray
    Write-Host "    Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta," -ForegroundColor DarkGray
    Write-Host "    DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta," -ForegroundColor DarkGray
    Write-Host "    Yellow, White" -ForegroundColor DarkGray
}

function Set-PowerShellShortcuts {
    Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║          Setting up PowerShell Shortcuts                ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    $shortcutsUpdated = $false
    
    # Get common shortcut locations
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $startMenuPath = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\PowerShell"
    
    # Find PowerShell 7 shortcuts
    $shortcutLocations = @(
        (Join-Path $desktopPath "PowerShell 7*.lnk"),
        (Join-Path $startMenuPath "PowerShell 7*.lnk")
    )
    
    $shell = New-Object -ComObject WScript.Shell
    
    foreach ($pattern in $shortcutLocations) {
        $shortcuts = Get-ChildItem -Path (Split-Path $pattern) -Filter (Split-Path $pattern -Leaf) -ErrorAction SilentlyContinue
        
        foreach ($shortcut in $shortcuts) {
            try {
                $link = $shell.CreateShortcut($shortcut.FullName)
                $originalArgs = $link.Arguments
                
                # Check if -NoLogo is already present
                if ($originalArgs -notmatch '-NoLogo') {
                    # Add -NoLogo to arguments
                    if ([string]::IsNullOrWhiteSpace($originalArgs)) {
                        $link.Arguments = "-NoLogo"
                    } else {
                        $link.Arguments = "-NoLogo $originalArgs"
                    }
                    $link.Save()
                    Write-Host "  ✓ Updated: $($shortcut.Name)" -ForegroundColor Green
                    $shortcutsUpdated = $true
                } else {
                    Write-Host "  • Already configured: $($shortcut.Name)" -ForegroundColor DarkGray
                }
            } catch {
                Write-Host "  ✗ Failed to update: $($shortcut.Name)" -ForegroundColor Yellow
            }
        }
    }
    
    if ($shortcutsUpdated) {
        Write-Host "`n✓ PowerShell shortcuts updated with -NoLogo flag" -ForegroundColor Green
    } else {
        Write-Host "`nNo shortcuts needed updating (already configured or not found)" -ForegroundColor DarkGray
    }
    
    Write-Host "`nNote: If using WezTerm or Windows Terminal, ensure -NoLogo is set" -ForegroundColor Yellow
    Write-Host "      in their configuration files as well." -ForegroundColor Yellow
}

# Main execution
Clear-Host
Show-Logo

# Check PowerShell version
if (-not (Test-PowerShellVersion)) {
    Wait-AnyKey
    exit 1
}

# Show menu and get profiles
$detectedProfiles = Show-Menu

if ($null -eq $detectedProfiles) {
    Wait-AnyKey
    exit 1
}

# Get user choice
$choice = Read-Host "Select an option"

$installSuccess = $false

switch ($choice.ToUpper()) {
    'A' {
        Write-Host "`nInstalling for ALL PowerShell versions..." -ForegroundColor Yellow
        foreach ($profileItem in $detectedProfiles) {
            if (Install-Profile -ProfilePath $profileItem.Path -ProfileName $profileItem.Name) {
                $installSuccess = $true
            }
        }
    }
    'Q' {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        exit 0
    }
    default {
        $index = $null
        if ([int]::TryParse($choice, [ref]$index)) {
            $index--
            if ($index -ge 0 -and $index -lt $detectedProfiles.Count) {
                $selectedProfile = $detectedProfiles[$index]
                if (Install-Profile -ProfilePath $selectedProfile.Path -ProfileName $selectedProfile.Name) {
                    $installSuccess = $true
                }
            } else {
                Write-Host "`nInvalid selection!" -ForegroundColor Red
            }
        } else {
            Write-Host "`nInvalid selection!" -ForegroundColor Red
        }
    }
}

if ($installSuccess) {
    Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║           Installation Completed Successfully!          ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host "`nTo see your new profile:" -ForegroundColor White
    Write-Host "  • Close and reopen PowerShell, OR" -ForegroundColor Gray
    Write-Host "  • Run: . `$PROFILE" -ForegroundColor Yellow
    
    # Ask if user wants to configure shortcuts for -NoLogo
    Write-Host ""
    $configureShortcuts = Read-Host "Configure PowerShell shortcuts to use -NoLogo? (Y/n)"
    if ($configureShortcuts -match '^[Yy]' -or [string]::IsNullOrWhiteSpace($configureShortcuts)) {
        Set-PowerShellShortcuts
    }
    
    Show-CustomizationHelp
}

Wait-AnyKey
exit 0