# =============================================================================
# Superset Configuration Example for superset_config.py
# =============================================================================
# Copy these settings to your Superset instance configuration file

# -----------------------------------------------------------------------------
# Guest Token Configuration
# -----------------------------------------------------------------------------

# Public key for RS256 token verification
# Replace with your actual public key from public_key.pem
GUEST_TOKEN_JWT_SECRET = """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyourpublickey
hereinbase64formatwithlinebreaksifyouneedthembutcanalsobe
asinglelinethesupersetconfigurationwillhandleiteitherway
-----END PUBLIC KEY-----"""

# Algorithm must match the one used in your application (RS256)
GUEST_TOKEN_JWT_ALGO = "RS256"

# Token expiration time in seconds (should match jwt.token.ttl / 1000 in superset.properties)
GUEST_TOKEN_JWT_EXP_SECONDS = 3600

# Optional: Custom header name for guest token
GUEST_TOKEN_HEADER_NAME = "X-GuestToken"

# -----------------------------------------------------------------------------
# Embedding Configuration
# -----------------------------------------------------------------------------

# Enable embedded Superset feature
FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
    "ENABLE_TEMPLATE_PROCESSING": True,
}

# -----------------------------------------------------------------------------
# CORS Configuration
# -----------------------------------------------------------------------------

# Enable CORS for embedding in external applications
ENABLE_CORS = True

CORS_OPTIONS = {
    'supports_credentials': True,
    'allow_headers': [
        'X-CSRFToken',
        'Content-Type',
        'Origin',
        'X-Requested-With',
        'Accept',
        'Authorization',
        'X-GuestToken',
    ],
    'resources': {
        '/superset/*': {'origins': '*'},
        '/api/*': {'origins': '*'},
        '/login/*': {'origins': '*'},
    },
    # For production, replace with specific origins:
    'origins': [
        'http://localhost:8080',
        'http://localhost:3000',
        'https://your-production-domain.com'
    ]
}

# -----------------------------------------------------------------------------
# Security Headers Configuration
# -----------------------------------------------------------------------------

# Disable Talisman for embedding (or configure properly)
TALISMAN_ENABLED = False

# If you need Talisman enabled, configure Content Security Policy:
# TALISMAN_CONFIG = {
#     'content_security_policy': {
#         'default-src': ["'self'"],
#         'frame-ancestors': [
#             "'self'",
#             'http://localhost:8080',
#             'https://your-production-domain.com'
#         ],
#         'script-src': ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
#         'style-src': ["'self'", "'unsafe-inline'"],
#     },
#     'force_https': False,  # Set True in production with HTTPS
# }

# -----------------------------------------------------------------------------
# Session Configuration
# -----------------------------------------------------------------------------

# Session cookie settings
SESSION_COOKIE_SECURE = False  # Set True in production with HTTPS
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'  # Or 'None' for cross-domain (requires Secure=True)

# -----------------------------------------------------------------------------
# Additional Security Settings
# -----------------------------------------------------------------------------

# JWT cookie name and domain
JWT_COOKIE_NAME = 'superset_jwt_access_token'
# JWT_COOKIE_DOMAIN = '.yourdomain.com'  # Set for subdomain sharing

# Enable guest user features
ENABLE_GUEST_USER = True

# -----------------------------------------------------------------------------
# Example: Creating Dashboard with Guest Token in Python
# -----------------------------------------------------------------------------

"""
# Test your configuration with Python:

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
import jwt
from datetime import datetime, timedelta
import uuid

# Load your private key
with open('private_key.pem', 'rb') as f:
    private_key = serialization.load_pem_private_key(
        f.read(),
        password=None,
        backend=default_backend()
    )

# Create token
payload = {
    'iss': 'your-issuer',
    'sub': 'guest_user',
    'aud': 'superset',
    'jti': str(uuid.uuid4()),
    'iat': datetime.utcnow(),
    'exp': datetime.utcnow() + timedelta(hours=1),
    'type': 'guest',
    'user': {
        'username': 'guest_user',
        'first_name': 'Guest',
        'last_name': 'User'
    },
    'resources': [
        {
            'type': 'dashboard',
            'id': 'your-dashboard-uuid'
        }
    ],
    'rls_rules': []
}

token = jwt.encode(payload, private_key, algorithm='RS256')
print(f"Guest Token: {token}")

# Test embed URL
embed_url = f"https://your-superset.com/superset/dashboard/your-dashboard-uuid/?standalone=3&guest_token={token}"
print(f"Embed URL: {embed_url}")
"""

# =============================================================================
# End of Configuration
# =============================================================================

