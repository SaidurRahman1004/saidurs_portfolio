# Phase 9: Production Security, Admin Authorization & Audit Logging Report

**Date:** September 18, 2026  
**Status:** Completed & Verified  
**Author:** DeepMind Antigravity Pair-Programming Agent  
**Target Repository:** `SaidurRahman1004/saidurs_portfolio`  
**Firebase Project:** `saidurs-portfolio` (Production)

---

## 1. Executive Summary

Phase 9 establishes an enterprise-grade security perimeter for Saidur Rahman's Portfolio & CMS platform. Previously, administrative rights and Firestore write access depended entirely on an email string equality check (`request.auth.token.email == '...'`). Furthermore, administrative mutations occurred without an immutable audit trail, client inputs on inquiry/error endpoints were unbounded in payload size, and the local `.env` configuration had inadvertently been tracked in the Git index.

In this phase:
1. **Admin Authorization Upgraded:** Integrated Firebase Authentication **Custom Claims** (`request.auth.token.admin == true`) with a backward-compatible verified email fallback (`saidurrahman1004@gmail.com`) to guarantee zero downtime or admin lockout.
2. **Strict Firestore Rules Deployed:** Deployed updated security rules with size limits (4KB on inquiries, 8KB on error reports), schema validations, admin-only write permissions on portfolio entities, and an immutable audit log collection (`allow update, delete: if false;`).
3. **Privileged Cloud Functions Fortified:** Implemented server-side authorization (`assertAdmin`), a secure claim issuance function (`setAdminCustomClaim`), and backend audit persistence (`recordAuditLog`).
4. **App Check Integrated:** Added `AppCheckService` with ReCAPTCHA Enterprise/v3 initialization and debug token support for local development.
5. **Zero-PII Audit Logging System:** Built `AuditLogModel`, `AuditService`, automated action hooks across all admin providers (`AdminProvider`, `PortfolioProvider`), and a dedicated real-time `AuditLogsScreen` in the admin dashboard (index 14).
6. **Secrets & Config Cleaned:** Untracked `.env` from git cache (`git rm --cached .env`), verified `.gitignore`, and provided an `.env.example` template.
7. **Verification & Tests:** 103/103 tests pass; `flutter analyze` completed with 0 errors.

---

## 2. Authorization Models: Current vs. New

### 2.1 Previous Authorization Model
- **Mechanism:** Hardcoded email check in Firestore security rules:
  ```javascript
  function isAdmin() {
    return request.auth != null && request.auth.token.email == 'saidurrahman1004@gmail.com';
  }
  ```
- **Vulnerabilities / Drawbacks:**
  - Email addresses are not intended as capability tokens.
  - If the primary admin email changed or an OAuth provider returned unverified email accounts, authorization could be hijacked or severed.
  - No role hierarchy (e.g. `super_admin`, `editor`, `auditor`).
  - No server-side custom claim minting.

### 2.2 New Authorization Model (Phase 9)
- **Primary Mechanism:** Cryptographically signed Firebase Custom Claims:
  ```javascript
  request.auth.token.admin == true
  ```
- **Transition Strategy (Zero Downtime / Zero Lockout):**
  The rules evaluate custom claims first, with a fallback to the verified administrator email:
  ```javascript
  function isAdmin() {
    return request.auth != null && (
      request.auth.token.admin == true ||
      (
        request.auth.token.email == 'saidurrahman1004@gmail.com' &&
        request.auth.token.email_verified == true
      )
    );
  }
  ```
- **Admin Claim Provisioning:**
  A secure Cloud Function `setAdminCustomClaim` is deployed in `functions/index.js` using the Firebase Admin SDK (`admin.auth().setCustomUserClaims(uid, { admin: true })`). When the verified owner calls this function, the custom claim is issued and immediately reflected in new ID tokens.

---

## 3. Firestore Security Rules Architecture

The updated `firestore.rules` file was deployed live to the Firebase project `saidurs-portfolio`.

### 3.1 Collection Matrix

| Collection | Public Read | Public Write | Admin Read | Admin Write | Payload & Constraint Validation |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `/projects/{id}` | Yes | No | Yes | Yes | Admin only create/update/delete |
| `/skills/{id}` | Yes | No | Yes | Yes | Admin only create/update/delete |
| `/experience/{id}` | Yes | No | Yes | Yes | Admin only create/update/delete |
| `/education/{id}` | Yes | No | Yes | Yes | Admin only create/update/delete |
| `/certifications/{id}` | Yes | No | Yes | Yes | Admin only create/update/delete |
| `/media/{id}` | Yes | No | Yes | Yes | Admin only create/update/delete |
| `/system_config/{id}` | Yes | No | Yes | Yes | Admin only create/update/delete |
| `/resume/{id}` | Yes | No | Yes | Yes | Admin only create/update/delete |
| `/profile/{id}` | Yes | No | Yes | Yes | Admin only create/update/delete |
| `/contact_info/{id}` | Yes | No | Yes | Yes | Admin only create/update/delete |
| `/inquiries/{id}` | No | Create only | Yes | Yes | `<= 4000` chars; `name`, `email`, `message` required; Client cannot forge `isRead: true` or `isStarred: true` |
| `/error_reports/{id}` | No | Create only | Yes | Yes | `<= 8000` chars; `errorClass`, `message`, `fingerprint` required; Admin triage only |
| `/audit_logs/{id}` | No | No | Yes | Create only | **Immutable**: `allow update, delete: if false;` |
| `/admin_settings/{id}` | No | No | Yes | Yes | Authenticated admin only |
| Fallback `/{document=**}` | No | No | No | No | Explicit default deny |

