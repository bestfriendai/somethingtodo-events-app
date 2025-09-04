# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Repository: SomethingToDo (Flutter + Firebase + Cloud Functions)

Development workflow and common commands
- One-time setup
  - flutter pub get
  - flutter packages pub run build_runner build --delete-conflicting-outputs
  - Optional helpers:
    - ./setup_env.sh    # creates .env from .env.example
    - ./check_api_keys.sh
    - ./launch.sh setup

- Run app
  - iOS simulator/device: ./launch.sh ios-simulator (or ios)
  - Android: ./launch.sh android
  - Web (uses .env if present): ./launch.sh web
  - Generic: flutter run

- Code generation (Freezed / json_serializable)
  - flutter packages pub run build_runner build --delete-conflicting-outputs
  - Watch mode: flutter packages pub run build_runner watch --delete-conflicting-outputs

- Lint and format
  - flutter analyze
  - dart format lib/

- Tests
  - All tests: flutter test
  - Single file: flutter test test/unit/utils/date_utils_test.dart -r expanded
  - Filter by name: flutter test --plain-name "substring of test name"
  - Coverage: flutter test --coverage

- Firebase (rules, indexes, emulators)
  - Deploy Firestore rules/indexes: firebase deploy --only firestore
  - Emulator suite: firebase emulators:start

- Cloud Functions (Node 20, TypeScript)
  - cd functions && npm install
  - Build: npm run build
  - Lint: npm run lint  |  Auto-fix: npm run lint:fix
  - Tests: npm test
  - Local serve (functions emulator): npm run serve
  - Deploy only functions: npm run deploy
  - Note: firebase.json predeploy runs npm --prefix "$RESOURCE_DIR" run build

- Production builds
  - Android: flutter build appbundle --release  (or build apk --release)
  - iOS: flutter build ipa --release
  - Web + hosting: flutter build web && firebase deploy --only hosting

Environment and configuration
- Flutter app configuration is centralized in lib/config/app_config.dart
  - Uses --dart-define values (e.g., FUNCTIONS_REGION, USE_FUNCTIONS_EMULATOR, OPENAI_API_KEY, etc.)
  - For web, ./launch.sh web loads defines from .env automatically (see setup_env.sh)
- Functions base URL resolution is in lib/config/functions_config.dart
  - Emulator: http://localhost:5001/<projectId>/<region>/api (iOS uses localhost, Android uses 10.0.2.2)
  - Production: https://<region>-<projectId>.cloudfunctions.net/api
- Firebase CLI project alias is in .firebaserc; firebase.json configures hosting, functions, firestore, storage, emulators, and remoteconfig
- Server-side secrets/config for functions
  - Use Firebase Functions config (e.g., firebase functions:config:set openai.api_key={{OPENAI_API_KEY}} rapidapi.key={{RAPIDAPI_KEY}} app.allowed_origins={{ORIGINS_COMMA_SEPARATED}})
  - Never commit secrets; do not rely on client-side keys

High-level architecture
- Flutter application (lib/)
  - Entry: lib/main.dart
    - Initializes Firebase (firebase_options.dart), Hive, services
    - MultiProvider with ChangeNotifier-based providers (AuthProvider, EventsProvider, ChatProvider, ThemeProvider)
    - Named routes and onGenerateRoute for dynamic screens (e.g., /event/<id>, /chat/<sessionId>)
  - State and services
    - Providers (lib/providers/):
      - AuthProvider: wraps Firebase Auth and local user fallback flows
      - EventsProvider: orchestrates event loading, location, caching, and background refresh
      - ChatProvider (paired with ChatService): chat session and message orchestration
    - Services (lib/services/):
      - FirestoreService: CRUD/queries for events, favorites, analytics; streams and batch ops
      - RapidAPIEventsService: talks to backend proxy (Cloud Functions /api) for search/nearby/trending/details; includes rate limiting, retries, caching, health ping, and circuit breaker
      - ChatService: handles chat sessions/messages and OpenAI interaction; persists to Firestore; supports demo/mock responses
      - Additional services: cache, location (enhanced + geofencing hooks), analytics/performance/logging, notifications
    - Models (lib/models/): Freezed + json_serializable generated (e.g., event.freezed.dart, event.g.dart)
  - UI layers
    - screens/ (feature pages), widgets/ (reusable components), config/ (themes, colors, responsive settings), utils/

- Firebase Cloud Functions (functions/)
  - TypeScript compiled to lib/ (main: lib/index.js, configured in functions/package.json)
  - Express app exported as functions.https.onRequest("api") with routes:
    - POST /chat (auth required) — validates, builds history from Firestore, queries OpenAI, persists messages
    - POST /events/sync — orchestrates create/update/delete hooks
    - GET /events/search | /events/trending | /events/nearby | /events/details — proxies to RapidAPI (with input validation); returns mock data when keys missing or on error
    - GET /health — health check
  - Middlewares: CORS (allowed origins from config), JSON body size limits, simple in-memory rate limiting, basic sanitization
  - Triggers: Firestore onCreate/onUpdate/onDelete for events; Auth on user create; Scheduled dailyRecommendations

Important docs and scripts
- README.md — setup, deploy, build, and testing basics (mirrors commands above)
- CLAUDE.md — repository-specific rules and priorities. Highlights relevant to operations:
  - Restrict CORS to explicit origins (no origin: true in production)
  - Ensure inputs are sanitized; do not expose keys in error messages
  - Align OpenAI usage with current APIs (functions backend uses gpt-4o-mini + tools API)
  - Keep flutter analyze clean and fix failing tests
- API_KEYS_SETUP_GUIDE.md — where keys come from and how to add them locally (.env + ./setup_env.sh)
- launch.sh and run.sh — convenience wrappers for run/build/analyze/test/deploy

Notes for future modifications
- Cloud Functions CORS: set allowed origins via functions config; do not broaden beyond intended domains
- Client API keys: rely on dart-define or Remote Config; avoid hardcoded defaults; prefer server-side calls via /api
- RapidAPI Events integration: app calls the proxy at /api; verify functions emulator/production base URL via FunctionsConfig

Examples
- Run a single test file with verbose output:
  - flutter test test/unit/utils/date_utils_test.dart -r expanded
- Run only tests whose name contains a substring:
  - flutter test --plain-name "should parse"
- Use functions emulator with the app (web):
  - USE_FUNCTIONS_EMULATOR=true FUNCTIONS_REGION=us-central1 ./launch.sh web

