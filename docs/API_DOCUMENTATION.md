# 📡 MESMER Digital Coaching - API Documentation

**Complete REST API Reference for the MESMER Digital Coaching App**

---

## 🌐 **Base URL**

```
Production: https://api.mesmer.app/v1
Development: http://localhost:3000/api/v1
```

---

## 🔐 **Authentication**

### **JWT Token-Based Authentication**

All API endpoints (except authentication) require a valid JWT token in the Authorization header:

```http
Authorization: Bearer <your-jwt-token>
```

### **Token Types**
- **Access Token**: 15-minute validity for API requests
- **Refresh Token**: 7-day validity for token renewal

---

## 📋 **API Endpoints Overview**

| Module | Endpoints | Description |
|---|---|---|
| **Authentication** | 4 | Login, logout, token refresh, user profile |
| **Users** | 6 | User management, roles, permissions |
| **Enterprises** | 8 | Enterprise CRUD, import, search |
| **Assessments** | 7 | Baseline, midline, endline assessments |
| **Coaching** | 9 | Sessions, evidence, scheduling |
| **Training** | 6 | Training management, attendance |
| **Quality Control** | 5 | QC reviews, audits, verification |
| **Certificates** | 6 | Certificate generation, verification |
| **Reports** | 4 | Analytics, exports, dashboards |
| **Notifications** | 3 | SMS, push notifications |

---

## 🔑 **Authentication Endpoints**

### **POST /auth/login**
Authenticate user and return JWT tokens.

**Request Body:**
```json
{
  "email": "user@mesmer.app",
  "password": "password123",
  "deviceInfo": {
    "platform": "android",
    "version": "1.0.0",
    "deviceId": "device_123"
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "email": "user@mesmer.app",
      "role": "coach",
      "firstName": "John",
      "lastName": "Doe",
      "region": "addis_ababa"
    },
    "tokens": {
      "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
      "refreshToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
      "expiresIn": 900
    }
  }
}
```

### **POST /auth/refresh**
Refresh access token using refresh token.

**Request Body:**
```json
{
  "refreshToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### **POST /auth/logout**
Invalidate user tokens and logout.

**Headers:** `Authorization: Bearer <access-token>`

### **GET /auth/profile**
Get current user profile.

**Headers:** `Authorization: Bearer <access-token>`

---

## 👥 **User Management Endpoints**

### **GET /users**
Get list of users (Admin/Manager only).

**Query Parameters:**
- `role` (optional): Filter by role
- `region` (optional): Filter by region
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "user_123",
        "email": "coach@mesmer.app",
        "role": "coach",
        "firstName": "John",
        "lastName": "Doe",
        "region": "addis_ababa",
        "isActive": true,
        "lastLogin": "2024-01-15T10:30:00Z",
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "totalPages": 3
    }
  }
}
```

### **POST /users**
Create new user (Admin only).

### **GET /users/:id**
Get user by ID.

### **PUT /users/:id**
Update user information.

### **DELETE /users/:id**
Soft delete user (Admin only).

### **PUT /users/:id/role**
Update user role (Admin only).

---

## 🏢 **Enterprise Management Endpoints**

### **GET /enterprises**
Get list of enterprises.

**Query Parameters:**
- `region` (optional): Filter by region
- `status` (optional): Filter by status (active, inactive, graduated)
- `coach` (optional): Filter by assigned coach
- `search` (optional): Search by name or owner

**Response (200):**
```json
{
  "success": true,
  "data": {
    "enterprises": [
      {
        "id": "enterprise_123",
        "name": "ABC Trading",
        "ownerName": "Abebe Kebede",
        "sector": "retail",
        "region": "addis_ababa",
        "status": "active",
        "coachId": "coach_123",
        "baselineCompleted": true,
        "sessionsCompleted": 6,
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "totalPages": 8
    }
  }
}
```

### **POST /enterprises**
Create new enterprise.

