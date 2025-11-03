# 🚀 How to Run the TTS Dashboard Application

## 🚨 IMPORTANT: Port 8080 Conflict?

If you see an error like **"Failed to bind to 0.0.0.0:8080: Address already in use"**:

### Quick Fix (Choose one):
1. **Run clean script:** `RUN-CLEAN.bat` (kills existing process + starts fresh)
2. **Use different port:** `RUN-ON-DIFFERENT-PORT.bat` (runs on port 9090)
3. **Manual stop:** `STOP-PORT-8080.bat` then `mvn jetty:run`

📖 **Full details:** See `PORT-8080-CONFLICT-SOLVED.md`

---

## ✅ Pre-flight Checklist

Before running the application, ensure you have:

### 1. **Required Software**
- [ ] Java JDK 8 or higher installed
- [ ] Apache Maven 3.6+ installed
- [ ] Tomcat 8.5+ OR use the built-in Jetty server

### 2. **Configuration Files**
- [ ] `src/main/resources/private_key.pem` - Your RSA private key
- [ ] `src/main/resources/superset.properties` - Configured with your Superset settings

### 3. **Superset Configuration**
- [ ] Superset instance is running and accessible
- [ ] Public key is configured in Superset's `superset_config.py`
- [ ] `EMBEDDED_SUPERSET` feature flag is enabled
- [ ] CORS is enabled for your application domain

---

## 🎯 Quick Start - Option 1: Jetty (Fastest)

This is the fastest way to test the application locally.

### Steps:

1. **Open Command Prompt** in the project directory:
   ```cmd
   cd C:\Users\Sandeep\Downloads\struts-main\structs
   ```

2. **Run the Jetty startup script**:
   ```cmd
   run-jetty.bat
   ```

3. **Wait for startup**. You'll see:
   ```
   [INFO] Started Jetty Server
   [INFO] Started ServerConnector@...{HTTP/1.1, (http/1.1)}{0.0.0.0:8080}
   ```

4. **Access the application**:
   ```
   http://localhost:8080/tts-dashboard/dashboard
   ```

5. **To stop**: Press `Ctrl+C` in the command prompt

---

## 🎯 Option 2: Build and Deploy to Tomcat

If you prefer using Tomcat:

### Step 1: Build the Project

```cmd
cd C:\Users\Sandeep\Downloads\struts-main\structs
run.bat
```

This will:
- Clean previous builds
- Compile the source code
- Create `target/tts-dashboard.war`

### Step 2: Deploy to Tomcat

**Option A: Using deploy.bat**
```cmd
deploy.bat
```
Then enter your Tomcat webapps path when prompted.

**Option B: Manual deployment**
1. Copy `target/tts-dashboard.war` to your Tomcat `webapps` folder
2. Start/restart Tomcat
3. Tomcat will auto-deploy the WAR file

### Step 3: Access the Application

After Tomcat starts, navigate to:
```
http://localhost:8080/tts-dashboard/dashboard
```

---

## 🎯 Option 3: Maven Commands (For Developers)

### Build Only
```cmd
mvn clean compile
```

### Create WAR file
```cmd
mvn clean package
```

### Run with Jetty
```cmd
mvn clean jetty:run
```

### Skip Tests
```cmd
mvn clean package -DskipTests
```

---

## 🔧 Configuration Files

### 1. Edit Superset Properties

Open: `src/main/resources/superset.properties`

```properties
# Change these values to match your setup
superset.base.url=http://localhost:8088
superset.dashboard.id=YOUR_DASHBOARD_UUID

# JWT Configuration
jwt.issuer=my-app
jwt.audience=superset
jwt.private.key.path=/private_key.pem
jwt.token.ttl=3600000

# Guest User Info
guest.username=guest_user
guest.first.name=Guest
guest.last.name=User
```

### 2. Verify Private Key

Ensure `src/main/resources/private_key.pem` exists and is in PKCS#8 format:

```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQ...
...
-----END PRIVATE KEY-----
```

If you need to generate a new key pair:

```bash
# Generate private key
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048

# Extract public key (for Superset)
openssl rsa -pubout -in private_key.pem -out public_key.pem
```

---

## 📊 Understanding the Token Flow

When you access the dashboard, here's what happens:

1. **Browser requests** → `http://localhost:8080/tts-dashboard/dashboard`

2. **Struts2 Action** (`SupersetAction.showDashboard()`) executes:
   - Loads configuration from `superset.properties`
   - Calls `GuestTokenUtil.createGuestTokenForDashboard()`

