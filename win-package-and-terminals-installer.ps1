# Windows Package Managers & Terminals Installer
# PowerShell script with beautiful text UI (Microsoft brand colors)
# Supports install/uninstall of Chocolatey, Scoop, Winget, UniGetUI + popular terminals via Winget

$esc = [char]27
# Microsoft Brand Colors
$MS_BLUE = "$esc[38;2;0;120;215m"        # Microsoft Blue
$MS_LIGHT_BLUE = "$esc[38;2;80;160;240m" # Light Blue
$WHITE = "$esc[38;2;255;255;255m"
$LIGHT_GRAY = "$esc[38;2;220;220;220m"
$GRAY = "$esc[38;2;150;150;150m"
$GREEN = "$esc[38;2;16;124;16m"          # Success Green
$RED = "$esc[38;2;232;17;35m"            # Error Red
$YELLOW = "$esc[38;2;255;185;0m"         # Warning Yellow
$ORANGE = "$esc[38;2;247;99;12m"         # Orange
$CYAN = "$esc[38;2;0;183;195m"           # Cyan
$RESET = "$esc[0m"
$BOLD = "$esc[1m"

# Check for installed package managers
$hasWinget = $false
$hasScoop = $false
$hasChoco = $false
$hasPwsh7 = $false

# Check Winget with multiple methods
try {
    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetCmd) {
        $hasWinget = $true
    } else {
        # Try alternative path
        $wingetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
        if (Test-Path $wingetPath) {
            $hasWinget = $true
        }
    }
} catch {
    $hasWinget = $false
}

# Check Scoop
try {
    $hasScoop = (Get-Command scoop -ErrorAction SilentlyContinue) -ne $null
} catch {
    $hasScoop = $false
}

# Check Chocolatey
try {
    $hasChoco = (Get-Command choco -ErrorAction SilentlyContinue) -ne $null
} catch {
    $hasChoco = $false
}

# Check PowerShell 7
try {
    $pwsh7Cmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh7Cmd) {
        $hasPwsh7 = $true
    } else {
        # Check common installation paths
        $pwsh7Paths = @(
            "$env:ProgramFiles\PowerShell\7\pwsh.exe",
            "$env:ProgramFiles\PowerShell\6\pwsh.exe"
        )
        foreach ($path in $pwsh7Paths) {
            if (Test-Path $path) {
                $hasPwsh7 = $true
                break
            }
        }
    }
} catch {
    $hasPwsh7 = $false
}

function print_header($Text) {
    $cols = $Host.UI.RawUI.WindowSize.Width
    if (-not $cols -or $cols -lt 60) { $cols = 80 }
    $line = '═' * ($cols - 2)
    
    # Windows Flag Logo (ASCII Art)
    Write-Host ""
    Write-Host "$MS_BLUE$BOLD                 ██████████████  ██████████████$RESET"
    Write-Host "$MS_BLUE$BOLD                 ██████████████  ██████████████$RESET"
    Write-Host "$MS_BLUE$BOLD                 ██████████████  ██████████████$RESET"
    Write-Host "$MS_BLUE$BOLD                 ██████████████  ██████████████$RESET"
    Write-Host "$MS_BLUE$BOLD                 ██████████████  ██████████████$RESET"
    Write-Host ""
    Write-Host "$MS_LIGHT_BLUE$BOLD                 ██████████████  ██████████████$RESET"
    Write-Host "$MS_LIGHT_BLUE$BOLD                 ██████████████  ██████████████$RESET"
    Write-Host "$MS_LIGHT_BLUE$BOLD                 ██████████████  ██████████████$RESET"
    Write-Host "$MS_LIGHT_BLUE$BOLD                 ██████████████  ██████████████$RESET"
    Write-Host "$MS_LIGHT_BLUE$BOLD                 ██████████████  ██████████████$RESET"
    Write-Host ""
    Write-Host "$MS_BLUE$BOLD            Windows Package Manager Installer$RESET"
    Write-Host ""
    
    Write-Host "$MS_BLUE$BOLD╔$line╗$RESET"
    $padding = [Math]::Floor(($cols - $Text.Length - 2) / 2)
    $left = " " * $padding
    $right = " " * ($cols - $Text.Length - 2 - $padding)
    Write-Host "$MS_BLUE$BOLD║$left$WHITE$BOLD$Text$right$MS_BLUE$BOLD║$RESET"
    Write-Host "$MS_BLUE$BOLD╚$line╝$RESET`n"
}

