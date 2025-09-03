# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🚨 CRITICAL ISSUES IDENTIFIED - MUST FIX IMMEDIATELY

### Priority 1: Security Vulnerabilities (CRITICAL)

#### Firebase Security Issues
- **CORS Policy Vulnerability**: `functions/src/index.ts` allows ALL origins (`origin: true`) - MUST restrict to specific domains
- **Duplicate Route Definitions**: Lines 179-220 and 600-629 have duplicate `/events/search` endpoints causing unpredictable behavior
- **API Key Exposure**: Error messages may expose API keys in `functions/src/index.ts`
- **Missing Input Validation**: No sanitization for user inputs in chat endpoints

#### Flutter Code Issues 
- **370 Flutter Analyzer Issues**: Run `flutter analyze` shows critical errors in production code
- **Print Statements**: Remove all `print()` statements from production code (found in auth screens, chat screens)
- **Test Files Broken**: Major issues with test implementations - missing required arguments, undefined functions

### Priority 2: Dependency & Version Issues (HIGH)

#### Outdated Dependencies
- **19 dependencies** constrained to older versions - run `flutter pub upgrade --major-versions`
- **Firebase SDK**: Major version updates available (v4→v6 for core services)
- **Critical Updates**: Flutter Map (6.2.1→8.2.1), Local Notifications (17.2.4→19.4.1), Geolocator (13.0.4→14.0.2)

#### Deprecated API Usage
- **OpenAI API**: Using deprecated `gpt-4-turbo-preview` and `functions` API in Firebase functions
- **Material 3 Migration**: Some `withOpacity()` calls need migration to `withValues(alpha:)`

## 🏗️ Architecture & Code Quality Issues

### Firebase Backend Problems
- **Monolithic Functions**: 732-line single function needs splitting into focused microservices
- **Incomplete Implementations**: Multiple stub functions with empty implementations
- **Missing Production Hardening**: No request timeouts, memory limits, or health checks
- **No Caching Strategy**: Expensive API calls and database queries without caching

### Flutter Architecture Issues
- **Multiple Entry Points**: Unnecessary complexity with `main.dart`, `main_premium.dart`, `main_premium_chat.dart`, `main_cards_demo.dart`
- **Unused Code**: Extensive unused imports, variables, and methods throughout codebase
- **Null Safety Issues**: Multiple null-aware operators on non-nullable types
- **Performance Issues**: No optimization for large lists, missing lazy loading

## 📋 SYSTEMATIC FIX PLAN

### Phase 1: Emergency Security Fixes (Day 1)

```bash
# 1. Fix Firebase CORS immediately
cd functions/src && edit index.ts
# Change: app.use(cors({ origin: true }))
# To: app.use(cors({ origin: ['https://yourdomain.com', 'https://localhost:5000'] }))

# 2. Remove duplicate routes
# Delete lines 600-629 in functions/src/index.ts (duplicate /events/search)

# 3. Fix API key exposure
# Sanitize error messages - remove error?.response?.data from all error handlers

# 4. Remove print statements
find lib/ -name "*.dart" -exec grep -l "print(" {} \; | xargs -I {} sed -i '' '/print(/d' {}
```

### Phase 2: Dependency Updates (Day 2)

```bash
# Update all dependencies
flutter pub upgrade --major-versions
flutter pub get

# Regenerate code after updates
flutter packages pub run build_runner build --delete-conflicting-outputs

# Fix any breaking changes from updates
flutter analyze
# Address each analyzer issue systematically
```

### Phase 3: Code Quality Fixes (Day 3-4)

```bash
# Fix all analyzer issues
flutter analyze > analyzer_issues.txt
# Address each issue:
# - Remove unused imports
# - Fix null safety issues  
# - Update deprecated APIs
# - Remove unused variables/methods

# Fix test files
flutter test --reporter=expanded
# Update test files with correct Event model constructors
# Fix undefined functions and missing parameters
```