3. **Token Generation** with RS256:
   ```java
   String token = JWT.create()
       .withIssuer(config.getIssuer())
       .withSubject(username)
       .withAudience(config.getAudience())
       .withJWTId(jti)
       .withIssuedAt(now)
       .withExpiresAt(expiryDate)
       .withClaim("type", "guest")
       .withClaim("user", userClaim)
       .withClaim("resources", resourcesClaim)
       .withClaim("rls_rules", rlsRulesClaim)
       .sign(algorithm);  // Signed with RS256
   ```

4. **JSP receives**:
   - `guestToken` - The signed JWT
   - `baseUrl` - Superset URL
   - `dashboardId` - Dashboard UUID

5. **JavaScript embeds** the dashboard in an iframe with the guest token

6. **Auto-refresh** happens every 50 minutes (before 60-minute token expiry)

---

## 🧪 Testing the Application

### 1. Check if the server is running
```
http://localhost:8080/tts-dashboard/
```

### 2. Access the dashboard
```
http://localhost:8080/tts-dashboard/dashboard
```

### 3. Test token refresh (in browser console)
```javascript
refreshToken();
```

### 4. Check server logs

**Jetty logs**: Shows in the command prompt where you ran `mvn jetty:run`

**Tomcat logs**: Check `TOMCAT_HOME/logs/catalina.out`

Look for:
```
✅ Guest token generated successfully
Dashboard ID: 3dd4dbae-...
Base URL: http://localhost:8088
```

---

## 🐛 Troubleshooting

### Problem: "Maven not found"
**Solution**: 
1. Download Maven from https://maven.apache.org/download.cgi
2. Extract to `C:\Program Files\Apache Maven`
3. Add to PATH: `C:\Program Files\Apache Maven\bin`
4. Verify: `mvn --version`

### Problem: "Failed to load dashboard"
**Check**:
1. Is Superset running? Try accessing it directly: `http://localhost:8088`
2. Is the dashboard ID correct in `superset.properties`?
3. Check browser console for CORS errors
4. Verify Superset has CORS enabled for `http://localhost:8080`

### Problem: "Token signature verification failed"
**Check**:
1. Did you add the PUBLIC key to Superset's `superset_config.py`?
2. Is `GUEST_TOKEN_JWT_ALGO = "RS256"` set in Superset?
3. Do the private and public keys match (generated together)?

### Problem: "Port 8080 already in use"
**Solution**: 
- Either stop the other application using port 8080
- Or change the port in `pom.xml` (Jetty plugin configuration)

### Problem: Compilation errors
**Solution**:
```cmd
mvn clean install -U
```

---

## 📝 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/dashboard` | GET | Main dashboard page (JSP) |
| `/refreshToken` | POST | Get a new guest token (AJAX/JSON) |
| `/getGuestToken` | GET | Get current guest token info (AJAX/JSON) |

---

## 🎨 Customization

### Change Dashboard UI

Edit: `src/main/webapp/index.jsp`
- Modify CSS in the `<style>` section
- Customize the header, buttons, and layout

### Add RLS Rules

Modify: `src/main/java/com/structs/util/GuestTokenUtil.java`

Example:
```java
List<Map<String, Object>> rlsRules = new ArrayList<>();
Map<String, Object> rule = new HashMap<>();
rule.put("clause", "department = 'Sales'");
rlsRules.add(rule);
```

### Change Token Expiry

Edit: `src/main/resources/superset.properties`
```properties
jwt.token.ttl=7200000  # 2 hours in milliseconds
```

---

## 📚 Additional Resources

- **Full Documentation**: `README.md`
- **Quick Setup**: `QUICKSTART.md`
- **Project Structure**: `PROJECT_SUMMARY.md`
- **Architecture**: `ARCHITECTURE.md`
- **Superset Config Example**: `superset_config_example.py`

---

## ✅ Success Indicators

When everything is working correctly, you should see:

1. ✅ Build completes without errors
2. ✅ Server starts and listens on port 8080
3. ✅ Dashboard page loads at `/tts-dashboard/dashboard`
4. ✅ Token status shows "Active" in the UI
5. ✅ Superset dashboard renders in the iframe
6. ✅ No CORS errors in browser console
7. ✅ Token auto-refresh works (check console every 50 minutes)

---

## 🆘 Need Help?

1. Check the logs for error messages
2. Review the `TROUBLESHOOTING` section above
3. Verify all configuration files are correct
4. Ensure Superset is properly configured
5. Test the token generation separately

---

**Good luck! 🚀**