function print_section($Text) {
    Write-Host "`n$MS_LIGHT_BLUE$BOLD> $Text$RESET"
    Write-Host "$GRAY$('-' * 50)$RESET"
}

function print_status($Text) { Write-Host "$CYAN>$RESET $WHITE$Text$RESET" }
function print_success($Text) { Write-Host "$GREEN[OK]$RESET $WHITE$Text$RESET" }
function print_error($Text) { Write-Host "$RED[X]$RESET $WHITE$Text$RESET" }
function print_warning($Text) { Write-Host "$YELLOW[!]$RESET $WHITE$Text$RESET" }
function print_info($Text) { Write-Host "$CYAN[i]$RESET $WHITE$Text$RESET" }

function Get-SingleKey {
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
}

$pmList = @(
    [PSCustomObject]@{Id="winget";Name="Winget";Desc="Microsoft's official Windows Package Manager"}
    [PSCustomObject]@{Id="chocolatey";Name="Chocolatey";Desc="Classic package manager for Windows"}
    [PSCustomObject]@{Id="scoop";Name="Scoop";Desc="Lightweight command-line installer (no admin required)"}
    [PSCustomObject]@{Id="unigetui";Name="UniGetUI";Desc="Beautiful GUI for Winget/Scoop/Chocolatey"}
)

$terminalsList = @(
    [PSCustomObject]@{Id="alacritty";Name="Alacritty";Desc="Fast, cross-platform, OpenGL terminal emulator";WingetId="Alacritty.Alacritty"}
    [PSCustomObject]@{Id="wezterm";Name="WezTerm";Desc="GPU-accelerated terminal written in Rust";WingetId="wez.wezterm"}
    [PSCustomObject]@{Id="windowsterminal";Name="Windows Terminal";Desc="Modern Microsoft terminal with tabs and panes";WingetId="Microsoft.WindowsTerminal"}
    [PSCustomObject]@{Id="warp";Name="Warp";Desc="Modern Rust-based terminal with AI features";WingetId="Warp.Warp"}
)

function Get-IsPMInstalled($id) {
    switch ($id) {
        'chocolatey' { return $hasChoco }
        'scoop' { return $hasScoop }
        'winget' { 
            # Re-check winget status
            try {
                $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
                if ($wingetCmd) { return $true }
                
                $wingetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
                if (Test-Path $wingetPath) { return $true }
                
                return $false
            } catch {
                return $false
            }
        }
        'unigetui' { 
            if (-not $hasWinget) { return $false }
            try {
                return (winget list -e --id MartiCliment.UniGetUI 2>$null | Select-String -Quiet "MartiCliment.UniGetUI")
            } catch {
                return $false
            }
        }
    }
    return $false
}

function Show-PackageManagers {
    while ($true) {
        Clear-Host
        print_header "Package Managers"

        print_section "Available Package Managers"

        for ($i = 0; $i -lt $pmList.Count; $i++) {
            $app = $pmList[$i]
            $status = if ((Get-IsPMInstalled $app.Id)) { "$GREEN[+]$RESET" } else { "   " }
            Write-Host "$MS_BLUE$BOLD$($i+1).$RESET $status $WHITE$($app.Name.PadRight(15))$GRAY$($app.Desc)$RESET"
        }

        Write-Host ""
        print_section "Navigation"
        Write-Host "$MS_LIGHT_BLUE$BOLD 1-$($pmList.Count)$RESET $WHITE to view details / install/uninstall$RESET"
        Write-Host "$RED$BOLD b$RESET $WHITE back to main menu$RESET"

        Write-Host ""
        Write-Host -NoNewline "$MS_LIGHT_BLUE$BOLD Your choice: $RESET"
        $choice = Read-Host

        if ($choice -match "^[bB]$") { return }

        if ([int]::TryParse($choice, [ref]$null) -and $choice -ge 1 -and $choice -le $pmList.Count) {
            Show-PMDetails ($choice - 1)
        } else {
            print_warning "Invalid choice"
            Start-Sleep -Milliseconds 800
        }
    }
}