### Phase 4: Firebase Backend Restructure (Day 5-6)

```typescript
// Split monolithic function into microservices:
// functions/src/chat/index.ts - Chat functionality
// functions/src/events/index.ts - Event operations  
// functions/src/recommendations/index.ts - AI recommendations
// functions/src/analytics/index.ts - Analytics tracking

// Update OpenAI integration:
// Replace 'gpt-4-turbo-preview' with 'gpt-4o-mini'
// Use tools API instead of deprecated functions API

// Add production hardening:
// Set request timeouts, memory limits
// Implement proper error handling
// Add comprehensive input validation
```

### Phase 5: Performance & Architecture (Week 2)

```dart
// Consolidate entry points - keep only main.dart
// Remove unused theme variations  
// Implement proper lazy loading for lists
// Add image optimization and caching
// Implement proper state management patterns
```

## 🚀 Development Commands

### Essential Commands
```bash
# Setup and dependency management
./launch.sh setup                    # Install dependencies and generate code
flutter pub upgrade --major-versions  # Update all dependencies
flutter packages pub run build_runner build --delete-conflicting-outputs

# Development workflow
./launch.sh ios                      # Run on iOS simulator/device
./launch.sh android                  # Run on Android emulator/device  
./launch.sh web                      # Run on web browser

# Quality assurance (MUST RUN before any commits)
flutter analyze                      # Fix all 370 issues before proceeding
flutter test                         # Fix all broken tests
./launch.sh format                   # Format code consistently

# Firebase operations
./launch.sh firebase-emulator        # Test Firebase functions locally
./launch.sh firebase-deploy          # Deploy to production (only after all fixes)

# Build for production (only after ALL fixes completed)
./launch.sh build-ios                # Build iOS release
./launch.sh build-android            # Build Android APK  
./launch.sh build-web                # Build for web deployment
```

### Testing Commands
```bash
flutter test test/unit/              # Run unit tests only
flutter test test/widget/            # Run widget tests only
flutter test test/integration/       # Run integration tests
flutter test --coverage             # Generate coverage report

# Firebase testing
cd functions && npm test            # Test cloud functions
firebase emulators:start           # Start Firebase emulator suite
```

## 📁 Critical File Locations

### Files Requiring Immediate Attention
```
🚨 CRITICAL SECURITY FIXES:
functions/src/index.ts              # Lines 15-20 (CORS), 179-220, 600-629 (duplicates)
lib/screens/auth/glass_auth_screen.dart  # Remove print statements
lib/screens/chat/chat_screen.dart   # Remove print statements

🔧 DEPENDENCY UPDATES:
pubspec.yaml                        # Update all 19 outdated dependencies
functions/package.json              # Update Firebase functions dependencies

🧪 BROKEN TESTS:
test/widgets/event_card_test.dart   # Fix Event model constructor calls
test/utils/accessibility_helper_test.dart  # Fix undefined identifiers
test/services/                      # Multiple service test failures

🏗️ ARCHITECTURE CLEANUP:
lib/main_premium.dart               # Consider consolidation
lib/main_premium_chat.dart          # Consider consolidation  
lib/main_cards_demo.dart           # Consider consolidation
```

### Service Architecture
```
lib/services/
├── error_handling_service.dart    # ✅ Well implemented
├── rapidapi_service.dart          # ⚠️ Needs circuit breaker fixes
├── cache_service.dart             # ⚠️ Needs performance optimization
├── auth_service.dart              # ⚠️ Needs security review
├── firestore_service.dart         # ⚠️ Needs query optimization
└── performance_service.dart       # ⚠️ Needs monitoring integration
```

### Firebase Structure
```
functions/
├── src/
│   ├── index.ts                   # 🚨 CRITICAL: Fix CORS, duplicates, errors
│   ├── config/                    # ⚠️ Needs environment validation
│   └── utils/                     # ⚠️ Needs helper function completion
├── package.json                   # 🔄 UPDATE: Node.js dependencies
└── .env                          # 🔒 SECURE: Validate all API keys
```

