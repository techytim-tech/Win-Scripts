# Wezterm Config for Windows - Menu-driven Installer
Set-StrictMode -Version Latest

# Target config file
$Global:ConfigFile = Join-Path $env:USERPROFILE ".wezterm.lua"

function Show-Logo {
    # Microsoft-style 4-pane logo using console colors (approximate)
    $block = '████'
    for ($i = 0; $i -lt 4; $i++) {
        Write-Host -NoNewline $block -ForegroundColor Blue
        Write-Host -NoNewline $block -ForegroundColor Yellow
        Write-Host -NoNewline $block -ForegroundColor Green
        Write-Host $block -ForegroundColor Red
    }
    Write-Host "`n" -NoNewline
    Write-Host "  Wezterm Config for Windows`n" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "`n"
}

# Ensure script is running in a 64-bit PowerShell process when possible.
function Start-64BitProcess {
    if ($env:WEZTERM_64LAUNCHED) { return $false }
    if ([IntPtr]::Size -eq 8) { return $false }

    Write-Host "Current process is 32-bit. Attempting to relaunch 64-bit PowerShell..." -ForegroundColor Yellow

    $pwsh64 = $null
    if ($env:ProgramFiles) {
        $pf = Join-Path $env:ProgramFiles 'PowerShell'
        if (Test-Path $pf) {
            $candidate = Get-ChildItem -Path $pf -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | ForEach-Object { Join-Path $_.FullName 'pwsh.exe' } | Where-Object { Test-Path $_ } | Select-Object -First 1
            if ($candidate) { $pwsh64 = $candidate }
        }
    }

    # Fallback to 64-bit Windows PowerShell via Sysnative if pwsh not available
    if (-not $pwsh64) {
        $psSysnative = Join-Path $env:WINDIR 'sysnative\WindowsPowerShell\v1.0\powershell.exe'
        if (Test-Path $psSysnative) { $pwsh64 = $psSysnative }
    }

    if (-not $pwsh64) {
        Write-Host "Could not locate a 64-bit PowerShell executable. Continuing in current process." -ForegroundColor Yellow
        return $false
    }

    # Set an env var so child doesn't loop
    $env:WEZTERM_64LAUNCHED = '1'
    $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$PSCommandPath)
    Start-Process -FilePath $pwsh64 -ArgumentList $argList -WindowStyle Normal
    Write-Host "Launched 64-bit PowerShell ($pwsh64). Exiting 32-bit process." -ForegroundColor Cyan
    exit 0
}

# Ensure we're running 64-bit where possible before proceeding
Start-64BitProcess

function Backup-File {
    param([string]$Path)
    if (Test-Path $Path) {
        $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backup = "${Path}.bak.$stamp"
        Copy-Item -Path $Path -Destination $backup -Force
        Write-Host "Backed up existing config to: $backup" -ForegroundColor Yellow
    }
}

function Wait-AnyKey {
    Write-Host "`nPress any key to continue..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

function Install-Wezterm {
    Write-Host "Install WezTerm for Windows" -ForegroundColor Cyan
    if (Get-Command wezterm -ErrorAction SilentlyContinue) {
        Write-Host "WezTerm already appears to be installed (in PATH)." -ForegroundColor Green
        Wait-AnyKey; return
    }

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Installing via winget (requires admin if not enabled)..." -ForegroundColor Gray
        $wingetArgs = @('install','--id','WezTerm.WezTerm','-e','--accept-package-agreements','--accept-source-agreements')
        Write-Host "Running: winget $($wingetArgs -join ' ')" -ForegroundColor DarkGray
        try {
            Start-Process -FilePath 'winget' -ArgumentList $wingetArgs -NoNewWindow -Wait -ErrorAction Stop
            Write-Host "winget finished — check output for success." -ForegroundColor Green
        } catch {
            Write-Host "winget installation failed or was cancelled." -ForegroundColor Red
        }
    }
    elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Installing via Chocolatey..." -ForegroundColor Gray
        try {
            Start-Process -FilePath 'choco' -ArgumentList @('install','wezterm','-y') -NoNewWindow -Wait -ErrorAction Stop
        } catch {
            Write-Host "Chocolatey install failed." -ForegroundColor Red
        }
    }
    else {
        Write-Host "No supported package manager found (winget/choco)." -ForegroundColor Yellow
        Write-Host "Please install WezTerm manually from: https://wezfurlong.org/wezterm/" -ForegroundColor Cyan
    }
    Wait-AnyKey
}