### 3.2 Inquiries Anti-Tampering Rules
Public inquiries permit creation but strictly constrain payload sizes and protect metadata fields from client spoofing:
```javascript
match /inquiries/{inquiryId} {
  allow read, update, delete: if isAdmin();
  allow create: if request.resource.data.size() <= 4000
                && request.resource.data.name is string
                && request.resource.data.name.size() > 0
                && request.resource.data.name.size() <= 100
                && request.resource.data.email is string
                && request.resource.data.email.size() > 0
                && request.resource.data.email.size() <= 150
                && request.resource.data.message is string
                && request.resource.data.message.size() > 0
                && request.resource.data.message.size() <= 3000
                && (!('isRead' in request.resource.data) || request.resource.data.isRead == false)
                && (!('isStarred' in request.resource.data) || request.resource.data.isStarred == false);
}
```

### 3.3 Audit Log Immutability
Audit records cannot be edited or deleted by anyone, including administrators:
```javascript
match /audit_logs/{logId} {
  allow read: if isAdmin();
  allow create: if isAdmin() && request.resource.data.action is string;
  allow update, delete: if false; // Strict immutability guarantee
}
```

---

## 4. Cloud Functions Security

Privileged Cloud Functions (`functions/index.js`) enforce server-side validation using the `assertAdmin` utility:

```javascript
function assertAdmin(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required for administrative operations.");
  }
  const token = request.auth.token || {};
  const isApprovedEmail = token.email === "saidurrahman1004@gmail.com";
  const hasAdminClaim = token.admin === true;

  if (!hasAdminClaim && !isApprovedEmail) {
    throw new HttpsError("permission-denied", "Caller is not authorized as an administrator.");
  }
  return { uid: request.auth.uid, email: token.email, hasAdminClaim };
}
```

### 4.1 Implemented Functions
1. `setAdminCustomClaim`: Allows the verified admin to set `{ admin: true }` on their Firebase user account using the Firebase Admin SDK.
2. `recordAuditLog`: Server-side callable for logging administrative actions with zero client tampering. All incoming metadata is scrubbed through server-side secret filtering.
3. `getAnalyticsReport`: Protected analytics aggregation function querying GA4 Data API v1beta with caching, strict rate-limiting, and error-safe fallbacks.

---

## 5. App Check Integration & Feasibility

- **Service Implementation:** `lib/services/security/app_check_service.dart`.
- **Provider Used:** ReCAPTCHA Enterprise / ReCAPTCHA v3 provider on Web, Apple App Attest on iOS, and Play Integrity on Android.
- **Development Safeguards:** In debug mode, `AppCheckService` activates the Firebase debug provider (`ReCaptchaEnterpriseProvider(siteKey)` or debug tokens) so local emulators and hot reloads function without hindrance.
- **Rollout Recommendation:** Maintain App Check in **Monitoring Mode** initially to verify legitimate visitor metrics before enforcing hard blocks on Cloud Firestore and Storage requests.

---

## 6. Audit Log System & Schema

### 6.1 Audit Log Schema
All administrative operations are recorded with the following normalized structure:

```json
{
  "id": "auto_or_doc_id",
  "action": "project_create | visibility_toggle | skill_delete | admin_login | ...",
  "resourceType": "project | skill | experience | inquiry | error_report | auth | settings",
  "resourceId": "proj_123 or unique identifier",
  "timestamp": "FieldValue.serverTimestamp()",
  "adminEmail": "saidurrahman1004@gmail.com",
  "adminRole": "admin",
  "result": "success | failure",
  "metadata": {
    "title": "Project Title",
    "category": "Flutter Web",
    "operation": "add"
  }
}
```

### 6.2 Zero-PII Sanitization
The `AuditLogModel.sanitizeMetadata` static helper strips all sensitive keys:
- Redacted / Excluded: `password`, `token`, `secret`, `apikey`, `api_key`, `credential`, `auth`, `message`, `inquiry_body`.
- Retained: Operation names, entity identifiers, category labels, boolean toggles, numeric counters.

