const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { BetaAnalyticsDataClient } = require("@google-analytics/data");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Maximum allowed payload size: 64 KB
const MAX_PAYLOAD_BYTES = 64 * 1024;

// Rate limiting configuration (In-memory per Cloud Function instance)
const rateLimitMap = new Map();
const RATE_LIMIT_WINDOW_MS = 60 * 1000; // 1 minute
const MAX_REPORTS_PER_WINDOW = 20;

// Analytics Cache (In-memory per Cloud Function instance with TTL)
const analyticsCache = new Map();

// GA4 Property ID from environment configuration (if configured)
const GA4_PROPERTY_ID = process.env.GA4_PROPERTY_ID || process.env.GOOGLE_ANALYTICS_PROPERTY_ID || null;

// Email regex for server-side PII redaction
const EMAIL_REGEX = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;

// Severity hierarchy for escalation
const SEVERITY_LEVELS = {
  low: 1,
  medium: 2,
  high: 3,
  critical: 4,
};

/**
 * Strips PII and bounds string length safely.
 */
function sanitizeServerString(input, maxLength = 1000) {
  if (typeof input !== "string") return "";
  const cleaned = input.replace(EMAIL_REGEX, "[REDACTED_EMAIL]").trim();
  return cleaned.length > maxLength ? cleaned.substring(0, maxLength) : cleaned;
}

/**
 * Checks client rate limits.
 */
function checkRateLimit(clientId) {
  const now = Date.now();
  const clientData = rateLimitMap.get(clientId) || { count: 0, resetAt: now + RATE_LIMIT_WINDOW_MS };

  if (now > clientData.resetAt) {
    clientData.count = 1;
    clientData.resetAt = now + RATE_LIMIT_WINDOW_MS;
  } else {
    clientData.count += 1;
  }

  rateLimitMap.set(clientId, clientData);

  // Periodic cleanup of stale entries if map gets large
  if (rateLimitMap.size > 5000) {
    for (const [key, value] of rateLimitMap.entries()) {
      if (now > value.resetAt) rateLimitMap.delete(key);
    }
  }

  return clientData.count <= MAX_REPORTS_PER_WINDOW;
}

/**
 * Secure Callable Cloud Function: reportWebError
 *
 * Receives sanitized error reports from the Flutter Web client, enforces
 * rate limiting and payload validation, and performs an atomic upsert into Firestore
 * error_reports with automatic duplicate count tracking.
 */
exports.reportWebError = onCall(
  {
    cors: true,
    maxInstances: 10,
  },
  async (request) => {
    // 1. Payload size check
    const rawData = request.data || {};
    const payloadSize = Buffer.byteLength(JSON.stringify(rawData), "utf8");
    if (payloadSize > MAX_PAYLOAD_BYTES) {
      throw new HttpsError("invalid-argument", "Error report payload exceeds maximum 64KB size limit.");
    }

    // 2. Rate limiting check
    const clientIp = request.rawRequest ? request.rawRequest.ip || "unknown_ip" : "unknown_client";
    const clientId = request.auth ? `auth_${request.auth.uid}` : `ip_${clientIp}`;

    if (!checkRateLimit(clientId)) {
      throw new HttpsError("resource-exhausted", "Too many error reports submitted. Please wait a moment.");
    }

    // 3. Schema validation & sanitization
    const rawFingerprint = rawData.fingerprint;
    if (
      !rawFingerprint ||
      typeof rawFingerprint !== "string" ||
      rawFingerprint.length < 8 ||
      rawFingerprint.length > 64 ||
      !/^[a-zA-Z0-9_-]+$/.test(rawFingerprint)
    ) {
      throw new HttpsError("invalid-argument", "A valid error fingerprint is required.");
    }

    const fingerprint = rawFingerprint.toLowerCase();
    const type = sanitizeServerString(rawData.type || "unknown_error", 64);
    const rawSeverity = (rawData.severity || "medium").toLowerCase();
    const severity = SEVERITY_LEVELS[rawSeverity] ? rawSeverity : "medium";
    const message = sanitizeServerString(rawData.message || "Unspecified error", 1000);
    const route = sanitizeServerString(rawData.route || "/", 200);
    const operation = sanitizeServerString(rawData.operation || "unknown", 100);
    const browser = sanitizeServerString(rawData.browser || "unknown", 200);
    const appVersion = sanitizeServerString(rawData.appVersion || "1.0.0+1", 50);
    const stackTrace = sanitizeServerString(rawData.stackTrace || "", 4000);

    // 4. Server-side Firestore upsert
    try {
      const errorRef = db.collection("error_reports").doc(fingerprint);
      const snapshot = await errorRef.get();

      if (snapshot.exists) {
        const existingData = snapshot.data();
        const existingSeverityLevel = SEVERITY_LEVELS[existingData.severity] || 1;
        const newSeverityLevel = SEVERITY_LEVELS[severity] || 1;
        const higherSeverity = newSeverityLevel > existingSeverityLevel ? severity : existingData.severity;

        await errorRef.update({
          occurrenceCount: admin.firestore.FieldValue.increment(1),
          lastSeenAt: admin.firestore.FieldValue.serverTimestamp(),
          severity: higherSeverity,
          route: route || existingData.route,
          operation: operation || existingData.operation,
          appVersion: appVersion || existingData.appVersion,
        });

        return {
          success: true,
          fingerprint: fingerprint,
          status: "updated",
        };
      } else {
        await errorRef.set({
          fingerprint: fingerprint,
          type: type,
          severity: severity,
          status: "open",
          message: message,
          route: route,
          operation: operation,
          platform: "web",
          browser: browser,
          appVersion: appVersion,
          stackTrace: stackTrace,
          firstSeenAt: admin.firestore.FieldValue.serverTimestamp(),
          lastSeenAt: admin.firestore.FieldValue.serverTimestamp(),
          occurrenceCount: 1,
          assignedTo: null,
          notes: [],
        });

        return {
          success: true,
          fingerprint: fingerprint,
          status: "created",
        };
      }
    } catch (dbError) {
      console.error("[reportWebError] Firestore write failed:", dbError);
      throw new HttpsError("internal", "Failed to persist error report.");
    }
  }
);