**Request Body:**
```json
{
  "name": "New Enterprise",
  "ownerName": "Owner Name",
  "email": "enterprise@example.com",
  "phone": "+251911234567",
  "sector": "manufacturing",
  "region": "addis_ababa",
  "address": "123 Main St",
  "coordinates": {
    "latitude": 9.1450,
    "longitude": 40.4897
  },
  "consent": {
    "given": true,
    "version": "1.0",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### **POST /enterprises/import**
Import enterprises from CSV file.

### **GET /enterprises/:id**
Get enterprise details by ID.

### **PUT /enterprises/:id**
Update enterprise information.

### **DELETE /enterprises/:id**
Soft delete enterprise.

### **GET /enterprises/:id/profile**
Get complete enterprise profile with all related data.

---

## 📊 **Assessment Endpoints**

### **GET /assessments**
Get list of assessments.

**Query Parameters:**
- `enterpriseId` (optional): Filter by enterprise
- `type` (optional): Assessment type (baseline, midline, endline)
- `status` (optional): Filter by status

### **POST /assessments**
Create new assessment.

**Request Body:**
```json
{
  "enterpriseId": "enterprise_123",
  "type": "baseline",
  "data": {
    "monthlyRevenue": 50000,
    "employees": 5,
    "hasBookkeeping": true,
    "hasInventory": false,
    "challenges": ["cash_flow", "competition"]
  },
  "evidence": [
    {
      "type": "photo",
      "url": "https://storage.example.com/evidence1.jpg",
      "timestamp": "2024-01-15T10:30:00Z",
      "coordinates": {
        "latitude": 9.1450,
        "longitude": 40.4897
      }
    }
  ]
}
```

### **GET /assessments/:id**
Get assessment by ID.

### **PUT /assessments/:id**
Update assessment.

### **POST /assessments/:id/evidence**
Upload evidence for assessment.

### **PUT /assessments/:id/submit**
Submit assessment for review.

### **PUT /assessments/:id/approve**
Approve assessment (M&E only).

---

## 🎓 **Coaching Endpoints**

### **GET /sessions**
Get coaching sessions.

**Query Parameters:**
- `enterpriseId` (optional): Filter by enterprise
- `coachId` (optional): Filter by coach
- `status` (optional): Filter by status
- `dateFrom` (optional): Filter by date range
- `dateTo` (optional): Filter by date range

### **POST /sessions**
Create new coaching session.

**Request Body:**
```json
{
  "enterpriseId": "enterprise_123",
  "scheduledDate": "2024-01-20T14:00:00Z",
  "type": "in_person",
  "focus": [
    "financial_management",
    "inventory_control"
  ],
  "notes": "Discussed cash flow challenges",
  "actions": [
    {
      "task": "Implement daily sales log",
      "responsible": "enterprise",
      "dueDate": "2024-01-27T00:00:00Z"
    }
  ],
  "nextVisit": "2024-01-27T14:00:00Z"
}
```

### **GET /sessions/:id**
Get session by ID.

### **PUT /sessions/:id**
Update session.

### **POST /sessions/:id/evidence**
Upload evidence for session.

### **PUT /sessions/:id/complete**
Mark session as completed.

### **GET /sessions/calendar**
Get coaching calendar (for authenticated user).

### **POST /sessions/:id/followup**
Create phone follow-up.

---

## 📚 **Training Endpoints**

### **GET /training**
Get training sessions.

### **POST /training**
Create new training session.

**Request Body:**
```json
{
  "title": "Basic Bookkeeping",
  "module": "bookkeeping",
  "date": "2024-01-25T09:00:00Z",
  "startTime": "09:00",
  "endTime": "12:00",
  "location": "MESMER Training Center",
  "trainerId": "trainer_123",
  "capacity": 20,
  "description": "Introduction to basic bookkeeping practices"
}
```

### **GET /training/:id**
Get training session by ID.

### **PUT /training/:id**
Update training session.

### **POST /training/:id/attendance**
Record attendance.

### **GET /training/:id/feedback**
Get training feedback.

### **POST /training/:id/feedback**
Submit training feedback.

---

## 🔍 **Quality Control Endpoints**

### **GET /qc/queue**
Get QC review queue (M&E only).

### **GET /qc/audits**
Get QC audits.

### **POST /qc/audits**
Create QC audit.

### **PUT /qc/audits/:id/review`
Review and approve/reject audit.

### **GET /qc/statistics**
Get QC statistics.

---

## 🏅 **Certificate Endpoints**

### **GET /certificates**
Get list of certificates.

### **POST /certificates**
Generate new certificate.

**Request Body:**
```json
{
  "enterpriseId": "enterprise_123",
  "coachName": "John Doe",
  "regionalCoordinator": "Jane Smith",
  "achievements": [
    "Implemented bookkeeping system",
    "Increased revenue by 25%",
    "Hired 2 new employees"
  ]
}
```

### **GET /certificates/:id**
Get certificate by ID.

### **PUT /certificates/:id/approve**
Approve certificate (M&E only).

### **PUT /certificates/:id/issue**
Issue certificate (Communications only).

