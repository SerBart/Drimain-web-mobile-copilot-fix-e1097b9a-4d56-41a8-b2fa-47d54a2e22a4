"# DriMain - Unified Web & Mobile Application

DriMain is a comprehensive maintenance management system with both web UI and mobile app support. This monorepo contains:

- **Backend**: Spring Boot REST API with JWT authentication (Java 17)
- **Frontend**: Flutter web and mobile application
- **Database**: H2 (development) / PostgreSQL (production)

## 🏗️ Monorepo Structure

```
├── src/main/java/               # Spring Boot backend source
├── src/main/resources/          # Backend resources and static assets
├── frontend/                    # Flutter application
│   ├── lib/                    # Flutter source code
│   ├── web/                    # Web-specific platform files
│   ├── android/                # Android platform files
│   ├── ios/                    # iOS platform files
│   └── pubspec.yaml           # Flutter dependencies
├── build-frontend.sh           # Frontend build script
└── pom.xml                     # Maven configuration
```

## 🚀 Development Workflow

### Prerequisites

- Java 17
- Flutter 3.22+ (stable)
- Maven (via `./mvnw`)

### Quick Start

1. **Clone and setup**:
   ```bash
   git clone <repository-url>
   cd Drimain-web-mobile-copilot-fix-*
   chmod +x build-frontend.sh
   ```

2. **Build everything (recommended)**:
   ```bash
   ./build-frontend.sh
   ```

3. **Run the application**:
   ```bash
   ./mvnw spring-boot:run
   # or
   java -jar target/driMain-1.0.0.jar
   ```

4. **Access the application**:
   - Web UI: http://localhost:8080
   - API Documentation: http://localhost:8080/swagger-ui/index.html
   - H2 Console: http://localhost:8080/h2-console

### Backend Development

1. **Start the backend**:
   ```bash
   ./mvnw spring-boot:run
   ```
   - Runs on http://localhost:8080
   - H2 Console: http://localhost:8080/h2-console
   - API Documentation: http://localhost:8080/swagger-ui/index.html

2. **Test the backend**:
   ```bash
   ./mvnw test
   ```

3. **Build without tests**:
   ```bash
   ./mvnw clean package -DskipTests
   ```

### Frontend Development

1. **Install dependencies**:
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Run Flutter in development**:
   ```bash
   cd frontend
   flutter run -d web --dart-define=API_BASE=http://localhost:8080
   ```
   - Runs on http://localhost:3000 (or dynamic port)
   - Hot reload enabled for rapid development

3. **Build for production**:
   ```bash
   ./build-frontend.sh
   ```

4. **Flutter commands**:
   ```bash
   cd frontend
   flutter analyze          # Code analysis
   flutter test            # Run tests
   flutter clean           # Clean build artifacts
   ```

### Docker Development

1. **Build Docker image**:
   ```bash
   docker build -t drimain:latest .
   ```

2. **Run with Docker**:
   ```bash
   docker run -p 8080:8080 drimain:latest
   ```

3. **Build with custom API base**:
   ```bash
   docker build --build-arg API_BASE=https://api.example.com -t drimain:prod .
   ```

### Full Production Build

```bash
# Build Flutter web and integrate with Spring Boot
./build-frontend.sh

# Build the complete application
./mvnw clean package

# Run the integrated application
java -jar target/driMain-1.0.0.jar
```

## 🔐 Authentication & Security

- **JWT-based authentication** for both web and mobile
- **Stateless REST API** with Bearer token authentication
- **Default test accounts**:
  - Admin: `admin` / `admin123` (ROLE_ADMIN, ROLE_USER)
  - User: `user` / `user123` (ROLE_USER)

### API Authentication

```bash
# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Use the returned token
curl -H "Authorization: Bearer <token>" \
  http://localhost:8080/api/zgloszenia
```

## 📱 Mobile & Web Support

The Flutter frontend supports:
- **Web browsers** (primary deployment target)
- **iOS** mobile applications
- **Android** mobile applications
- **Desktop** (Linux, macOS, Windows) 

All platforms share the same codebase and connect to the unified REST API.

## 🛠️ REST API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Current user info

