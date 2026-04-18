# <div align="center">![DevDroid Banner](https://capsule-render.vercel.app/api?type=waving&height=220&color=0:0B1628,50:143A66,100:1D6FA5&text=DevDroid&fontColor=EAF4FF&fontSize=62&fontAlignY=38&desc=Code.%20Run.%20Ship%20from%20your%20phone.&descAlignY=58&animation=fadeIn)</div>

<div align="center">
  <img src="asset/appIcon/DevDroid.png" alt="DevDroid Logo" width="110" />

  <h3>Android-first mobile coding workspace built with Flutter</h3>

  <p>
    <img src="https://img.shields.io/badge/Flutter-3.41.6-02569B?logo=flutter&logoColor=white" alt="Flutter Version" />
    <img src="https://img.shields.io/badge/Platform-Android%20first-3DDC84?logo=android&logoColor=white" alt="Platform" />
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License" />
    <a href="https://github.com/Azrul16/DevDroid-android-code-editor/actions/workflows/ci.yml">
      <img src="https://github.com/Azrul16/DevDroid-android-code-editor/actions/workflows/ci.yml/badge.svg" alt="Build Status" />
    </a>
  </p>

  <p>
    <a href="#features">Features</a> |
    <a href="#getting-started">Getting Started</a> |
    <a href="#project-structure">Project Structure</a> |
    <a href="#contributing">Contributing</a> |
    <a href="#roadmap">Roadmap</a>
  </p>
</div>

## Overview

`DevDroid` is a mobile development workspace focused on coding directly from Android. It combines a code editor, integrated terminal, and git controls in a single app experience.

The UI is built around a project-centric flow:
- Create and open local projects
- Browse files from an in-app explorer
- Edit and run code quickly
- Use terminal and git without leaving the app

## Features

- Multi-tab code editor with syntax-aware language detection
- In-app file explorer with create/open/rename workflow
- Terminal integration powered by Termux and xterm
- Quick run/format actions from the editor command panel
- Built-in git actions: status, pull, push, add and commit
- Recent projects, settings, and workflow shortcuts

## Tech Stack

- Flutter (Dart)
- Provider for state management
- `re_editor` + `re_highlight` for editor capabilities
- `xterm` for terminal rendering
- `shared_preferences` for local settings persistence
- `dartssh2` for SSH terminal support

## Getting Started

### Prerequisites

- Flutter SDK `3.41.6` (Dart `3.11.4`)
- Android device/emulator
- Termux installed (recommended for command execution workflows)

### Installation

```bash
git clone https://github.com/Azrul16/DevDroid-android-code-editor.git
cd devdroid
flutter pub get
```

### Run

```bash
flutter run
```

## Project Structure

```text
lib/
  controllers/   # App state and workflow orchestration
  core/          # Theme, constants, and shared utilities
  models/        # Data models
  screens/       # Main app screens (home, project, editor, terminal, git, settings)
  services/      # File, git, settings, terminal, and SSH integrations
  widgets/       # Reusable UI components
```

## Current Status

Active development. Core workspace functionality is in place and ready for iterative improvements.

## Contributing

Contributions are welcome. If you want to help improve DevDroid:

1. Fork the repository and create a feature branch.
2. Keep changes focused and scoped to a single issue/feature.
3. Run checks before opening a PR:

```bash
flutter analyze
flutter test
```

4. Open a pull request with:
- A clear summary of what changed
- Screenshots or GIFs for UI updates
- Notes about testing performed

### Contribution Guidelines

- Follow existing project structure and naming conventions.
- Prefer small, reviewable PRs over large mixed changes.
- Update README/docs when behavior or setup changes.
- Be respectful and collaborative in issue and PR discussions.

## Roadmap

- [x] Finalize open-source license
- [x] Add GitHub Actions CI for analyze and tests
- [ ] Improve git workflow UX (branching, staging feedback)
- [ ] Add richer editor support (more languages and tooling hooks)
- [ ] Expand terminal profiles and SSH session management
- [ ] Add onboarding/tutorial flow for first-time users

## License

Licensed under the MIT License. See [LICENSE](LICENSE).
