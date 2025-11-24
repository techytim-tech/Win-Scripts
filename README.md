# Win-Scripts

A comprehensive collection of PowerShell scripts for Windows system automation, package management, and terminal configuration.

**Created by:** [TechyTim](https://github.com/techytim-tech)

## Overview

This repository contains powerful, user-friendly PowerShell scripts designed to simplify common Windows administration tasks. Each script features beautiful Microsoft-branded interfaces and comprehensive functionality.

## 📚 Scripts

### 1. Wezterm Config for Windows (`Wezterm-Config-for-Win.Ps1`)

A comprehensive menu-driven installer and configurator for **WezTerm**, a modern GPU-accelerated terminal emulator.

**Features:**
- 🎯 Menu-driven interface with 4 main operations
- 🎨 5 color theme options (Windows Blue, Catppuccin, Dracula, Gruvbox)
- 🔤 Font selection (Cascadia Code, Consolas, Courier New)
- 💻 Shell selection (PowerShell 7, PowerShell 6, cmd.exe)
- 🖥️ Automatic 64-bit process detection
- 📦 Smart package manager detection (Winget/Chocolatey)
- 📐 Optimal window sizing configuration
- 💾 Automatic config backups

**Quick Start:**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Wezterm-Config-for-Win.Ps1
```

**Full Documentation:** [Wezterm-Config-for-Win.md](docs/Wezterm-Config-for-Win.md)

---

### 2. Windows Package & Terminals Installer (`win-package-and-terminals-installer.ps1`)

Install and manage popular package managers and terminal emulators with an elegant, interactive interface.

**Features:**
- 🎯 Beautiful TUI with color-coded options
- 📦 Package Manager Support:
  - Winget (Microsoft's official package manager)
  - Chocolatey (Classic Windows package manager)
  - Scoop (Lightweight, no-admin installer)
  - UniGetUI (GUI for all package managers)
- 💻 Terminal Emulator Support:
  - WezTerm (GPU-accelerated)
  - Windows Terminal (Microsoft's modern terminal)
  - Alacritty (Fast, cross-platform)
  - Warp (AI-powered terminal)
- 🔍 Auto-detection of installed tools
- 🎨 Microsoft brand colors throughout
- 🛡️ Safe execution with proper error handling

**Quick Start:**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File win-package-and-terminals-installer.ps1
```

**Full Documentation:** [win-package-and-terminals-installer.md](docs/win-package-and-terminals-installer.md)

---

## 🚀 Quick Start Guide

### Prerequisites

- Windows 10 or Windows 11
- PowerShell 5.1 or PowerShell 7+
- Administrator privileges (for some operations)
- Internet connection (for downloading packages)

### Installation

1. **Clone the repository:**
   ```powershell
   git clone https://github.com/techytim-tech/Win-Scripts.git
   cd Win-Scripts
   ```

2. **Run any script with bypass:**
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File <ScriptName.ps1>
   ```

3. **Or set execution policy permanently:**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   & '.\<ScriptName.ps1>'
   ```

## 📖 Documentation

Each script has comprehensive documentation in the `docs/` folder:

- [Wezterm-Config-for-Win.md](docs/Wezterm-Config-for-Win.md) - Complete WezTerm setup guide
- [win-package-and-terminals-installer.md](docs/win-package-and-terminals-installer.md) - Package manager and terminal installer guide

## 🎨 Features

### Common Features Across All Scripts

✨ **User Experience:**
- Beautiful Microsoft-branded color schemes
- Interactive menus with status indicators
- Unicode box-drawing for professional UI
- Color-coded success/error/warning messages
- Auto-detection of system capabilities

🔧 **Technical Excellence:**
- Proper error handling with try/catch blocks
- Safe execution practices (no aliases like `iex`)
- Automatic configuration backups
- Smart fallback mechanisms
- Path validation and environment checks

🛡️ **Safety & Reliability:**
- Confirmation prompts for destructive operations
- Timestamped backups of configurations
- Graceful error recovery
- No write-to-system without consent

## 🔍 System Requirements

| Requirement | Minimum | Recommended |
|------------|---------|-------------|
| OS | Windows 10 1903+ | Windows 11 |
| PowerShell | 5.1 | 7.x |
| Memory | 2GB | 4GB+ |
| Network | For downloads | Broadband |
| Admin Rights | For some features | For full functionality |

## 🐛 Troubleshooting

### Execution Policy Error

```powershell
# Temporary bypass
powershell -ExecutionPolicy Bypass -File script.ps1

# Permanent (current user only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Admin Rights Required

Right-click PowerShell and select **"Run as Administrator"** before running the scripts.

### Package Manager Not Found

Install Winget:
```powershell
# Windows 11 (usually pre-installed)
# Windows 10: Install from Microsoft Store or:
Get-AppxPackage -name "DesktopAppInstaller" | ForEach-Object {
    Add-AppxPackage -AppxBundle $_.InstallLocation\AppxBundleManifest.xml
}
```

## 📝 Script Behavior

### Logging & Backups

- Configurations are automatically backed up before modification
- Backups use timestamp format: `filename.bak.YYYYMMDD_HHMMSS`
- Original files are never overwritten without a backup

### Environment Variables

Some scripts set temporary environment variables:
- `WEZTERM_64LAUNCHED` - Prevents 64-bit relaunch loops
- Custom variables are automatically cleaned up

### Path Updates

Package installations may require:
- System restart to update PATH
- Terminal restart to recognize new tools
- PowerShell profile refresh in some cases

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes with clear commit messages
4. Test thoroughly
5. Submit a pull request

## 📄 License

These scripts are provided as-is for personal and educational use.

## 💬 Support & Feedback

- **Issues & Bugs:** Open an issue on GitHub
- **Feature Requests:** Suggest improvements via GitHub discussions
- **Questions:** Check the documentation first, then open an issue

## 🔗 Related Resources

- [WezTerm Official](https://wezfurlong.org/wezterm/)
- [Windows Terminal](https://github.com/microsoft/terminal)
- [Winget Documentation](https://github.com/microsoft/winget-cli)
- [Chocolatey](https://chocolatey.org/)
- [Scoop](https://scoop.sh/)

## 📞 Contact

Created with ❤️ by **TechyTim**

---

**Last Updated:** November 24, 2025
