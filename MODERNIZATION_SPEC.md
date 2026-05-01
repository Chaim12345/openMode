# OpenMode Modernization Spec

## Migration Evaluation: Flutter → React Native / Expo (and Alternatives)

**Date:** 2026-05-01  
**Status:** Recommendation & Plan  
**Author:** AI Analysis  

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current Codebase Analysis](#2-current-codebase-analysis)
3. [Framework Evaluation](#3-framework-evaluation)
4. [Feature-to-Feature Dependency Mapping](#4-feature-to-feature-dependency-mapping)
5. [Risk Assessment](#5-risk-assessment)
6. [Recommendation](#6-recommendation)
7. [Migration Plan: Option A — Expo Rewrite](#7-migration-plan-option-a--expo-rewrite)
8. [Migration Plan: Option B — Flutter Modernization](#8-migration-plan-option-b--flutter-modernization)
9. [Effort & Timeline Estimates](#9-effort--timeline-estimates)
10. [Decision Matrix](#10-decision-matrix)

---

## 1. Executive Summary

OpenMode is a ~9,500-line Flutter/Dart mobile client for OpenCode AI, implementing an AI chat interface with SSE streaming, session management, and server configuration. The codebase follows Clean Architecture with Provider state management, Dio for networking, and GetIt for dependency injection.

**Key Finding:** Migration to Expo (React Native) is **technically feasible** with moderate effort. The main risk is SSE streaming support, which requires a third-party library (`react-native-sse`) or custom native module. However, the **Vercel AI SDK now has first-class Expo support** (SDK 52+), which significantly de-risks AI chat streaming.

**Recommendation:** **Expo with TypeScript** is the recommended migration target if the team has JavaScript/TypeScript expertise. If the team is Dart-first or performance-critical, **modernizing the existing Flutter codebase** is the safer path. Both options are detailed below.

---

## 2. Current Codebase Analysis

### 2.1 Project Stats

| Metric | Value |
|--------|-------|
| Total Dart LOC | ~9,534 |
| Number of Dart files | 52 |
| Largest file | `home_page.dart` (710 LOC) |
| Domain entities | 6 (ChatMessage, ChatSession, Provider, Project, Session, Message, AppInfo) |
| Use cases | 9 |
| Providers (state) | 3 (AppProvider, ChatProvider, ProjectProvider) |
| Pages | 3 (ChatPage, ServerSettingsPage, HomePage) |
| Widgets | 3 (ChatMessageWidget, ChatInputWidget, ChatSessionList) |
| Data sources | 4 (remote + local) |
| Repository impls | 3 |
| Models | 7 (+ generated `.g.dart` files) |
| Test files | 1 (default template, no real tests) |
| Target platforms | Android, Web (no iOS config) |

### 2.2 Architecture

```
Clean Architecture (Domain → Data → Presentation)
├── core/          — Constants, DI, Errors, Network
├── data/          — DataSources, Models, Repository impls
├── domain/        — Entities, Repository interfaces, UseCases
└── presentation/  — Pages, Providers, Widgets, Theme
```

### 2.3 Key Technical Features

1. **SSE (Server-Sent Events) streaming** — Custom implementation in `chat_remote_datasource.dart` using Dio + manual SSE parsing for real-time AI response streaming
2. **Clean Architecture** — Strict layer separation with Either monads (dartz) for error handling
3. **Provider state management** — ChangeNotifier-based with manual state enums
4. **Dependency injection** — GetIt service locator
5. **JSON serialization** — json_serializable + build_runner code generation
6. **Markdown rendering** — flutter_markdown for AI response display
7. **Code syntax highlighting** — flutter_highlight
8. **Local persistence** — SharedPreferences for settings, session cache, auth config
9. **HTTP client** — Dio with interceptors, Basic Auth, configurable base URL
10. **Dark theme** — Material Design 3 with custom AI-themed color scheme

### 2.4 Current Pain Points

| Issue | Severity | Description |
|-------|----------|-------------|
| **No real tests** | 🔴 High | Single default widget test that doesn't match the app. Zero unit/integration test coverage. |
| **Mixed language comments** | 🟡 Medium | Chinese + English comments throughout, maintenance overhead |
| **Stubbed features** | 🟡 Medium | File picker, camera, rename session — all show "coming soon" |
| **No iOS configuration** | 🟡 Medium | iOS build not set up despite being a cross-platform framework |
| **Large widget files** | 🟡 Medium | `home_page.dart` (710 LOC), `chat_message_widget.dart` (612 LOC) — should be decomposed |
| **Verbose error handling** | 🟠 Low-Med | Repetitive try/catch + Either pattern in every repository method |
| **No CI/CD** | 🟡 Medium | No GitHub Actions, no automated builds or tests |
| **Hardcoded defaults** | 🟠 Low | Provider/model fallbacks hardcoded in ChatProvider |
| **Deprecated APIs** | 🟠 Low | Uses `withOpacity()` (deprecated in Flutter 3.27+) in many places |
| **No navigation system** | 🟡 Medium | Manual `Navigator.push` instead of declarative routing |

---

## 3. Framework Evaluation

### 3.1 Option A: Expo (React Native + TypeScript)

**Stack:** Expo SDK 55+ · React Native 0.76+ · TypeScript · Expo Router · Zustand

| Criterion | Rating | Notes |
|-----------|--------|-------|
| **SSE Support** | ⚠️ Medium | `react-native-sse` library (361★, 783 dependents) OR Vercel AI SDK Expo integration (SDK 52+) |
| **Developer Velocity** | ✅ High | JS/TS ecosystem, hot reload, Expo OTA updates, larger hiring pool |
| **AI Chat Patterns** | ✅ High | Vercel AI SDK `useChat` hook provides turnkey streaming chat UI patterns |
| **Web Support** | ✅ High | Expo Router provides universal deep linking + web out of the box |
| **Native Feel** | ✅ Good | New Architecture (Fabric + JSI) default since RN 0.76, bridgeless |
| **iOS Support** | ✅ High | EAS Build handles iOS provisioning; no manual Xcode setup needed |
| **State Management** | ✅ High | Zustand (minimal boilerplate) or Jotai (atomic) — both excellent |
| **Markdown Rendering** | ✅ Good | `react-native-markdown-display` or `@ronradtke/react-native-markdown-display` |
| **Code Highlighting** | ✅ Good | `react-native-syntax-highlighter` or webview-based solutions |
| **Local Storage** | ✅ High | `expo-secure-store` (encrypted) + `@react-native-async-storage/async-storage` |
| **DI Pattern** | ✅ Good | No formal DI needed — React context + hooks replace GetIt naturally |
| **HTTP Client** | ✅ High | `axios` or `expo/fetch` (built-in, streaming-capable since SDK 52) |
| **Navigation** | ✅ High | Expo Router v4+ — file-based routing with typed routes, deep linking |
| **OTA Updates** | ✅ High | EAS Update — push JS bundles without app store review |
| **Binary Size** | ⚠️ Medium | Larger than Flutter (~20MB iOS, ~25MB Android for Expo) |
| **Performance** | ✅ Good | Adequate for chat app; New Architecture + Hermes engine competitive |
| **Maturity** | ✅ High | 83% of SDK 54 EAS Build projects use New Architecture (Jan 2026) |

### 3.2 Option B: Capacitor (Ionic)

**Stack:** Capacitor 6+ · React/Vue/Angular · TypeScript · Next.js optional

| Criterion | Rating | Notes |
|-----------|--------|-------|
| **SSE Support** | ✅ High | Native browser EventSource API works in WebView |
| **Native Feel** | ❌ Low | WebView-based, doesn't feel truly native |
| **Performance** | ❌ Low | WebView rendering significantly slower than RN/Flutter |
| **AI Chat UX** | ⚠️ Medium | Scrolling, keyboard handling, and animations subpar in WebView |
| **Code Reuse** | ✅ High | Can share 100% of web code if Next.js app exists |
| **Verdict** | ❌ Not recommended | WebView approach unsuitable for real-time streaming chat UX |

### 3.3 Option C: Solito (Next.js + Expo unified)

**Stack:** Solito · Next.js · Expo · TypeScript

| Criterion | Rating | Notes |
|-----------|--------|-------|
| **Web+Native unification** | ✅ High | Single codebase for web and native with platform-specific rendering |
| **Complexity** | ⚠️ Medium | Adds monorepo complexity, two build pipelines |
| **Maturity** | ⚠️ Medium | Smaller community, fewer examples |
| **Verdict** | ⚠️ Consider later | Over-engineering for current scope. Revisit if web app becomes a priority. |

### 3.4 Option D: Tauri Mobile

**Stack:** Tauri 2.0 · Rust · Web frontend

| Criterion | Rating | Notes |
|-----------|--------|-------|
| **Binary Size** | ✅ High | Extremely small binaries |
| **Maturity** | ❌ Low | Mobile support still experimental |
| **Ecosystem** | ❌ Low | Very few mobile-ready plugins |
| **Verdict** | ❌ Not recommended | Too early for mobile. Interesting for future desktop companion. |

### 3.5 Option E: Stay on Flutter (Modernize)

**Stack:** Flutter 3.29+ · Dart 3.8+ · Riverpod · go_router · Freezed

| Criterion | Rating | Notes |
|-----------|--------|-------|
| **Zero migration cost** | ✅ High | No rewrite needed |
| **SSE Support** | ✅ High | Already implemented and working |
| **Performance** | ✅ High | Best-in-class for chat UI, smooth scrolling, fast rendering |
| **Modernization effort** | ⚠️ Medium | Provider→Riverpod, Navigator→go_router, manual JSON→Freezed |
| **Hiring pool** | ⚠️ Medium | Smaller than JS/TS, but growing |
| **OTA Updates** | ❌ None | No equivalent to Expo OTA (requires full app store submission) |

---

## 4. Feature-to-Feature Dependency Mapping

### Flutter → Expo/React Native

| Flutter Dependency | Version | Expo/RN Equivalent | Maturity | Notes |
|--------------------|---------|-------------------|----------|-------|
| `provider` | ^6.1.1 | `zustand` ^5.x | ✅ Mature | Simpler API, less boilerplate, built-in devtools |
| `dio` | ^5.4.0 | `axios` ^1.x or `expo/fetch` | ✅ Mature | expo/fetch supports streaming (SDK 52+) |
| `shared_preferences` | ^2.2.2 | `@react-native-async-storage/async-storage` + `expo-secure-store` | ✅ Mature | SecureStore for auth credentials |
| `flutter_markdown` | ^0.6.18 | `react-native-markdown-display` ^1.x | ✅ Good | Alternative: `rn-markdown` |
| `flutter_highlight` | ^0.7.0 | `react-native-syntax-highlighter` or `highlight.js` + WebView | ⚠️ OK | WebView-based approach more reliable for complex highlighting |
| `file_picker` | ^8.1.2 | `expo-document-picker` + `expo-image-picker` | ✅ Mature | Better: native Expo modules |
| `url_launcher` | ^6.2.2 | `expo-linking` | ✅ Mature | Built-in |
| `package_info_plus` | ^4.2.0 | `expo-application` | ✅ Mature | Built-in |
| `json_annotation` + `json_serializable` | ^6.7.1 | `zod` ^3.x | ✅ Mature | Runtime validation > code generation |
| `equatable` | ^2.0.5 | Built-in TS equality / `fast-deep-equal` | ✅ Simple | Native TS structural equality |
| `dartz` | ^0.10.1 | `neverthrow` ^8.x or `fp-ts` ^2.x | ✅ Mature | `neverthrow` is more idiomatic in TS |
| `get_it` | ^7.6.4 | React Context + custom hooks | ✅ Native | No library needed in React ecosystem |
| `flutter_lints` | ^5.0.0 | `eslint` + `@typescript-eslint` + `prettier` | ✅ Mature | Industry standard |
| `build_runner` | ^2.4.7 | `zod` (runtime) or `tsc` (compile) | ✅ Better | No code-gen step needed |
| `flutter_launcher_icons` | ^0.13.1 | `expo-prebuild` config | ✅ Mature | Built into Expo |

### Custom SSE Implementation → RN

| Current (Flutter) | Expo/RN Approach | Notes |
|-------------------|------------------|-------|
| Custom SSE parser in `chat_remote_datasource.dart` (~100 LOC) | `react-native-sse` library OR `expo/fetch` + custom parser | The `react-native-sse` library (361★, MIT) handles SSE natively. Vercel AI SDK's `useChat` hook abstracts streaming entirely for Expo SDK 52+. |

---

## 5. Risk Assessment

### 5.1 Migration Risks (Flutter → Expo)

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **SSE streaming reliability** | Medium | High | Use Vercel AI SDK `useChat` (Expo-supported); fallback to `react-native-sse`; worst case: custom TurboModule |
| **Markdown + code highlight fidelity** | Low | Medium | WebView-based rendering as fallback; `react-native-markdown-display` covers most cases |
| **Feature parity gaps** | Low | Medium | Stubbed features (file picker, camera) have mature Expo equivalents (`expo-document-picker`, `expo-image-picker`, `expo-camera`) |
| **Performance regression** | Low | Low-Med | Chat apps are not GPU-intensive; RN New Architecture + Hermes is competitive |
| **Learning curve** | Medium | Low | TypeScript is widely known; Expo patterns are well-documented |
| **Migration timeline overrun** | Medium | Medium | Incremental migration possible; parallel development with Expo |
| **Lost domain logic** | Low | High | Port domain layer carefully; add unit tests first |

### 5.2 Staying-on-Flutter Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Talent scarcity** | Medium | Medium | Dart/Flutter developers are fewer than JS/TS; document code well |
| **No OTA updates** | High | Medium | Must submit app store updates for every change |
| **Deprecated APIs accumulation** | High | Low-Med | `withOpacity()` already deprecated; proactive updates needed |
| **Test debt** | High | High | Zero test coverage is a ticking time bomb |
| **Stagnation** | Medium | Medium | Flutter ecosystem growing but slower than RN |

---

## 6. Recommendation

### Primary Recommendation: **Expo (React Native) Rewrite**

**Rationale:**

1. **Codebase is small enough** (~9,500 LOC) that a rewrite is cost-effective. The domain layer maps nearly 1:1 to TypeScript.
2. **Vercel AI SDK Expo support** (since SDK 52) de-risks the hardest part — AI chat streaming. The `useChat` hook provides production-ready streaming chat patterns.
3. **Expo ecosystem is mature** — SDK 55+ with New Architecture default, EAS Build/Update/Submit, Expo Router v4+, and comprehensive native module coverage.
4. **Developer velocity** — TypeScript/React ecosystem, faster hiring, OTA updates, EAS Build CI/CD.
5. **iOS support** — EAS Build handles provisioning; no manual Xcode configuration needed.
6. **Future-proof** — Solito (Next.js + Expo) path available if web app becomes needed.

### Secondary Recommendation: **Flutter Modernization** (if team is Dart-first)

If the team strongly prefers Dart or has significant Flutter expertise, modernizing the existing codebase is the pragmatic choice. The improvements in Section 8 address all pain points without migration risk.

---

## 7. Migration Plan: Option A — Expo Rewrite

### 7.1 Target Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **Framework** | Expo SDK 55+ | Latest stable, New Architecture default |
| **Language** | TypeScript 5.x | Type safety, ecosystem compatibility |
| **Routing** | Expo Router v4+ | File-based routing, deep linking, web support |
| **State** | Zustand 5.x | Minimal boilerplate, excellent DX, built-in devtools |
| **HTTP** | `expo/fetch` + `axios` | Streaming support + interceptor pattern |
| **SSE/Streaming** | Vercel AI SDK (`useChat`) | First-class Expo support since SDK 52 |
| **Validation** | Zod 3.x | Runtime + compile-time type safety |
| **Error Handling** | `neverthrow` | Result type pattern (same as dartz Either) |
| **Local Storage** | `expo-secure-store` + `AsyncStorage` | Encrypted credentials + general storage |
| **Markdown** | `react-native-markdown-display` | Mature, customizable |
| **Syntax Highlight** | `react-native-syntax-highlighter` | Based on `highlight.js` |
| **Styling** | NativeWind v4 (Tailwind) | Familiar for web devs, performant |
| **Linting** | ESLint + Prettier | Industry standard |
| **Testing** | Jest + React Native Testing Library | Comprehensive unit + integration |
| **CI/CD** | EAS Build + EAS Update | OTA updates, automated builds |
| **DI** | React Context + custom hooks | No library needed |

### 7.2 Project Structure

```
openmode-expo/
├── app/                          # Expo Router (file-based routing)
│   ├── _layout.tsx               # Root layout (providers, theme)
│   ├── index.tsx                 # Home / Chat list
│   ├── chat/
│   │   ├── [sessionId].tsx       # Chat session page (dynamic route)
│   │   └── new.tsx               # New chat creation
│   ├── settings/
│   │   └── server.tsx            # Server settings
│   └── +not-found.tsx            # 404 page
├── src/
│   ├── domain/
│   │   ├── entities/             # ChatMessage, Session, Provider, Project, etc.
│   │   ├── repositories/         # Repository interfaces
│   │   └── usecases/             # Business use cases
│   ├── data/
│   │   ├── datasources/          # API client, local storage
│   │   ├── models/               # Zod schemas + mappers
│   │   └── repositories/         # Repository implementations
│   ├── infrastructure/
│   │   ├── api/                  # OpenCode API client (axios/fetch)
│   │   ├── storage/              # SecureStore + AsyncStorage wrappers
│   │   └── sse/                  # SSE client (Vercel AI SDK or react-native-sse)
│   ├── presentation/
│   │   ├── components/           # Reusable UI components
│   │   │   ├── ChatMessage.tsx
│   │   │   ├── ChatInput.tsx
│   │   │   ├── SessionList.tsx
│   │   │   ├── MarkdownRenderer.tsx
│   │   │   └── ThinkingIndicator.tsx
│   │   ├── hooks/                # Custom React hooks
│   │   │   ├── useChat.ts        # Chat session hook (wraps Vercel AI SDK)
│   │   │   ├── useServerConfig.ts
│   │   │   └── useProviders.ts
│   │   ├── stores/               # Zustand stores
│   │   │   ├── chatStore.ts
│   │   │   ├── appStore.ts
│   │   │   └── settingsStore.ts
│   │   └── theme/                # Theme configuration
│   │       ├── colors.ts         # AI-themed color palette (port from Flutter)
│   │       ├── typography.ts
│   │       └── index.ts
│   └── shared/
│       ├── errors/               # Error types (neverthrow Result)
│       ├── constants/            # App/API constants
│       └── utils/                # Utility functions
├── __tests__/                    # Test files
│   ├── domain/
│   ├── data/
│   └── presentation/
├── app.json                      # Expo config
├── eas.json                      # EAS Build config
├── tsconfig.json
├── package.json
└── README.md
```

### 7.3 Migration Phases

#### Phase 1: Foundation (Week 1-2)

| Task | Details | Est. Hours |
|------|---------|-----------|
| Initialize Expo project | `npx create-expo-app@latest openmode-expo --template tabs` with SDK 55+ | 2h |
| Configure TypeScript | Strict mode, path aliases (`@domain/`, `@data/`, etc.) | 2h |
| Set up Expo Router | File-based routing structure, root layout with theme provider | 4h |
| Port domain entities | Translate Dart entities to TS interfaces + Zod schemas | 6h |
| Set up error types | Port Failure hierarchy to `neverthrow` Result type | 3h |
| Port constants | API constants, app constants | 1h |
| Configure NativeWind | Tailwind-based styling with custom AI theme | 4h |
| Set up ESLint + Prettier | Code quality tooling | 1h |
| Configure Jest | Testing infrastructure | 2h |
| **Total** | | **25h** |

#### Phase 2: Data Layer (Week 2-3)

| Task | Details | Est. Hours |
|------|---------|-----------|
| Create API client | Axios instance with interceptors, auth, base URL config | 4h |
| Implement SSE client | Integrate `react-native-sse` or Vercel AI SDK transport | 8h |
| Port local storage | SecureStore for auth, AsyncStorage for settings/cache | 3h |
| Port data models | Zod schemas for all API request/response types | 6h |
| Implement repositories | Repository pattern with neverthrow Result returns | 8h |
| Port use cases | Translate each Dart use case to TS function/class | 4h |
| Write data layer tests | Unit tests for repositories, models, datasources | 6h |
| **Total** | | **39h** |

#### Phase 3: Presentation Layer (Week 3-5)

| Task | Details | Est. Hours |
|------|---------|-----------|
| Create Zustand stores | App store, chat store, settings store | 6h |
| Build ChatPage | Main chat UI with streaming message display | 12h |
| Build ChatMessage component | Markdown rendering, code highlighting, tool call display | 8h |
| Build ChatInput component | Text input, attachment options, send button | 4h |
| Build SessionList component | Session drawer/list with swipe actions | 4h |
| Build ServerSettings page | Host/port config, auth toggle, connection test | 4h |
| Build HomePage | Feature grid, connection status indicator | 4h |
| Port theme | AI-themed dark mode color scheme, Material You tokens | 3h |
| Implement smart scroll | Auto-scroll on new messages (near-bottom detection) | 2h |
| Wire up streaming | Connect Vercel AI SDK useChat or custom SSE hook to UI | 6h |
| Write component tests | React Native Testing Library tests | 4h |
| **Total** | | **57h** |

#### Phase 4: Polish & Ship (Week 5-6)

| Task | Details | Est. Hours |
|------|---------|-----------|
| iOS configuration | EAS Build iOS provisioning, TestFlight | 4h |
| Android configuration | Keystore, signing, Play Store prep | 2h |
| EAS Build pipeline | CI/CD setup with `eas.json` | 4h |
| EAS Update setup | OTA update channel configuration | 2h |
| App icons + splash | `expo-prebuild` config for launcher icons | 2h |
| Accessibility | Screen reader support, semantic labels | 4h |
| Error boundaries | Global error handling, crash reporting | 3h |
| Performance audit | FlashList for large message lists, memo optimization | 4h |
| End-to-end testing | Manual testing on iOS + Android devices | 6h |
| Documentation | README, contributing guide, architecture docs | 3h |
| **Total** | | **34h** |

### 7.4 Total Estimated Effort

| Phase | Hours | Weeks (1 dev, 30h/week) |
|-------|-------|------------------------|
| Phase 1: Foundation | 25h | 0.8 weeks |
| Phase 2: Data Layer | 39h | 1.3 weeks |
| Phase 3: Presentation | 57h | 1.9 weeks |
| Phase 4: Polish & Ship | 34h | 1.1 weeks |
| **Total** | **155h** | **~5.2 weeks** |

With 2 developers working in parallel (Phase 1 sequential, Phase 2-3 parallelizable by layer):
**~3-4 weeks** elapsed time.

---

## 8. Migration Plan: Option B — Flutter Modernization

If staying on Flutter, these are the priority improvements, ordered by impact:

### 8.1 Critical Fixes (Week 1-2)

| Priority | Task | Details |
|----------|------|---------|
| 🔴 P0 | Add unit tests | Test all use cases, repositories, providers. Target 60%+ coverage. |
| 🔴 P0 | Fix widget test | Replace default counter test with actual app smoke test |
| 🔴 P0 | Replace `withOpacity()` | Use `Color.withValues(alpha:)` (Flutter 3.27+ API) — affects ~30+ locations |
| 🔴 P0 | Add go_router | Replace manual `Navigator.push` with declarative routing |

### 8.2 Architecture Modernization (Week 2-4)

| Priority | Task | Details |
|----------|------|---------|
| 🟡 P1 | Migrate Provider → Riverpod 2.x | Type-safe, compile-time checked, auto-dispose, family patterns |
| 🟡 P1 | Migrate GetIt → Riverpod providers | Use Riverpod's provider system for DI (eliminates service locator antipattern) |
| 🟡 P1 | Migrate json_serializable → Freezed | Immutable data classes, copyWith, union types, pattern matching |
| 🟡 P1 | Add integration tests | Test critical user flows (send message, create session, settings) |
| 🟠 P2 | Decompose large widgets | Split `home_page.dart` (710 LOC), `chat_message_widget.dart` (612 LOC) into smaller components |
| 🟠 P2 | Unify language | Translate all Chinese comments to English for consistency |
| 🟠 P2 | Add error reporting | Integrate Sentry or Crashlytics |

### 8.3 Feature Completion (Week 4-6)

| Priority | Task | Details |
|----------|------|---------|
| 🟡 P1 | Implement file picker | Use `file_picker` package (already a dependency) — wire up to API |
| 🟡 P1 | Implement image picker | Use `image_picker` package for camera/gallery |
| 🟠 P2 | Implement session rename | Wire up rename dialog to `updateSession` API |
| 🟠 P2 | Implement session share/unshare | Wire up to existing `shareSession`/`unshareSession` API |
| 🟢 P3 | Add iOS configuration | Xcode project setup, CocoaPods, signing config |
| 🟢 P3 | Add CI/CD | GitHub Actions for test, build, deploy |
| 🟢 P3 | Add light theme | Complete the light theme (currently marked "not recommended") |

### 8.4 Modern Dependencies

| Current | Upgrade To | Reason |
|---------|-----------|--------|
| `provider` ^6.1.1 | `flutter_riverpod` ^2.5+ | Type-safe, auto-dispose, testable |
| `get_it` ^7.6.4 | Riverpod providers | Eliminates service locator antipattern |
| `json_serializable` | `freezed` + `freezed_annotation` | Immutable models, union types, copyWith |
| `dartz` ^0.10.1 | `fpdart` ^1.x or Riverpod's `AsyncValue` | Better Dart 3 support, maintained |
| `flutter_lints` | `very_good_analysis` | Stricter, industry-standard lint rules |
| Manual `Navigator.push` | `go_router` ^14.x | Declarative routing, deep linking, type-safe |

### 8.5 Estimated Effort

| Phase | Weeks |
|-------|-------|
| Critical Fixes | 1-2 weeks |
| Architecture Modernization | 2-3 weeks |
| Feature Completion | 2-3 weeks |
| **Total** | **5-8 weeks** |

---

## 9. Effort & Timeline Estimates

### Side-by-Side Comparison

| Factor | Expo Rewrite | Flutter Modernization |
|--------|-------------|----------------------|
| **Total effort** | ~155 hours (5.2 weeks) | ~5-8 weeks |
| **Elapsed time (2 devs)** | 3-4 weeks | 4-6 weeks |
| **Risk level** | Medium (SSE is key risk) | Low (incremental improvements) |
| **Test coverage outcome** | High (built into process) | High (P0 priority) |
| **New capabilities** | OTA updates, EAS CI/CD, iOS support, web path | Better architecture, more tests |
| **Long-term velocity** | Higher (TS ecosystem, hiring) | Moderate (Dart ecosystem) |
| **Performance** | Good (adequate for chat) | Excellent (Flutter's strength) |
| **Binary size** | ~20-25 MB | ~15-18 MB |
| **Startup time** | ~33ms TTFF (iOS) | ~17ms TTFF (iOS) |

---

## 10. Decision Matrix

| Criterion | Weight | Expo (RN) | Flutter Modernize | Capacitor | Stay As-Is |
|-----------|--------|-----------|-------------------|-----------|------------|
| Developer velocity | 20% | 9 | 7 | 6 | 4 |
| Performance | 15% | 7 | 9 | 4 | 8 |
| SSE/streaming | 15% | 7 | 9 | 8 | 9 |
| Hiring pool | 10% | 9 | 5 | 7 | 5 |
| OTA updates | 10% | 10 | 2 | 6 | 0 |
| Test coverage fix | 10% | 9 | 8 | 5 | 1 |
| iOS support ease | 5% | 9 | 5 | 7 | 2 |
| Migration risk | 10% | 6 | 8 | 4 | 10 |
| Ecosystem maturity | 5% | 9 | 8 | 6 | 8 |
| **Weighted Score** | **100%** | **8.15** | **7.00** | **5.55** | **5.15** |

### Final Rankings

1. 🥇 **Expo (React Native)** — 8.15/10 — Best long-term choice for TS-fluent teams
2. 🥈 **Flutter Modernization** — 7.00/10 — Safest, fastest to show results, best performance
3. 🥉 **Capacitor** — 5.55/10 — WebView limitations make it unsuitable for this app type
4. ❌ **Stay As-Is** — 5.15/10 — Technical debt will compound; not sustainable

---

## Appendix A: Key Code Translation Examples

### A1: Domain Entity (Dart → TypeScript)

**Before (Dart):**
```dart
class ChatSession extends Equatable {
  final String id;
  final String? title;
  final DateTime time;
  final bool shared;
  final String? summary;
  // ... props override
}
```

**After (TypeScript + Zod):**
```typescript
export const ChatSessionSchema = z.object({
  id: z.string(),
  title: z.string().nullable(),
  time: z.date(),
  shared: z.boolean().default(false),
  summary: z.string().nullable(),
});
export type ChatSession = z.infer<typeof ChatSessionSchema>;
```

### A2: Use Case (Dart → TypeScript)

**Before (Dart):**
```dart
class GetChatSessions {
  final ChatRepository repository;
  const GetChatSessions(this.repository);
  Future<Either<Failure, List<ChatSession>>> call() {
    return repository.getSessions();
  }
}
```

**After (TypeScript + neverthrow):**
```typescript
export const getChatSessions = (
  repository: ChatRepository
): ResultAsync<ChatSession[], AppError> => {
  return repository.getSessions();
};
```

### A3: State Management (Provider → Zustand)

**Before (Dart Provider):**
```dart
class ChatProvider extends ChangeNotifier {
  ChatState _state = ChatState.initial;
  List<ChatSession> _sessions = [];
  // ... 50+ lines of state + methods
}
```

**After (Zustand):**
```typescript
interface ChatStore {
  state: 'initial' | 'loading' | 'loaded' | 'error' | 'sending';
  sessions: ChatSession[];
  currentSession: ChatSession | null;
  messages: ChatMessage[];
  // actions
  loadSessions: () => Promise<void>;
  selectSession: (session: ChatSession) => Promise<void>;
  sendMessage: (text: string) => Promise<void>;
}

export const useChatStore = create<ChatStore>()(
  devtools((set, get) => ({
    state: 'initial',
    sessions: [],
    currentSession: null,
    messages: [],
    loadSessions: async () => {
      set({ state: 'loading' });
      const result = await chatRepository.getSessions();
      result.match(
        (sessions) => set({ sessions, state: 'loaded' }),
        (error) => set({ state: 'error' })
      );
    },
    // ... other actions
  }))
);
```

### A4: SSE Streaming (Custom Dio → Vercel AI SDK)

**Before (Flutter custom SSE):**
```dart
// ~100 lines of custom SSE parsing with Dio + StreamController
Stream<ChatMessageModel> sendMessage(...) async* {
  // 1. Connect to /event SSE endpoint
  // 2. Parse events manually
  // 3. Fetch complete message on each event
  // 4. Yield messages through StreamController
}
```

**After (Vercel AI SDK + Expo):**
```typescript
import { useChat } from 'ai/react';

function ChatPage() {
  const { messages, input, handleInputChange, handleSubmit } = useChat({
    api: `${serverUrl}/session/${sessionId}/message`,
    body: { providerId, modelId },
  });
  
  // Vercel AI SDK handles SSE parsing, message accumulation, and streaming
  // Just render messages and handle input
}
```

---

## Appendix B: Vercel AI SDK Expo Compatibility Notes

The Vercel AI SDK (`ai` package) has had first-class Expo support since SDK 52:

- Uses `expo/fetch` for streaming responses (replaces native `fetch`)
- `useChat` hook works natively in Expo with `react-native-sse` under the hood
- Supports custom transport adapters for non-OpenAI-compatible APIs
- **Important:** OpenCode API is NOT OpenAI-compatible, so a custom Transport adapter will be needed to map OpenCode's SSE format to Vercel AI SDK's expected format. This is ~50-100 LOC of adapter code.

If the custom transport proves too complex, fall back to `react-native-sse` directly with manual message state management (closer to the current Flutter approach).

---

## Appendix C: Expo New Architecture Compatibility

As of January 2026, **83% of SDK 54 EAS Build projects** use the New Architecture. Key implications:

- All Expo Modules API native modules support New Architecture by default
- `react-native-sse` is a JS-only library (no native code) — fully compatible
- Fabric renderer provides smoother UI than old bridge architecture
- TurboModules enable faster JSI-based native module communication
- Hermes engine (default) provides good startup time and memory efficiency

---

*End of Spec*