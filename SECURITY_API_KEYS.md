# API Key Security Guide

## 🔐 Critical Security Update

The RapidAPI key has been removed from the source code and must now be provided via environment variables.

## Setup Instructions

### For Development

1. **Create a `.env` file** (never commit this):
   ```bash
   cp .env.example .env
   ```

2. **Add your RapidAPI key**:
   ```
   RAPIDAPI_KEY=your_actual_api_key_here
   ```

3. **Run the app with the environment variable**:
   ```bash
   flutter run --dart-define=RAPIDAPI_KEY=your_actual_api_key_here
   ```

### For Production

#### Option 1: Firebase Functions (Recommended)
Move all API calls to Firebase Functions to keep keys server-side:

1. Set the key in Firebase:
   ```bash
   firebase functions:config:set rapidapi.key="your_api_key"
   ```

2. Update the Flutter app to call Firebase Functions instead of RapidAPI directly

#### Option 2: Build-time Configuration
For CI/CD pipelines:

```bash
flutter build ios --dart-define=RAPIDAPI_KEY=$RAPIDAPI_KEY
flutter build apk --dart-define=RAPIDAPI_KEY=$RAPIDAPI_KEY
```

## Security Best Practices

### ✅ DO:
- Store API keys in environment variables
- Use Firebase Functions for API calls in production
- Rotate API keys regularly
- Use different keys for dev/staging/production
- Monitor API key usage on RapidAPI dashboard

### ❌ DON'T:
- Commit API keys to version control
- Hardcode keys in source code
- Share keys in documentation or issues
- Use the same key across environments
- Log or display API keys in error messages

## Secret Scanning

### GitHub Secret Scanning
This repository should have secret scanning enabled to prevent accidental commits:

1. Go to Settings → Security & analysis
2. Enable "Secret scanning" 
3. Enable "Push protection"

### Pre-commit Hooks
Add a pre-commit hook to check for secrets:

```bash
# Install detect-secrets
pip install detect-secrets

# Create baseline
detect-secrets scan > .secrets.baseline

# Add to pre-commit hook
detect-secrets-hook --baseline .secrets.baseline
```

## If a Key is Exposed

1. **Immediately revoke** the exposed key on RapidAPI
2. **Generate a new key**
3. **Update** all environments with the new key
4. **Audit** logs for any unauthorized usage
5. **Review** git history and remove the key using BFG Repo-Cleaner

## Additional Security Measures

### Rate Limiting
The app implements client-side rate limiting:
- Minimum 100ms between API requests
- Circuit breaker after 5 failures
- Exponential backoff for retries

### Error Handling
API errors never expose the key:
- Keys are stripped from error messages
- Generic error messages shown to users
- Detailed errors only in debug logs (without keys)

## Monitoring

Set up monitoring for:
- Unusual API usage patterns
- Failed authentication attempts
- Rate limit violations
- Geographic anomalies

## Contact

For security concerns, contact the security team immediately.
Do NOT post security issues publicly.