/**
 * Cloud Function: getAnalyticsReport
 *
 * Secure server-side endpoint for retrieving aggregated Google Analytics (GA4)
 * metrics and dimension breakdowns for the authenticated Admin Dashboard.
 *
 * Security:
 * - Strictly requires authentication (request.auth).
 * - Enforces admin authorization server-side (custom claims or approved admin email).
 * - GA4 service account credentials and Property IDs are NEVER exposed to the client.
 * - Enforces request parameter validation and intelligent server-side caching.
 * - Does NOT create fake data in production when GA4 is unconfigured; returns clean,
 *   structured status with setup guidance.
 */
exports.getAnalyticsReport = onCall(
  {
    cors: true,
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (request) => {
    // 1. Verify admin authorization server-side
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required to access analytics reports.");
    }

    const token = request.auth.token || {};
    const isAdmin = token.admin === true || token.email === "saidurrahman1004@gmail.com";
    if (!isAdmin) {
      throw new HttpsError("permission-denied", "Administrator authorization required to access analytics reports.");
    }

    // 2. Validate input parameters
    const rawData = request.data || {};
    const dateRange = ["today", "7d", "30d", "custom"].includes(rawData.dateRange) ? rawData.dateRange : "7d";
    const forceRefresh = Boolean(rawData.forceRefresh);
    let startDate = typeof rawData.startDate === "string" ? rawData.startDate.trim() : null;
    let endDate = typeof rawData.endDate === "string" ? rawData.endDate.trim() : null;

    if (dateRange === "custom") {
      const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
      if (!startDate || !endDate || !dateRegex.test(startDate) || !dateRegex.test(endDate)) {
        throw new HttpsError("invalid-argument", "Custom date range requires valid startDate and endDate in YYYY-MM-DD format.");
      }
      if (startDate > endDate) {
        throw new HttpsError("invalid-argument", "startDate must be earlier than or equal to endDate.");
      }
    }

    // 3. Cache check (In-memory per instance with TTL)
    const cacheKey = `${GA4_PROPERTY_ID || "unconfigured"}_${dateRange}_${startDate || ""}_${endDate || ""}`;
    const now = Date.now();
    const cachedEntry = analyticsCache.get(cacheKey);

    let ttlMs = 15 * 60 * 1000; // 15 mins default
    if (dateRange === "today") ttlMs = 2 * 60 * 1000; // 2 mins for today
    else if (dateRange === "30d") ttlMs = 30 * 60 * 1000; // 30 mins for 30d

    if (!forceRefresh && cachedEntry && now < cachedEntry.expiresAt) {
      return { ...cachedEntry.data, cached: true };
    }

    // Helper for unconfigured response structure
    const makeEmptyInteractions = () => ({
      projects: {
        detailsOpened: 0,
        githubClicks: 0,
        liveDemoClicks: 0,
        googlePlayClicks: 0,
        appStoreClicks: 0,
        galleryInteractions: 0,
      },
      resume: {
        viewed: 0,
        downloaded: 0,
      },
      contact: {
        ctaClicks: 0,
        formStarts: 0,
        formSubmits: 0,
        formSuccess: 0,
        formErrors: 0,
      },
    });

    // 4. Handle unconfigured GA4 Property ID gracefully
    if (!GA4_PROPERTY_ID) {
      const unconfiguredResponse = {
        configured: false,
        propertyId: null,
        message: "Google Analytics 4 (GA4) Property ID is not configured. Set the GA4_PROPERTY_ID environment variable in Cloud Functions to connect live reporting.",
        cached: false,
        timestamp: new Date().toISOString(),
        dateRange: dateRange,
        configurationGuide: {
          requiredEnvVars: ["GA4_PROPERTY_ID"],
          serviceAccount: "Firebase / Google Cloud Default Service Account",
          permissions: "Viewer role on your Google Analytics 4 property (Admin > Property Access Management)",
          enableApi: "analyticsdata.googleapis.com (Google Analytics Data API v1beta)",
        },
        overview: {
          activeUsers: 0,
          newUsers: 0,
          sessions: 0,
          screenPageViews: 0,
          engagementRate: 0,
          averageSessionDuration: 0,
          eventCount: 0,
        },
        timeseries: [],
        pages: [],
        events: [],
        devices: [],
        browsers: [],
        countries: [],
        trafficSources: [],
        contentInteractions: makeEmptyInteractions(),
      };

      analyticsCache.set(cacheKey, { data: unconfiguredResponse, expiresAt: now + ttlMs });
      return unconfiguredResponse;
    }

    // 5. Query GA4 Data API v1beta
    try {
      const analyticsClient = new BetaAnalyticsDataClient();
      const property = `properties/${GA4_PROPERTY_ID}`;

      let dateRangeSpec = { startDate: "7daysAgo", endDate: "today" };
      if (dateRange === "today") {
        dateRangeSpec = { startDate: "today", endDate: "today" };
      } else if (dateRange === "30d") {
        dateRangeSpec = { startDate: "30daysAgo", endDate: "today" };
      } else if (dateRange === "custom") {
        dateRangeSpec = { startDate: startDate, endDate: endDate };
      }

      // Execute queries in parallel
      const [
        overviewResult,
        timeseriesResult,
        pagesResult,
        eventsResult,
        devicesResult,
        browsersResult,
        countriesResult,
        sourcesResult,
      ] = await Promise.all([
        // 1. Overview metrics
        analyticsClient.runReport({
          property,
          dateRanges: [dateRangeSpec],
          metrics: [
            { name: "activeUsers" },
            { name: "newUsers" },
            { name: "sessions" },
            { name: "screenPageViews" },
            { name: "engagementRate" },
            { name: "averageSessionDuration" },
            { name: "eventCount" },
          ],
        }),
        // 2. Daily Timeseries
        analyticsClient.runReport({
          property,
          dateRanges: [dateRangeSpec],
          dimensions: [{ name: "date" }],
          metrics: [
            { name: "activeUsers" },
            { name: "screenPageViews" },
            { name: "sessions" },
          ],
          orderBys: [{ dimension: { dimensionName: "date" }, desc: false }],
        }),
        // 3. Top Pages
        analyticsClient.runReport({
          property,
          dateRanges: [dateRangeSpec],
          dimensions: [{ name: "pagePath" }],
          metrics: [{ name: "screenPageViews" }],
          limit: 10,
          orderBys: [{ metric: { metricName: "screenPageViews" }, desc: true }],
        }),
        // 4. Top Events
        analyticsClient.runReport({
          property,
          dateRanges: [dateRangeSpec],
          dimensions: [{ name: "eventName" }],
          metrics: [{ name: "eventCount" }],
          limit: 25,
          orderBys: [{ metric: { metricName: "eventCount" }, desc: true }],
        }),
        // 5. Devices
        analyticsClient.runReport({
          property,
          dateRanges: [dateRangeSpec],
          dimensions: [{ name: "deviceCategory" }],
          metrics: [{ name: "activeUsers" }],
          orderBys: [{ metric: { metricName: "activeUsers" }, desc: true }],
        }),
        // 6. Browsers
        analyticsClient.runReport({
          property,
          dateRanges: [dateRangeSpec],
          dimensions: [{ name: "browser" }],
          metrics: [{ name: "activeUsers" }],
          limit: 6,
          orderBys: [{ metric: { metricName: "activeUsers" }, desc: true }],
        }),
        // 7. Countries
        analyticsClient.runReport({
          property,
          dateRanges: [dateRangeSpec],
          dimensions: [{ name: "country" }],
          metrics: [{ name: "activeUsers" }],
          limit: 10,
          orderBys: [{ metric: { metricName: "activeUsers" }, desc: true }],
        }),
        // 8. Traffic Sources
        analyticsClient.runReport({
          property,
          dateRanges: [dateRangeSpec],
          dimensions: [{ name: "sessionSource" }, { name: "sessionMedium" }],
          metrics: [{ name: "sessions" }],
          limit: 10,
          orderBys: [{ metric: { metricName: "sessions" }, desc: true }],
        }),
      ]);

      // Parse Overview
      const overviewRow = overviewResult[0]?.rows?.[0]?.metricValues || [];
      const activeUsers = parseInt(overviewRow[0]?.value || "0", 10);
      const newUsers = parseInt(overviewRow[1]?.value || "0", 10);
      const sessions = parseInt(overviewRow[2]?.value || "0", 10);
      const screenPageViews = parseInt(overviewRow[3]?.value || "0", 10);
      const engagementRate = parseFloat(overviewRow[4]?.value || "0");
      const averageSessionDuration = parseFloat(overviewRow[5]?.value || "0");
      const eventCount = parseInt(overviewRow[6]?.value || "0", 10);

      const overview = {
        activeUsers,
        newUsers,
        sessions,
        screenPageViews,
        engagementRate,
        averageSessionDuration,
        eventCount,
      };

      // Parse Daily Timeseries
      const timeseries = (timeseriesResult[0]?.rows || []).map((r) => ({
        date: r.dimensionValues?.[0]?.value || "",
        activeUsers: parseInt(r.metricValues?.[0]?.value || "0", 10),
        screenPageViews: parseInt(r.metricValues?.[1]?.value || "0", 10),
        sessions: parseInt(r.metricValues?.[2]?.value || "0", 10),
      }));

      // Helper for formatting breakdown items
      const formatBreakdown = (rows, totalRef, labelExtractor) => {
        return (rows || []).map((r) => {
          const label = labelExtractor(r);
          const count = parseInt(r.metricValues?.[0]?.value || "0", 10);
          const percentage = totalRef > 0 ? (count / totalRef) * 100 : 0;
          return { label, count, percentage: Math.round(percentage * 10) / 10 };
        });
      };

      const pages = formatBreakdown(pagesResult[0]?.rows, screenPageViews, (r) => r.dimensionValues?.[0]?.value || "/");
      const events = formatBreakdown(eventsResult[0]?.rows, eventCount, (r) => r.dimensionValues?.[0]?.value || "unknown");
      const devices = formatBreakdown(devicesResult[0]?.rows, activeUsers, (r) => r.dimensionValues?.[0]?.value || "desktop");
      const browsers = formatBreakdown(browsersResult[0]?.rows, activeUsers, (r) => r.dimensionValues?.[0]?.value || "unknown");
      const countries = formatBreakdown(countriesResult[0]?.rows, activeUsers, (r) => r.dimensionValues?.[0]?.value || "unknown");
      const trafficSources = formatBreakdown(sourcesResult[0]?.rows, sessions, (r) => {
        const src = r.dimensionValues?.[0]?.value || "(direct)";
        const med = r.dimensionValues?.[1]?.value || "(none)";
        return `${src} / ${med}`;
      });

      // Parse Content Interactions (Phase 2 Custom Events)
      const eventMap = new Map();
      (eventsResult[0]?.rows || []).forEach((r) => {
        const name = r.dimensionValues?.[0]?.value || "";
        const count = parseInt(r.metricValues?.[0]?.value || "0", 10);
        eventMap.set(name, count);
      });

      const contentInteractions = {
        projects: {
          detailsOpened: eventMap.get("project_details_open") || 0,
          githubClicks: eventMap.get("project_link_github") || 0,
          liveDemoClicks: eventMap.get("project_link_live_demo") || 0,
          googlePlayClicks: eventMap.get("project_link_google_play") || 0,
          appStoreClicks: eventMap.get("project_link_app_store") || 0,
          galleryInteractions: eventMap.get("project_gallery_open") || 0,
        },
        resume: {
          viewed: eventMap.get("resume_view") || 0,
          downloaded: eventMap.get("resume_download") || 0,
        },
        contact: {
          ctaClicks: eventMap.get("contact_cta_click") || 0,
          formStarts: eventMap.get("contact_form_start") || 0,
          formSubmits: eventMap.get("contact_form_submit") || 0,
          formSuccess: eventMap.get("contact_form_success") || 0,
          formErrors: eventMap.get("contact_form_error") || 0,
        },
      };

      const responsePayload = {
        configured: true,
        propertyId: GA4_PROPERTY_ID,
        message: "Successfully retrieved live GA4 analytics metrics.",
        cached: false,
        timestamp: new Date().toISOString(),
        dateRange: dateRange,
        overview,
        timeseries,
        pages,
        events,
        devices,
        browsers,
        countries,
        trafficSources,
        contentInteractions,
      };

      analyticsCache.set(cacheKey, { data: responsePayload, expiresAt: now + ttlMs });
      return responsePayload;
    } catch (apiError) {
      console.error("[getAnalyticsReport] GA4 Data API error:", apiError);
      return {
        configured: false,
        propertyId: GA4_PROPERTY_ID,
        message: `GA4 Data API query failed: ${apiError.message || "Unknown error"}. Verify GA4 property ID and service account IAM permissions.`,
        cached: false,
        timestamp: new Date().toISOString(),
        dateRange: dateRange,
        configurationGuide: {
          requiredEnvVars: ["GA4_PROPERTY_ID"],
          serviceAccount: "Firebase / Google Cloud Default Service Account",
          permissions: "Viewer role on your Google Analytics 4 property",
          enableApi: "analyticsdata.googleapis.com (Google Analytics Data API v1beta)",
        },
        overview: {
          activeUsers: 0,
          newUsers: 0,
          sessions: 0,
          screenPageViews: 0,
          engagementRate: 0,
          averageSessionDuration: 0,
          eventCount: 0,
        },
        timeseries: [],
        pages: [],
        events: [],
        devices: [],
        browsers: [],
        countries: [],
        trafficSources: [],
        contentInteractions: makeEmptyInteractions(),
      };
    }
  }
);

