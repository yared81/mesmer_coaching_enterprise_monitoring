# 🏗️ MESMER Digital Coaching Platform - Architecture Guide

**System Design, Patterns, and Technical Architecture**

---

## 🎯 **Architecture Overview**

The MESMER Digital Coaching Platform follows **Clean Architecture** principles with **Flutter** for the mobile frontend and **Node.js** for the backend API. The system is designed for scalability, maintainability, and security.

### **Architecture Principles**
- **Separation of Concerns**: Clear boundaries between layers
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Single Responsibility**: Each component has one reason to change
- **Open/Closed Principle**: Open for extension, closed for modification
- **Testability**: All components are easily testable

---

## 📱 **Frontend Architecture (Flutter)**

### **Project Structure**

```
lib/
├── core/                           # Shared infrastructure
│   ├── constants/                  # App constants and configurations
│   │   ├── api_constants.dart      # API endpoints and URLs
│   │   ├── app_constants.dart      # App-wide constants
│   │   └── storage_constants.dart  # Storage keys and paths
│   ├── errors/                     # Error handling
│   │   ├── exceptions.dart         # Custom exception classes
│   │   ├── failures.dart           # Failure classes
│   │   └── error_handler.dart      # Global error handling
│   ├── network/                    # Network layer
│   │   ├── dio_client.dart         # HTTP client configuration
│   │   ├── interceptors.dart       # Request/response interceptors
│   │   └── network_info.dart       # Network connectivity
│   ├── router/                     # Navigation and routing
│   │   ├── app_router.dart         # Route configuration
│   │   ├── app_routes.dart         # Route constants
│   │   └── route_guard.dart        # Route protection
│   ├── services/                   # Shared services
│   │   ├── biometric_service.dart  # Biometric authentication
│   │   ├── storage_service.dart    # Local storage
│   │   ├── notification_service.dart # Push notifications
│   │   └── location_service.dart   # GPS and location
│   ├── storage/                    # Local storage
│   │   ├── hive_storage.dart       # Hive database
│   │   ├── secure_storage.dart     # Encrypted storage
│   │   └── sqlite_storage.dart     # SQLite database
│   └── theme/                      # App theming
│       ├── app_theme.dart          # Theme configuration
│       ├── app_colors.dart         # Color definitions
│       ├── text_styles.dart        # Typography
│       └── custom_widgets.dart     # Custom UI components
├── shared/                         # Reusable components
│   ├── widgets/                    # Common UI widgets
│   │   ├── buttons/                # Custom button components
│   │   ├── forms/                  # Form components
│   │   ├── cards/                  # Card components
│   │   └── dialogs/                # Dialog components
│   ├── utils/                      # Utility functions
│   │   ├── date_utils.dart         # Date formatting
│   │   ├── validation_utils.dart   # Input validation
│   │   ├── file_utils.dart         # File operations
│   │   └── format_utils.dart       # Data formatting
│   └── extensions/                 # Dart extensions
│       ├── string_extensions.dart  # String utilities
│       ├── datetime_extensions.dart # Date utilities
│       └── context_extensions.dart # BuildContext utilities
└── features/                       # Feature modules
    ├── auth/                       # Authentication feature
    │   ├── data/                   # Data layer
    │   │   ├── datasources/        # Data sources
    │   │   │   ├── auth_remote_datasource.dart
    │   │   │   └── auth_local_datasource.dart
    │   │   ├── models/             # Data models
    │   │   │   ├── user_model.dart
    │   │   │   └── auth_response_model.dart
    │   │   └── repositories/       # Repository implementations
    │   │       └── auth_repository_impl.dart
    │   ├── domain/                 # Domain layer
    │   │   ├── entities/           # Domain entities
    │   │   │   ├── user.dart
    │   │   │   └── auth_session.dart
    │   │   ├── repositories/       # Repository interfaces
    │   │   │   └── auth_repository.dart
    │   │   └── usecases/           # Business logic
    │   │       ├── login_usecase.dart
    │   │       ├── logout_usecase.dart
    │   │       └── refresh_token_usecase.dart
    │   └── presentation/           # Presentation layer
    │       ├── screens/            # UI screens
    │       │   ├── login_screen.dart
    │       │   ├── splash_screen.dart
    │       │   └── profile_screen.dart
    │       ├── widgets/            # Feature-specific widgets
    │       └── providers/          # State management
    │           └── auth_provider.dart
    ├── dashboard/                  # Dashboard feature
    ├── enterprise/                 # Enterprise management
    ├── workflow/                   # Business workflows
    │   ├── coaching/               # Coaching sessions
    │   ├── training/               # Training management
    │   ├── diagnosis/              # Assessments
    │   ├── qc/                    # Quality control
    │   └── comms/                 # Communications
    ├── monitoring/                 # MERL and analytics
    └── reports/                   # Reporting and exports
```

