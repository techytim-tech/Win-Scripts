# Windows Package Managers & Terminals Installer
# PowerShell version of the original Flatpak installer with beautiful text UI (Fedora colors)
# Supports install/uninstall of Chocolatey, Scoop, Winget, UniGetUI + popular terminals via Winget

$esc = [char]27
$FEDORA_BLUE = "$esc[38;2;60;110;180m"
$FEDORA_LIGHT_BLUE = "$esc[38;2;123;159;210m"
$WHITE = "$esc[38;2;255;255;255m"
$LIGHT_GRAY = "$esc[38;2;220;220;220m"
$GRAY = "$esc[38;2;180;180;180m"
$GREEN = "$esc[38;2;115;210;115m"
$RED = "$esc[38;2;240;85;85m"
$YELLOW = "$esc[38;2;250;200;80m"
$ORANGE = "$esc[38;2;250;150;50m"
$CYAN = "$esc[38;2;100;200;230m"
$RESET = "$esc[0m"
$BOLD = "$esc[1m"

$hasWinget = (Get-not (Get-Command winget -ErrorAction SilentlyContinue)) -eq $false
$hasScoop = (Get-Command scoop -ErrorAction SilentlyContinue) -ne $null
$hasChoco = (Get-Command choco -ErrorAction SilentlyContinue) -ne $null

function print_header($Text) {
    $cols = $Host.UI.RawUI.WindowSize.Width
    if (-not $cols -or $cols -lt 60) { $cols = 80 }
    $line = '═' * ($cols - 2)
    Write-Host "$FEDORA_BLUE$BOLD╔$line╗$RESET"
    $padding = [Math]::Floor(($cols - $Text.Length - 2) / 2)
    $left = " " * $padding
    $right = " " * ($cols - $Text.Length - 2 - 2 * $padding)
    Write-Host "$FEDORA_BLUE$BOLD║$left$WHITE$BOLD$Text$RESET$right$FEDORA_BLUE$BOLD║$RESET"
    Write-Host "$FEDORA_BLUE$BOLD╚$line╝$RESET`n"
}

function print_section($Text) {
    Write-Host "`n$FEDORA_LIGHT_BLUE$BOLD▶ $Text$RESET"
    Write-Host "$GRAY$('─' * 50)$RESET"
}

function print_status($Text) { Write-Host "$CYAN➜$RESET $WHITE$Text$RESET" }
function print_success($Text) { Write-Host "$GREEN✓$RESET $WHITE$Text$RESET" }
function print_error($Text) { Write-Host "$RED✗$RESET $WHITE$Text$RESET" }
function print_warning($Text) { Write-Host "$YELLOW⚠$RESET $WHITE$Text$RESET" }
function print_info($Text) { Write-Host "$CYANℹ$RESET $WHITE$Text$RESET" }

function Get-SingleKey {
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
}

$pmList = @(
    [PSCustomObject]@{Id="chocolatey";Name="Chocolatey";Desc="Classic package manager for Windows"}
    [PSCustomObject]@{Id="scoop";Name="Scoop";Desc="Lightweight command-line installer (no admin required)"}
    [PSCustomObject]@{Id="winget";Name="Winget";Desc="Microsoft's official Windows Package Manager"}
    [PSCustomObject]@{Id="unigetui";Name="UniGetUI";Desc="Beautiful GUI for Winget/Scoop/Chocolatey"}
)

$terminalsList = @(
    [PSCustomObject]@{Id="alacritty";Name="Alacritty";Desc="Fast, cross-platform, OpenGL terminal emulator";WingetId="Alacritty.Alacritty"}
    [PSCustomObject]@{Id="wezterm";Name="WezTerm";Desc="GPU-accelerated terminal written in Rust";WingetId="Wez.WezTerm"}
    [PSCustomObject]@{Id="windowsterminal";Name="Windows Terminal";Desc="Modern Microsoft terminal with tabs & panes";WingetId="Microsoft.WindowsTerminal"}
    [PSCustomObject]@{Id="warp";Name="Warp";Desc="Modern Rust-based terminal with AI features";WingetId="Warp.Warp"}
)

