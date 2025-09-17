"# DriMain - Unified Maintenance Management System

DriMain is a modern maintenance management system with a Spring Boot REST API backend and Flutter frontend. The system provides both web and mobile interfaces for managing maintenance tasks, schedules, reports, and equipment.

## 🏗️ Architecture

- **Backend**: Spring Boot 3.2.5 with Java 17, REST API with JWT authentication
- **Frontend**: Flutter (web + mobile) with responsive design
- **Database**: H2 (development) / PostgreSQL (production)
- **Security**: Stateless JWT authentication, role-based access control

## 🚀 Quick Start

### Prerequisites

- **Java 17** (required)
- **Flutter SDK** (for frontend development)
- **Maven** (wrapper included)

### Development Mode

```bash
# Backend only (API)
./mvnw spring-boot:run

# Frontend only (Flutter web)
cd frontend && flutter run -d chrome

# Frontend mobile
cd frontend && flutter run
```

### Production Build

```bash
# Build everything (frontend + backend)
./build-frontend.sh

# Run the combined application
java -jar target/driMain-1.0.0.jar
```

## 📊 Available Endpoints

### Authentication
- `POST /api/auth/login` - User login (returns JWT token)
- `GET /api/auth/me` - Get current user info

### Core Features
- `GET /api/czesci` - Parts management
- `GET /api/zgloszenia` - Issue tracking  
- `GET /api/harmonogramy` - Schedule management
- `GET /api/raporty` - Reports and analytics

### Administration (Admin only)
- `GET /api/admin/dzialy` - Departments
- `GET /api/admin/maszyny` - Machines
- `GET /api/admin/osoby` - Personnel
- `GET /api/admin/users` - User accounts

## 🔐 Default Accounts

- **Admin**: `admin` / `admin123` (full access)
- **User**: `user` / `user123` (standard access)

## 🛠️ Development Workflow

1. **Start Backend**: `./mvnw spring-boot:run` (runs on port 8080)
2. **Start Frontend**: `cd frontend && flutter run -d chrome`
3. **API Testing**: Visit http://localhost:8080/swagger-ui/index.html
4. **Database**: H2 Console at http://localhost:8080/h2-console
   - URL: `jdbc:h2:mem:testdb`
   - Username: `sa`
   - Password: (empty)

## 📁 Project Structure

```
├── src/main/java/drimer/drimain/
│   ├── controller/          # REST controllers
│   ├── model/              # JPA entities
│   ├── repository/         # Data repositories
│   ├── security/           # JWT & Spring Security
│   ├── service/            # Business logic
│   └── api/dto/            # Data Transfer Objects
├── frontend/               # Flutter application
│   ├── lib/                # Dart source code
│   ├── web/                # Web-specific files
│   └── build/web/          # Built web assets (copied to static/)
├── src/main/resources/
│   ├── static/             # Static web resources (Flutter build output)
│   └── application.yml     # Configuration
└── build-frontend.sh       # Build script
```

## 🔧 Configuration

### JWT Settings (application.yml)
```yaml
jwt:
  expiration:
    minutes: 60
  secret:
    # TODO: Use external configuration in production
    plain: "your-secret-key-here"
```

### Database Configuration
- **Development**: H2 in-memory (default)
- **Production**: Configure PostgreSQL in `application-local.properties`

### CORS Settings
Configured for development with Flutter:
- `http://localhost:5173` (Flutter web dev)
- `http://localhost:8080` (Spring Boot)

## 🧪 Testing

```bash
# Run backend tests
./mvnw test

# Build and test everything
./mvnw clean package

# Skip tests during build
./mvnw package -DskipTests
```

## 📱 Flutter Frontend

The Flutter frontend provides:
- **Cross-platform**: Web, iOS, Android, Windows, macOS, Linux
- **Responsive design**: Adapts to different screen sizes
- **API integration**: Communicates with Spring Boot backend via REST
- **JWT authentication**: Secure token-based authentication

### Frontend Development

```bash
cd frontend

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on mobile (requires device/emulator)
flutter run

# Build for web deployment
flutter build web
```

## 🚀 Deployment

### Development
```bash
./mvnw spring-boot:run
# Access at: http://localhost:8080
```

### Production
```bash
./build-frontend.sh
java -jar target/driMain-1.0.0.jar
```

### Environment Variables (Production)
```bash
export JWT_SECRET="your-production-secret"
export SPRING_PROFILES_ACTIVE="local"
export DATABASE_URL="your-postgres-url"
```

## 📚 API Documentation

- **Swagger UI**: http://localhost:8080/swagger-ui/index.html
- **OpenAPI JSON**: http://localhost:8080/v3/api-docs

## 🛡️ Security

- **Stateless authentication**: JWT tokens, no server sessions
- **CORS configured**: For development and production
- **Role-based access**: Admin, User roles
- **Password encryption**: BCrypt hashing
- **H2 console**: Enabled for development only

## 🔄 Migration from Legacy

This version replaces the previous Thymeleaf-based web interface with:
- ✅ Pure REST API backend
- ✅ Flutter web/mobile frontend  
- ✅ JWT authentication (no HTML redirects)
- ✅ Unified codebase (monorepo)
- ✅ Modern responsive UI

## 📋 TODO

- [ ] Import complete Flutter code from SerBart/driMain-Mobile
- [ ] Configure external JWT secret management
- [ ] Add comprehensive API tests
- [ ] Set up CI/CD pipeline
- [ ] Add Docker deployment configuration
- [ ] Implement real-time notifications
- [ ] Add file upload functionality for Flutter web" 
