# PHASE 4: Secure Flutter Web Error Monitoring Report

**Project:** Saidur Rahman Portfolio (Flutter Web & Firebase)  
**Date:** September 18, 2026  
**Status:** ✅ Successfully Implemented & Verified  
**Target Platform:** Flutter Web (`lib/services/error_monitoring/`, `functions/`)  
**Backend:** Firebase Cloud Functions v2 + Cloud Firestore  
**Author:** Antigravity AI Assistant  

---

## 1. Executive Summary

Phase 4 establishes a **production-grade, secure, and resilient Web Error Monitoring system** specifically engineered for Flutter Web. It solves the critical vulnerability and architectural gaps identified in the baseline audit:
- The previous `ErrorBoundary` only overrode `ErrorWidget.builder` and failed to capture asynchronous, platform, Firebase, or network errors.
- Raw stack traces were historically vulnerable to public exposure.
- Direct client writes to sensitive Firestore collections posed a severe security and database pollution risk.

The new architecture implements a **complete 6-layer pipeline**:
1. **Global Interception Layer:** Intercepts Flutter framework errors, unhandled asynchronous errors, platform dispatcher events, and widget tree crashes.
2. **Zero-PII Client Sanitizer:** Automatically scrubs passwords, auth tokens, secrets, emails, phone numbers, contact messages, and URL query strings.
3. **Deterministic Error Fingerprinting:** Computes normalized 16-character SHA-256 hashes to group identical root causes and prevent Firestore churn.
4. **Objective Severity Classifier:** Evaluates technical error types into standardized tiers (`critical`, `high`, `medium`, `low`).
5. **Client-Side Deduplication & Anti-Recursion Engine:** Throttles identical errors within a 60-second window and enforces reentrancy locks to prevent infinite error loops.
6. **Secure Cloud Function Endpoint (`reportWebError`):** Authenticates, validates schema, enforces rate limits (<20 req/min per client), applies secondary server sanitization, and performs atomic Firestore upserts on `error_reports/{fingerprint}`.
7. **Strict Admin-Only Security Rules:** Firestore security rules strictly block direct client document creation (`allow create: if false;`), reserving read, update, and delete actions exclusively for authenticated administrators.

---

## 2. Architecture & Data Flow

```
+-----------------------------------------------------------------------------------+
|                                  FLUTTER WEB                                      |
|                                                                                   |
|  [FlutterError.onError]     [PlatformDispatcher.onError]     [ErrorBoundary]      |
|  (Framework / Layout)       (Unhandled Async / Future)       (Widget Failures)    |
|            \                             |                            /           |
|             +----------------------------+---------------------------+            |
|                                          |                                        |
|                                          v                                        |
|                           [CrashlyticsService (Facade)]                           |
|                                          |                                        |
|                           [WebCrashlyticsDelegate]                                |
|                                          |                                        |
|                                          v                                        |
|                            [WebErrorReporter.instance]                            |
|                     (Reentrancy Lock + 60s Client Deduplication)                  |
|                                          |                                        |
|            +-----------------------------+-----------------------------+          |
|            |                             |                             |          |
|            v                             v                             v          |
|    [ErrorSanitizer]             [ErrorFingerprinter]       [SeverityClassifier]   |
|   (Zero-PII Scrubbing)         (16-char SHA-256 Hash)      (Technical Severity)   |
|            |                             |                             |          |
|            +-----------------------------+-----------------------------+          |
|                                          |                                        |
|                                          v                                        |
|                                  [ErrorReportModel]                               |
|                               (Structured Payload)                                |
+------------------------------------------+----------------------------------------+
                                           |
                              HTTPS Callable (App Check Ready)
                                           |
                                           v
+-----------------------------------------------------------------------------------+
|                             FIREBASE CLOUD FUNCTIONS                              |
|                                                                                   |
|                     functions/index.js -> reportWebError()                        |
|   1. Payload Size Check (<64KB)                                                   |
|   2. In-Memory Rate Limiting (20 req / 60s per client)                            |
|   3. Schema & Type Validation (Whitelisted fields)                                |
|   4. Secondary Server-Side Sanitization (Regex defense-in-depth)                  |
|   5. Atomic Upsert & Severity Escalation                                          |
+------------------------------------------+----------------------------------------+
                                           |
                             Admin SDK Internal Write
                                           |
                                           v
+-----------------------------------------------------------------------------------+
|                              CLOUD FIRESTORE                                      |
|                                                                                   |
|                       Collection: /error_reports/{fingerprint}                    |
|                                                                                   |
|   Rules:                                                                          |
|     - allow create: if false;                         (Public clients BLOCKED)    |
|     - allow read, update, delete: if isAdmin();       (Admins only)               |
+-----------------------------------------------------------------------------------+
                                           |
                                           v
                         [Admin Dashboard (Phase 5)]
```

