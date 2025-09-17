# Multi-stage Docker build for DriMain
# Stage 1: Build Flutter web application
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-builder

# Set the working directory for Flutter build
WORKDIR /app/frontend

# Copy Flutter project files
COPY frontend/pubspec.yaml frontend/pubspec.lock ./
RUN flutter pub get

# Copy Flutter source code
COPY frontend/ ./

# Build Flutter web with environment variable for API base
ARG API_BASE=http://localhost:8080
RUN flutter build web --release --dart-define=API_BASE=${API_BASE}

# Stage 2: Build Spring Boot application with embedded Flutter web
FROM eclipse-temurin:17-jdk AS spring-builder

# Set the working directory for Spring Boot build
WORKDIR /app

# Copy Maven wrapper and configuration
COPY mvnw* ./
COPY .mvn .mvn/
COPY pom.xml ./

# Download Maven dependencies
RUN ./mvnw dependency:go-offline -B

# Copy Spring Boot source code
COPY src/ src/

# Copy Flutter web build to Spring Boot static resources
COPY --from=flutter-builder /app/frontend/build/web/ src/main/resources/static/

# Build Spring Boot application
RUN ./mvnw clean package -DskipTests

# Stage 3: Final runtime image
FROM eclipse-temurin:17-jre-jammy

# Set metadata
LABEL maintainer="DriMain Team"
LABEL description="DriMain Maintenance Management System"

# Create non-root user for security
RUN groupadd -r drimain && useradd -r -g drimain drimain

# Set working directory
WORKDIR /app

# Copy the built JAR from builder stage
COPY --from=spring-builder /app/target/driMain-1.0.0.jar app.jar

# Change ownership to non-root user
RUN chown drimain:drimain app.jar

# Switch to non-root user
USER drimain

# Expose port 8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Set JVM options for production
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]