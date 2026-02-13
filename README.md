# KeyPilot

<div align="center">
  <img src="Resources/icon_1024.png" alt="KeyPilot Icon" width="200"/>

  **Professional macOS menu bar app for managing custom keyboard profiles on 3-button programmable keyboards**

  [![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://www.apple.com/macos/)
  [![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
</div>

## 🎹 About

KeyPilot is a native macOS application designed for **3-button programmable keyboards** (mechanical keyboards with 3 customizable keys). It allows you to create multiple profiles with different key mappings and automatically switch between them based on the active application.

Perfect for:
- **3-key macro pads** (e.g., custom-built mechanical keyboards)
- **Small programmable keyboards** with 3 buttons
- **USB macro devices** with 3 programmable keys

## ✨ Features

- 🎯 **Profile Management**: Create unlimited profiles with custom key mappings for each button
- 🔄 **Auto-Switching**: Automatically switch profiles when changing applications
- 🖥️ **Menu Bar Integration**: Clean, native macOS menu bar interface
- 🚀 **Launch at Login**: Optional auto-start with macOS
- 📝 **YAML Export**: Export profiles to YAML configuration files
- 🎨 **Custom Icons**: Personalize profiles with emoji icons
- ⚡ **Real-time Upload**: Instantly upload profiles to your keyboard
- 🔍 **App Detection**: Automatic detection of active applications for profile switching

## 📸 Screenshots

![Menu Bar](screenshots/menubar.png)
*Menu bar with profile selection and quick actions*

![Profile Editor](screenshots/editor.png)
*Easy-to-use profile editor with key mapping*

![Settings](screenshots/settings.png)
*Configure auto-switching and launch at login*

## 🔧 Hardware Requirements

This application is designed for **3-button programmable keyboards**. Your keyboard should:
- Have exactly **3 programmable keys/buttons**
- Support custom key mapping (remapping keys to different functions)
- Be compatible with macOS

### Compatible Keyboard Types:
- Custom-built 3-key macro pads
- Commercial 3-button programmable keyboards
- DIY mechanical keyboards with 3 switches
- USB HID devices with 3 programmable keys

## 📦 Installation

### Option 1: Download Release
1. Download the latest `KeyPilot.app` from [Releases](https://github.com/yourusername/KeyPilot/releases)
2. Move `KeyPilot.app` to your `/Applications` folder
3. Launch KeyPilot from Applications or Spotlight

### Option 2: Build from Source

**Requirements:**
- macOS 14.0 or later
- Xcode Command Line Tools
- Swift 6.0+

```bash
# Clone the repository
git clone https://github.com/yourusername/KeyPilot.git
cd KeyPilot

# Build the application
./build.sh

# Install to Applications
cp -R KeyPilot.app /Applications/

# Launch
open /Applications/KeyPilot.app
```

## 🚀 Quick Start

1. **Launch KeyPilot** - Find the keyboard icon in your menu bar
2. **Create a Profile**:
   - Click the menu bar icon
   - Select "Edit Profiles..."
   - Click "+" to add a new profile
3. **Map Your Keys**:
   - Name your profile (e.g., "Photoshop", "Default")
   - Set key mappings for buttons 1, 2, and 3
   - Choose an icon
4. **Upload Profile**:
   - Select your profile from the menu bar
   - Profile is automatically uploaded to your keyboard
5. **Enable Auto-Switch** (optional):
   - Link profiles to specific applications
   - Toggle "Auto-switch" in the menu

## 📖 Usage

### Creating Profiles

Each profile can have:
- **Name**: Descriptive name for the profile
- **Icon**: Emoji to identify the profile quickly
- **Button Mappings**: Custom key assignments for all 3 buttons
- **App Association**: Link to specific applications for auto-switching
- **Default Status**: Mark as default profile

### Key Mapping Format

Keys can be mapped using standard notation:
- Single keys: `a`, `1`, `Space`, `Return`
- Modifiers: `Cmd+C`, `Ctrl+Alt+Delete`, `Shift+A`
- Special keys: `F1`-`F12`, `Escape`, `Tab`, `Delete`

### Auto-Switching

Enable auto-switching to automatically change profiles when switching applications:
1. Create profiles for different apps
2. Associate each profile with an application bundle ID
3. Toggle "Auto-switch" in the menu bar
4. KeyPilot will switch profiles automatically

## ⚙️ Configuration

KeyPilot stores profiles locally and can export them to YAML format:

```yaml
profiles:
  - name: "Default"
    icon: "⌨️"
    isDefault: true
    buttons:
      button1: "Cmd+C"
      button2: "Cmd+V"
      button3: "Cmd+Z"
```

## 🛠️ Development

### Project Structure

```
KeyPilot/
├── Sources/
│   └── KeyPilot/
│       ├── App/              # Application entry point
│       ├── Models/           # Data models (Profile, KeyMapping)
│       ├── Services/         # Business logic services
│       ├── Views/            # SwiftUI views
│       └── Utilities/        # Helper utilities
├── Resources/                # App resources (icons)
├── build.sh                  # Build script
└── Package.swift             # Swift Package manifest
```

### Building

```bash
# Debug build
swift build

# Release build
swift build -c release

# Create app bundle
./build.sh
```

## 🔒 Privacy & Permissions

KeyPilot requires:
- **Accessibility Access**: To detect active applications and send key events
- **Input Monitoring**: To capture and remap keyboard inputs

These permissions are requested on first launch and can be managed in System Settings > Privacy & Security.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with Swift and SwiftUI
- Uses ServiceManagement framework for launch at login
- Designed for macOS 14.0+

## 📧 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check existing issues for solutions

---

<div align="center">
  Made with ❤️ for the mechanical keyboard community
</div>
