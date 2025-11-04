# Superset Dashboard Embedding with Struts2 and RS256 Guest Tokens

This project demonstrates how to embed Apache Superset dashboards in a Struts2 application using RS256-signed guest tokens for secure, authenticated embedding.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Configuration](#configuration)
- [How It Works](#how-it-works)
- [API Endpoints](#api-endpoints)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

## ✨ Features

- **RS256 JWT Token Generation**: Secure guest token creation using RSA private key
- **Automatic Token Refresh**: Client-side automatic token refresh before expiration
- **Row-Level Security (RLS)**: Support for custom RLS rules in guest tokens
- **Responsive UI**: Modern, responsive dashboard interface
- **AJAX Token Management**: Refresh tokens without page reload
- **Error Handling**: Comprehensive error handling and user feedback

## 🏗️ Architecture

```
┌─────────────────┐
│   Browser/JSP   │
│   (Frontend)    │
└────────┬────────┘
         │
         │ HTTP Request
         ▼
┌─────────────────┐
│ Struts2 Action  │
│ SupersetAction  │
└────────┬────────┘
         │
         │ Generate Token
         ▼
┌─────────────────┐
│ GuestTokenUtil  │
│  (RS256 JWT)    │
└────────┬────────┘
         │
         │ Embed URL + Token
         ▼
┌─────────────────┐
│   Superset      │
│   Dashboard     │
└─────────────────┘
```

## 📦 Prerequisites

1. **Java Development Kit (JDK)**: JDK 8 or higher
2. **Apache Maven**: Version 3.6+
3. **Application Server**: Apache Tomcat 8.5+ or similar servlet container
4. **Apache Superset**: Running instance with guest token feature enabled
5. **RSA Key Pair**: PKCS#8 format private key for signing tokens

## 🚀 Setup Instructions

### 1. Generate RSA Key Pair

```bash
# Generate private key (PKCS#8 format)
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048

# Extract public key
openssl rsa -pubout -in private_key.pem -out public_key.pem
```

### 2. Configure Superset

Add the public key to your Superset configuration (`superset_config.py`):

```python
# Enable guest token feature
GUEST_TOKEN_JWT_SECRET = """-----BEGIN PUBLIC KEY-----
YOUR_PUBLIC_KEY_CONTENT_HERE
-----END PUBLIC KEY-----"""

GUEST_TOKEN_JWT_ALGO = "RS256"
GUEST_TOKEN_HEADER_NAME = "X-GuestToken"
GUEST_TOKEN_JWT_EXP_SECONDS = 3600

# Enable embedding
FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
    "ENABLE_TEMPLATE_PROCESSING": True,
}

# CORS settings (adjust for your domain)
ENABLE_CORS = True
CORS_OPTIONS = {
    'supports_credentials': True,
    'allow_headers': ['*'],
    'resources': ['*'],
    'origins': ['http://localhost:8080', 'https://your-domain.com']
}

# Ensure Content-Security-Policy allows embedding
TALISMAN_ENABLED = False
# Or configure CSP to allow your domain
```

### 3. Configure Application

Edit `src/main/resources/superset.properties`:

```properties
# Your Superset instance URL
superset.base.url=https://your-superset-instance.com

# Dashboard UUID (get from Superset dashboard URL)
superset.dashboard.id=your-dashboard-uuid

# JWT Configuration
jwt.issuer=your-application-name
jwt.audience=superset
jwt.secret.type=RS256
jwt.private.key.path=/private_key.pem
jwt.token.ttl=3600000

# Guest user details
guest.username=guest_user
guest.first.name=Guest
guest.last.name=User
```

### 4. Add Private Key

Copy your generated `private_key.pem` to:
```
src/main/resources/private_key.pem
```

**⚠️ IMPORTANT**: Add `private_key.pem` to `.gitignore` to avoid committing it!

### 5. Build the Project

```bash
# Clean and build
mvn clean package

# The WAR file will be created at: target/tts-dashboard.war
```

### 6. Deploy

Deploy `target/tts-dashboard.war` to your Tomcat server:
```bash
# Copy to Tomcat webapps directory
cp target/tts-dashboard.war /path/to/tomcat/webapps/

# Or use Tomcat Manager or your IDE deployment
```

### 7. Access the Application

Open your browser and navigate to:
```
http://localhost:8080/tts-dashboard/dashboard
```

## ⚙️ Configuration

### JWT Token Claims

The guest token includes the following claims:

```java
{
  "iss": "your-issuer",           // Token issuer
  "sub": "guest_user",            // Subject (username)
  "aud": "superset",              // Audience
  "jti": "unique-id",             // JWT ID
  "iat": 1234567890,              // Issued at timestamp
  "exp": 1234571490,              // Expiration timestamp
  "type": "guest",                // Token type
  "user": {                       // User information
    "username": "guest_user",
    "first_name": "Guest",
    "last_name": "User"
  },
  "resources": [                  // Accessible resources
    {
      "type": "dashboard",
      "id": "dashboard-uuid"
    }
  ],
  "rls_rules": []                 // Row-level security rules
}
```

### Adding RLS Rules

To add row-level security rules, modify `SupersetAction.java`:

```java
List<Map<String, Object>> rlsRules = new ArrayList<>();

// Example: Filter by department
Map<String, Object> rule1 = new HashMap<>();
rule1.put("clause", "department = 'Sales'");
rlsRules.add(rule1);

// Example: Filter by date range
Map<String, Object> rule2 = new HashMap<>();
rule2.put("clause", "date >= '2024-01-01'");
rlsRules.add(rule2);

String token = GuestTokenUtil.createGuestTokenWithRLS(dashboardId, rlsRules);
```

## 🔍 How It Works

### Token Generation Flow

1. **User Request**: Browser requests `/dashboard` endpoint
2. **Action Processing**: `SupersetAction.showDashboard()` method executes
3. **Token Generation**: 
   - Loads RSA private key from resources
   - Creates RS256 algorithm instance
   - Builds JWT with all required claims
   - Signs token with private key
4. **Response**: Forwards to `index.jsp` with token and dashboard URL
5. **Embedding**: JSP embeds Superset dashboard iframe with guest token

### Auto Token Refresh

The frontend JavaScript automatically refreshes the token:
- Default: Every 50 minutes (before 60-minute expiration)
- Configurable in `index.jsp`: `tokenRefreshInterval`
- Uses AJAX call to `/refreshToken` endpoint

## 🌐 API Endpoints

### GET/POST `/dashboard`
Shows the dashboard page with embedded Superset

**Response**: HTML page with embedded dashboard

### POST `/getGuestToken`
Returns a new guest token (AJAX endpoint)

**Response**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJSUzI1NiIs...",
  "dashboardId": "dashboard-uuid",
  "expiresIn": 3600
}
```

### POST `/refreshToken`
Refreshes the guest token (AJAX endpoint)

**Response**: Same as `/getGuestToken`

## 🔒 Security Considerations

1. **Private Key Protection**
   - Never commit private keys to version control
   - Use restrictive file permissions (chmod 600)
   - Consider using environment variables or key management services

2. **HTTPS Only**
   - Always use HTTPS in production
   - Configure secure cookies and headers

3. **Token Expiration**
   - Use short-lived tokens (15-60 minutes)
   - Implement automatic refresh mechanism

4. **CORS Configuration**
   - Restrict CORS origins to specific domains
   - Don't use wildcard (*) in production

5. **RLS Rules**
   - Validate and sanitize RLS clauses
   - Use parameterized queries to prevent SQL injection

6. **Environment-Specific Keys**
   - Use different key pairs for dev/staging/prod
   - Rotate keys periodically

## 🐛 Troubleshooting

### Dashboard Not Loading

**Issue**: Blank iframe or loading indicator stuck

**Solutions**:
- Check browser console for CORS errors
- Verify Superset CORS configuration
- Ensure `EMBEDDED_SUPERSET` feature flag is enabled
- Check Content-Security-Policy headers

### Token Validation Failed

**Issue**: "Invalid token" or "Token verification failed" errors

**Solutions**:
- Verify public key is correctly configured in Superset
- Ensure private key format is PKCS#8
- Check token expiration time
- Verify JWT claims match Superset expectations

### Private Key Load Error

**Issue**: "Unable to load private key" error

**Solutions**:
- Verify private key file exists at specified path
- Check private key format (must be PKCS#8)
- Convert PKCS#1 to PKCS#8 if needed:
  ```bash
  openssl pkcs8 -topk8 -nocrypt -in old_key.pem -out private_key.pem
  ```

### Build Errors

**Issue**: Maven build fails

**Solutions**:
- Run `mvn clean install`
- Check Java version (must be 8+)
- Verify Maven version (3.6+)
- Delete `.m2/repository` cache if needed

### 404 Errors

**Issue**: Action not found or 404 errors

**Solutions**:
- Verify `struts.xml` configuration
- Check action names and namespaces
- Ensure Struts filter is configured in `web.xml`
- Check deployment context path

## 📚 Additional Resources

- [Apache Superset Documentation](https://superset.apache.org/docs/intro)
- [Superset Embedded SDK](https://github.com/apache/superset/tree/master/superset-embedded-sdk)
- [Auth0 Java JWT Library](https://github.com/auth0/java-jwt)
- [Apache Struts2 Documentation](https://struts.apache.org/core-developers/)

## 📝 License

This project is provided as-is for educational and development purposes.

## 🤝 Contributing

Feel free to submit issues, fork the repository, and create pull requests.

---

**Note**: Remember to update all placeholder values (URLs, dashboard IDs, etc.) with your actual configuration before deploying to production.
