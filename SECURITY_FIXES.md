# Security Fixes - SomethingToDo Firebase Backend

## Critical Security Vulnerabilities Fixed

### 1. CORS Policy (CRITICAL - FIXED)
**Previous Issue:** `origin: true` allowed ALL origins to access the API
**Fix Applied:** 
- Implemented domain whitelist with configurable allowed origins
- Added proper CORS validation with credentials support
- Cached preflight responses for 24 hours to improve performance

**Configuration:**
```bash
# Set allowed origins for production
firebase functions:config:set app.allowed_origins="https://yourdomain.com,https://app.yourdomain.com"
```

### 2. Duplicate Route Definitions (FIXED)
**Previous Issue:** Duplicate `/events/search` endpoints causing routing conflicts
**Fix Applied:**
- Removed duplicate route definitions (lines 600-629)
- Consolidated all event endpoints into single, clean definitions
- Added proper parameter validation for all routes

### 3. API Key Exposure Prevention (FIXED)
**Previous Issue:** Error messages could leak API keys and sensitive information
**Fix Applied:**
- Implemented `sendErrorResponse` helper that sanitizes all error messages
- Removes potential API keys (20+ character strings)
- Removes IP addresses from error messages
- Only shows detailed errors in development mode

### 4. Input Validation (FIXED)
**Previous Issue:** No input sanitization, vulnerable to injection attacks
**Fix Applied:**
- Comprehensive `validateInput` middleware on all endpoints
- Removes script tags and potential XSS vectors
- Prevents SQL injection attempts
- Limits string lengths to prevent abuse
- Validates all numeric parameters

### 5. OpenAI API Update (FIXED)
**Previous Issue:** Using deprecated `gpt-4-turbo-preview` model and functions API
**Fix Applied:**
- Updated to `gpt-4o-mini` model (latest, cost-effective)
- Migrated from deprecated `functions` API to new `tools` API
- Added proper error handling without exposing details
- Limited chat history to last 10 messages to control costs

### 6. Rate Limiting (FIXED)
**Previous Issue:** No protection against API abuse
**Fix Applied:**
- Implemented IP-based rate limiting middleware
- Configurable limits (default: 100 requests per minute)
- Returns proper 429 status with retry-after header
- Memory-based implementation suitable for single instances

**Configuration:**
```bash
firebase functions:config:set security.rate_limit_max="100" security.rate_limit_window="60000"
```

### 7. Authentication on Sensitive Endpoints (FIXED)
**Previous Issue:** Critical endpoints lacked authentication
**Fix Applied:**
- Added `authenticateUser` middleware to:
  - `/chat` - AI chat endpoint
  - `/events/sync` - Event synchronization
  - `/recommendations/generate` - Personalized recommendations
- Validates Firebase ID tokens
- Properly handles unauthorized requests

### 8. Firestore Security Rules (ENHANCED)
**Previous Issue:** Basic security rules with potential vulnerabilities
**Enhancements Applied:**
- Added comprehensive helper functions for validation
- Implemented data size limits (1MB max)
- Added string length validation for all fields
- Prevented privilege escalation (users can't make themselves admin/premium)
- Added XSS protection in content validation
- Implemented proper role-based access control
- Added audit log support for security tracking
- Default deny rule for unmatched paths

## Additional Security Improvements

### Request Size Limiting
- Limited JSON body size to 10MB
- Prevents memory exhaustion attacks

### Parameter Validation
- All numeric parameters validated and bounded
- Location radius limited to 50km maximum
- Query results limited to 100 items maximum
- String parameters truncated to safe lengths

### Health Check Endpoint
- Added `/health` endpoint for monitoring
- Returns version and status information
- No sensitive data exposed

### Secure Configuration Management
- Created `set-config.sh` script for secure configuration
- API keys stored in Firebase Functions config, not in code
- Environment-specific configuration handling

## Deployment Instructions

### 1. Set Configuration (Production)
```bash
cd functions
./set-config.sh
# Enter your API keys and allowed origins when prompted
```

### 2. Build Functions
```bash
npm run build
```

### 3. Deploy Functions
```bash
firebase deploy --only functions
```

### 4. Deploy Security Rules
```bash
firebase deploy --only firestore:rules
```

### 5. Verify Deployment
```bash
# Test health endpoint
curl https://your-project.cloudfunctions.net/api/health

# Check configuration
firebase functions:config:get
```

## Security Best Practices

### For Development
1. Use `.env` file for local development (never commit it)
2. Use Firebase emulators for testing
3. Keep rate limits lower for testing

### For Production
1. Use HTTPS only - never HTTP
2. Set specific domain origins - no wildcards
3. Monitor rate limit violations in logs
4. Regularly rotate API keys
5. Enable Firebase App Check for additional protection
6. Set up alerts for suspicious activity
7. Review audit logs regularly

## Environment Variables

### Required Configuration
- `OPENAI_API_KEY` - OpenAI API key for chat functionality
- `RAPIDAPI_KEY` - RapidAPI key for event data
- `ALLOWED_ORIGINS` - Comma-separated list of allowed domains

### Optional Configuration
- `RATE_LIMIT_MAX` - Maximum requests per window (default: 100)
- `RATE_LIMIT_WINDOW` - Time window in milliseconds (default: 60000)

## Testing Security

### CORS Testing
```bash
# Should fail (unauthorized origin)
curl -H "Origin: https://evil.com" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: X-Requested-With" \
     -X OPTIONS \
     https://your-project.cloudfunctions.net/api/events/search
```

### Rate Limiting Testing
```bash
# Run this multiple times quickly to trigger rate limit
for i in {1..150}; do
  curl https://your-project.cloudfunctions.net/api/events/search
done
```

### Authentication Testing
```bash
# Should return 401 Unauthorized
curl -X POST https://your-project.cloudfunctions.net/api/chat \
     -H "Content-Type: application/json" \
     -d '{"message": "test"}'
```

## Monitoring & Alerts

### Recommended Monitoring
1. Set up Firebase Performance Monitoring
2. Enable Cloud Logging for security events
3. Configure alerts for:
   - High rate limit violations
   - Authentication failures
   - Error rate spikes
   - Unusual traffic patterns

### Log Queries
```sql
-- Find rate limit violations
resource.type="cloud_function"
jsonPayload.message="Rate limit exceeded"

-- Find authentication failures
resource.type="cloud_function"
jsonPayload.error="Invalid authentication token"
```

## Security Checklist

- [x] CORS restricted to specific domains
- [x] Duplicate routes removed
- [x] Error messages sanitized
- [x] Input validation implemented
- [x] OpenAI API updated to latest version
- [x] Rate limiting implemented
- [x] Authentication on sensitive endpoints
- [x] Firestore rules enhanced
- [x] Configuration script created
- [x] Security documentation completed

## Support

For security concerns or questions, please:
1. Review this documentation
2. Check Firebase logs for detailed error information
3. Test in Firebase emulator first
4. Contact your security team for production deployments

---

**Last Updated:** December 2024
**Version:** 1.0.0
**Status:** Production Ready