### **Layer Responsibilities**

#### **Presentation Layer**
- **Screens**: UI components and user interfaces
- **Widgets**: Reusable UI components
- **Providers**: Riverpod state management
- **Navigation**: Route handling and navigation

#### **Domain Layer**
- **Entities**: Business objects and rules
- **Use Cases**: Application business logic
- **Repository Interfaces**: Data access contracts
- **Domain Services**: Business logic services

#### **Data Layer**
- **Models**: Data transfer objects
- **Data Sources**: API and local data access
- **Repository Implementations**: Concrete data access
- **Mappers**: Data transformation between layers

---

## 🖥️ **Backend Architecture (Node.js)**

### **Project Structure**

```
server/
├── src/
│   ├── controllers/                # Request handlers
│   │   ├── auth.controller.js      # Authentication endpoints
│   │   ├── user.controller.js      # User management
│   │   ├── enterprise.controller.js # Enterprise CRUD
│   │   ├── coaching.controller.js  # Coaching sessions
│   │   ├── training.controller.js  # Training management
│   │   ├── qc.controller.js        # Quality control
│   │   ├── certificate.controller.js # Certificate generation
│   │   └── report.controller.js    # Reporting endpoints
│   ├── services/                   # Business logic
│   │   ├── auth.service.js         # Authentication logic
│   │   ├── user.service.js         # User management
│   │   ├── enterprise.service.js   # Enterprise operations
│   │   ├── coaching.service.js     # Coaching workflows
│   │   ├── training.service.js     # Training operations
│   │   ├── qc.service.js           # Quality control
│   │   ├── certificate.service.js  # Certificate generation
│   │   ├── notification.service.js # Notifications
│   │   └── report.service.js       # Report generation
│   ├── models/                     # Data models
│   │   ├── User.js                 # User model
│   │   ├── Enterprise.js           # Enterprise model
│   │   ├── CoachingSession.js      # Coaching session model
│   │   ├── TrainingSession.js      # Training session model
│   │   ├── Assessment.js           # Assessment model
│   │   ├── Certificate.js          # Certificate model
│   │   └── Report.js               # Report model
│   ├── repositories/               # Data access layer
│   │   ├── base.repository.js      # Base repository
│   │   ├── user.repository.js      # User data access
│   │   ├── enterprise.repository.js # Enterprise data access
│   │   ├── coaching.repository.js  # Coaching data access
│   │   └── certificate.repository.js # Certificate data access
│   ├── middleware/                 # Request middleware
│   │   ├── auth.middleware.js      # Authentication
│   │   ├── validation.middleware.js # Input validation
│   │   ├── error.middleware.js     # Error handling
│   │   ├── rate-limit.middleware.js # Rate limiting
│   │   └── audit.middleware.js     # Audit logging
│   ├── routes/                     # Route definitions
│   │   ├── auth.routes.js          # Authentication routes
│   │   ├── user.routes.js          # User routes
│   │   ├── enterprise.routes.js    # Enterprise routes
│   │   ├── coaching.routes.js      # Coaching routes
│   │   ├── training.routes.js      # Training routes
│   │   ├── qc.routes.js            # Quality control routes
│   │   ├── certificate.routes.js   # Certificate routes
│   │   └── report.routes.js        # Report routes
│   ├── utils/                      # Utility functions
│   │   ├── database.js             # Database connection
│   │   ├── logger.js               # Logging utility
│   │   ├── validator.js            # Input validation
│   │   ├── encryption.js           # Encryption utilities
│   │   ├── email.js                # Email sending
│   │   ├── sms.js                  # SMS sending
│   │   ├── file-upload.js          # File handling
│   │   └── pdf-generator.js        # PDF generation
│   ├── config/                     # Configuration
│   │   ├── database.js             # Database config
│   │   ├── jwt.js                  # JWT config
│   │   ├── email.js                # Email config
│   │   ├── sms.js                  # SMS config
│   │   └── storage.js              # File storage config
│   └── app.js                      # Application entry point
├── tests/                          # Test files
├── docs/                           # API documentation
├── package.json                    # Dependencies
└── .env.example                    # Environment variables
```

