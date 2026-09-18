# Saidur's Portfolio — Project Audit

**Audit date:** 2026-09-14  
**Scope:** Flutter web portfolio, Android target, Firebase/Auth/Firestore, admin dashboard, image upload, responsive UI, tests and release build.

## Executive summary

প্রজেক্টটির মূল ধারণা ভালো: public portfolio এবং Firebase-backed admin panel একই অ্যাপে আছে। তবে এখনই production update শুরু করার আগে build/dependency, security এবং data-flow ঠিক করা দরকার। বর্তমান অবস্থায় web release build এবং widget test দুটিই ব্যর্থ হচ্ছে।

### বর্তমান verification ফলাফল

| Check | Result | Evidence |
|---|---|---|
| `flutter analyze` | Failed quality gate / 217 issues | deprecated API, async/context warnings, dependency warning এবং unused code |
| `flutter test` | Failed at compilation | `font_awesome_flutter-10.12.0` `IconData` final class extend করছে |
| `flutter build web --release` | Failed | একই `font_awesome_flutter` compile error |

## Priority findings

### P0 — আগে ঠিক করা বাধ্যতামূলক

#### 1. Web/test/release build ভেঙে আছে

`pubspec.yaml`-এ `font_awesome_flutter: ^10.12.0` আছে, কিন্তু বর্তমান Flutter/Dart toolchain-এ dependency-টির `IconDataBrands`, `IconDataSolid` ইত্যাদি `IconData` extend করতে গিয়ে compile error হচ্ছে। এটি `contact_section.dart`-এ GitHub/LinkedIn icon ব্যবহারের সময় build graph-এ ঢুকে যায়।

**প্রভাব:** production web deploy এবং test run করা যাচ্ছে না।

**করণীয়:** compatible `font_awesome_flutter` version-এ upgrade/downgrade করে `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build web --release` চালাতে হবে। প্রয়োজনে Font Awesome বাদ দিয়ে Material icons ব্যবহার করা যায়। Lock file-ও একই compatibility অনুযায়ী regenerate করতে হবে।

#### 2. Secret key repository-তে tracked

`.env` git-tracked এবং এতে ImgBB API key আছে। `git ls-files`-এ `.env` পাওয়া গেছে। `FIREBASE_WEB_API_KEY`-ও source/config-এ expose করা আছে; Firebase web API key সাধারণত secret নয়, কিন্তু ImgBB key ব্যবহারকারীর browser-এ পাঠানো হচ্ছে।

**প্রভাব:** key abuse, quota loss এবং unwanted uploads-এর ঝুঁকি। API key আগে থেকেই exposed ধরে rotate করতে হবে।

**করণীয়:**

- ImgBB key revoke/rotate করুন।
- `.env` ignore করুন এবং Git history থেকে secret purge করুন।
- Browser থেকে direct ImgBB upload না করে authenticated backend/Cloud Function দিয়ে upload proxy করুন, অথবা অন্তত strict quota/rate-limit রাখুন।
- `--dart-define` বা `.env` value কোনোভাবেই client secret হিসেবে বিবেচনা করবেন না।

#### 3. Firestore rules source repository-তে নেই

রুটে `firestore.rules` বা `firestore.indexes.json` নেই, অথচ app public query এবং admin CRUD চালায়। Admin UI-র `AuthGuard` থাকলেও সেটি শুধু client-side navigation guard; Firestore permission enforce করে না।

**প্রভাব:** ভুল Firebase console rules থাকলে public user write/delete করতে পারে, আবার rules কঠোর হলে app-এর admin CRUD ব্যর্থ হতে পারে। Composite query-র জন্য index-ও লাগতে পারে।

**করণীয়:** repository-তে rules/indexes version-control করুন। Public read কেবল visible documents-এর জন্য এবং write/update/delete কেবল authenticated admin UID/custom claim-এর জন্য রাখুন। Rules emulator দিয়ে CRUD test লিখুন।

#### 4. Firebase initialization error গিলে ফেলা হচ্ছে

`lib/main.dart:23-29`-এ `Firebase.initializeApp(...).catchError(...)` ব্যবহার হয়েছে, কিন্তু `catchError`-এর handler `FirebaseApp` return করে না। Analyzer এটিকে warning দিয়েছে এবং init fail হলেও app চালু করার চেষ্টা করে।

