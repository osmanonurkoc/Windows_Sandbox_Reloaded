# 🛡️ Windows Sandbox Reloaded

A powerful, modern GUI manager for Windows Sandbox. Enable or disable the sandbox feature with a single click and integrate **"Open in Sandbox (Read-Only)"** directly into your right-click context menu for safe testing.

[![Download Latest Release](https://img.shields.io/badge/Download-Latest_Release-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/osmanonurkoc/Windows_Sandbox_Reloaded/releases/latest)

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows-0078D4.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-v5.1%2B-5391FE.svg)

## 📸 Overview

*Testing suspicious files shouldn't be complicated.*

Windows Sandbox is a fantastic feature, but mounting folders usually requires manually creating `.wsb` configuration files. **Windows Sandbox Reloaded** solves this by automating the process via the Context Menu.

## 📸 Screenshots

<p align="center">
  <img src="images/screenshot1.png" width="45%" />
  <img src="images/screenshot2.png" width="25%" />
</p>


## ✨ Key Features

* **🚀 One-Click Toggle:** Enable or Disable the "Windows Sandbox" optional feature without digging through the Control Panel.
* **🖱️ Context Menu Integration:** Adds a right-click option to your File Explorer background.
    * **Action:** Instantly mounts the *current folder* into a fresh Sandbox instance.
    * **Mode:** **Read-Only**. The sandbox cannot modify, encrypt, or delete your original files. Perfect for malware analysis.
* **🎨 Modern UI & Theme Engine:** Automatically detects your Windows System Theme (Dark/Light Mode) and adjusts the interface in real-time.
* **🔒 Safe Execution:** The tool uses native PowerShell and Windows API calls. No external binaries or DLLs are required.

## 🚀 Getting Started

### Prerequisites
* **OS:** Windows 10 Pro/Enterprise or Windows 11 Pro/Enterprise.
* **Virtualization:** Must be enabled in BIOS.

### Installation & Usage

#### Option 1: Using the Executable (Recommended)
1. Download the latest `Windows_Sandbox_Reloaded.exe` from the **[Releases Page](https://github.com/osmanonurkoc/Windows_Sandbox_Reloaded/releases/latest)**.
2. Double-click `Windows_Sandbox_Reloaded.exe` to run.

#### Option 2: Running the Script (For Developers)
1. Download the source code.
2. Right-click `Windows_Sandbox_Reloaded.ps1` and select **Run with PowerShell**.
   * *Note:* If you encounter an Execution Policy error, run this command in PowerShell once:
     ```powershell
     Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
     ```
   * *Note:* Requires **Administrator** privileges to enable features and modify the Registry.
3. Use the switches to enable the Sandbox Feature or the Context Menu integration.

### ⚠️ Antivirus Warnings (False Positives)

You may notice that some antivirus engines (such as Windows Defender, SentinelOne, or CrowdStrike) flag the `.exe` release of this tool as suspicious (e.g., `Trojan:Win32/Wacatac`, `MachineLearning/Anomalous`, or `Generic.Malware`).

**This is a known False Positive.**

#### Why is this happening?

This application is originally a **PowerShell script** converted into an executable (`.exe`) to make it easier to run. Modern antivirus "AI" and "Heuristic" engines often aggressively block _any_ unsigned program that executes PowerShell commands internally, classifying them as "droppers" or "loaders" by default, even if the code itself is completely safe.

#### I don't trust the EXE. What should I do?

Since this project is open-source, **you do not have to use the EXE file.**

If your antivirus blocks the executable or if you prefer full transparency, you can run the source script directly:

1.  Download the `.ps1` file from this repository.
    
2.  Right-click the file and select **Run with PowerShell**.
    
3.  _(Note: You may need to enable script execution by running `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` in PowerShell once)._
    

We provide the compiled `.exe` solely for convenience (icon support, double-click execution). The code logic is identical to the `.ps1` script.


## 🛠️ How It Works

### Context Menu Integration
When you click "Open in Sandbox (Read-Only)":
1. The tool generates a temporary `.wsb` (Windows Sandbox Configuration) file.
2. It maps the host folder to the Sandbox desktop.
3. It sets `ReadOnly="true"` to protect your host data.
4. It launches Windows Sandbox with this configuration.

## ⚠️ Disclaimer
While this tool mounts folders in **Read-Only** mode to protect your files from modification (e.g., Ransomware encryption), **network access is enabled by default** in Windows Sandbox. 
- Always exercise caution when running unknown software.

## 📄 License
This project is licensed under the [MIT License](LICENSE).

---
*Created by [@osmanonurkoc](https://github.com/osmanonurkoc)*
