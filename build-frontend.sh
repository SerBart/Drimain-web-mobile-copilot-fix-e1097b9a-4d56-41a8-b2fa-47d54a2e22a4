#!/bin/bash

# Enhanced build script for DriMain Flutter frontend and Spring Boot backend
set -e

echo "🏗️  Building DriMain Frontend and Backend..."

# Default API base URL (can be overridden via environment variable)
API_BASE=${API_BASE:-"http://localhost:8080"}

# Build mode: development or production
BUILD_MODE=${BUILD_MODE:-"development"}

echo "📋 Build Configuration:"
echo "   API_BASE: $API_BASE"
echo "   BUILD_MODE: $BUILD_MODE"
echo "   Working directory: $(pwd)"

# Step 1: Build Flutter frontend
echo ""
echo "📱 Building Flutter frontend..."

# Navigate to frontend directory
cd frontend

# Install dependencies
echo "   📦 Installing Flutter dependencies..."
flutter pub get

# Build for web
if [ "$BUILD_MODE" = "production" ]; then
    echo "   🔨 Building Flutter web (production) with API_BASE=$API_BASE..."
    flutter build web --release --dart-define=API_BASE="$API_BASE"
else
    echo "   🔨 Building Flutter web (development) with API_BASE=$API_BASE..."
    flutter build web --dart-define=API_BASE="$API_BASE"
fi

# Navigate back to root
cd ..

# Step 2: Copy Flutter build to Spring Boot static resources
echo ""
echo "📂 Copying Flutter web build to Spring Boot static resources..."

# Clean existing static resources
echo "   🧹 Cleaning existing static resources..."
rm -rf src/main/resources/static/*

# Copy Flutter web build
echo "   📋 Copying Flutter web build..."
cp -r frontend/build/web/* src/main/resources/static/

# Verify the copy
if [ -f "src/main/resources/static/index.html" ]; then
    echo "   ✅ Flutter web build copied successfully"
else
    echo "   ❌ Error: Flutter web build not found in static resources"
    exit 1
fi

# Step 3: Build Spring Boot backend
echo ""
echo "☕ Building Spring Boot backend..."

# Build backend with or without tests based on build mode
if [ "$BUILD_MODE" = "production" ]; then
    echo "   🔨 Building Spring Boot (production - with tests)..."
    ./mvnw clean package
else
    echo "   🔨 Building Spring Boot (development - skipping tests)..."
    ./mvnw clean package -DskipTests
fi

# Verify JAR was created
if [ -f "target/driMain-1.0.0.jar" ]; then
    echo "   ✅ Spring Boot JAR created successfully"
    echo "   📦 JAR size: $(du -h target/driMain-1.0.0.jar | cut -f1)"
else
    echo "   ❌ Error: Spring Boot JAR not found"
    exit 1
fi

echo ""
echo "🎉 Build completed successfully!"
echo ""
echo "📋 Build Summary:"
echo "   Frontend: Flutter web (${BUILD_MODE})"
echo "   Backend: Spring Boot JAR"
echo "   Static resources: Embedded in JAR"
echo "   API base URL: $API_BASE"
echo ""
echo "🚀 To run the application:"
echo "   java -jar target/driMain-1.0.0.jar"
echo "   or"
echo "   ./mvnw spring-boot:run"
echo ""
echo "🌐 Access the application:"
echo "   Web UI: http://localhost:8080"
echo "   API docs: http://localhost:8080/swagger-ui/index.html"
echo "   H2 Console: http://localhost:8080/h2-console"