**প্রভাব:** Firebase না চললেও app blank/error state-এ যেতে পারে; failure স্পষ্ট নয়।

**করণীয়:** `try/catch` দিয়ে initialization await করুন, fatal হলে dedicated error screen বা controlled fallback দেখান।

## P1 — logic এবং data-flow সমস্যা

### 5. Stream-কে Future হিসেবে await করা হয়েছে

`lib/providers/portfolio_provider.dart:83`-এ `await _firebaseService.getSkills().listen(...)` আছে। `listen()` `StreamSubscription` দেয়, Future নয়; analyzer-ও `await_only_futures` ধরেছে। অন্য loader-গুলোও `listen()`-based হলেও `Future<void>` return করছে।

**প্রভাব:** `loadAllData()` আসলে প্রথম Firestore event আসা পর্যন্ত অপেক্ষা করে না। loading state, refresh এবং error sequencing misleading হয়। প্রত্যেক refresh-এ নতুন subscription তৈরি হয়; পুরনো subscription cancel করা হয় না।

**করণীয়:** হয় provider-এ `StreamSubscription` ধরে dispose/cancel করুন, নয়তো public data-র জন্য one-shot `get()` ব্যবহার করুন। Admin/public stream আলাদা lifecycle-এ রাখুন। `loadAllData()`-কে সত্যিকার completion semantics দিন।

### 6. Provider subscription leak

`loadSkills`, `loadProjects`, `loadContactInfo`, `loadAllSkills`, `loadAllProjects` বারবার call করলে প্রতিবার নতুন listener তৈরি হয়। কোনো `dispose()` নেই।

**প্রভাব:** duplicate callbacks, duplicate rebuild, memory leak এবং logout/login বা retry-তে অপ্রত্যাশিত update।

**করণীয়:** প্রতিটি subscription field-এ রাখুন, replace করার আগে cancel করুন, provider `dispose()` override করুন। অথবা `StreamProvider`/single repository subscription ব্যবহার করুন।

### 7. Firestore date format অসঙ্গত

`ProjectModel.toFirestore()` এবং `ContactModel.toFirestore()` date-কে ISO string হিসেবে লিখছে, কিন্তু `getAllProjects()` `orderBy('createdAt')` করে এবং model আবার `Timestamp`/String দুই format handle করছে। পুরনো/নতুন document mix হলে sort এবং query behavior inconsistent হতে পারে।

**করণীয়:** `FieldValue.serverTimestamp()` বা Firestore `Timestamp` একটিই canonical format করুন এবং migration দিন। `createdAt` missing/null হলে `DateTime.now()` দিয়ে silently replace না করে controlled fallback/error রাখুন।

### 8. Admin data load নির্ভর করছে tab open হওয়ার উপর

`loadAllSkills()` এবং `loadAllProjects()` management screen-এর `initState` থেকে শুরু হয়। Dashboard statistics tab না খুললে zero দেখাতে পারে।

**করণীয়:** admin provider/layout initialization-এ একবার load করুন, অথবা dashboard-এ explicit loading state দেখান।

### 9. Auth guard redirect loop/race risk

`lib/widgets/admin/auth_guard.dart`-এ `currentUser == null` হলেই build-এর মধ্যে `addPostFrameCallback` দিয়ে login route pushReplacement করা হয়। Auth state listener initial event পাওয়ার আগেও এই branch চলে, এবং guard `AdminLayout`-এর ভিতরেও আবার wrap করা হয়েছে।

**প্রভাব:** app startup-এ unnecessary redirect, duplicate route এবং auth state race।

**করণীয়:** `authStateChanges`-এর `waiting/authenticated/unauthenticated` তিনটি state render করুন। Redirect এক জায়গায় রাখুন; build-এর ভিতর বারবার navigation schedule করবেন না।

### 10. Error handling তথ্য হারাচ্ছে

`FirebaseService.addSkill/updateSkill` exception catch করে শুধু print করছে এবং success হিসেবে return করছে। অন্য service methods exception rethrow করে।

**প্রভাব:** skill save/update ব্যর্থ হলেও UI success flow চালাতে পারে।

**করণীয়:** সব repository method-এর error contract এক করুন—exception rethrow করুন বা typed result দিন; UI-তে success কেবল awaited operation সফল হলে দেখান।