/**
 * Helper function to verify caller has administrative authorization.
 */
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

/**
 * Callable Cloud Function: setAdminCustomClaim
 * Allows verified admin to set or refresh custom claim { admin: true } on their account.
 */
exports.setAdminCustomClaim = onCall(
  { cors: true },
  async (request) => {
    const adminUser = assertAdmin(request);
    const targetEmail = (request.data && request.data.email) || adminUser.email;

    // Safety: Only allow setting admin claim on approved admin email
    if (targetEmail !== "saidurrahman1004@gmail.com") {
      throw new HttpsError("invalid-argument", "Cannot assign admin role to unauthorized email address.");
    }

    const userRecord = await admin.auth().getUserByEmail(targetEmail);
    await admin.auth().setCustomUserClaims(userRecord.uid, { admin: true });

    // Log this privileged operation to audit logs
    await db.collection("audit_logs").add({
      action: "admin_claim_assigned",
      resourceType: "auth",
      resourceId: userRecord.uid,
      adminEmail: adminUser.email,
      adminRole: "admin",
      result: "success",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      metadata: { targetEmail },
    });

    return {
      success: true,
      message: `Custom claim { admin: true } successfully assigned to ${targetEmail}`,
      uid: userRecord.uid,
    };
  }
);

/**
 * Callable Cloud Function: recordAuditLog
 * Secure endpoint to record admin operational activity from backend or client.
 */
