# Flutter Frontend

This directory contains the Flutter frontend application for DriMain.

## Current Status

This is a placeholder Flutter application structure. For a complete implementation, 
you would need to:

1. Import the full Flutter code from the SerBart/driMain-Mobile repository
2. Adapt the existing mobile app for web deployment
3. Implement proper API integration with the Spring Boot backend

## Development Setup

To develop the Flutter frontend:

1. Install Flutter SDK (https://flutter.dev/docs/get-started/install)
2. Navigate to this directory: `cd frontend`
3. Get dependencies: `flutter pub get`
4. Run for web: `flutter run -d chrome`
5. Run for mobile: `flutter run`

## Building for Production

To build the web version for deployment:

```bash
cd frontend
flutter build web
```

The built files will be in `build/web/` and should be copied to `src/main/resources/static/`

## API Integration

The frontend should use the REST API endpoints provided by the Spring Boot backend:

- Authentication: `POST /api/auth/login`
- User info: `GET /api/auth/me`
- Parts: `GET /api/czesci`
- Reports: `GET /api/raporty`
- Issues: `GET /api/zgloszenia`
- Schedules: `GET /api/harmonogramy`
- Admin: `GET /api/admin/*`

Use JWT tokens in Authorization headers: `Bearer <token>`