## P1 — responsive/UI risks

### 11. Project cards-এর fixed grid aspect ratio overflow করতে পারে

`lib/screens/public/sections/projects_section.dart:184-209`-এ tablet `childAspectRatio: 0.9`, desktop `1.2`, কিন্তু card-এর ভিতরের content variable এবং non-mobile card-এ `maxHeight: 380`। Long project title/description/tech stack বা narrow tablet width-এ RenderFlex overflow হতে পারে।

**করণীয়:** fixed aspect ratio বাদ দিয়ে `SliverGridDelegateWithMaxCrossAxisExtent`/responsive card height ব্যবহার করুন, অথবা card content-এর জন্য predictable height + text constraints দিন। 320px minimum ও 380px maximum একই সঙ্গে পরীক্ষা করুন।

### 12. Hero section narrow tablet/mobile-এ width চাপ তৈরি করতে পারে

Hero illustration-এ mobile width 320 এবং desktop/tablet width 550 fixed। Hero content ও illustration পাশাপাশি রাখলে ছোট tablet বা landscape phone-এ horizontal overflow/অতিরিক্ত squeeze হওয়ার ঝুঁকি আছে।

**করণীয়:** 600/900 breakpoint-এ বাস্তব device width দিয়ে পরীক্ষা করুন; `LayoutBuilder`-ভিত্তিক width `min(maxWidth - padding, desiredWidth)` করুন এবং narrow tablet-এ column layout দিন।

### 13. Admin table/layout small tablet-এর জন্য যথেষ্ট adaptive নয়

Skills/projects management-এ একাধিক `Row` + `Expanded` column এবং desktop grid আছে। 600–899px range-এ sidebar drawer থাকলেও table columns, search/filter row এবং action buttons compact width-এ clipped হতে পারে।

**করণীয়:** 900-এর নিচে card/list presentation বা horizontal scroll দিন; search/filter controls `Wrap` করুন। 320, 375, 600, 768, 1024, 1440px viewport-এ golden/screenshot test রাখুন।

### 14. Global `SingleChildScrollView`-এর ভিতরে nested shrink-wrapped lists/grids

Home screen পুরো body-কে `SingleChildScrollView` করেছে এবং ভিতরের project/skill grids `shrinkWrap: true` ও `NeverScrollableScrollPhysics`। অল্প data-তে কাজ করলেও বড় data set-এ সব item একসঙ্গে layout/build হবে।

**করণীয়:** বড় portfolio হলে sliver-based single scroll architecture (`CustomScrollView`) ব্যবহার করুন; project count cap/pagination রাখুন।

### 15. Navigation scroll callback unsafe

`lib/screens/public/home_screen.dart:22-33`-এ delayed callback-এর ভিতর `key.currentContext!` force unwrap করা হয়েছে এবং widget unmounted কি না check নেই। দ্রুত route change বা disposed widget হলে crash হতে পারে।

**করণীয়:** `if (!mounted) return; final target = key.currentContext; if (target == null) return;` ব্যবহার করুন। drawer বন্ধের animation complete হওয়ার জন্য `endOfFrame` বা controlled callback ব্যবহার করুন।

### 16. Async gap-এর পর BuildContext ব্যবহার

Analyzer-এ login, contact management, add/edit project, admin sidebar-এ `use_build_context_synchronously` warnings আছে। সব জায়গায় `mounted` check যথেষ্ট নয়—কিছু ক্ষেত্রে unrelated State mounted check হচ্ছে।

**করণীয়:** await-এর পরে নির্দিষ্ট `context.mounted` check করুন এবং navigation/snackbar-এর আগে state lifecycle verify করুন।

## P1 — public product/logic gaps

### 17. “View Details” আসলে GitHub খুলছে

Projects card-এ button label `View Details`, কিন্তু `project.githubUrl` launch করে। আলাদা project detail page বা modal নেই। UX expectation এবং actual action mismatch।

### 18. Empty/invalid URL handling অসম্পূর্ণ

কিছু জায়গায় `canLaunchUrl` false হলে শুধু debug log হয়; user feedback নেই। GitHub URL required হলেও URL format validator নেই।

**করণীয়:** `Uri.tryParse`, scheme/host validation, এবং user-visible failure snackbar দিন। Empty GitHub URL হলে disabled button দেখান।