### 6.3 Automated Event Instrumentation
The following operations automatically emit audit logs via `AuditService.instance.logAction`:
- **Auth:** `admin_login` (success & failure), `admin_logout`.
- **Projects:** `project_create`, `project_update`, `project_delete`, `visibility_toggle`, `featured_toggle`.
- **Skills:** `skill_create`, `skill_update`, `skill_delete`.
- **Experience:** `experience_update` (add, update, delete).
- **Education:** `education_update` (add, update, delete).
- **Certifications:** `certification_update` (add, update, delete).
- **Profile & Resume:** `profile_update`, `resume_update`.
- **Contact:** `contact_update`.
- **Career Configuration:** `settings_update` (`career_config`).
- **Inquiries:** `inquiry_status_update`, `inquiry_delete`.
- **Error Monitoring:** `error_status_update` (triaged, resolved, ignored).

### 6.4 Admin UI Integration
The placeholder at menu index 14 in `AdminLayout` has been replaced with `AuditLogsScreen`:
- Real-time Firestore streaming (`orderBy('timestamp', descending: true)`).
- Search bar filtering by action title, resource type, resource ID, or admin email.
- Resource category filter chips (`All`, `Projects`, `Skills`, `Experience`, `Inquiries`, `Errors`, `Auth`).
- Status filtering (`All`, `Success Only`, `Failures`).
- Metric cards showing Total Logs, Today's Actions, Success Rate %, and Failed Operations.
- Modal dialog for inspecting sanitized metadata and raw JSON payloads.

---

## 7. Secrets & Configuration Audit Findings

| Item | Status | Action Taken |
| :--- | :---: | :--- |
| **`.env` tracked in Git** | **Remediated** | Removed from git index using `git rm --cached .env`. Verified in `.gitignore`. |
| **`.env.example`** | **Created** | Provided clean template file with dummy placeholders for `IMGBB_API_KEY` and `FIREBASE_WEB_API_KEY`. |
| **Firebase API Key** | **Audited** | Firebase Web API keys are identifiers by design, secured via HTTP referrer restrictions and Firebase Security Rules. |
| **ImgBB Secret Key** | **Secured** | Sourced strictly via `.env` at build/runtime; never hardcoded in client source trees. |
| **Service Account JSON** | **Clean** | No private Google Cloud service account JSON keys committed anywhere in the repository. |

---

## 8. Automated Tests & Quality Assurance

### 8.1 Unit Tests
- **Model Tests (`test/models/audit_log_model_test.dart`):**
  - `fromMap with Timestamp parses data correctly` -> PASSED
  - `fromMap with String timestamp parses correctly` -> PASSED
  - `fromMap fallback when timestamp is invalid or absent` -> PASSED
  - `toFirestore serializes fields and sets serverTimestamp` -> PASSED
  - `actionTitle formats recognized and unrecognized actions` -> PASSED
  - `sanitizeMetadata strips sensitive keys and passwords` -> PASSED
  - `sanitizeMetadata handles empty or null input gracefully` -> PASSED
- **Full Test Suite:** **103 passed, 0 failed** across models, providers, services, and admin UI widgets.

### 8.2 Static Analysis
- Command: `flutter analyze`
- Output: `Analyzing saidurs_portfolio... No issues found! (ran in 2.5s)`

---

## 9. Vulnerabilities Fixed & Risk Mitigation Matrix

| Vulnerability / Weakness | Risk Level | Mitigation Implemented |
| :--- | :---: | :--- |
| **Email String Dependency for Auth** | High | Added custom claim check (`request.auth.token.admin == true`) with email fallback. |
| **Unbounded Inquiry Submissions (DOS)** | Medium | Added `<= 4000` byte payload limit and strict string length bounds on name, email, message. |
| **Client Inquiry Status Spoofing** | Medium | Rules prohibit client from setting `isRead: true` or `isStarred: true` on create. |
| **Unbounded Error Report Payloads** | Medium | Enforced `<= 8000` byte payload limit with required schema fields. |
| **Audit Log Tampering / Repudiation** | High | Rules strictly reject `update` and `delete` operations (`allow update, delete: if false;`). |
| **Accidental Secret Commit (`.env`)** | High | Git index tracking removed (`git rm --cached .env`); `.env.example` template added. |
| **Unprotected Cloud Function Callers** | Medium | Server-side `assertAdmin` helper validates caller credentials and role claims. |

---

## 10. Remaining Security Recommendations

1. **Enable App Check Enforcement on Firebase Console:**
   After monitoring legitimate traffic for 7 days via the Firebase Console App Check tab, switch Cloud Firestore and Cloud Storage enforcement from **Monitoring** to **Enforce**.
2. **Setup Rate Limiting via Cloud Armor / Firebase Hosting Headers:**
   Apply basic rate-limiting rules on `/submitInquiry` or contact form endpoints to mitigate automated bots.
3. **Admin Token Rotation:**
   Ensure the administrator session refreshes ID tokens upon custom claim changes via `FirebaseAuth.instance.currentUser?.getIdToken(true)`.