function Set-WeztermConfig {
    # Interactive config setup and write out wezterm.lua
    Show-Logo
    Write-Host "This will create or update your WezTerm config at:`n  $Global:ConfigFile`n" -ForegroundColor Gray

    Write-Host "Choose your theme:" -ForegroundColor Gray
    Write-Host "  1) Windows Blue (default)" -ForegroundColor Cyan
    Write-Host "  2) Catppuccin Mocha (dark)" -ForegroundColor Magenta
    Write-Host "  3) Catppuccin Latte (light)" -ForegroundColor Yellow
    Write-Host "  4) Dracula" -ForegroundColor DarkMagenta
    Write-Host "  5) Gruvbox Dark" -ForegroundColor DarkYellow

    $choice = Read-Host " [1-5] (default 1)"
    if ([string]::IsNullOrWhiteSpace($choice)) { $choice = '1' }
    switch ($choice) {
        '2' { $Theme = 'mocha'; $Name = 'Catppuccin Mocha' }
        '3' { $Theme = 'latte'; $Name = 'Catppuccin Latte' }
        '4' { $Theme = 'dracula'; $Name = 'Dracula' }
        '5' { $Theme = 'gruvbox'; $Name = 'Gruvbox Dark' }
        default { $Theme = 'windows'; $Name = 'Windows Blue' }
    }

    Write-Host ""
    Write-Host "Choose your font:" -ForegroundColor Gray
    Write-Host "  1) Cascadia Code (recommended)" -ForegroundColor Cyan
    Write-Host "  2) Consolas (classic)" -ForegroundColor Green
    Write-Host "  3) Courier New (fallback)" -ForegroundColor Yellow

    $fontChoice = Read-Host " [1-3] (default 1)"
    if ([string]::IsNullOrWhiteSpace($fontChoice)) { $fontChoice = '1' }
    
    switch ($fontChoice) {
        '2' { $FontConfig = "config.font = wezterm.font('Consolas')" }
        '3' { $FontConfig = "config.font = wezterm.font('Courier New')" }
        default { $FontConfig = "config.font = wezterm.font('Cascadia Code')" }
    }

    Write-Host ""
    Write-Host "Choose your shell:" -ForegroundColor Gray
    Write-Host "  1) PowerShell 7 (recommended, requires installation)" -ForegroundColor Cyan
    Write-Host "  2) PowerShell 6 (legacy)" -ForegroundColor Green
    Write-Host "  3) cmd.exe (Windows Command Prompt)" -ForegroundColor Yellow

    $shellChoice = Read-Host " [1-3] (default 1)"
    if ([string]::IsNullOrWhiteSpace($shellChoice)) { $shellChoice = '1' }
    
    # If PowerShell 7 selected, check if installed
    if ($shellChoice -eq '1') {
        $ps7Installed = Get-Command pwsh -ErrorAction SilentlyContinue
        if (-not $ps7Installed) {
            Write-Host ""
            Write-Host "PowerShell 7 is not currently installed." -ForegroundColor Yellow
            $installPS7 = Read-Host "Download and install PowerShell 7 now? (y/N)"
            if ($installPS7 -match '^[Yy]') {
                Write-Host ""
                Install-Wezterm  # Reuse the package install logic
                Write-Host "Attempting PowerShell 7 installation..." -ForegroundColor Cyan
                $ps7Args = @('install','--id','Microsoft.PowerShell','-e','--accept-package-agreements','--accept-source-agreements')
                try {
                    if (Get-Command winget -ErrorAction SilentlyContinue) {
                        Start-Process -FilePath 'winget' -ArgumentList $ps7Args -NoNewWindow -Wait -ErrorAction Stop
                        Write-Host "PowerShell 7 installed. Please restart this script to use it." -ForegroundColor Green
                    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
                        Start-Process -FilePath 'choco' -ArgumentList @('install','powershell-core','-y') -NoNewWindow -Wait -ErrorAction Stop
                        Write-Host "PowerShell 7 installed. Please restart this script to use it." -ForegroundColor Green
                    }
                } catch {
                    Write-Host "PowerShell 7 installation failed. Using cmd.exe instead." -ForegroundColor Yellow
                    $shellChoice = '3'
                }
                if ($ps7Args) { Wait-AnyKey; return }
            }
        }
    }
    
    switch ($shellChoice) {
        '2' {
            $ShellConfig = @"
-- PowerShell 6
config.default_prog = { 'pwsh', '-NoLogo' }
"@
            $ShellDisplay = 'PowerShell 6'
        }
        '3' {
            $ShellConfig = @"
-- cmd.exe (Command Prompt)
config.default_prog = { 'cmd.exe' }
"@
            $ShellDisplay = 'cmd.exe'
        }
        default {
            $ShellConfig = @"
-- PowerShell 7
config.default_prog = { 'pwsh', '-NoLogo' }
"@
            $ShellDisplay = 'PowerShell 7'
        }
    }

    $useTitle = Read-Host "Title bar on Windows? (y/n) [y]"
    if ([string]::IsNullOrWhiteSpace($useTitle)) { $useTitle = 'y' }
    $Decor = if ($useTitle -match '^[Yy]') { 'TITLE | RESIZE' } else { 'RESIZE' }

    Backup-File -Path $Global:ConfigFile

    $luaHeader = @"
-- WezTerm – $Name
-- Generated by Wezterm-Config-for-Win.Ps1
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.warn_about_missing_glyphs = false

$FontConfig
config.font_size = 13.0
config.line_height = 1.15

-- Window sizing to fit screen
config.initial_rows = 40
config.initial_cols = 120

$ShellConfig
config.window_decorations = "$Decor"
config.window_padding = { left = '1cell', right = '1cell', top = '0.5cell', bottom = '0.5cell' }
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 600

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
local act = wezterm.action
config.keys = {
  {key='-', mods='LEADER', action=act.SplitVertical{domain='CurrentPaneDomain'}},
  {key='|', mods='LEADER|SHIFT', action=act.SplitHorizontal{domain='CurrentPaneDomain'}},
  {key='h', mods='LEADER', action=act.ActivatePaneDirection'Left'},
  {key='j', mods='LEADER', action=act.ActivatePaneDirection'Down'},
  {key='k', mods='LEADER', action=act.ActivatePaneDirection'Up'},
  {key='l', mods='LEADER', action=act.ActivatePaneDirection'Right'},
  {key='c', mods='LEADER', action=act.SpawnTab'CurrentPaneDomain'},
}
for i=1,9 do table.insert(config.keys, {key=tostring(i), mods='LEADER', action=act.ActivateTab(i-1)}) end

"@

    switch ($Theme) {
        'latte' {
            $colors = @"
-- Catppuccin Latte (light)
config.colors = {
  foreground = '#4c4f69',
  background = '#eff1f5',
  cursor_bg = '#dc8a78',
  cursor_border = '#dc8a78',
  selection_fg = '#eff1f5',
  selection_bg = '#dc8a78',
  ansi = { '#5c5f77', '#d20f39', '#40a02b', '#df8e1d', '#1e66f5', '#ea76cb', '#179299', '#acb0be' },
  brights = { '#6c6f85', '#d20f39', '#40a02b', '#df8e1d', '#1e66f5', '#ea76cb', '#179299', '#bcc0cc' },
  tab_bar = {
    background = '#e6e9ef',
    active_tab = { bg_color = '#1e66f5', fg_color = '#eff1f5', intensity = 'Bold' },
  },
}
"@
        }
        'mocha' {
            $colors = @"
-- Catppuccin Mocha (dark)
config.colors = {
  foreground = '#cdd6f4',
  background = '#1e1e2e',
  cursor_bg = '#f5e0dc',
  cursor_border = '#f5e0dc',
  selection_fg = '#1e1e2e',
  selection_bg = '#f5e0dc',
  ansi = { '#45475a', '#f38ba8', '#a6e3a1', '#f9e2af', '#89b4fa', '#f5c2e7', '#94e2d5', '#bac2de' },
  brights = { '#585b70', '#f38ba8', '#a6e3a1', '#f9e2af', '#89b4fa', '#f5c2e7', '#94e2d5', '#a6adc8' },
  tab_bar = {
    background = '#11111b',
    active_tab = { bg_color = '#89b4fa', fg_color = '#1e1e2e', intensity = 'Bold' },
  },
}
"@
        }
        'dracula' {
            $colors = @"
-- Dracula
config.colors = {
  foreground = '#f8f8f2',
  background = '#282a36',
  cursor_bg = '#ff79c6',
  cursor_border = '#ff79c6',
  selection_fg = '#282a36',
  selection_bg = '#44475a',
  ansi = { '#000000', '#ff5555', '#50fa7b', '#f1fa8c', '#bd93f9', '#ff79c6', '#8be9fd', '#bbbbbb' },
  brights = { '#44475a', '#ff6e6e', '#69ff94', '#ffffa5', '#d6acff', '#ff92df', '#a4ffff', '#ffffff' },
}
"@
        }
        'gruvbox' {
            $colors = @"
-- Gruvbox Dark
config.colors = {
  foreground = '#ebdbb2',
  background = '#282828',
  cursor_bg = '#fb4934',
  cursor_border = '#fb4934',
  selection_fg = '#282828',
  selection_bg = '#fb4934',
  ansi = { '#282828', '#cc241d', '#98971a', '#d79921', '#458588', '#b16286', '#689d6a', '#a89984' },
  brights = { '#928374', '#fb4934', '#b8bb26', '#fabd2f', '#83a598', '#d3869b', '#8ec07c', '#ebdbb2' },
}
"@
        }
        default {
            $colors = @"
-- Windows Blue (default for this script)
config.colors = {
  foreground = '#ffffff',
  background = '#0078D7',
  cursor_bg = '#ffffff',
  cursor_border = '#ffffff',
  selection_fg = '#0078D7',
  selection_bg = '#ffffff',
  ansi = { '#000000', '#cc0000', '#00cc00', '#cccc00', '#0000cc', '#cc00cc', '#00cccc', '#cccccc' },
  brights = { '#666666', '#ff4444', '#44ff44', '#ffff44', '#4444ff', '#ff44ff', '#44ffff', '#ffffff' },
  tab_bar = {
    background = '#005a9e',
    active_tab = { bg_color = '#00a4ef', fg_color = '#001f3f', intensity = 'Bold' },
  },
}
"@
        }
    }

    $luaFooter = @"
return config
"@

    $full = $luaHeader + "`n" + $colors + "`n" + $luaFooter
    $full | Out-File -FilePath $Global:ConfigFile -Encoding utf8 -Force

    $fontDisplay = switch ($fontChoice) {
        '2' { 'Consolas' }
        '3' { 'Courier New' }
        default { 'Cascadia Code' }
    }

    Write-Host "`nConfig written to: $Global:ConfigFile" -ForegroundColor Green
    Write-Host "  Theme: $Name" -ForegroundColor Cyan
    Write-Host "  Font: $fontDisplay" -ForegroundColor Cyan
    Write-Host "  Shell: $ShellDisplay" -ForegroundColor Cyan
    Write-Host "  Title bar: $(if ($Decor -like '*TITLE*') { 'ON' } else { 'OFF' })`n" -ForegroundColor Cyan

    $open = Read-Host "Open config in Notepad? (y/N)"
    if ($open -match '^[Yy]') { Start-Process notepad.exe -ArgumentList $Global:ConfigFile }
    Wait-AnyKey
}

