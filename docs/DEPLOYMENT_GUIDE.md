# 🚀 MESMER Digital Coaching Platform - Deployment Guide

**Complete Setup and Deployment Instructions**

---

## 📋 **Prerequisites**

### **System Requirements**

#### **Development Machine**
- **Operating System**: Windows 10+, macOS 10.15+, Ubuntu 18.04+
- **RAM**: Minimum 8GB, Recommended 16GB
- **Storage**: Minimum 20GB free space
- **Processor**: 64-bit processor with 4+ cores

#### **Software Requirements**
- **Flutter SDK**: 3.11.1 or higher
- **Dart SDK**: 3.0.0 or higher
- **Node.js**: 18.0.0 or higher
- **PostgreSQL**: 14.0 or higher
- **Git**: 2.20.0 or higher
- **Docker**: 20.10.0 or higher (optional)

#### **Mobile Development**
- **Android Studio**: Latest version (for Android development)
- **Xcode**: 14.0 or higher (for iOS development, macOS only)
- **Android SDK**: API level 33 or higher
- **iOS Simulator**: Latest version (macOS only)

---

## 🛠️ **Environment Setup**

### **1. Flutter Installation**

#### **Windows**
```powershell
# Download Flutter SDK
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.11.1-stable.zip" -OutFile "flutter_sdk.zip"
Expand-Archive flutter_sdk.zip -DestinationPath C:\
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")

# Verify installation
flutter doctor
```

#### **macOS**
```bash
# Install Flutter using Homebrew
brew install --cask flutter

# Or download manually
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.11.1-stable.zip
unzip flutter_macos_3.11.1-stable.zip
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### **Linux (Ubuntu)**
```bash
# Download and extract Flutter
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.11.1-stable.tar.xz
tar xf flutter_linux_3.11.1-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Add to PATH permanently
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
flutter doctor
```

### **2. Node.js Installation**

#### **Windows**
```powershell
# Download and install Node.js from nodejs.org
# Or use Chocolatey
choco install nodejs

# Verify installation
node --version
npm --version
```

#### **macOS/Linux**
```bash
# Using Node Version Manager (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18

# Verify installation
node --version
npm --version
```

### **3. PostgreSQL Installation**

#### **Windows**
```powershell
# Download and install from postgresql.org
# Or use Chocolatey
choco install postgresql

# Initialize database
sudo -i -u postgres
psql
```

#### **macOS**
```bash
# Using Homebrew
brew install postgresql
brew services start postgresql

# Create database user
createuser -s postgres
```

#### **Linux (Ubuntu)**
```bash
# Install PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib

# Start service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Set password for postgres user
sudo -i -u postgres psql
\password postgres
```

---

## 🗄️ **Database Setup**

### **1. Create Database and User**

```sql
-- Connect to PostgreSQL as postgres user
psql -U postgres

-- Create database
CREATE DATABASE mesmer_db;

-- Create user
CREATE USER mesmer_user WITH PASSWORD 'your_secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE mesmer_db TO mesmer_user;

-- Exit
\q
```

### **2. Initialize Database Schema**

```bash
# Navigate to project directory
cd mesmer_coaching_enterprise_monitoring

# Run schema initialization
psql -h localhost -U mesmer_user -d mesmer_db -f docs/setup.sql

# Verify tables were created
psql -h localhost -U mesmer_user -d mesmer_db -c "\dt"
```

### **3. Seed Initial Data (Optional)**

```bash
# Seed with test data
psql -h localhost -U mesmer_user -d mesmer_db -f docs/seed_data.sql
```

---

## 📱 **Mobile App Setup**

### **1. Clone Repository**

```bash
# Clone the repository
git clone <repository-url>
cd mesmer_coaching_enterprise_monitoring

# Install Flutter dependencies
flutter pub get

# Run code generation (if needed)
dart run build_runner build --delete-conflicting-outputs
```

### **2. Environment Configuration**

#### **Create Environment File**
```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

#### **Environment Variables (.env)**
```env
# API Configuration
API_BASE_URL=http://localhost:3000/api/v1
API_TIMEOUT=30000

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mesmer_db
DB_USER=mesmer_user
DB_PASSWORD=your_secure_password

# Security
JWT_SECRET=your_jwt_secret_key
ENCRYPTION_KEY=your_encryption_key

# External Services
BREVO_API_KEY=your_brevo_api_key
R2_ACCESS_KEY=your_r2_access_key
R2_SECRET_KEY=your_r2_secret_key
R2_BUCKET=mesmer-files
R2_ENDPOINT=https://your-account.r2.cloudflarestorage.com

# App Configuration
APP_NAME=MESMER Digital Coaching
APP_VERSION=1.0.0
ENVIRONMENT=development
```

### **3. Platform-Specific Setup**