### 19. Contact/Resume defaults অসম্পূর্ণ

`AppConstants.linkedin` empty এবং `resumeUrl` এখনও `https://your-resume-link.pdf` placeholder। Contact Firestore document missing হলে public section পুরো contact information unavailable দেখায়।

**করণীয়:** production content complete করুন; fallback contact model বা setup checklist রাখুন; placeholder URL কখনও clickable না রাখুন।

### 20. “Recent Activity” placeholder

Admin dashboard-এ Recent Activity সরাসরি “Activity tracking coming soon...” দেখায়। এটি missing feature হিসেবে README/product scope-এ স্পষ্ট করুন অথবা section সরিয়ে দিন।

## P2 — code quality/maintenance

### 21. Analyzer warnings/deprecations পরিষ্কার করা দরকার

মোট ২১৭টি issue-এর মধ্যে বহু `withOpacity` deprecation, `print` usage, unused imports/variables, missing key/super parameter, naming এবং `BuildContext` warning আছে। বিশেষভাবে `withOpacity`-কে নতুন Flutter API অনুযায়ী `.withValues()`-এ migrate করতে হবে।

### 22. Dependency declaration অসম্পূর্ণ

`main.dart` সরাসরি `flutter_web_plugins/url_strategy.dart` import করেছে, কিন্তু `pubspec.yaml`-এ `flutter_web_plugins` dependency নেই; analyzer `depend_on_referenced_packages` warning দিয়েছে। Flutter SDK dependency হিসেবে সঠিকভাবে declare/resolve করুন।

### 23. Test file template test

`test/widget_test.dart` এখনও counter app-এর default test: `0`, `1`, `Icons.add` খোঁজে। Portfolio-এর real behavior—Firebase init isolation, auth guard, responsive sections, project card actions এবং empty/error states—কোনোটিই test হচ্ছে না।

**করণীয়:** Firebase services injectable/mockable করুন; তারপর provider, model parsing, auth flow এবং widget smoke/golden tests যোগ করুন।

### 24. Release signing placeholder

`android/app/build.gradle.kts` release build-এ debug signing ব্যবহার করছে। Store release-এর আগে proper keystore, secrets বাইরে রাখা, versioning এবং package label (`futter_portfileo_website` typo সহ) ঠিক করতে হবে।

### 25. Naming/encoding cleanup

Package name-এ `futter_portfileo_website` typo আছে। কয়েকটি source/comment/UI text-এ mojibake দেখা যাচ্ছে (`ðŸ...`, `Â©`, `à¦...`)। UTF-8 encoding cleanup এবং package rename করার migration plan দরকার।

## Suggested update order

1. ImgBB key rotate, `.env` untrack, Git history cleanup, Firebase rules/indexes যোগ।
2. `font_awesome_flutter` compatibility ঠিক করে web release build green করা।
3. Firebase init ও provider stream lifecycle refactor করা।
4. Auth guard এবং service error contract ঠিক করা।
5. 320–1440px responsive pass: hero, projects, skills, admin table/dialog।
6. Placeholder content/URL ঠিক করা এবং URL validation যোগ।
7. Analyzer warnings কমিয়ে zero-warning target করা।
8. Real tests যোগ করে `flutter test` এবং release build CI-তে বাধ্যতামূলক করা।

## Recommended acceptance checklist

- [ ] `flutter analyze` কোনো warning/error ছাড়া pass করে
- [ ] `flutter test` pass করে
- [ ] `flutter build web --release` pass করে
- [ ] Firebase rules emulator tests pass করে
- [ ] anonymous user visible portfolio read করতে পারে, write/delete পারে না
- [ ] admin login ছাড়া `/admin` access করলে stable login screen আসে
- [ ] refresh/retry করলে duplicate Firestore listener তৈরি হয় না
- [ ] 320, 375, 600, 768, 900, 1024, 1440px viewport-এ overflow নেই
- [ ] invalid/missing image, URL, Firestore data এবং network error user-visible fallback দেখায়
- [ ] release Android build debug keystore ব্যবহার করে না
- [ ] repository/Git history-তে কোনো live ImgBB secret নেই

## Files requiring first attention