function Uninstall-Wezterm {
    Write-Host "Remove Wezterm and config" -ForegroundColor Cyan
    $confirm = Read-Host "This will attempt to uninstall WezTerm and remove $Global:ConfigFile. Continue? (y/N)"
    if ($confirm -notmatch '^[Yy]') { Write-Host "Cancelled." -ForegroundColor Yellow; Wait-AnyKey; return }

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        try {
            Start-Process -FilePath 'winget' -ArgumentList @('uninstall','--id','WezTerm.WezTerm','-e') -NoNewWindow -Wait -ErrorAction Stop
        } catch { Write-Host "winget uninstall failed or package not found." -ForegroundColor Yellow }
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        try { Start-Process -FilePath 'choco' -ArgumentList @('uninstall','wezterm','-y') -NoNewWindow -Wait -ErrorAction Stop } catch { Write-Host "choco uninstall failed or package not found." -ForegroundColor Yellow }
    } else {
        Write-Host "No supported package manager found. Removal of binary must be manual." -ForegroundColor Yellow
    }

    if (Test-Path $Global:ConfigFile) {
        Backup-File -Path $Global:ConfigFile
        Remove-Item -Path $Global:ConfigFile -Force
        Write-Host "Removed config: $Global:ConfigFile" -ForegroundColor Green
    } else {
        Write-Host "No config file found at $Global:ConfigFile" -ForegroundColor DarkGray
    }
    Wait-AnyKey
}

