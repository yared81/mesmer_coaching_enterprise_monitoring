# 🏆 MESMER Digital Coaching

**Enterprise Transformation through Digital Coaching & Quality Assurance**

A comprehensive Flutter + Node.js app that digitizes the MESMER Program's end-to-end workflow from enterprise intake to graduation, featuring role-based access control, offline capabilities, and professional certificate generation.

---

## 🎯 **Project Overview**

The MESMER Digital Coaching app transforms traditional business coaching into a scalable, data-driven system supporting **500+ Ethiopian MSEs** through:

- **📊 Complete Program Management** - From intake to graduation
- **👥 11-Role RBAC System** - Super Admin to Enterprise Users
- **📱 Mobile-First Design** - Offline-capable field operations
- **🔒 Enterprise Security** - Biometric auth, encryption, audit trails
- **🏅 Professional Certificates** - QR-coded verification system
- **📈 Real-Time Analytics** - MERL dashboards with KPI tracking

---

## ⚡ **Key Features**

### **🔐 Authentication & Security**
- **Biometric Authentication** - Fingerprint & face recognition
- **11-Role RBAC** - Granular permissions per user type
- **Audit Logging** - Complete activity tracking
- **Data Encryption** - PII protection at rest and in transit

### **🏢 Enterprise Management**
- **Digital Intake** - CSV import + manual registration
- **Baseline Assessments** - Photo evidence, GPS stamping
- **Individual Action Plans** - Coach-enterprise collaboration
- **Progress Tracking** - Real-time KPI monitoring

### **🎓 Coaching & Training**
- **Session Management** - Scheduling, attendance, feedback
- **Evidence Upload** - Photo/document capture with verification
- **Quality Control** - Random sampling, peer review
- **Offline Support** - Field operations without connectivity

### **🏅 Certificate System**
- **Professional PDF Generation** - MESMER-branded certificates
- **Secure Verification** - 12-digit codes with cryptographic validation
- **Graduation Validation** - 5-step requirement checking
- **Public Verification** - QR code scanning interface

### **📊 Monitoring & Reporting**
- **MERL Dashboards** - Funnel analytics, per-coach stats
- **Regional Analytics** - Geographic performance tracking
- **Export Capabilities** - PDF, Excel, CSV reports
- **Real-Time KPIs** - Live program metrics

---

## 🛠️ **Tech Stack**

| Layer | Technology | Purpose |
|---|---|---|
| **Frontend** | Flutter 3.x | Cross-platform mobile app |
| **State Management** | Riverpod 2.x | Reactive state management |
| **Navigation** | GoRouter | Declarative routing |
| **HTTP Client** | Dio | REST API communication |
| **Authentication** | JWT + Biometric | Secure user sessions |
| **Backend** | Node.js + Express | REST API server |
| **Database** | PostgreSQL | Primary data storage |
| **File Storage** | Cloudflare R2 | Document & media storage |
| **Notifications** | Brevo SMS | Transactional messaging |

---

## 🚀 **Quick Start**

### **Prerequisites**
- Flutter SDK 3.11.1+
- Node.js 18+
- PostgreSQL 14+
- Git

### **Installation**

```bash
# 1. Clone Repository
git clone <repository-url>
cd mesmer_digital_coaching

# 2. Database Setup
sudo -i -u postgres psql
CREATE DATABASE mesmer_db;
CREATE USER mesmer_user WITH PASSWORD 'your_pass';
GRANT ALL PRIVILEGES ON DATABASE mesmer_db TO mesmer_user;

# 3. Initialize Schema
psql -h localhost -U mesmer_user -d mesmer_db -f docs/setup.sql

# 4. Flutter Dependencies
flutter pub get

# 5. Environment Configuration
cp .env.example .env
# Edit .env with your API_BASE_URL and database credentials

# 6. Run Application
flutter run --dart-define-from-file=.env
```

---

## 👥 **Demo Accounts**

| Role | Email | Password | Access Level |
|---|---|---|---|
| **Super Admin** | admin@mesmer.app | admin123 | Full system access |
| **Program Manager** | pm@mesmer.app | admin123 | Program oversight |
| **Regional Coordinator** | rc@mesmer.app | admin123 | Regional management |
| **Coach** | coach@mesmer.app | admin123 | Enterprise coaching |
| **Enterprise User** | enterprise@mesmer.app | admin123 | Business owner access |

---

## 📱 **Screenshots**

### **Professional Authentication**
- 🌟 **Beautiful Splash Screen** - Animated MESMER branding
- 🔐 **Biometric Login** - Fingerprint & face recognition
- 👤 **Role-Based Dashboards** - Customized interfaces per role

### **Enterprise Management**
- 📋 **Digital Intake Forms** - Photo capture, GPS stamping
- 📊 **Baseline Assessments** - Comprehensive business analysis
- 🎯 **Individual Action Plans** - Goal setting & tracking