## 🔍 Quality Assurance Checklist

### Before Any Code Changes
- [ ] Run `flutter analyze` - must show 0 issues before proceeding
- [ ] Run `flutter test` - all tests must pass
- [ ] Check Firebase emulator works locally
- [ ] Verify all API keys are properly secured
- [ ] Review Firestore security rules for vulnerabilities

### Before Production Deployment
- [ ] All 370 analyzer issues resolved
- [ ] All dependencies updated to latest compatible versions
- [ ] Firebase CORS policy restricted to production domains
- [ ] All print statements removed from production code
- [ ] All test files working with correct Event model constructors
- [ ] Security review completed for all Firebase functions
- [ ] Performance testing completed with optimization applied
- [ ] All stub functions properly implemented

## 🛡️ Security Standards

### Firebase Security
- **CORS Policy**: Restrict to specific production domains only
- **Input Validation**: Sanitize all user inputs in Firebase functions
- **Error Handling**: Never expose internal details or API keys in error messages
- **Rate Limiting**: Implement rate limiting for all API endpoints
- **Authentication**: Verify Firebase Auth tokens in all protected endpoints

### Flutter Security  
- **API Key Management**: Use Firebase Remote Config for API keys, never hardcode
- **Data Validation**: Validate all user inputs before processing
- **Secure Storage**: Use Flutter Secure Storage for sensitive data
- **Network Security**: Implement certificate pinning for production
- **Code Obfuscation**: Enable code obfuscation for release builds

## 📊 Performance Standards

### Flutter Performance
- **App Launch Time**: Target <3 seconds cold start
- **List Performance**: Implement virtual scrolling for >100 items
- **Image Loading**: Use CachedNetworkImage with proper placeholder strategy
- **Memory Management**: Proper disposal of controllers and streams
- **State Management**: Efficient Provider usage with proper selectors

### Firebase Performance
- **Function Execution**: Target <2 seconds per function call
- **Database Queries**: Use composite indexes for complex queries
- **Cache Strategy**: Implement Redis/Memorystore for frequently accessed data
- **API Response Time**: Target <500ms for all API endpoints
- **Resource Utilization**: Monitor memory and CPU usage in production

## ⚠️ Common Pitfalls to Avoid

### Development
- Never commit code with `flutter analyze` showing issues
- Never merge code with failing tests
- Never hardcode API keys or sensitive configuration
- Never use `print()` statements in production code
- Always run security checks before Firebase function deployment

### Firebase
- Never use `origin: true` in CORS policy for production
- Never expose internal error details to clients
- Always validate input parameters in cloud functions
- Never implement duplicate routes with different behavior
- Always implement proper authentication checks

### Testing
- Always update test files when model constructors change
- Never skip testing Firebase security rules
- Always test offline functionality thoroughly
- Never deploy without running full test suite
- Always validate performance under load

## 🏆 Success Criteria

### Code Quality
- [ ] Zero Flutter analyzer issues
- [ ] 100% test pass rate
- [ ] No deprecated API usage
- [ ] All security vulnerabilities resolved

### Performance  
- [ ] App startup <3 seconds
- [ ] All Firebase functions <2 seconds execution
- [ ] No memory leaks detected
- [ ] All images cached properly

### Security
- [ ] Production-ready CORS policy
- [ ] All API keys secured
- [ ] Input validation implemented
- [ ] Security rules tested

### Maintainability
- [ ] No duplicate code or routes
- [ ] Clear architecture patterns
- [ ] Comprehensive documentation
- [ ] Production monitoring setup

This CLAUDE.md serves as the complete blueprint for fixing all identified issues in the SomethingToDo Flutter application. Follow this systematically to achieve a production-ready, secure, and performant application.