function Show-Menu {
    Clear-Host
    Show-Logo
    # Themed border and title
    $borderColor = 'Cyan'
    $title = ' Main Menu '
    $width = 50
    $pad = ($width - $title.Length) / 2.0
    $left = [int][math]::Floor($pad)
    $right = $width - $title.Length - $left
    $hline = [string]::new([char]0x2550, [int]$width)    # '═' repeated
    $spacesLeft = [string]::new([char]32, [int]$left)
    $spacesRight = [string]::new([char]32, [int]$right)
    $top = '╔' + $hline + '╗'
    $mid = '║' + $spacesLeft + $title + $spacesRight + '║'
    $sep = '╠' + $hline + '╣'
    $bottom = '╚' + $hline + '╝'

    Write-Host $top -ForegroundColor $borderColor
    Write-Host $mid -ForegroundColor $borderColor
    Write-Host $sep -ForegroundColor $borderColor
    Write-Host ('║' + ' 1) Install WezTerm for Windows'.PadRight($width) + '║') -ForegroundColor White
    Write-Host ('║' + ' 2) Config Setup'.PadRight($width) + '║') -ForegroundColor White
    Write-Host ('║' + ' 3) Remove / Uninstall WezTerm and Config'.PadRight($width) + '║') -ForegroundColor White
    Write-Host ('║' + ' 4) Exit'.PadRight($width) + '║') -ForegroundColor White
    Write-Host $bottom -ForegroundColor $borderColor
}

# Main loop
while ($true) {
    Show-Menu
    $sel = Read-Host "Select an option [1-4]"
    switch ($sel) {
        '1' { Install-Wezterm }
        '2' { Set-WeztermConfig }
        '3' { Uninstall-Wezterm }
        '4' { Write-Host "Goodbye." -ForegroundColor Gray; exit 0 }
        default { Write-Host "Invalid selection." -ForegroundColor Red; Wait-AnyKey }
    }
}

exit 0