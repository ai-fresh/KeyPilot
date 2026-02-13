# Contributing to KeyPilot

Thank you for your interest in contributing to KeyPilot! This document provides guidelines and instructions for contributing.

## 🚀 Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/KeyPilot.git
   cd KeyPilot
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 🛠️ Development Setup

### Requirements
- macOS 14.0 or later
- Xcode Command Line Tools
- Swift 6.0+

### Building
```bash
# Build debug version
swift build

# Build release version
swift build -c release

# Create app bundle
./build.sh

# Run the app
open KeyPilot.app
```

## 📝 Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and concise
- Use SwiftUI for all UI components

## 🧪 Testing

Before submitting a pull request:
1. Build the app successfully
2. Test all features manually
3. Ensure no new warnings or errors
4. Test on macOS 14.0+ if possible

## 📤 Submitting Changes

1. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Brief description of changes"
   ```

2. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Open a Pull Request**:
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Select your fork and branch
   - Describe your changes clearly

## 🐛 Reporting Bugs

When reporting bugs, please include:
- macOS version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)

## 💡 Feature Requests

We welcome feature requests! Please:
- Check if the feature already exists
- Describe the feature clearly
- Explain why it would be useful
- Consider how it fits with existing features

## 📋 Pull Request Guidelines

- Keep PRs focused on a single feature or fix
- Update documentation if needed
- Test your changes thoroughly
- Write clear commit messages
- Reference related issues

## 🎯 Areas for Contribution

- **Features**: New keyboard support, additional profile options
- **UI/UX**: Interface improvements, better user experience
- **Documentation**: README updates, code comments, tutorials
- **Bug Fixes**: Fixing issues and improving stability
- **Performance**: Optimization and efficiency improvements

## 📜 Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help others learn and grow

## ❓ Questions?

Feel free to:
- Open an issue for discussion
- Ask questions in pull requests
- Suggest improvements to this guide

Thank you for contributing to KeyPilot! 🎉