- `pubspec.yaml` — dependency compatibility এবং missing `flutter_web_plugins`
- `lib/main.dart` — Firebase init error handling
- `lib/providers/portfolio_provider.dart` — stream lifecycle/`await listen`
- `lib/services/firebase_service.dart` — error contract এবং timestamp consistency
- `lib/widgets/admin/auth_guard.dart` — auth state/redirect lifecycle
- `lib/screens/public/home_screen.dart` — delayed scroll null safety
- `lib/screens/public/sections/projects_section.dart` — fixed grid/card sizing
- `lib/screens/public/sections/hero_section.dart` — fixed illustration sizing
- `lib/screens/admin/dashboard/*` — small-screen table/dialog layouts এবং async context
- `.env`, `firebase.json`, Firebase rules/indexes — security/deployment hygiene
- `test/widget_test.dart` — replace template test with portfolio tests

## Design/UI/UX audit

> এই অংশটি source-level layout review। বর্তমানে web build ভাঙা থাকায় real browser screenshot/golden comparison করা সম্ভব হয়নি; তাই নিচেরগুলো code থেকে নিশ্চিত design risk বা visible UX issue হিসেবে চিহ্নিত।

### D1 — Hero mobile layout-এ spacing bug

`lib/screens/public/sections/hero_section.dart:45-52`-এ mobile `Column`-এর মধ্যে illustration-এর পরে `SizedBox(width: 40)` ব্যবহার হয়েছে। Column-এ width কোনো vertical gap তৈরি করে না; ফলে image ও text-এর মধ্যে প্রত্যাশিত 40px vertical spacing থাকবে না। এখানে `height: 40` হওয়া উচিত।

### D2 — Hero desktop height/content clipping risk

Hero section-এর minimum height 600px এবং vertical padding 80px। এর ভিতরে 420px illustration, heading, animated role, description এবং তিনটি button আছে। ছোট laptop height বা browser zoom 125–200%-এ content 600px-এর বেশি হয়ে যেতে পারে; section visually cramped/overflow হতে পারে।

**সংশোধন:** fixed/minimum height-এর বদলে `minHeight`-এর সঙ্গে content-driven layout রাখুন; desktop-এ `mainAxisAlignment.center` এবং mobile-এ natural height ব্যবহার করুন।

### D3 — Hero text animation layout shift তৈরি করতে পারে

`AnimatedTextKit`-এর তিনটি role-এর দৈর্ঘ্য আলাদা। `Wrap`-এর মধ্যে animated text থাকার কারণে text বদলানোর সময় line wrap/height বদলাতে পারে, ফলে পাশে/নিচের description ও button jump করতে পারে।

**সংশোধন:** animated role-এর জন্য fixed/minimum width বা fixed height reserve করুন; reduced-motion preference থাকলে animation কমান/বন্ধ করুন।

### D4 — Hero illustration ছোট width-এ fixed-size

Mobile illustration width 320px, outer horizontal padding 24px। 320px viewport-এ content width 272px হলেও illustration 320px; তাই horizontal overflow হওয়ার সরাসরি ঝুঁকি আছে। একই সমস্যা 300px inner container-এও আছে।

**সংশোধন:** `width: min(constraints.maxWidth, 320)` ধরনের `LayoutBuilder`-based sizing ব্যবহার করুন এবং image container-এ `double.infinity`/bounded width দিন।

### D5 — Desktop-only navigation-এর breakpoint অসঙ্গত

`ResponsiveWrapper.isDesktop()` 900px থেকে desktop ধরে, কিন্তু `ResponsiveWrapper`-এর `desktop` variant 1200px-এ পৌঁছালে আলাদা branch নেয়। ফলে 900–1199px range-এ public layout desktop-style হলেও navbar hamburger/tablet-style থাকে।

**প্রভাব:** layout mode এবং navigation mode একে অপরের সঙ্গে visually inconsistent।

**সংশোধন:** public layout breakpoint ও navigation breakpoint আলাদা নাম/নীতিতে নির্ধারণ করুন, অথবা একই breakpoint contract ব্যবহার করুন।

### D6 — Navigation bar sticky নয় এবং active section indicator নেই

Custom app bar section scroll-এর সময় screen-এর সঙ্গে থাকে না, এবং কোন section active তা দেখায় না। Long portfolio page-এ user context হারায়; section navigation-এর feedback কম।

**সংশোধন:** `SliverAppBar`/sticky header, active nav state এবং scroll offset listener যোগ করুন।