---

## 🗄️ **Database Architecture**

### **PostgreSQL Schema**

#### **Core Tables**

```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    region VARCHAR(100),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enterprises table
CREATE TABLE enterprises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    sector VARCHAR(100),
    region VARCHAR(100),
    address TEXT,
    coordinates POINT,
    status VARCHAR(50) DEFAULT 'active',
    coach_id UUID REFERENCES users(id),
    baseline_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Coaching sessions table
CREATE TABLE coaching_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enterprise_id UUID REFERENCES enterprises(id),
    coach_id UUID REFERENCES users(id),
    scheduled_date TIMESTAMP WITH TIME ZONE,
    actual_date TIMESTAMP WITH TIME ZONE,
    type VARCHAR(50),
    status VARCHAR(50) DEFAULT 'scheduled',
    notes TEXT,
    actions JSONB,
    next_visit TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Assessments table
CREATE TABLE assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enterprise_id UUID REFERENCES enterprises(id),
    type VARCHAR(50), -- baseline, midline, endline
    data JSONB,
    status VARCHAR(50) DEFAULT 'draft',
    submitted_at TIMESTAMP WITH TIME ZONE,
    approved_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Certificates table
CREATE TABLE certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enterprise_id UUID REFERENCES enterprises(id),
    certificate_number VARCHAR(50) UNIQUE NOT NULL,
    verification_code VARCHAR(12) UNIQUE NOT NULL,
    issue_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending',
    coach_id UUID REFERENCES users(id),
    me_officer_id UUID REFERENCES users(id),
    regional_coordinator_id UUID REFERENCES users(id),
    pdf_file_url TEXT,
    qr_code_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### **Database Design Principles**
- **Normalization**: Follow 3NF for data integrity
- **Indexing**: Strategic indexes for performance
- **Constraints**: Foreign keys and check constraints
- **Audit Trails**: Created/updated timestamps
- **Soft Deletes**: Logical deletion with status flags

---

## 🔐 **Security Architecture**

### **Authentication & Authorization**

#### **JWT Token Strategy**
```javascript
// Access Token (15 minutes)
{
  "sub": "user_id",
  "email": "user@example.com",
  "role": "coach",
  "region": "addis_ababa",
  "permissions": ["coaching:read", "coaching:write"],
  "iat": 1642694400,
  "exp": 1642695300
}

// Refresh Token (7 days)
{
  "sub": "user_id",
  "type": "refresh",
  "iat": 1642694400,
  "exp": 1643299200
}
```

#### **Role-Based Access Control (RBAC)**
```javascript
const permissions = {
  'super_admin': ['*'],
  'program_manager': [
    'users:read', 'users:write',
    'enterprises:read', 'enterprises:write',
    'reports:read', 'reports:write'
  ],
  'coach': [
    'enterprises:read:assigned',
    'coaching:read', 'coaching:write',
    'assessments:read', 'assessments:write'
  ],
  'enterprise_user': [
    'profile:read:own',
    'tasks:read:own', 'tasks:write:own'
  ]
};
```

### **Data Security**
- **Encryption at Rest**: PII encrypted in database
- **Encryption in Transit**: HTTPS/TLS for all communications
- **Password Hashing**: bcrypt with salt rounds
- **PII Masking**: Sensitive data masked in logs
- **Audit Logging**: All data changes tracked

---

## 📱 **State Management Architecture**

### **Riverpod Provider Pattern**

#### **Provider Types**
```dart
// Provider for immutable data
final apiProvider = Provider<ApiService>((ref) => ApiService());