### **GET /certificates/verify/:code**
Verify certificate by code.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "certificate": {
      "id": "cert_123",
      "enterpriseName": "ABC Trading",
      "ownerName": "Abebe Kebede",
      "issueDate": "2024-01-15T00:00:00Z",
      "verificationCode": "ABCD1234EFGH",
      "status": "issued",
      "pdfUrl": "https://storage.example.com/certificates/cert_123.pdf"
    }
  }
}
```

---

## 📈 **Reports Endpoints**

### **GET /reports/dashboard`
Get dashboard analytics.

### **GET /reports/funnel**
Get program funnel metrics.

### **GET /reports/enterprise/:id/progress`
Get enterprise progress report.

### **POST /reports/export`
Export report data.

**Request Body:**
```json
{
  "type": "enterprise_list",
  "format": "excel",
  "filters": {
    "region": "addis_ababa",
    "status": "active"
  }
}
```

---

## 📱 **Notification Endpoints**

### **POST /notifications/sms**
Send SMS notification.

### **POST /notifications/push**
Send push notification.

### **GET /notifications/history`
Get notification history.

---

## 🚨 **Error Handling**

### **Standard Error Response Format**

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "email",
      "reason": "Invalid email format"
    }
  }
}
```

### **HTTP Status Codes**

| Status | Description |
|---|---|
| **200** | Success |
| **201** | Created |
| **400** | Bad Request |
| **401** | Unauthorized |
| **403** | Forbidden |
| **404** | Not Found |
| **409** | Conflict |
| **422** | Validation Error |
| **429** | Rate Limited |
| **500** | Internal Server Error |

### **Common Error Codes**

| Code | Description |
|---|---|
| `VALIDATION_ERROR` | Input validation failed |
| `AUTHENTICATION_FAILED` | Invalid credentials |
| `AUTHORIZATION_FAILED` | Insufficient permissions |
| `RESOURCE_NOT_FOUND` | Resource does not exist |
| `DUPLICATE_RESOURCE` | Resource already exists |
| `RATE_LIMIT_EXCEEDED` | Too many requests |
| `INTERNAL_ERROR` | Server error |

---

## 🔄 **Rate Limiting**

### **Rate Limits by Endpoint**

| Endpoint Type | Limit | Window |
|---|---|---|
| Authentication | 5 requests | 1 minute |
| File Upload | 10 requests | 1 minute |
| Standard API | 100 requests | 1 minute |
| Reports | 20 requests | 1 minute |

### **Rate Limit Headers**

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642694400
```

---

## 📄 **Response Formats**

### **Success Response**

```json
{
  "success": true,
  "data": {
    // Response data
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0.0"
  }
}
```

### **Paginated Response**

```json
{
  "success": true,
  "data": {
    "items": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

---

## 🔒 **Security Features**

### **Request Validation**
- All inputs are validated and sanitized
- SQL injection protection
- XSS protection
- CSRF protection

### **Data Encryption**
- PII encrypted at rest
- HTTPS enforced in production
- Sensitive data masked in logs

### **Audit Logging**
- All API requests logged
- User actions tracked
- Data changes audited

---

## 🧪 **Testing Endpoints**

### **POST /test/auth/login**
Test authentication (development only).

### **GET /test/health**
API health check.

### **POST /test/seed**
Seed test data (development only).

---

## 📊 **API Versioning**

- **Current Version**: v1
- **Version Format**: `/api/v1/`
- **Backward Compatibility**: Maintained for 6 months
- **Depreciation Notice**: Sent via API headers

---

## 🛠️ **SDK and Libraries**

### **Official SDKs**
- **Flutter/Dart**: `mesmer_flutter_sdk`
- **JavaScript/Node.js**: `mesmer-js-sdk`
- **Python**: `mesmer-python-sdk`

### **Third-Party Integrations**
- **Postman Collection**: Available
- **OpenAPI Specification**: `/api/v1/openapi.json`
- **RAML Definition**: `/api/v1/raml`

---

## 📞 **Support**

### **API Support**
- **Email**: api-support@mesmer.app
- **Documentation**: https://docs.mesmer.app
- **Status Page**: https://status.mesmer.app

### **Developer Community**
- **GitHub Discussions**: https://github.com/mesmer/api/discussions
- **Stack Overflow**: Tag with `mesmer-api`
- **Discord**: https://discord.gg/mesmer

---

**📡 Last Updated: January 2024**
**🔒 Security Level: Enterprise**
**🚀 API Version: v1.0.0**
