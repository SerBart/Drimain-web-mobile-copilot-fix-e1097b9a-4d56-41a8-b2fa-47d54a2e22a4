#!/bin/bash

# Build script for DriMain frontend + backend integration
# This script builds the Flutter web app and copies it to Spring Boot static resources

set -e

echo "🚀 Building DriMain Frontend + Backend"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter SDK first."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Navigate to frontend directory
cd frontend

echo "📦 Installing Flutter dependencies..."
flutter pub get

echo "🔨 Building Flutter web app..."
flutter build web

echo "📂 Copying built files to Spring Boot static resources..."
# Remove existing static files
rm -rf ../src/main/resources/static/*

# Copy Flutter web build to static resources
cp -r build/web/* ../src/main/resources/static/

echo "🏗️  Building Spring Boot application..."
cd ..
./mvnw clean package -DskipTests

echo "✅ Build complete!"
echo ""
echo "🎯 Next steps:"
echo "   - To run the application: java -jar target/driMain-1.0.0.jar"
echo "   - Access the app at: http://localhost:8080"
echo "   - API documentation: http://localhost:8080/swagger-ui/index.html"
echo ""
echo "💡 For development:"
echo "   - Backend: ./mvnw spring-boot:run"
echo "   - Frontend: cd frontend && flutter run -d chrome"