// StateNotifier for mutable state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(apiProvider))
);

// FutureProvider for async data
final enterprisesProvider = FutureProvider<List<Enterprise>>(
  (ref) => ref.read(apiProvider).getEnterprises()
);

// StreamProvider for real-time data
final notificationsProvider = StreamProvider<List<Notification>>(
  (ref) => ref.read(apiProvider).getNotificationStream()
);
```

#### **State Management Pattern**
```dart
// State class
class AuthState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;
  
  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });
  
  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier class
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  
  AuthNotifier(this._apiService) : super(const AuthState());
  
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final user = await _apiService.login(email, password);
      state = state.copyWith(
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}
```

---

## 🔄 **Data Flow Architecture**

### **Request Flow**
```
User Interface (Flutter)
    ↓
Provider (Riverpod)
    ↓
Use Case (Domain Layer)
    ↓
Repository Interface
    ↓
Repository Implementation
    ↓
Data Source (Remote/Local)
    ↓
API/Database
```

### **Offline-First Architecture**
```dart
// Data synchronization strategy
class SyncService {
  Future<void> syncData() async {
    // 1. Check network connectivity
    if (!await _networkInfo.isConnected()) return;
    
    // 2. Upload pending local changes
    await _uploadPendingChanges();
    
    // 3. Download remote changes
    await _downloadRemoteChanges();
    
    // 4. Resolve conflicts
    await _resolveConflicts();
    
    // 5. Update local cache
    await _updateLocalCache();
  }
}
```

---

## 📊 **Performance Architecture**

### **Caching Strategy**
- **Memory Cache**: Frequently accessed data in memory
- **Disk Cache**: Persistent cache for offline support
- **Network Cache**: HTTP caching for API responses
- **Image Cache**: Optimized image loading and caching

### **Database Optimization**
- **Connection Pooling**: Efficient database connections
- **Query Optimization**: Indexed queries and analysis
- **Pagination**: Large datasets split into pages
- **Lazy Loading**: Load data on demand

### **Frontend Performance**
- **Widget Optimization**: Efficient widget rebuilding
- **Image Optimization**: Compressed images and lazy loading
- **Code Splitting**: Feature-based code organization
- **Asset Optimization**: Minimized and compressed assets

---

## 🔧 **Integration Architecture**

### **External Services**
```javascript
// SMS Service (Brevo)
const smsService = {
  provider: 'brevo',
  apiKey: process.env.BREVO_API_KEY,
  templates: {
    coaching_reminder: 'template_123',
    training_notification: 'template_456'
  }
};

// Email Service (Brevo)
const emailService = {
  provider: 'brevo',
  apiKey: process.env.BREVO_API_KEY,
  templates: {
    welcome_email: 'template_789',
    certificate_issued: 'template_101'
  }
};

// File Storage (Cloudflare R2)
const storageService = {
  provider: 'cloudflare_r2',
  endpoint: process.env.R2_ENDPOINT,
  accessKey: process.env.R2_ACCESS_KEY,
  secretKey: process.env.R2_SECRET_KEY,
  bucket: 'mesmer-files'
};
```

### **API Integration Pattern**
```dart
// Repository pattern for API integration
class EnterpriseRepositoryImpl implements EnterpriseRepository {
  final EnterpriseRemoteDataSource _remoteDataSource;
  final EnterpriseLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  
  EnterpriseRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );
  
  @override
  Future<List<Enterprise>> getEnterprises() async {
    if (await _networkInfo.isConnected()) {
      try {
        final remoteEnterprises = await _remoteDataSource.getEnterprises();
        await _localDataSource.cacheEnterprises(remoteEnterprises);
        return remoteEnterprises;
      } catch (e) {
        // Fallback to local data if remote fails
        return await _localDataSource.getCachedEnterprises();
      }
    } else {
      // Return cached data when offline
      return await _localDataSource.getCachedEnterprises();
    }
  }
}
```

---

## 🧪 **Testing Architecture**

### **Test Pyramid**
```
                 E2E Tests (10%)
                /               \
        Integration Tests (20%)
       /                       \
    Unit Tests (70%)