---

## 3. Error Categories & Interception Mechanisms

| Category | Interceptor | Default Severity | Example Scenarios | Handling Mechanism |
| :--- | :--- | :--- | :--- | :--- |
| **Framework Render & Layout Errors** | `FlutterError.onError` ([main.dart](file:///e:/MyWeb/saidurs_portfolio/lib/main.dart)) | `high` / `critical` | RenderFlex overflow, layout cycle exceptions, widget build failure | Captured via `CrashlyticsService.recordFlutterError(details, fatal: true)`. Forwarded to `WebErrorReporter`. In debug mode, displays formatted console diagnostics. |
| **Unhandled Asynchronous Errors** | `PlatformDispatcher.instance.onError` ([main.dart](file:///e:/MyWeb/saidurs_portfolio/lib/main.dart)) | `critical` | Unhandled `Future.error`, unawaited microtasks, background stream errors | Intercepted at root dispatcher, forwarded via `recordError(error, stack, fatal: true)`. Returns `true` to signal Flutter that the error was caught and recorded. |
| **Platform & DOM Interop Errors** | `PlatformDispatcher.instance.onError` | `high` | JavaScript interop type mismatches, DOM API access failures | Classifies error as `platform_error` or `async_error`. Detects browser name and operating platform. |
| **Firebase Services Exceptions** | Service Layer catch blocks + Global Handlers | `high` / `medium` | `FirebaseException`, `permission-denied`, index requirements, quota exceeded | Sanitizer scrubs project IDs, tokens, and database path details. Severity elevated to `high` if permission/quota related. |
| **Network & API Failures** | Repository HTTP catch blocks | `medium` | `SocketException`, `ClientException`, HTTP 500/502/503 timeouts | Classified as `network_error`. Sanitizer strips API keys and query parameters from request URLs. |
| **Widget Tree Failures** | `ErrorBoundary` ([error_boundary.dart](file:///e:/MyWeb/saidurs_portfolio/lib/widgets/comon/error_boundary.dart)) | `high` | Child widget build crash, missing provider, null pointer in build method | Intercepts build failure, records to `WebErrorReporter`, and renders user-friendly error UI with incident reference code `#<fingerprint>`. |

---

## 4. Structured Error Model (`ErrorReportModel`)

Stored at `error_reports/{fingerprint}` in Cloud Firestore:

| Field | Type | Description |
| :--- | :--- | :--- |
| `fingerprint` | `String` | Stable 16-character SHA-256 hexadecimal identifier. Used as the Firestore document ID. |
| `type` | `String` | Categorical classification: `framework_error`, `async_error`, `network_error`, `firebase_error`, `widget_error`, `application_error`. |
| `severity` | `String` | `critical`, `high`, `medium`, `low`. |
| `status` | `String` | Lifecycle state: `open` (default), `investigating`, `resolved`, `ignored`. Maintained across recurring occurrences. |
| `message` | `String` | Sanitized, single-line error description with secrets and PII scrubbed. |
| `route` | `String` | Active route name or URI fragment at the time of error (e.g. `/`, `/admin`). |
| `operation` | `String` | Granular operation context (e.g. `widget_build`, `fetch_projects`, `unhandled_async`). |
| `feature` | `String` | High-level module (e.g. `error_boundary_widget`, `portfolio_navigation`). |
| `platform` | `String` | Operating system/platform identifier (`web`). |
| `browser` | `String` | User browser detected from user-agent (`Chrome`, `Firefox`, `Safari`, `Edge`, `Unknown`). |
| `appVersion` | `String` | App semantic version string (e.g. `1.0.0+1`). |
| `firstSeenAt` | `Timestamp` | Server timestamp when the error fingerprint was first logged. |
| `lastSeenAt` | `Timestamp` | Server timestamp of the most recent occurrence. |
| `occurrenceCount`| `int` | Cumulative count of deduplicated occurrences (`FieldValue.increment(1)`). |
| `stackTrace` | `String` | Sanitized top 5–10 stack frames. Strips memory addresses and user directories. |
| `assignedTo` | `String?` | Admin user ID assigned to triage the issue (reserved for Phase 5 CMS). |
| `notes` | `String?` | Internal engineering triage notes (reserved for Phase 5 CMS). |

---

## 5. Stable Fingerprint & Deduplication Strategy

### Deterministic Fingerprinting Algorithm (`ErrorFingerprinter`)
To avoid Firestore document explosion where a single recurring error generates thousands of redundant records, every error is normalized into a deterministic 16-character SHA-256 hash:

1. **Error Type Isolation:** Extracts the concrete runtime type (e.g. `FlutterError`, `FormatException`, `LateInitializationError`).
2. **Message Normalization:**
   - Strips dynamic line/column numbers (`line 45, col 12`).
   - Replaces hex memory addresses and pointer hashes (`0x7ffee12a3b`, `#1234a`) with `<ADDR>`.
   - Replaces UUIDs and numeric IDs with `<UUID>` and `<ID>`.
   - Replaces ISO-8601 timestamps with `<TIMESTAMP>`.
3. **Stack Frame Normalization:**
   - Extracts the top 3-5 normalized frames of the stack trace.
   - Cleans compiled web JavaScript minification artifacts (e.g. `dart:sdk_internal`, `main.dart.js:1234:56`).
   - Normalizes file names and function signatures.
4. **Hashing:** Concatenates `type | normalized_message | normalized_frames` and hashes with SHA-256 (`crypto: ^3.0.7`), truncating to 16 hexadecimal characters.

### Client-Side Deduplication Throttle
- `WebErrorReporter` maintains an in-memory cache of recent fingerprint timestamps.
- If an identical fingerprint is triggered within **60 seconds**, the client skips remote dispatch to conserve network and Cloud Function invocations.
- A boolean reentrancy guard (`_isReporting`) completely prevents recursive error monitoring loops if an error occurs while reporting.

---

## 6. Zero-PII Sanitization Rules

Both client (`ErrorSanitizer.dart`) and server (`functions/index.js`) apply strict, automated scrubbing:

1. **Tokens & Credentials:**
   - Matches and replaces `Bearer eyJ...` with `Bearer [REDACTED_TOKEN]`.
   - Scrubs API keys, client secrets, passwords, private keys (`api_key=[REDACTED_SECRET]`).
2. **Email Addresses:**
   - Regex: `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}` -> `[REDACTED_EMAIL]`.
3. **Phone Numbers:**
   - International and local phone patterns -> `[REDACTED_PHONE]`.
4. **URL Query Parameters:**
   - Strips all URL query strings (`https://example.com/api?token=secret&user=123` -> `https://example.com/api?[REDACTED_QUERY]`).
5. **Contact Messages & Form Bodies:**
   - Forbidden payload fields (`contact_message`, `message_body`, `password`, `token`) are stripped or dropped before serialization.
6. **Defense in Depth:** The Cloud Function applies a secondary regex pass on `message`, `stackTrace`, `route`, and `operation` before saving to Firestore.

---

## 7. Backend Cloud Function (`reportWebError`)

Located at `functions/index.js`:

- **Execution Model:** Firebase HTTPS Callable (`onCall`). Automatically handles CORS, auth context, and protocol headers for Flutter Web.
- **Payload Guard:** Rejects payloads exceeding **64 KB** to prevent DoS via bloated stack traces.
- **Rate Limiting:** Enforces a client sliding window limit of **20 submissions per 60 seconds** based on IP / client ID.
- **Schema Validation:** Strict verification of `fingerprint`, `type`, `severity`, and `message`. Rejects unauthorized arbitrary keys.
- **Atomic Firestore Upsert:**
  ```javascript
  const docRef = db.collection('error_reports').doc(sanitized.fingerprint);
  await db.runTransaction(async (transaction) => {
    const doc = await transaction.get(docRef);
    if (!doc.exists) {
      transaction.set(docRef, {
        ...sanitized,
        firstSeenAt: admin.firestore.FieldValue.serverTimestamp(),
        lastSeenAt: admin.firestore.FieldValue.serverTimestamp(),
        occurrenceCount: 1,
        status: 'open',
      });
    } else {
      const existingData = doc.data();
      const newSeverity = getHighestSeverity(existingData.severity, sanitized.severity);
      transaction.update(docRef, {
        lastSeenAt: admin.firestore.FieldValue.serverTimestamp(),
        occurrenceCount: admin.firestore.FieldValue.increment(1),
        severity: newSeverity,
        message: sanitized.message,
        stackTrace: sanitized.stackTrace,
      });
    }
  });
  ```
- **Severity Escalation:** If an existing issue was previously recorded as `low` or `medium` and suddenly triggers a `critical` event, the severity is automatically escalated in Firestore.
- **Status Preservation:** Does not blindly overwrite status; existing triage status (`investigating`, `resolved`) is preserved for admin visibility.

---

## 8. Firestore Security Rules

Direct public creation of error reports is **strictly forbidden**:

```javascript
// firestore.rules
match /error_reports/{document} {
  // Production Web Error Monitoring:
  // Public clients MUST submit reports via the secure 'reportWebError' Cloud Function.
  // Direct client writes are strictly blocked to prevent tampering and document spam.
  allow create: if false;
  
  // Only authenticated admins can read, update, or delete error reports
  allow read, update, delete: if isAdmin();
}
```

---

## 9. User-Facing Error Boundary (`ErrorBoundary`)

The user-facing error UI was completely modernized in `lib/widgets/comon/error_boundary.dart`:
- **Zero Public Technical Leakage:** Visitors never see raw exception names, file paths, or stack traces in release mode.
- **Glassmorphic Portfolio Design:** Matches the existing dark/light responsive aesthetic of the portfolio.
- **Actionable Controls:**
  - **"Try Again" button:** Clears the error state and rebuilds the subtree.
  - **"Go to Home" button:** Safely navigates the user back to the top route.
- **Incident Reference Badge:** Displays `#<fingerprint>` with a one-tap copy button (`Clipboard.setData`), allowing users or beta testers to report specific issue IDs to the administrator without exposing technical data.
- **Developer Inspection:** An expandable `Developer Diagnostics` tile is only visible in `kDebugMode`.

---

## 10. Automated Tests & Quality Assurance

### Unit Test Suite (`test/services/error_monitoring_test.dart`)
17 comprehensive unit tests were authored and executed:

1. `ErrorSanitizer` - scrubs authorization bearer tokens and JWTs.
2. `ErrorSanitizer` - scrubs plain text password query strings and parameters.
3. `ErrorSanitizer` - scrubs email addresses from messages and stack traces.
4. `ErrorSanitizer` - scrubs phone numbers.
5. `ErrorSanitizer` - strips full URL query parameters.
6. `ErrorFingerprinter` - produces identical 16-character hashes for identical errors.
7. `ErrorFingerprinter` - normalizes dynamic UUIDs, numbers, and memory addresses.
8. `ErrorFingerprinter` - differentiates fundamentally different error types.
9. `ErrorSeverityClassifier` - classifies unhandled async errors as critical.
10. `ErrorSeverityClassifier` - classifies Firebase exceptions accurately.
11. `ErrorSeverityClassifier` - classifies network socket and client errors as medium.
12. `ErrorSeverityClassifier` - classifies UI overflow and layout errors as medium.
13. `ErrorReportModel` - serialization to Callable Cloud Function payload format.
14. `ErrorReportModel` - generates accurate short reference code (`#<first8Chars>`).
15. `WebErrorReporter` - client deduplication throttle (suppresses duplicate within 60s).
16. `WebErrorReporter` - allows reporting when fingerprint differs.
17. `WebErrorReporter` - reentrancy lock prevents recursive error monitoring loops.

### Verification Results:
- **`flutter test`:** **65 / 65 tests passed** (100% pass rate).
- **`flutter analyze`:** **0 issues found** (clean codebase).
- **`flutter build web`:** Verified release compilation with tree-shaking and web assets.

---

## 11. Bugs Discovered & Resolved During Implementation

1. **Query Parameter Sanitization Ordering:**
   - *Bug:* Running password/email regex replacements before stripping URL query strings caused URLs like `https://api.com?token=xyz&email=abc` to leave fragmented URL paths.
   - *Fix:* Reordered sanitization in `ErrorSanitizer` to strip URL query strings first with `_urlQueryRegex`, ensuring clean URLs.
2. **Missing Phone Pattern Sanitization:**
   - *Bug:* Audit identified telephone numbers could leak in error strings from contact inputs.
   - *Fix:* Added `_phoneRegex` matching international E.164 and standard format numbers, replacing with `[REDACTED_PHONE]`.
3. **Theme Token Compatibility in `ErrorBoundary`:**
   - *Bug:* `error_boundary.dart` initially referenced `AppColors.neonBlue`, which does not exist in the palette.
   - *Fix:* Aligned styling with `AppTheme.primaryColor` and `AppTheme.cardDark`.

---

## 12. Remaining Operational Considerations

1. **Deploying Cloud Functions:**
   - The backend function is staged at `functions/index.js` and registered in `firebase.json`.
   - Deployment command:
     ```bash
     firebase deploy --only functions:reportWebError,firestore:rules
     ```
   - Requires active Firebase CLI credentials on the deployment machine.
2. **App Check Enforcement (Optional Enhancement):**
   - The callable function is designed to support App Check verification (`request.app.token`). Once reCAPTCHA v3 or Enterprise is registered in Firebase Console, enforcement can be toggled on.
3. **Phase 5 Admin Errors Dashboard:**
   - The data model (`ErrorReportModel`) and Firestore collection (`error_reports`) are structured specifically to power the upcoming Phase 5 Admin Errors Dashboard with filtering by severity, status triage, occurrence count sorting, and developer notes.