function Show-PackageManagers {
    while ($true) {
        Clear-Host
        print_header "Package Managers"

        print_section "Available Package Managers"

        for ($i = 0; $i -lt $pmList.Count; $i++) {
            $app = $pmList[$i]
            $status = if ((Get-IsPMInstalled $app.Id)) { "$GREEN✓$RESET" } else { " " }
            Write-Host "$FEDORA_BLUE$BOLD$( $i+1 ).$RESET $status $WHITE$($app.Name.PadRight(15))$GRAY$app.Desc$RESET"
        }

        Write-Host ""
        print_section "Navigation"
        Write-Host "$FEDORA_LIGHT_BLUE$BOLD 1-$( $pmList.Count )$RESET $WHITE to view details / install/uninstall$RESET"
        Write-Host "$RED$BOLD q$RESET $WHITE back to main menu$RESET"

        Write-Host ""
        Write-Host -NoNewline "$FEDORA_LIGHT_BLUE$BOLD Your choice: $RESET"
        $choice = Read-Host

        if ($choice -match "^qQ]$") { return }

        if ([int]::TryParse($choice, [ref]$null) -and $choice -ge 1 -and $choice -le $pmList.Count) {
            Show-PMDetails ($choice - 1)
        } else {
            print_warning "Invalid choice"
            Start-Sleep -Milliseconds 800
        }
    }
}

function Get-IsPMInstalled($id) {
    switch ($id -eq 'chocolatey') { return $hasChoco }
    ($id -eq 'scoop') { return $hasScoop }
    ($id -eq 'winget') { return $hasWinget }
    ($id -eq 'unigetui') { 
        if (-not $hasWinget) { return $false }
        return (winget list -e --id MartiCliment.UniGetUI 2>$null | Select-String -Quiet "MartiCliment.UniGetUI")
    }
}

function Show-PMDetails($index) {
    $app = $pmList[$index]
    Clear-Host
    print_header "$($app.Name) Details"

    $installed = Get-IsPMInstalled $app.Id

    Write-Host "$FEDORA_LIGHT_BLUE$BOLDPackage:$RESET $WHITE$app.Name$RESET"
    Write-Host "$FEDORA_LIGHT_BLUE$BOLDStatus:$RESET $(if ($installed) {"$GREEN Installed$RESET"} else {"$RED Not installed$RESET"})"
    Write-Host "$FEDORA_LIGHT_BLUE$BOLDDescription:$RESET $WHITE$app.Desc$RESET"
    Write-Host ""

    if ($app.Id -eq "winget") {
        if ($hasWinget) {
            print_success "Winget is already installed"
        } else {
            print_error "Winget is not installed"
            print_info "Install from Microsoft Store → search 'App Installer'"
            print_info "or download from https://github.com/microsoft/winget-cli/releases/latest"
            print_info "Direct link: https://aka.ms/getwinget"
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
        Write-Host "$FEDORA_BLUE$BOLD [b]$RESET Back"
        while ($true) {
            $key = Get-SingleKey
            if ($key -match '[uU]') { Uninstall-PM $app.Id ; break }
            if ($key -match '[bB]') { return }
        }
    } else {
        Write-Host "`n$FEDORA_BLUE$BOLD╔$( '═'═' * 58)╗$RESET"
        Write-Host "$FEDORA_BLUE$BOLD║$YELLOW$BOLD    Do you want to install $($app.Name)?          $FEDORA_BLUE$BOLD║$RESET"
        Write-Host "$FEDORA_BLUE$BOLD╚$( '═' * 58)╝$RESET"
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
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
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
            if ($_ -match "Downloading|Installing|Hash") { Write-Host "$ORANGE ⟳ $_$RESET" } else { Write-Host "$GRAY$_$RESET" }
        }
        if ($LASTEXITCODE -eq 0) { print_success "UniGetUI installed!" } else { print_error "Installation failed" }
    }
}