function Show-PMDetails($index) {
    $app = $pmList[$index]
    Clear-Host
    print_header "$($app.Name) Details"

    $installed = Get-IsPMInstalled $app.Id

    Write-Host "$MS_LIGHT_BLUE${BOLD}Package:$RESET $WHITE$($app.Name)$RESET"
    Write-Host "$MS_LIGHT_BLUE${BOLD}Status:$RESET $(if ($installed) {"$GREEN Installed$RESET"} else {"$RED Not installed$RESET"})"
    Write-Host "$MS_LIGHT_BLUE${BOLD}Description:$RESET $WHITE$($app.Desc)$RESET"
    Write-Host ""

    if ($app.Id -eq "winget") {
        if ($hasWinget) {
            print_success "Winget is already installed"
        } else {
            print_error "Winget is not installed"
            Write-Host ""
            Write-Host "$MS_LIGHT_BLUE${BOLD}Installation Options:$RESET"
            Write-Host "$CYAN[1]$RESET Install via Microsoft Store (Recommended)"
            Write-Host "$CYAN[2]$RESET Download from GitHub releases"
            Write-Host "$CYAN[3]$RESET Use direct download link"
            Write-Host "$MS_BLUE$BOLD[b]$RESET Back"
            Write-Host ""
            
            while ($true) {
                $key = Get-SingleKey
                if ($key -eq '1') {
                    print_info "Opening Microsoft Store..."
                    Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1"
                    print_success "Please install 'App Installer' from the Store"
                    break
                } elseif ($key -eq '2') {
                    print_info "Opening GitHub releases page..."
                    Start-Process "https://github.com/microsoft/winget-cli/releases/latest"
                    print_info "Download and install the .msixbundle file"
                    break
                } elseif ($key -eq '3') {
                    print_info "Opening direct download link..."
                    Start-Process "https://aka.ms/getwinget"
                    print_success "Download will start automatically"
                    break
                } elseif ($key -match '[bB]') {
                    return
                }
            }
        }
        
        Write-Host "`n$WHITE Press any key to return...$RESET"
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    if ($app.Id -eq "unigetui" -and -not $hasWinget) {
        print_error "Winget is required to install UniGetUI"
        Write-Host "`n$WHITE Press any key to return...$RESET"
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    if ($installed) {
        print_success "Already installed"
        Write-Host "`n$YELLOW$BOLD Actions:$RESET"
        Write-Host "$RED$BOLD [u]$RESET Uninstall"
        Write-Host "$MS_BLUE$BOLD [b]$RESET Back"
        while ($true) {
            $key = Get-SingleKey
            if ($key -match '[uU]') { Uninstall-PM $app.Id ; break }
            if ($key -match '[bB]') { return }
        }
    } else {
        Write-Host "`n$MS_BLUE$BOLD╔$('═' * 58)╗$RESET"
        Write-Host "$MS_BLUE$BOLD║$YELLOW$BOLD    Do you want to install $($app.Name)?          $MS_BLUE$BOLD║$RESET"
        Write-Host "$MS_BLUE$BOLD╚$('═' * 58)╝$RESET"
        Write-Host "`n$GREEN$BOLD [y]$RESET Install   $RED$BOLD [b]$RESET Back"
        while ($true) {
            $key = Get-SingleKey
            if ($key -match '[yY]') { Install-PM $app.Id ; break }
            if ($key -match '[bB]') { return }
        }
    }

    Write-Host "`n$WHITE Press any key to continue...$RESET"
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Install-PM($id) {
    if ($id -eq "chocolatey") {
        print_section "Installing Chocolatey (requires admin)"
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        print_success "Chocolatey installed! Restart terminal for 'choco' command."
        $global:hasChoco = $true
    } elseif ($id -eq "scoop") {
        print_section "Installing Scoop (no admin needed)"
        irm get.scoop.sh | iex
        print_success "Scoop installed! Restart terminal for 'scoop' command."
        $global:hasScoop = $true
    } elseif ($id -eq "unigetui") {
        print_section "Installing UniGetUI"
        winget install -e --id MartiCliment.UniGetUI --accept-package-agreements --accept-source-agreements 2>&1 | ForEach-Object {
            if ($_ -match "Downloading|Installing|Hash") { Write-Host "$ORANGE [*] $_$RESET" } else { Write-Host "$GRAY$_$RESET" }
        }
        if ($LASTEXITCODE -eq 0) { print_success "UniGetUI installed!" } else { print_error "Installation failed" }
    }
}

function Uninstall-PM($id) {
    if ($id -eq "chocolatey") {
        print_warning "Uninstall Chocolatey manually: Remove-Item `"$env:ChocolateyInstall`" -Recurse -Force"
    } elseif ($id -eq "scoop") {
        print_section "Uninstalling Scoop"
        scoop uninstall scoop
        Remove-Item "$env:USERPROFILE\scoop" -Recurse -Force -ErrorAction SilentlyContinue
        print_success "Scoop uninstalled"
        $global:hasScoop = $false
    } elseif ($id -eq "unigetui") {
        print_section "Uninstalling UniGetUI"
        winget uninstall -e --id MartiCliment.UniGetUI 2>&1 | ForEach-Object { Write-Host "$GRAY$_$RESET" }
    }
}

# ======================= Terminals =======================

function Show-Terminals {
    if (-not $hasWinget) {
        Clear-Host
        print_header "Terminals"
        print_warning "Winget not detected — recommended for installing terminals"
        print_info "Go to 'Package Managers' → install Winget or UniGetUI first"
        Write-Host "`nPress any key to return..."
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    while ($true) {
        Clear-Host
        print_header "Terminals"

        print_section "Available Terminals"

        for ($i = 0; $i -lt $terminalsList.Count; $i++) {
            $app = $terminalsList[$i]
            $status = if ((winget list -e --id $app.WingetId 2>$null | Select-String -Quiet $app.WingetId)) { "$GREEN[+]$RESET" } else { "   " }
            Write-Host "$MS_BLUE$BOLD$($i+1).$RESET $status $WHITE$($app.Name.PadRight(20))$GRAY$($app.Desc)$RESET"
        }

        Write-Host ""
        print_section "Navigation"
        Write-Host "$MS_LIGHT_BLUE$BOLD 1-$($terminalsList.Count)$RESET $WHITE select to view details$RESET"
        Write-Host "$RED$BOLD b$RESET $WHITE back to main menu$RESET"

        Write-Host ""
        Write-Host -NoNewline "$MS_LIGHT_BLUE$BOLD Your choice: $RESET"
        $choice = Read-Host

        if ($choice -match "^[bB]$") { return }

        if ([int]::TryParse($choice, [ref]$null) -and $choice -ge 1 -and $choice -le $terminalsList.Count) {
            Show-TerminalDetails ($choice - 1)
        } else {
            print_warning "Invalid choice"
            Start-Sleep -Milliseconds 800
        }
    }
}

function Show-TerminalDetails($index) {
    $app = $terminalsList[$index]
    $installed = (winget list -e --id $app.WingetId 2>$null | Select-String -Quiet $app.WingetId)

    Clear-Host
    print_header "$($app.Name) Details"

    Write-Host "$MS_LIGHT_BLUE${BOLD}Terminal:$RESET $WHITE$($app.Name)$RESET"
    Write-Host "$MS_LIGHT_BLUE${BOLD}Winget ID:$RESET $LIGHT_GRAY$($app.WingetId)$RESET"
    Write-Host "$MS_LIGHT_BLUE${BOLD}Description:$RESET $WHITE$($app.Desc)$RESET"
    Write-Host ""

    if ($installed) {
        print_success "Already installed"
        Write-Host "`n$YELLOW$BOLD Actions:$RESET"
        Write-Host "$RED$BOLD [r] Reinstall$RESET"
        Write-Host "$RED$BOLD [u] Uninstall$RESET"
        Write-Host "$MS_BLUE$BOLD [b] Back$RESET"
    } else {
        Write-Host "$MS_BLUE$BOLD╔$('═' * 60)╗$RESET"
        Write-Host "$MS_BLUE$BOLD║$YELLOW$BOLD     Install $($app.Name)?                     $MS_BLUE$BOLD║$RESET"
        Write-Host "$MS_BLUE$BOLD╚$('═' * 60)╝$RESET"
        Write-Host "`n$GREEN$BOLD [y] Install$RESET  $RED$BOLD [b] Back$RESET"
    }

    while ($true) {
        $key = Get-SingleKey
        if ($installed -and $key -match '[rRuUbB]') {
            if ($key -match '[rR]') { Reinstall-Terminal $app.WingetId $app.Name }
            if ($key -match '[uU]') { Uninstall-Terminal $app.WingetId $app.Name }
            if ($key -match '[bB]') { return }
        } elseif (-not $installed -and $key -match '[yY]') {
            Install-Terminal $app.WingetId $app.Name
            break
        } elseif ($key -match '[bB]') { return }
    }

    Write-Host "`n$WHITE Press any key to continue...$RESET"
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Install-Terminal($id, $name) {
    print_section "Installing $name"
    print_status "Using winget..."
    winget install -e --id $id --accept-package-agreements --accept-source-agreements 2>&1 | ForEach-Object {
        if ($_ -match "Downloading|Installing|Hash") { Write-Host "$ORANGE ⟳ $_$RESET" } else { Write-Host "$GRAY$_$RESET" }
    }
    if ($LASTEXITCODE -eq 0) { print_success "$name installed!" } else { print_error "Failed" }
}

function Reinstall-Terminal($id, $name) {
    print_section "Reinstalling $name"
    winget uninstall -e --id $id --silent 2>&1 | ForEach-Object { Write-Host "$GRAY$_$RESET" }
    Install-Terminal $id $name
}

function Uninstall-Terminal($id, $name) {
    print_section "Uninstalling $name"
    winget uninstall -e --id $id 2>&1 | ForEach-Object { Write-Host "$GRAY$_$RESET" }
    if ($LASTEXITCODE -eq 0) { print_success "$name uninstalled" } else { print_error "Failed" }
}

# ======================= Extras =======================

function Show-Extras {
    while ($true) {
        Clear-Host
        print_header "Extras"

        print_section "Available Tools"

        Write-Host "$MS_BLUE$BOLD 1.$RESET $WHITE Setup Winget for Terminal$RESET"
        Write-Host "    $GRAY Fix PATH and enable Winget command in terminal$RESET"
        Write-Host ""
        Write-Host "$MS_BLUE$BOLD 2.$RESET $WHITE Install Microsoft UI XAML 2.7$RESET"
        Write-Host "    $GRAY Required dependency for some Windows apps$RESET"
        Write-Host ""
        Write-Host "$MS_BLUE$BOLD 3.$RESET $WHITE PowerShell 7$RESET"
        $pwsh7Status = if ($hasPwsh7) { "$GREEN [Installed]$RESET" } else { "$RED [Not Installed]$RESET" }
        Write-Host "    $GRAY Modern cross-platform PowerShell $pwsh7Status$RESET"

        Write-Host ""
        print_section "Navigation"
        Write-Host "$MS_LIGHT_BLUE$BOLD 1-3$RESET $WHITE select option$RESET"
        Write-Host "$RED$BOLD b$RESET $WHITE back to main menu$RESET"

        Write-Host ""
        Write-Host -NoNewline "$MS_LIGHT_BLUE$BOLD Your choice: $RESET"
        $choice = Read-Host

        if ($choice -match "^[bB]$") { return }

        if ($choice -eq "1") { Setup-WingetForTerminal }
        elseif ($choice -eq "2") { Install-MicrosoftUIXaml }
        elseif ($choice -eq "3") { Show-PowerShell7Details }
        else {
            print_warning "Invalid choice"
            Start-Sleep -Milliseconds 800
        }
    }
}

function Setup-WingetForTerminal {
    Clear-Host
    print_header "Setup Winget for Terminal"

    # Re-check winget installation
    $wingetInstalled = $false
    try {
        $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
        if ($wingetCmd) {
            $wingetInstalled = $true
        } else {
            $wingetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
            if (Test-Path $wingetPath) {
                $wingetInstalled = $true
            }
        }
    } catch {
        $wingetInstalled = $false
    }

    if (-not $wingetInstalled) {
        print_error "Winget is not installed"
        print_info "Please install Winget first from Package Managers menu"
        Write-Host "`n$WHITE Press any key to return...$RESET"
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    print_section "Setting up Winget for Terminal"
    print_status "Adding Winget to PATH..."
    
    # Add Winget to PATH
    $wingetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    if ($currentPath -notlike "*$wingetPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$wingetPath", "User")
        print_success "Added Winget to PATH"
    } else {
        print_info "Winget already in PATH"
    }
    
    # Refresh environment variables in current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    print_status "Registering App Execution Alias..."
    
    # Enable App Execution Alias for winget
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (Test-Path $registryPath) {
        Set-ItemProperty -Path $registryPath -Name "EnableAppExecutionAliases" -Value 1 -ErrorAction SilentlyContinue
        print_success "App Execution Aliases enabled"
    }
    
    print_status "Testing winget command..."
    try {
        $wingetVersion = winget --version
        print_success "Winget is working! Version: $wingetVersion"
        print_info "Please restart your terminal for changes to take full effect"
        $global:hasWinget = $true
    } catch {
        print_warning "Please restart your terminal and try again"
    }

    Write-Host "`n$WHITE Press any key to continue...$RESET"
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Install-MicrosoftUIXaml {
    Clear-Host
    print_header "Install Microsoft UI XAML 2.7"

    print_section "About Microsoft UI XAML 2.7"
    print_info "This is a required dependency for many Windows applications"
    print_info "Including some apps that use modern Windows UI components"
    Write-Host ""

    print_status "Downloading Microsoft.UI.Xaml.2.7..."
    
    $downloadUrl = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.0"
    $tempPath = "$env:TEMP\Microsoft.UI.Xaml.2.7.zip"
    $extractPath = "$env:TEMP\Microsoft.UI.Xaml.2.7"
    
    try {
        # Download the package
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing
        print_success "Downloaded successfully"
        
        # Extract the package
        print_status "Extracting package..."
        Expand-Archive -Path $tempPath -DestinationPath $extractPath -Force
        
        # Find and install the appropriate appx file
        print_status "Installing XAML package..."
        $appxFiles = Get-ChildItem -Path $extractPath -Filter "*.appx" -Recurse
        
        $installed = $false
        foreach ($appx in $appxFiles) {
            if ($appx.Name -match "x64" -or $appx.Name -match "Microsoft.UI.Xaml") {
                try {
                    Add-AppxPackage -Path $appx.FullName -ErrorAction Stop
                    print_success "Microsoft UI XAML 2.7 installed successfully!"
                    $installed = $true
                    break
                } catch {
                    # Try next file if this one fails
                }
            }
        }
        
        if (-not $installed) {
            print_error "Could not install XAML package automatically"
            print_info "Package extracted to: $extractPath"
            print_info "You can install manually by right-clicking the .appx file"
        }
        
        # Cleanup
        Remove-Item -Path $tempPath -Force -ErrorAction SilentlyContinue
        
    } catch {
        print_error "Installation failed: $_"
        print_info "You can download manually from:"
        print_info "https://www.nuget.org/packages/Microsoft.UI.Xaml/"
    }

    Write-Host "`n$WHITE Press any key to continue...$RESET"
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-PowerShell7Details {
    Clear-Host
    print_header "PowerShell 7"

    # Re-check PowerShell 7 installation
    $pwsh7Installed = $false
    $pwsh7Version = $null
    
    try {
        $pwsh7Cmd = Get-Command pwsh -ErrorAction SilentlyContinue
        if ($pwsh7Cmd) {
            $pwsh7Installed = $true
            $pwsh7Version = & pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>$null
        } else {
            # Check common installation paths
            $pwsh7Paths = @(
                "$env:ProgramFiles\PowerShell\7\pwsh.exe",
                "$env:ProgramFiles\PowerShell\6\pwsh.exe"
            )
            foreach ($path in $pwsh7Paths) {
                if (Test-Path $path) {
                    $pwsh7Installed = $true
                    $pwsh7Version = & $path -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>$null
                    break
                }
            }
        }
    } catch {
        $pwsh7Installed = $false
    }

    Write-Host "$MS_LIGHT_BLUE${BOLD}Application:$RESET $WHITE PowerShell 7$RESET"
    Write-Host "$MS_LIGHT_BLUE${BOLD}Status:$RESET $(if ($pwsh7Installed) {"$GREEN Installed$RESET"} else {"$RED Not installed$RESET"})"
    if ($pwsh7Version) {
        Write-Host "$MS_LIGHT_BLUE${BOLD}Version:$RESET $WHITE$pwsh7Version$RESET"
    }
    Write-Host "$MS_LIGHT_BLUE${BOLD}Description:$RESET $WHITE Modern, cross-platform PowerShell$RESET"
    Write-Host ""

    if ($pwsh7Installed) {
        print_success "PowerShell 7 is already installed"
        print_info "You can launch it by typing 'pwsh' in your terminal"
        Write-Host "`n$YELLOW$BOLD Actions:$RESET"
        Write-Host "$CYAN[u]$RESET Update/Reinstall PowerShell 7"
        Write-Host "$MS_BLUE$BOLD[b]$RESET Back"
        
        while ($true) {
            $key = Get-SingleKey
            if ($key -match '[uU]') { Install-PowerShell7 ; break }
            if ($key -match '[bB]') { return }
        }
    } else {
        Write-Host "`n$MS_BLUE$BOLD╔$('═' * 60)╗$RESET"
        Write-Host "$MS_BLUE$BOLD║$YELLOW$BOLD     Install PowerShell 7?                        $MS_BLUE$BOLD║$RESET"
        Write-Host "$MS_BLUE$BOLD╚$('═' * 60)╝$RESET"
        Write-Host "`n$GREEN$BOLD [y] Install$RESET  $RED$BOLD [b] Back$RESET"
        
        while ($true) {
            $key = Get-SingleKey
            if ($key -match '[yY]') { Install-PowerShell7 ; break }
            if ($key -match '[bB]') { return }
        }
    }

    Write-Host "`n$WHITE Press any key to continue...$RESET"
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Install-PowerShell7 {
    print_section "Installing PowerShell 7"
    
    print_status "Downloading PowerShell 7 installer..."
    
    try {
        # Download and run the install script from Microsoft
        print_info "Using official Microsoft installation script"
        
        $installScript = Invoke-WebRequest -Uri "https://aka.ms/install-powershell.ps1" -UseBasicParsing
        
        print_status "Running installer..."
        Invoke-Expression $installScript.Content
        
        print_success "PowerShell 7 installation completed!"
        print_info "You can launch PowerShell 7 by typing 'pwsh' in your terminal"
        print_info "Restart your terminal to use the 'pwsh' command"
        
        $global:hasPwsh7 = $true
        
    } catch {
        print_error "Automatic installation failed"
        print_info "Trying alternative method..."
        
        try {
            # Alternative: Download MSI directly
            $downloadUrl = "https://github.com/PowerShell/PowerShell/releases/latest/download/PowerShell-7-win-x64.msi"
            $msiPath = "$env:TEMP\PowerShell-7-win-x64.msi"
            
            print_status "Downloading MSI installer..."
            Invoke-WebRequest -Uri $downloadUrl -OutFile $msiPath -UseBasicParsing
            
            print_status "Launching installer..."
            Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1" -Wait
            
            print_success "PowerShell 7 installed successfully!"
            print_info "Restart your terminal to use the 'pwsh' command"
            
            # Cleanup
            Remove-Item -Path $msiPath -Force -ErrorAction SilentlyContinue
            
            $global:hasPwsh7 = $true
            
        } catch {
            print_error "Installation failed: $_"
            print_info "Please install manually from:"
            print_info "https://github.com/PowerShell/PowerShell/releases/latest"
        }
    }
}

# ======================= Main =======================

while ($true) {
    Clear-Host
    print_header "Windows Tools Installer"

    print_section "Categories"

    Write-Host "$MS_BLUE$BOLD 1.$RESET $WHITE Package Managers$RESET"
    Write-Host "$MS_BLUE$BOLD 2.$RESET $WHITE Terminals$RESET"
    Write-Host "$MS_BLUE$BOLD 3.$RESET $WHITE Extras$RESET"

    Write-Host ""
    $detected = (@(
        if($hasWinget){"Winget"} 
        if($hasScoop){"Scoop"} 
        if($hasChoco){"Chocolatey"}
        if($hasPwsh7){"PowerShell 7"}
    ) -join ", ")
    if ($detected) { print_info "Detected: $detected" } else { print_warning "No package manager detected" }

    Write-Host ""
    Write-Host "$RED$BOLD b$RESET $WHITE Quit$RESET"
    Write-Host ""
    Write-Host -NoNewline "$MS_LIGHT_BLUE$BOLD Select category: $RESET"
    $choice = Read-Host

    if ($choice -eq "1") { Show-PackageManagers }
    elseif ($choice -eq "2") { Show-Terminals }
    elseif ($choice -eq "3") { Show-Extras }
    elseif ($choice -match "^[bB]$") {
        Clear-Host
        print_header "Goodbye!"
        Write-Host "$WHITE Thank you for using Windows Tools Installer!$RESET`n"
        break
    } else {
        print_warning "Invalid choice"
        Start-Sleep -Milliseconds 800
    }
}