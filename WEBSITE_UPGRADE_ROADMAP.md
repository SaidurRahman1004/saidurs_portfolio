# Saidur Portfolio Upgrade Roadmap

**Prepared:** 2026-09-15  
**Sources:** [Live website](https://saidurs-portfolio.web.app/), `CV/saidur_cv.pdf`, `PROJECT_AUDIT.md`

## 1. CV বনাম বর্তমান website — সবচেয়ে বড় content gap

আপনার CV আপনাকে শুধু “Flutter app developer” হিসেবে নয়, production experience-সহ একজন junior mobile engineer হিসেবে উপস্থাপন করছে। বর্তমান website-এ সেই positioning যথেষ্ট শক্তিশালী নয়।

### CV থেকে website-এ অবশ্যই যোগ করা উচিত

- **পরিচয়:** `MD Saidur Rahman Bhuyan` — CV-র নামের সঙ্গে website-এর `Saidur Rahman` মিলিয়ে canonical display name ঠিক করুন।
- **Current experience:** `Junior Flutter Developer — SM Technology, A Betopia Group Company`, Mar 2026–Present।
- **Production credibility:** Google Play Store এবং Apple App Store publishing, release preparation, versioning, deployment এবং production lifecycle।
- **Core technical story:** Flutter/Dart, REST API, Firebase, Provider/Riverpod/GetX, Django REST, JWT, WebSocket/Socket.IO, SQLite/Hive, Clean Architecture/MVVM/MVC/Repository Pattern।
- **Project proof:** EzyDash, ChugChain, PocketVault, TravelSnap।
- **Advanced features:** real-time messaging, video streaming/preloading, payment integrations, QR ticketing, Maps/GPS, IAP, subscriptions, AdMob, FCM, Analytics, Crashlytics।
- **Education:** Diploma in Computer Engineering/CST — Dhaka Polytechnic Institute, 2022–2026।
- **Certifications:** Ostad Flutter & Dart এবং Bohubrihi Web Development।
- **Languages:** Bengali — Native, English — Intermediate।
- **Links:** CV-তে LinkedIn আছে (`linkedin.com/in/saidur1004`), কিন্তু বর্তমান app constants-এ LinkedIn empty।

### Content mismatch/সতর্কতা

1. Website বর্তমানে `Flutter App Developer` বলছে; CV অনুযায়ী headline হওয়া উচিত `Junior Flutter Developer | Production Mobile App Engineer`।
2. Website-এর about text-এ “currently learning Django” বলা আছে; CV-তে Django REST, JWT এবং full-stack project experience আছে। এটিকে কম আত্মবিশ্বাসী না করে evidence-based wording দিন।
3. CV-র চার project-এর জায়গায় website-এ Firebase থেকে project data আসে; admin dashboard-এ seed/import workflow না থাকলে visitor portfolio ফাঁকা দেখতে পারে।
4. CV-তে LinkedIn, store publishing এবং professional experience আছে—কিন্তু contact/hero/about sections-এ সেগুলো prominent নয়।
5. CV-তে phone format `+880 1795 664122`; website-এ `+8801795664122`। এক canonical format ব্যবহার করুন।
6. CV file-টি website-এর resume CTA-তে ব্যবহার করুন; placeholder `https://your-resume-link.pdf` সরিয়ে deployed PDF URL দিন।

## 2. Recommended information architecture

### Public website

1. **Hero:** name, role, 1-line value proposition, `View Projects`, `Download CV`, `Contact Me`।
2. **Trust strip:** `6+ months professional experience`, `Production apps`, `Play Store + App Store`, `Flutter/Dart`।
3. **About/Experience:** current job, responsibilities, collaboration, release ownership।
4. **Featured projects:** EzyDash, ChugChain, PocketVault, TravelSnap; each with role, problem, features, stack, screenshots, links।
5. **Skills:** grouped by Mobile, Backend/API, Firebase/Cloud, Storage, Architecture, Deployment/Monetization, Tools।
6. **Career timeline:** education, current role, certification।
7. **Contact:** email, phone/WhatsApp, LinkedIn, GitHub, CV download।

### Project detail model

প্রতিটি project document-এ অন্তত এগুলো রাখুন:

```text
title
slug
shortDescription
longDescription
role
timeline
status: production | in-development | personal
techStack[]
features[]
architecture
platforms[]
imageUrl
gallery[]
githubUrl
liveUrl
storeLinks: { android, ios }
isFeatured
isVisible
order
createdAt
updatedAt
```

## 3. Visual direction recommendation

বর্তমান dark cyan/purple theme রাখা যেতে পারে, কিন্তু এটিকে “neon portfolio” থেকে “production mobile engineer” brand-এ নেওয়া উচিত।

- Background: deep navy; cards কম glow, বেশি clean surface।
- Accent: cyan/purple শুধু CTA, links এবং status-এ; সব জায়গায় gradient নয়।
- Typography: heading-এ Poppins বা একই family; body-তে Inter; maximum 3 font sizes per section।
- Layout: 1200px content max-width, consistent 24/32/48 spacing scale।
- Hero: oversized name নয়, clear outcome + proof points।
- Project cards: screenshot-first, role/features/stack visible; “View Details” যেন সত্যিই details page খোলে।
- Admin dashboard: marketing-style glow বাদ দিয়ে dense but calm data-management UI; filters, status chips, inline errors, table/card view।
- Accessibility: visible keyboard focus, 44px minimum tap target, readable contrast, reduced-motion support, selectable contact text।

## 4. Backend/Firebase redesign

### Collections

```text
portfolio/profile
portfolio/experience/{experienceId}
portfolio/projects/{projectId}
portfolio/skills/{skillId}
portfolio/certifications/{certificationId}
portfolio/education/{educationId}
portfolio/settings/site
```

বর্তমান top-level `skills`, `projects`, `contact` collection রাখা গেলেও future growth-এর জন্য namespace (`portfolio/...`) ব্যবহার করা ভালো। Migration-এর আগে existing production data backup নিন।

### Admin roles

- Firebase Auth + custom claim: `admin: true`
- Client-side `AuthGuard` শুধু UX guard হবে
- Firestore rules-এ UID/custom claim দিয়ে actual authorization হবে
- Public read: `isVisible == true`
- Admin write/update/delete: admin claim only
- Audit fields: `createdBy`, `updatedBy`, `createdAt`, `updatedAt`

### Image handling

ImgBB API key client bundle-এ পাঠাবেন না। Authenticated Cloud Function/backend upload endpoint ব্যবহার করুন। Image metadata, size, MIME type, alt text এবং deletion strategy রাখুন।

### Data reliability

- Firestore `Timestamp` canonical করুন, ISO string ও Timestamp mix করবেন না।
- Public stream subscription একবার চালু করুন এবং dispose করুন।
- Admin dashboard-এ explicit loading/error/empty state রাখুন।
- `firestore.rules`, `firestore.indexes.json`, emulator tests repository-তে রাখুন।

## 5. Admin dashboard-এর নতুন structure

### Dashboard overview

- profile completeness score
- visible projects/skills count
- featured projects count
- missing fields alert: LinkedIn, CV, store links, screenshots
- recent changes: who changed what and when

### Content modules

- Profile & hero
- Experience
- Projects
- Skills
- Education & certificates
- Social/contact links
- Media library
- Site settings

### Better admin workflow

1. Draft save
2. Preview as public visitor
3. Validation summary
4. Publish/visible toggle
5. Activity log

## 6. Step-by-step implementation plan

### Phase 0 — Safety and baseline

- ImgBB key rotate করুন
- `.env` untrack এবং Git history clean করুন
- Firestore rules/indexes backup ও source-control করুন
- current Firebase data export করুন
- broken `font_awesome_flutter` dependency ঠিক করুন
- `flutter analyze`, `flutter test`, `flutter build web --release` green করুন

**Done when:** build, tests, rules baseline এবং secret hygiene verified।

### Phase 1 — CV content foundation

- `ContactModel`-কে `ProfileModel`-এ expand করুন
- Experience, education, certification model যোগ করুন
- CV PDF deploy করুন
- LinkedIn/GitHub/store links যোগ করুন
- four flagship projects seed করুন

**Done when:** visitor CV-এর গুরুত্বপূর্ণ claim website-এ evidence হিসেবে দেখতে পারে।

### Phase 2 — Public redesign

- Hero rewrite
- trust strip যোগ
- experience/timeline section যোগ
- project detail page যোগ
- skills grouping CV অনুযায়ী rewrite
- contact/footer complete করুন

**Done when:** mobile 320px থেকে desktop 1440px পর্যন্ত overflow নেই এবং CTA clear।

### Phase 3 — Admin redesign

- profile/experience/projects/certificates modules
- draft/preview/publish flow
- image upload backend proxy
- validation, empty/error/skeleton states
- audit log

**Done when:** admin থেকে public site-এর পুরো content manage করা যায়, code edit ছাড়া।

### Phase 4 — Quality, SEO, performance

- real widget/unit/integration tests
- responsive screenshot tests
- Lighthouse/SEO metadata
- image resize/lazy loading
- keyboard/accessibility audit
- analytics events: CTA click, CV download, project open

## 7. Generator/Codex-এ দেওয়ার জন্য master prompt

নিচের prompt-টি একবারে পুরো app rewrite করতে না দিয়ে phase-by-phase ব্যবহার করুন:

```text
তুমি একজন senior Flutter web architect, product designer এবং Firebase security engineer।

Project: Saidur Rahman portfolio
Stack: Flutter web, Firebase Auth, Cloud Firestore, Provider, url_launcher
Source of truth:
- CV: MD Saidur Rahman Bhuyan, Junior Flutter Developer at SM Technology (Betopia Group), Mar 2026–Present
- Projects: EzyDash, ChugChain, PocketVault, TravelSnap
- Skills: Flutter/Dart, REST, Firebase, Django REST, JWT, Socket.IO/WebSocket, SQLite/Hive, Clean Architecture, Provider/Riverpod/GetX, Play Store/App Store publishing, IAP, AdMob
- Audit: PROJECT_AUDIT.md

Goal:
Build a credible production mobile engineer portfolio, not a generic template.

Rules:
1. আগে repository inspect করো এবং relevant files/line numbers উল্লেখ করো।
2. একবারে এক phase implement করো; unrelated code rewrite করো না।
3. Existing data migration plan ছাড়া Firestore schema ভেঙো না।
4. Client bundle-এ কোনো secret রাখবে না।
5. Public read এবং admin write-এর জন্য Firestore rules লিখবে।
6. 320, 375, 600, 768, 900, 1024 এবং 1440px responsive behavior verify করবে।
7. Loading, error, empty, offline এবং invalid URL state যোগ করবে।
8. প্রত্যেক change-এর পরে flutter analyze, flutter test এবং প্রয়োজন হলে flutter build web --release চালাবে।
9. শেষে changed files, tests, known limitations এবং next step report করবে।

Start with Phase 0 only: dependency/build baseline, secret hygiene plan, Firebase rules/indexes audit, and a safe implementation plan. Code change করার আগে findings দেখাও।
```

## 8. Phase-specific prompts

### Prompt A — CV content migration

```text
CV-এর তথ্যকে website content model-এ migrate করো। Profile, experience, education, certification এবং project-এর typed Dart models, Firestore serialization, validation এবং seed data তৈরি করো। Existing project data না মুছে backward-compatible রাখো। প্রথমে proposed schema ও changed files দেখাও, তারপর implement করো।
```

### Prompt B — Public homepage redesign

```text
Homepage redesign করো: hero, trust strip, experience timeline, four featured projects, CV CTA এবং contact section। Existing dark cyan/purple brand refined করে production-engineer look দাও। 320px width-এ কোনো overflow নয়। Hero CTA-তে Download CV, View Projects, Contact Me রাখো। Fixed-width image বাদ দিয়ে LayoutBuilder ব্যবহার করো। আগে widget tree এবং responsive rules লিখে তারপর code করো।
```

### Prompt C — Project detail system

```text
Reusable ProjectCard এবং ProjectDetailsPage তৈরি করো। Card-এর View Details সত্যিকারের detail page খুলবে; GitHub/Live/Play Store/App Store আলাদা CTA হবে। Firestore model-এ role, timeline, features, architecture, gallery এবং store links যোগ করো। Missing URL হলে button hide/disable হবে। loading/error/empty state এবং responsive gallery দাও।
```

### Prompt D — Firebase security/backend

```text
Firebase backend harden করো। Firestore rules ও indexes file যোগ করো। Public users শুধু visible portfolio content read করতে পারবে। Admin custom claim ছাড়া কোনো write/update/delete পারবে না। Client-side ImgBB secret সরিয়ে authenticated upload proxy design দাও। Rules emulator test লিখো এবং migration/rollback steps দাও।
```

### Prompt E — Admin dashboard

```text
Admin dashboard-কে content management system হিসেবে redesign করো। Modules: profile, experience, projects, skills, certificates, education, media এবং settings। Draft/preview/publish, validation summary, missing-content alert, audit fields এবং responsive mobile form যোগ করো। Desktop-এ table/card toggle এবং mobile-এ full-screen form দাও। Existing AuthGuard behavior পরীক্ষা করে redirect loop ঠিক করো।
```

### Prompt F — responsive/accessibility QA

```text
Public এবং admin UI-র responsive/accessibility audit করো। 320, 375, 600, 768, 900, 1024, 1440px এবং 200% text scale test করো। RenderFlex overflow, fixed width, keyboard overlap, focus state, contrast, semantic labels, tap target এবং reduced-motion issue খুঁজে line-numberসহ report করো। তারপর শুধুমাত্র verified fixes implement করো এবং regression test যোগ করো।
```

## 9. Immediate next action

সবচেয়ে নিরাপদ শুরু হবে এই ক্রমে:

1. `font_awesome_flutter` build issue এবং test baseline ঠিক করা
2. ImgBB secret rotate/untrack করা
3. CV-র চারটি project ও experience-এর seed data তৈরি করা
4. Profile/Experience/Project model ও Firestore rules তৈরি করা
5. Public homepage redesign
6. Admin CMS redesign

একবারে পুরো project generate/rewrite করাবেন না। প্রতিটি phase-এর পরে build, test, preview এবং data verification করে পরের phase-এ যাবেন।