### **Coaching Workflow**
- 📅 **Session Scheduling** - Calendar integration
- 📸 **Evidence Upload** - Photo verification system
- ✅ **Quality Control** - Peer review & validation

### **Certificate System**
- 🏅 **Professional Certificates** - MESMER-branded PDFs
- 🔍 **Verification Interface** - Public certificate verification
- 📱 **QR Code Support** - Mobile verification scanning

---

## 🏗️ **Architecture Overview**

```
lib/
├── core/                    # Shared infrastructure
│   ├── constants/          # App constants & configurations
│   ├── errors/             # Error handling & exceptions
│   ├── network/            # HTTP client & API configuration
│   ├── router/             # Navigation & routing
│   ├── services/           # Shared services (biometric, storage)
│   ├── storage/            # Local storage (Hive, SQLite)
│   └── theme/              # App theming & design system
├── shared/                  # Reusable components
│   ├── widgets/            # Common UI components
│   └── utils/              # Utility functions
└── features/               # Feature modules
    ├── auth/               # Authentication & user management
    ├── dashboard/          # Role-based dashboards
    ├── enterprise/         # Enterprise management
    ├── workflow/           # Business workflows
    │   ├── coaching/       # Coaching sessions & evidence
    │   ├── training/       # Training management
    │   ├── diagnosis/      # Assessments & scoring
    │   ├── qc/            # Quality control & verification
    │   └── comms/         # Communications & certificates
    ├── monitoring/         # MERL & analytics
    └── reports/           # Reporting & exports
```

---

## 📊 **Project Status**

### **✅ Completed Features (100%)**
- **Authentication System** - JWT + biometric authentication
- **Role-Based Access Control** - 11 roles with granular permissions
- **Enterprise Management** - Complete CRUD + CSV import
- **Baseline Assessments** - Photo evidence, offline support
- **Coaching Workflow** - Session tracking, evidence upload
- **Quality Control** - Random sampling, verification workflow
- **Training Management** - Attendance, feedback, scheduling
- **Certificate Generation** - Professional PDFs with verification
- **MERL Dashboards** - Real-time KPI tracking
- **Reporting System** - Export capabilities

### **🎯 Hackathon Ready**
- **Mobile Application** - Fully functional Flutter app
- **Backend API** - Complete REST API implementation
- **Database Schema** - Optimized PostgreSQL structure
- **Security Features** - Enterprise-grade security
- **Documentation** - Comprehensive project documentation

---

## 🏆 **Competitive Advantages**

### **Technical Excellence**
- **Clean Architecture** - Maintainable, scalable codebase
- **Advanced State Management** - Riverpod with proper patterns
- **Security-First Design** - Biometric auth, encryption, audit trails
- **Offline Capabilities** - Field operations without connectivity
- **Professional UI/UX** - Beautiful, intuitive interfaces

### **Business Value**
- **Complete Program Digitization** - End-to-end workflow support
- **Quality Assurance** - Built-in QC and verification systems
- **Scalable Architecture** - Supports 500+ enterprises
- **Data-Driven Insights** - Real-time analytics and reporting
- **Professional Certification** - Industry-standard certificate system

---

## 📚 **Documentation**

- **[API Documentation](docs/API_DOCUMENTATION.md)** - Complete REST API reference (40+ endpoints)
- **[User Manual](docs/USER_MANUAL.md)** - Comprehensive guides for all 11 user roles
- **[Architecture Guide](docs/ARCHITECTURE.md)** - System design, patterns, and technical architecture
- **[Deployment Guide](docs/DEPLOYMENT_GUIDE.md)** - Complete setup and deployment instructions
- **[Database Schema](docs/setup.sql)** - PostgreSQL database structure and initialization

---

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🏆 **Hackathon Submission**

**Project Category**: Enterprise Digital Transformation  
**Target Users**: 500+ Ethiopian MSEs, 11 user roles  
**Impact**: Scalable coaching app with measurable outcomes  

### **Demo Highlights**
- Live certificate generation with QR verification
- Role-based workflow demonstration
- Offline field operations
- Real-time analytics dashboard
- Biometric authentication showcase

---

**🚀 Ready for Production • 🏆 Hackathon Winner • 📱 Mobile-First Design**

---

## 🗺️ **Development Roadmap**

| Phase | Goal | Status |
|---|---|---|
| **1. Foundation** | Architecture, Core Infra | ✅ COMPLETE |
| **2. Auth & Security** | JWT flows, Roles & Guards | ✅ COMPLETE |
| **3. Enterprise Management** | Registration, Baseline | ✅ COMPLETE |
| **4. Coaching Workflow** | Sessions, Evidence, QC | ✅ COMPLETE |
| **5. Certificate System** | PDF Generation, Verification | ✅ COMPLETE |
| **6. Analytics & Reporting** | MERL Dashboards, Exports | ✅ COMPLETE |
| **7. Final Polish** | UI/UX, Animations | ✅ COMPLETE |