### D7 — App bar background প্রায় transparent

`custom_app_bar.dart:43`-এ background `darkBackground.withOpacity(0.1)`। Content scroll হওয়ার সময় text/image-এর উপর দিয়ে গেলে contrast কমতে পারে; backdrop blur বা solid translucent surface নেই।

**সংশোধন:** opaque/semi-opaque surface, bottom border এবং optional blur ব্যবহার করুন। WCAG contrast check করুন।

### D8 — Dark theme contrast ও muted text risk

`textHint` `#6B7280`, card/surface dark এবং অনেক border/decoration opacity 0.1–0.3। Secondary/hint text, disabled LinkedIn/Resume action এবং subtle borders low-contrast হতে পারে।

**সংশোধন:** body/secondary/hint text-এর contrast ratio যাচাই করুন; disabled control-এ শুধু color নয়, clear state label/tooltip দিন।

### D9 — CTA buttons mobile-এ বেশি জায়গা নিতে পারে

`GradientButton`-এ সব breakpoint-এ horizontal padding 32 এবং vertical padding 16। Hero-তে তিনটি CTA `Wrap`-এ থাকায় 320–375px viewport-এ button দ্রুত আলাদা লাইনে ভেঙে যায় এবং hero অনেক লম্বা হয়।

**সংশোধন:** mobile-এ full-width/half-width CTA layout বা compact padding দিন; primary action-কে visual priority দিন, Resume-কে secondary link/button করুন।

### D10 — Skills section-এর fixed icon/grid sizing

Skills grid-এর icon card ও text layout-এ narrow width-এ category/name দীর্ঘ হলে card height এবং alignment unequal হওয়ার ঝুঁকি আছে। Icon code থেকে dynamic `IconData` বানানোর fallback-ও visualভাবে arbitrary icon দেখাতে পারে।

**সংশোধন:** consistent card min/max height, text maxLines/ellipsis, responsive `maxCrossAxisExtent` এবং meaningful fallback icon ব্যবহার করুন।

### D11 — Project card দু’টি view-তে visual system এক নয়

Homepage project card এবং `AllProjectsPage` card-এর image height, padding, button label, aspect ratio ও information density আলাদা। User homepage থেকে all-projects page-এ গেলে component consistency নষ্ট হয়। Homepage button `View Details` হলেও GitHub action; all-projects-এ `Code`/`Live` দেখা যায়।

**সংশোধন:** একটি reusable `ProjectCard` variant system বানান—compact/expanded, কিন্তু typography, badges, CTA semantics একই রাখুন।

### D12 — Project card action semantics confusing

Homepage-এর `View Details` button সরাসরি GitHub খোলে। এটি detail page-এর প্রত্যাশা তৈরি করে, কিন্তু external repository launch করে। এটি visual bug না হলেও UX design defect।

**সংশোধন:** label `View on GitHub` করুন অথবা সত্যিকারের details page/modal যোগ করুন।

### D13 — Project card content density/overflow risk

Homepage card-এ description height desktop-এ 50px, tech stack সর্বোচ্চ 3টি, card maxHeight 380px। Long translated text, বড় font setting বা accessibility text scale-এ buttons চাপা/overflow হতে পারে।

**সংশোধন:** fixed height কমিয়ে content-driven card রাখুন অথবা action row-এর জন্য guaranteed space দিন; 200% text scale test করুন।

### D14 — About section avatar bounds অস্বাভাবিক হতে পারে

Avatar wrapper-এ mobile max width/height 300, inner circle 280; desktop wrapper max 400, inner 380। কিন্তু wrapper-এর parent `Expanded` এবং image constraints সবসময় square নয়। কিছু width-এ Stack-এর available height/width একে অপরের সঙ্গে না মিললে glow/background circle visually crop হতে পারে।

**সংশোধন:** `AspectRatio(aspectRatio: 1)` ব্যবহার করুন এবং avatar size parent constraints থেকে derive করুন।

### D15 — Contact row দীর্ঘ email/phone-এ overflow risk

`contact_section.dart`-এর contact item Row-তে icon, label এবং value পাশাপাশি থাকে। Narrow mobile বা বড় text scale-এ email/phone এক লাইনে fit না হলে overflow হতে পারে, বিশেষ করে value-তে wrapping policy নেই।