#### **Android Setup**
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Configure keystore for release builds
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Update android/key.properties
echo "storePassword=your_store_password" > android/key.properties
echo "keyPassword=your_key_password" >> android/key.properties
echo "keyAlias=upload" >> android/key.properties
echo "storeFile=../upload-keystore.jks" >> android/key.properties
```

#### **iOS Setup (macOS only)**
```bash
# Install CocoaPods
sudo gem install cocoapods

# Navigate to iOS directory
cd ios

# Install pods
pod install

# Open project in Xcode
open Runner.xcworkspace
```

---

## 🖥️ **Backend API Setup**

### **1. Navigate to Server Directory**

```bash
# If backend is in separate repository
cd server

# Or if backend is in same project
cd server
```

### **2. Install Dependencies**

```bash
# Install Node.js dependencies
npm install

# Or using yarn
yarn install
```

### **3. Environment Configuration**

```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

#### **Backend Environment Variables (.env)**
```env
# Server Configuration
NODE_ENV=development
PORT=3000
HOST=localhost

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mesmer_db
DB_USER=mesmer_user
DB_PASSWORD=your_secure_password

# JWT Configuration
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# Security
BCRYPT_ROUNDS=12
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX=100

# External Services
BREVO_API_KEY=your_brevo_api_key
BREVO_EMAIL_FROM=noreply@mesmer.app

# File Storage
R2_ACCESS_KEY=your_r2_access_key
R2_SECRET_KEY=your_r2_secret_key
R2_BUCKET=mesmer-files
R2_ENDPOINT=https://your-account.r2.cloudflarestorage.com

# Logging
LOG_LEVEL=info
LOG_FILE=logs/app.log
```

### **4. Database Migration**

```bash
# Run database migrations
npm run migrate

# Or run manually
node scripts/migrate.js
```

### **5. Start Development Server**

```bash
# Start development server
npm run dev

# Or using nodemon
npm run start:dev
```

---

## 🐳 **Docker Deployment**

### **1. Docker Compose Setup**

#### **docker-compose.yml**
```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:14
    container_name: mesmer_postgres
    environment:
      POSTGRES_DB: mesmer_db
      POSTGRES_USER: mesmer_user
      POSTGRES_PASSWORD: your_secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./docs/setup.sql:/docker-entrypoint-initdb.d/setup.sql
    ports:
      - "5432:5432"
    networks:
      - mesmer_network

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: mesmer_redis
    ports:
      - "6379:6379"
    networks:
      - mesmer_network

  # Backend API
  api:
    build:
      context: ./server
      dockerfile: Dockerfile
    container_name: mesmer_api
    environment:
      NODE_ENV: production
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: mesmer_db
      DB_USER: mesmer_user
      DB_PASSWORD: your_secure_password
      REDIS_HOST: redis
      REDIS_PORT: 6379
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
    networks:
      - mesmer_network

  # Web Server (Nginx)
  web:
    image: nginx:alpine
    container_name: mesmer_web
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - api
    networks:
      - mesmer_network

volumes:
  postgres_data:

networks:
  mesmer_network:
    driver: bridge
```

### **2. Backend Dockerfile**

#### **server/Dockerfile**
```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Create logs directory
RUN mkdir -p logs

# Expose port
EXPOSE 3000

# Start application
CMD ["npm", "start"]
```

### **3. Deploy with Docker**

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up -d --build
```

---

## 🌐 **Production Deployment**

### **1. Server Preparation**

#### **System Requirements**
- **CPU**: 2+ cores
- **RAM**: 4GB+ 
- **Storage**: 50GB+ SSD
- **OS**: Ubuntu 20.04 LTS (recommended)

#### **Server Setup**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl wget git nginx certbot python3-certbot-nginx

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### **2. SSL Certificate Setup**

```bash
# Obtain SSL certificate
sudo certbot --nginx -d yourdomain.com -d api.yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### **3. Production Environment**

#### **docker-compose.prod.yml**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:14
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    networks:
      - mesmer_network

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    networks:
      - mesmer_network

  api:
    build:
      context: ./server
      dockerfile: Dockerfile.prod
    environment:
      NODE_ENV: production
      DB_HOST: postgres
      REDIS_HOST: redis
    restart: unless-stopped
    networks:
      - mesmer_network

  web:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.prod.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    restart: unless-stopped
    networks:
      - mesmer_network

volumes:
  postgres_data:

networks:
  mesmer_network:
    driver: bridge
```

### **4. Deploy to Production**

```bash
# Clone repository
git clone <repository-url>
cd mesmer_coaching_enterprise_monitoring

# Set up environment variables
cp .env.prod .env
# Edit .env with production values

# Deploy services
docker-compose -f docker-compose.prod.yml up -d

