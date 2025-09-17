# DriMain Flutter Frontend

This directory contains the Flutter mobile application for DriMain.

For complete setup instructions, development workflow, and project documentation, please see the main [README.md](../README.md) in the root directory.

## Quick Start

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run in development mode:
   ```bash
   flutter run -d web --dart-define=API_BASE=http://localhost:8080
   ```

3. Build for production:
   ```bash
   flutter build web --release --dart-define=API_BASE=http://localhost:8080
   ```

## API Configuration

The app connects to the Spring Boot backend. The API base URL can be configured via the `API_BASE` environment variable during build.

Default: `http://localhost:8080`