**সংশোধন:** value-তে `Expanded` + `softWrap`, `TextOverflow.ellipsis`/selectable text এবং tap target বজায় রাখুন।

### D16 — Error/loading state design layout jump তৈরি করে

Skills, projects ও contact section loading/error/empty state-এ আলাদা padding/height ব্যবহার করেছে—কোথাও 40px, কোথাও 60px। Data আসার পরে section height হঠাৎ বদলায়, ফলে scroll position jump এবং visual instability হয়।

**সংশোধন:** skeleton বা reserved content height ব্যবহার করুন; error/empty state-এর জন্য shared component ও consistent vertical rhythm রাখুন।

### D17 — Admin sidebar 280px fixed width

`admin_sidebar.dart:21`-এ sidebar width 280px। 900–1024px viewport-এ app bar/content-এর জন্য কম জায়গা থাকে; dashboard cards/table cramped হয়।

**সংশোধন:** 1024px-এর নিচে collapsed rail বা drawer ব্যবহার করুন; desktop sidebar width 240–260px এবং content max-width/grid নিয়ম নির্ধারণ করুন।

### D18 — Admin mobile form/dialog usability risk

Add/edit project ও skill dialogs-এ dense multi-field form, image preview, tech chips এবং action buttons আছে। এগুলো scrollable হলেও mobile keyboard open অবস্থায় bottom actions obscured হতে পারে; dialog-এর fixed internal spacing ছোট viewport-এ অতিরিক্ত চাপ তৈরি করবে।

**সংশোধন:** full-screen mobile route/sheet ব্যবহার করুন, `MediaQuery.viewInsets` handle করুন, sticky bottom action bar দিন এবং form sections accordion/step-wise করুন।

### D19 — Admin loading/error state-এ visual context হারায়

Management screens error হলে center-এ generic message দেখায়; retry button থাকে, কিন্তু search/filter/header context থাকে না। User বুঝতে পারে না কোন data scope ব্যর্থ হয়েছে এবং loading-এর সময় page structure বদলে যায়।

**সংশোধন:** page shell/header স্থির রাখুন; content area-তে inline error banner/skeleton ব্যবহার করুন।

### D20 — Accessibility design gaps

- অনেক decorative icon/image-এর semantic label নেই।
- `CachedNetworkImage`-এ meaningful image description নেই।
- 9–13px text (`FEATURED`, tech chips, card buttons) low vision user-এর জন্য ছোট।
- Gradient/colored text-এর উপর contrast যাচাই নেই।
- Hover-oriented visual style আছে, কিন্তু keyboard focus state স্পষ্ট নয়।
- `Text`-based contact values selectable নয়।

**সংশোধন:** semantic labels, focus/pressed states, minimum readable text size, keyboard navigation এবং accessibility text scale test যোগ করুন।

### Design QA matrix

পরবর্তী UI pass-এ অন্তত এই viewport/setting-এ manual বা screenshot test করা উচিত:

| Scenario | কী দেখতে হবে |
|---|---|
| 320×568 | hero overflow, CTA wrapping, contact value wrapping |
| 375×812 | drawer, hero image, project card এবং keyboard form |
| 600×800 | tablet/public breakpoint mismatch |
| 768×1024 | project/skills grid, admin filters |
| 900×700 | sidebar/navigation transition |
| 1024×768 | fixed 280px sidebar ও dashboard density |
| 1440×900 | max content width, excessive empty space |
| 200% text scale | card/dialog/button overflow |
| reduced motion | animated hero text usability |

## Phase 10 — Complete Production Readiness Audit (2026-09-18)

The final production audit is documented in [FINAL_PRODUCTION_AUDIT.md](FINAL_PRODUCTION_AUDIT.md). The repository now has a passing Dart analyzer, 103 passing Flutter tests, passing debug/release web builds, and passing Functions lint. Firestore rules were compiled and deployed successfully.

The audit also fixed Functions ESLint 9 configuration, hostname/canonical SEO metadata, viewport zoom restriction, and public exposure of hidden portfolio content. Cloud Functions and Firebase Storage could not be verified because the project has not enabled the Cloud Functions API and Storage is not provisioned. Manual responsive, authenticated CRUD, analytics, error-ingestion, accessibility and real-device performance QA remain required.