```

### **Testing Strategy**
- **Unit Tests**: Individual functions and classes
- **Widget Tests**: UI component testing
- **Integration Tests**: API and database testing
- **E2E Tests**: Complete user workflows

### **Test Organization**
```dart
// Unit test example
void main() {
  group('AuthNotifier', () {
    test('should login successfully with valid credentials', () async {
      // Arrange
      final mockApiService = MockApiService();
      final authNotifier = AuthNotifier(mockApiService);
      
      // Act
      await authNotifier.login('test@example.com', 'password');
      
      // Assert
      expect(authNotifier.state.user, isNotNull);
      expect(authNotifier.state.isLoading, false);
    });
  });
}

// Widget test example
void main() {
  testWidgets('Login screen should validate email input', (tester) async {
    // Arrange
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    
    // Act
    await tester.enterText(find.byType(TextFormField), 'invalid-email');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    
    // Assert
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });
}
```

---

## 📈 **Scalability Architecture**

### **Horizontal Scaling**
- **Load Balancing**: Multiple app instances behind load balancer
- **Database Sharding**: Data distributed across multiple databases
- **Microservices**: Service decomposition for independent scaling
- **CDN Integration**: Static assets served via CDN

### **Vertical Scaling**
- **Resource Optimization**: Efficient resource utilization
- **Caching Layers**: Multiple caching levels
- **Database Optimization**: Query and index optimization
- **Code Optimization**: Performance profiling and optimization

---

## 🔍 **Monitoring Architecture**

### **Application Monitoring**
```javascript
// Performance monitoring
const monitoring = {
  metrics: {
    responseTime: 'avg_response_time',
    errorRate: 'error_rate_percentage',
    activeUsers: 'concurrent_users',
    apiCalls: 'api_calls_per_minute'
  },
  alerts: {
    highErrorRate: 'error_rate > 5%',
    slowResponse: 'response_time > 2000ms',
    databaseDown: 'database_connection_failed'
  }
};
```

### **Logging Strategy**
- **Structured Logging**: JSON format for easy parsing
- **Log Levels**: DEBUG, INFO, WARN, ERROR
- **Centralized Logging**: Log aggregation service
- **Security Logging**: Audit trails for security events

---

## 🚀 **Deployment Architecture**

### **Development Environment**
```yaml
# Docker Compose for development
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    depends_on:
      - postgres
      - redis
  
  postgres:
    image: postgres:14
    environment:
      - POSTGRES_DB=mesmer_dev
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
```

### **Production Environment**
- **Container Orchestration**: Kubernetes for deployment
- **Database Clustering**: PostgreSQL with replication
- **Load Balancing**: NGINX or cloud load balancer
- **SSL/TLS**: HTTPS for all communications
- **Backup Strategy**: Automated database backups

---

## 📋 **Architecture Decisions**

### **Technology Choices**
- **Flutter**: Cross-platform development with native performance
- **Node.js**: JavaScript ecosystem with rapid development
- **PostgreSQL**: Relational database with strong consistency
- **Riverpod**: Modern state management with dependency injection
- **Clean Architecture**: Maintainable and testable code structure

### **Design Patterns**
- **Repository Pattern**: Data access abstraction
- **Observer Pattern**: Reactive state management
- **Factory Pattern**: Object creation with flexibility
- **Strategy Pattern**: Algorithm selection at runtime
- **Decorator Pattern**: Additional functionality without modification

---

## 🔄 **Future Architecture Considerations**

### **Potential Enhancements**
- **Microservices**: Service decomposition for team scaling
- **Event Sourcing**: Immutable event log for audit trails
- **CQRS**: Command Query Responsibility Segregation
- **GraphQL**: Flexible API queries
- **Serverless**: Function-based architecture for cost optimization

### **Technology Migration**
- **Flutter Web**: Cross-platform web deployment
- **PostgreSQL Extensions**: Enhanced database capabilities
- **AI/ML Integration**: Predictive analytics and recommendations
- **Blockchain**: Certificate verification and immutability

---

**🏗️ Architecture Version: 1.0**
**🔄 Last Updated: January 2024**
**📧 Architecture Team: tech@mesmer.app**