function Uninstall-PM($id) {
    if ($id -eq "chocolatey") {
        print_warning "Uninstall Chocolatey manually: Remove-Item "$env:ChocolateyInstall" -Recurse -Force"
    } elseif ($id -eq "scoop") {
        print_section "Uninstalling Scoop"
        scoop uninstall scoop
        Remove-Item "$env:USERPROFILE\scoop" -Recurse -Force -ErrorAction SilentlyContinue
        print_success "Scoop uninstalled"
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
            $status = if ((winget list -e --id $app.WingetId 2>$null | Select-String -Quiet $app.WingetId)) { "$GREEN✓$RESET" } else { " " }
            Write-Host "$FEDORA_BLUE$BOLD$( $i+1 ).$RESET $status $WHITE$($app.Name.PadRight(20))$GRAY$app.Desc$RESET"
        }

        Write-Host ""
        print_section "Navigation"
        Write-Host "$FEDORA_LIGHT_BLUE$BOLD 1-$( $terminalsList.Count )$RESET $WHITE select to view details$RESET"
        Write-Host "$RED$BOLD q$RESET $WHITE back to main menu$RESET"

        Write-Host ""
        Write-Host -NoNewline "$FEDORA_LIGHT_BLUE$BOLD Your choice: $RESET"
        $choice = Read-Host

        if ($choice -match "^[qQ]$") { return }

        if ([int]::TryParse($choice, [ref]0) -and $choice -ge 1 -and $choice -le $terminalsList.Count) {
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

    Write-Host "$FEDORA_LIGHT_BLUE$BOLDTerminal:$RESET $WHITE$app.Name$RESET"
    Write-Host "$FEDORA_LIGHT_BLUE$BOLDWinget ID:$RESET $LIGHT_GRAY$app.WingetId$RESET"
    Write-Host "$FEDORA_LIGHT_BLUE$BOLDDescription:$RESET $WHITE$app.Desc$RESET"
    Write-Host ""

    if ($installed) {
        print_success "Already installed"
        Write-Host "`n$YELLOW$BOLD Actions:$RESET"
        Write-Host "$RED$BOLD [r] Reinstall$RESET"
        Write-Host "$RED$BOLD [u] Uninstall$RESET"
        Write-Host "$FEDORA_BLUE$BOLD [b] Back$RESET"
    } else {
        Write-Host "$FEDORA_BLUE$BOLD╔$( '═' * 60)╗$RESET"
        Write-Host "$FEDORA_BLUE$BOLD║$YELLOW$BOLD     Install $($app.Name)?                     $FEDORA_BLUE$BOLD║$RESET"
        Write-Host "$FEDORA_BLUE$BOLD╚$( '═' * 60)╝$RESET"
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

# ======================= Main =======================

while ($true) {
    Clear-Host
    print_header "Windows Tools Installer"

    print_section "Categories"

    Write-Host "1. Package Managers"
    Write-Host "2. Terminals"

    Write-Host ""
    $detected = (@(if($hasWinget){"Winget"} if($hasScoop){"Scoop"} if($hasChoco){"Chocolatey"}) -join ", ")
    if ($detected) { print_info "Detected: $detected" } else { print_warning "No package manager detected" }

    Write-Host ""
    Write-Host "$RED$BOLD q$RESET $WHITE Quit$RESET"
    Write-Host ""
    Write-Host -NoNewline "$FEDORA_LIGHT_BLUE$BOLD Select category: $RESET"
    $choice = Read-Host

    if ($choice -eq "1") { Show-PackageManagers }
    elseif ($choice -eq "2") { Show-Terminals }
    elseif ($choice -match "^[qQ]$") {
        Clear-Host
        print_header "Goodbye!"
        Write-Host "$WHITE Thank you for using Windows Tools Installer!$RESET`n"
        break
    } else {
        print_warning "Invalid choice"
        Start-Sleep -Milliseconds 800
    }
}