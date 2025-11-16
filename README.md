# Japanese Keyboard Layout Overrider

These scripts allow you to override the default Japanese IME (Input Method Editor) layout on Windows, ensuring it works with your preferred keyboard layout.

By default, the Japanese IME on Windows is configured for the US keyboard.

**What this means**: If you are using a non-US keyboard (e.g., German, French, etc.), some keys may not produce the expected characters when typing in Japanese. This can be adjusted via the Windows Registry or using the scripts below.

## Scripts

That's why I made two script to handle this for you. A system restart for both scripts is required. In addition, the LayerDriver JPN driver is deleted because it causes the Japanese input to use an incorrect layout. After a Windows update, this file may reappear. If so, simply delete it again using the script.

### 1. ```JapanLayoutOverrider.ps1``` (recommended)

A PowerShell script that allows you to choose from your installed keyboard layouts and automatically apply it as the Japanese IME layout. This script also removes the LayerDriver JPN if present.

Run in PowerShell with administrator privileges.

### 2. ```JapanLayoutOverrider.reg```

A simple registry file that replaces the Japanese keyboard layout DLL to a fixed language and removes the LayerDriver JPN driver with a simple double-click. In this script the fixed language is the Swiss German Layout **KBDSG.DLL**. Make sure to change it to your language.

## Recommended Additional Windows Setting

To make switching the IME on/off more convenient:
1. Right-click the Japanese keyboard icon in the lower-right corner of your taskbar.
2. Open Settings.
3. Navigate to Customize keys and touch input.
4. Enable Select preferred function for each key/shortcut.
5. Set Ctrl + Space to Toggle IME.

## Shortcut Lookup Table

### Windows (Standard IME Shortcuts)

| Action                  | Shortcut |
|-------------------------|----------|
| Change Language         | WIN + Space |
| Romaji ↔ Hiragana       | Shift + CapsLock |
| Katakana                | Alt + CapsLock |
| Hiragana                | Ctrl + CapsLock |

### Custom Shortcuts & Linux (Mozc)

| Action                  | Shortcut |
|-------------------------|----------|
| Romaji ↔ Hiragana       | Ctrl + Space |
| Convert to Katakana     | F7 |

### Typing Tricks (Windows & Linux)

| Action                  | How to Type |
|-------------------------|-------------|
| Small Kana              | L- or X-prefix |
| 「」                    | kakko |

## Linux Users

On Linux, you can simply use **Japanese – Mozc** in the IBus input system:

```sh
sudo apt install ibus
sudo apt-get install ibus-mozc
ibus-setup
```
Add **Japanese – Mozc** to the Input Method.