exports.recordAuditLog = onCall(
  { cors: true },
  async (request) => {
    const adminUser = assertAdmin(request);
    const data = request.data || {};

    if (!data.action || typeof data.action !== "string") {
      throw new HttpsError("invalid-argument", "Audit action is required.");
    }

    const resourceType = typeof data.resourceType === "string" ? data.resourceType.trim() : "general";
    const resourceId = typeof data.resourceId === "string" ? data.resourceId.trim() : "none";
    const result = ["success", "failure"].includes(data.result) ? data.result : "success";

    // Strictly sanitize metadata - forbid sensitive keys
    const rawMetadata = data.metadata && typeof data.metadata === "object" ? data.metadata : {};
    const sanitizedMetadata = {};
    const forbiddenKeys = ["password", "token", "secret", "apikey", "message", "credential", "auth"];

    for (const [k, v] of Object.entries(rawMetadata)) {
      const lower = k.toLowerCase();
      if (!forbiddenKeys.some((fk) => lower.includes(fk))) {
        if (typeof v === "string" || typeof v === "number" || typeof v === "boolean" || Array.isArray(v)) {
          sanitizedMetadata[k] = v;
        }
      }
    }

    const auditEntry = {
      action: sanitizeServerString(data.action, 100),
      resourceType: sanitizeServerString(resourceType, 100),
      resourceId: sanitizeServerString(resourceId, 200),
      adminEmail: adminUser.email,
      adminRole: "admin",
      result,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      metadata: sanitizedMetadata,
    };

    const docRef = await db.collection("audit_logs").add(auditEntry);
    return { success: true, id: docRef.id };
  }
);