# Verify deployment
docker-compose -f docker-compose.prod.yml ps
```

---

## 📱 **Mobile App Deployment**

### **1. Android APK Build**

```bash
# Clean build
flutter clean
flutter pub get

# Build APK for release
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output locations
# APK: build/app/outputs/flutter-apk/app-release.apk
# App Bundle: build/app/outputs/bundle/release/app-release.aab
```

### **2. iOS Build (macOS only)**

```bash
# Clean build
flutter clean
flutter pub get
cd ios
pod install
cd ..

# Build iOS app
flutter build ios --release

# Open in Xcode for final build and upload
open ios/Runner.xcworkspace
```

### **3. Distribution**

#### **Google Play Store**
1. **Create Developer Account**: https://play.google.com/console
2. **Upload App Bundle**: Use `app-release.aab`
3. **Complete Store Listing**: App description, screenshots, etc.
4. **Submit for Review**: Wait for Google approval

#### **Apple App Store**
1. **Create Developer Account**: https://developer.apple.com
2. **Build in Xcode**: Archive and upload
3. **Complete App Store Connect**: Metadata, screenshots, etc.
4. **Submit for Review**: Wait for Apple approval

#### **Direct Distribution**
```bash
# Share APK directly
# Upload to file sharing service
# Create download link for users
```

---

## 🔍 **Testing and Validation**

### **1. API Testing**

```bash
# Test API endpoints
curl -X GET http://localhost:3000/api/v1/health

# Test authentication
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

### **2. Mobile App Testing**

```bash
# Run Flutter tests
flutter test

# Run integration tests
flutter test integration_test/

# Test on device/emulator
flutter run --release
```

### **3. Database Testing**

```bash
# Connect to database
psql -h localhost -U mesmer_user -d mesmer_db

# Verify tables
\dt

# Test queries
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM enterprises;
```

---

## 🔧 **Maintenance and Monitoring**

### **1. Database Maintenance**

```bash
# Backup database
pg_dump -h localhost -U mesmer_user mesmer_db > backup_$(date +%Y%m%d).sql

# Restore database
psql -h localhost -U mesmer_user mesmer_db < backup_20240115.sql

# Database optimization
psql -h localhost -U mesmer_user -d mesmer_db -c "VACUUM ANALYZE;"
```

### **2. Application Updates**

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.prod.yml up -d --build

# Clear Flutter cache
flutter clean
flutter pub get
```

### **3. Monitoring**

```bash
# View container logs
docker-compose -f docker-compose.prod.yml logs -f api

# Monitor system resources
docker stats

# Check disk space
df -h

# Monitor memory usage
free -h
```

---

## 🚨 **Troubleshooting**

### **Common Issues**

#### **Flutter Build Issues**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Check Flutter doctor
flutter doctor -v

# Clear Flutter cache
flutter pub cache clean
```

#### **Database Connection Issues**
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check connection
psql -h localhost -U mesmer_user -d mesmer_db

# Check logs
sudo tail -f /var/log/postgresql/postgresql-14-main.log
```

#### **API Server Issues**
```bash
# Check Node.js process
ps aux | grep node

# Check port availability
netstat -tulpn | grep :3000

# View logs
docker-compose logs -f api
```

#### **Docker Issues**
```bash
# Check Docker status
sudo systemctl status docker

# Rebuild containers
docker-compose down
docker-compose up -d --build

# Remove orphaned containers
docker system prune -f
```

### **Performance Issues**

#### **Slow API Response**
```bash
# Check database queries
psql -h localhost -U mesmer_user -d mesmer_db -c "SELECT * FROM pg_stat_activity;"

# Optimize database
psql -h localhost -U mesmer_user -d mesmer_db -c "VACUUM ANALYZE;"

# Check resource usage
docker stats
```

#### **Mobile App Performance**
```bash
# Use Flutter inspector
flutter run --profile

# Check memory usage
flutter run --profile --trace-startup

# Profile app performance
flutter run --profile --trace-startup --dump-performance-to-file=performance.json
```

---

## 📞 **Support and Resources**

### **Documentation**
- **API Documentation**: `/docs/API_DOCUMENTATION.md`
- **User Manual**: `/docs/USER_MANUAL.md`
- **Architecture Guide**: `/docs/ARCHITECTURE.md`

### **Community Support**
- **GitHub Issues**: Report bugs and request features
- **Stack Overflow**: Tag with `mesmer-platform`
- **Discord Community**: Join for real-time support

### **Professional Support**
- **Email**: support@mesmer.app
- **Documentation**: https://docs.mesmer.app
- **Status Page**: https://status.mesmer.app

---

**🚀 Deployment Guide Version: 1.0**
**🔄 Last Updated: January 2024**
**📧 Support: support@mesmer.app**