### Core Features
- `GET|POST|PUT|DELETE /api/zgloszenia` - Issue management
- `GET|POST|PUT|DELETE /api/harmonogramy` - Schedule management  
- `GET|POST|PUT|DELETE /api/czesci` - Parts management
- `GET|POST|PUT|DELETE /api/raporty` - Reports management

### Admin Functions (ROLE_ADMIN required)
- `/api/admin/dzialy` - Department management
- `/api/admin/maszyny` - Machine management
- `/api/admin/osoby` - Personnel management
- `/api/admin/users` - User account management

## 🗄️ Database Configuration

### Development (H2)
```properties
# src/main/resources/application.properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.username=sa
spring.datasource.password=
```

### Production (PostgreSQL)
```yaml
# src/main/resources/application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/drimain
    username: drimain
    password: drimain
```

## 🔧 JWT Configuration

JWT settings in `application.yml`:
```yaml
app:
  jwt:
    secret: "REPLACE_WITH_STRONG_SECRET_AT_LEAST_32_CHARS_LONG_1234567890"
    ttl-seconds: 3600
```

**⚠️ Important**: Change the JWT secret for production deployment!

## 🔄 CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/build.yml`):

- ✅ **Backend Testing**: Maven test execution with JUnit reporting
- ✅ **Frontend Testing**: Flutter analyze and test execution  
- ✅ **Integration Build**: Flutter web → Spring Boot static resources embedding
- ✅ **Docker Build**: Multi-stage build with Flutter web embedded in Spring Boot JAR
- ✅ **Artifact Management**: JAR and Docker image generation with GitHub Container Registry
- ✅ **Caching**: Maven and Flutter dependencies cached for faster builds

### Build Process

1. **Backend tests** run in parallel with **Frontend tests**
2. **Integration build** combines Flutter web build into Spring Boot JAR
3. **Docker image** is built and pushed to GitHub Container Registry (on main/master branch)
4. **Artifacts** are uploaded for deployment

### Environment Variables

- `API_BASE`: Backend API base URL (default: http://localhost:8080)
- `BUILD_MODE`: development or production (affects test execution)
- `JAVA_VERSION`: Java version for builds (17)
- `FLUTTER_VERSION`: Flutter version for builds (3.22.0)

## 🌐 CORS Configuration

Development origins are pre-configured in `CorsConfig.java`:
- `http://localhost:3000` - Flutter web dev
- `http://localhost:5173` - Vite dev server
- `http://10.0.2.2:8080` - Android emulator

**📝 TODO**: Restrict CORS origins for production deployment.

## 🚧 Migration Status

This is an active migration from legacy Thymeleaf templates to a modern Flutter-based architecture:

- ✅ **REST API Infrastructure** - Complete with OpenAPI documentation
- ✅ **JWT Authentication** - Complete with persistent session restore
- ✅ **Flutter Foundation** - Complete with Riverpod state management
- ✅ **Zgloszenia Feature** - Complete CRUD with real-time updates
- ✅ **CI/CD Pipeline** - Complete with Docker multi-stage builds
- ✅ **Developer Experience** - Enhanced with error handling and consistent theming
- 🔄 **SSE Integration** - In Progress (EventSource for real-time updates)
- ⏳ **Additional Features** - Planned (Harmonogramy, Raporty, Części)
- ⏳ **Legacy UI Removal** - Planned after feature parity

### Architecture Highlights

- **Backend**: Spring Boot 3.2.5 with Java 17
- **Frontend**: Flutter 3.22+ with Riverpod state management
- **Authentication**: JWT with automatic session restore
- **API**: RESTful with OpenAPI/Swagger documentation
- **Real-time**: Server-Sent Events for live updates
- **Build**: Docker multi-stage with embedded Flutter web
- **Testing**: Comprehensive backend and frontend test suites

## 📚 Additional Resources

- **Spring Boot Documentation**: https://spring.io/projects/spring-boot
- **Flutter Documentation**: https://flutter.dev/docs
- **JWT.io**: https://jwt.io/
- **H2 Database Console**: http://localhost:8080/h2-console (when running)
- **OpenAPI/Swagger UI**: http://localhost:8080/swagger-ui/index.html" 
