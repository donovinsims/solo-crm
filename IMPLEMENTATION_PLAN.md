# Relay — Implementation Plan
## Parallel Sub-Agent Build Toward "Exemplary iOS" Parity

**App**: Relay (solo-crm) — Donovin's personal Client Operations / Business OS
**Philosophy**: Audit → Optimize → Automate · Full screens to understand, bottom sheets to do
**Design Benchmark**: [Exemplary iOS Apps — Shared Design Doctrine & Pattern Library](../../.opencode/skills/swiftui-design-skill/references/Exemplary%20iOS%20Apps%20—%20Shared%20Design%20Doctrine%20&%20Pattern%20Library.md)
**Toolchain**: Xcode 26.6 · iOS 26 deployment target · SwiftUI · `@Observable` AppStore

> **Target outcome**: Relay feels like Fabric, Brainbits, Linear, Things, Paste, Avec, and Grok Bot — *calm, structured, immediate, native, information-rich without clutter, powerful without exposing complexity.* All seven reference apps contribute a transferable *principle*; none are cloned.

---

## How This Plan Runs

This plan is designed for **parallel execution using sub-agents** (the `Task` tool with `subagent_type`). Each workstream:

- Is **file-ownership isolated** so streams do not step on each other (see **Conflict Map** below).
- Delegates to the appropriate sub-agent type and loads the matching project-local skill.
- Ends with **verification** (a clean build + a design-review score) before merging.

### Agent types available
| Agent | Best for | Used in |
|-------|----------|---------|
| `explorer` | Bounded local code/config search with evidence | WS-0 (audit), any pre-flight |
| `fixer` | Bounded mechanical implementation with file ownership + verification | WS-1, WS-2, WS-3, WS-4, WS-5 |
| `designer` | Visual/product judgment; returns implementable recommendations | WS-6 (design direction), design review gate |
| `librarian` | External documentation/web research with source links | WS-5 (Twenty CRM API), WS-7 (App Intents docs) |
| `observer` | Media inspection & factual visual extraction | Screenshot QA gate |
| `oracle` | Consequential architecture / final review (advisory, read-only) | Merge gate before commit |

### Skills to load per workstream (slash-command style)
| Skill | Applied to |
|-------|-----------|
| `engineering-workflow` | Every stream — execution discipline, minimal diffs, verification |
| `swiftui-design-skill` | WS-1, WS-6 — design tokens, anti-AI-slop, 5-dimension review |
| `swiftui-ui-patterns` | WS-1, WS-2, WS-3 — component patterns, sheets, navigation, async state |
| `swiftui-view-refactor` | WS-1, WS-6 — splitting views, Observation ownership, MV-data flow |
| `swiftui-liquid-glass` | WS-6 — iOS 26 glass surfaces (chips, capture bottom bar) |
| `ios-app-intents` | WS-7 — App Shortcuts, Siri, widget surface |
| `ios-debugger-agent` + `xcodebuildmcp` | WS-8 — build, run, simulator UI/QA |
| `ios-simulator-browser` | WS-8 — browser-visible simulator proof |
| `ios-ettrace-performance` | WS-8 — focused profiler evidence on the capture flow |
| `ios-memgraph-leaks` | WS-8 — leak proof on capture/dismiss flows |
| `swiftui-performance-audit` | WS-8 — code-first perf review of list screens |
| `better-accessibility` | WS-2 — VoiceOver, rotor, Dynamic Type, keyboard |
| `better-interface` | Design-review gate — holistic cross-discipline audit |

---

## Ground Rules for Every Sub-Agent

1. **Load `engineering-workflow` first.** Apply correctness > speed, minimal diffs, and verify-before-declaring-done.
2. **Do not touch the `.xcodeproj` or `build/`** unless a stream explicitly owns that (WS-8 only). `Project.json` and `App/` are the source of authority.
3. **Design tokens first, hard-coded values never.** Introduce `App/DesignTokens.swift` (WS-1) *before* any visual polish stream (WS-6) starts, so later streams consume tokens rather than inventing local values.
4. **Load the matching skill and follow it literally** — e.g. `swiftui-ui-patterns` sheet rules, `swiftui-design-skill` anti-slop rules.
5. **Every stream ends with a clean build** (`xcodebuild -scheme Relay -destination 'generic/platform=iOS Simulator' build`) before its result counts as done.
6. **Commit only at the explicit merge gate (Step 9).** Streams leave changes on disk / on a named worktree; they do not commit.
7. **Stay in scope.** A stream may not refactor a screen it does not own. Route cross-cutting refactors through WS-1/WS-6 or flag for the orchestrator.

---

## Conflict Map (Who Owns What File)

| Stream | Files it may create/modify |
|--------|---------------------------|
| **WS-1 Design System Foundation** | `App/DesignTokens.swift` (new), `App/Components/*` (the 6 shared components) |
| **WS-2 Accessibility & States** | `App/Components/*`, `App/Screens/*` (adds empty/error/loading overlays + a11y), `App/Sheets/*` |
| **WS-3 Persistence (SwiftData)** | `App/Store/AppStore.swift`, `App/Models/*` (add `@Model`), new `App/Store/Persistence.swift` |
| **WS-4 Finding→Project Pipeline + Command Search** | `App/Sheets/SearchSheet.swift`, `App/Screens/More/FindingsView.swift`, `App/Screens/More/MoreView.swift`, `App/Store/AppStore.swift` (new methods only) |
| **WS-5 Twenty CRM Sync** | new `App/Sync/` dir, `App/Store/AppStore.swift` (sync hooks only), `App/Info.plist` (network usage description) |
| **WS-6 Design Direction & Liquid Glass polish** | `App/Root/RootTabView.swift`, `App/Screens/*` (polish only), `App/Sheets/*` (polish only) — **after** WS-1 tokens exist |
| **WS-7 App Intents** | new `App/Intents/` dir, `App/App.swift` (shortcut provider wiring only) |
| **WS-8 Build/Run & QA gate** | `.xcodeproj` (simulator run only), temporary profiling wiring (removed after) |

> **Hard ordering constraints**: WS-1 must finish before WS-6. WS-3 must finish before WS-5. WS-2 and WS-4 can run in parallel with WS-1 (they mostly edit different files). WS-7 and WS-8 can start anytime. WS-8 is the final integration/QA gate.

---

## Workstream-by-Workstream

### WS-0 — Preflight Audit (orchestrator or `explorer`)
- Confirm current screen inventory, bundle id, scheme name, deployment target.
- Confirm `Project.json` is the source of truth (Xcode project is XcodeGen-style, `SWIFT_VERSION 5.0`, target `Relay`, iOS 26).
- Produce the "as-is" file map. **Output**: a short findings note; no code changes.

---

### WS-1 — Design System Foundation *(Gate for WS-6)*
**Agent**: `fixer` · **Skill**: `swiftui-design-skill`, `swiftui-ui-patterns`

Build the shared visual language the whole app consumes:

1. **`App/DesignTokens.swift`** — a token file (per `swiftui-design-skill`):
   - Semantic colors as `Color` (warm neutral palette, custom accent — not default blue), light *and* dark adapt.
   - Spacing scale (4/8/12/16/20/24/32 — the values currently hard-coded as `16, 20, 26, 28` map to tokens).
   - Corner-radius scale (`8/14/18/28` → tokens).
   - Typography helpers (the existing `largeTitle.bold → body → caption` ladder codified).
2. Refactor the **6 shared components** (`ClientRow`, `FindingRow`, `TaskRow`, `SectionLabel`, `StatusDot`, `DueDateFormatting`) to consume tokens — validate all `#Preview`s render.
3. Add `brand-spec.md` under the skill's templates with the chosen palette + accent (source the accent intentionally, no purple-blue gradient).

**Definition of done**: a single token file; all 6 components consume it; `xcodebuild` clean; `swiftui-design-skill` validation checklist passes (no banned slop, 44pt targets, dark mode defined).

---

### WS-2 — Accessibility & State Completeness
**Agent**: `fixer` · **Skills**: `better-accessibility`, `swiftui-ui-patterns` (async-state, loading-placeholders)

Bring every list/sheet to production state completeness and accessibility parity:

1. **Empty states** on `ClientsListView`, `WorkView`, `FindingsView`, `MoneyView` — a calm, guiding empty view (not a blank list).
2. **Loading / error states** using `.task`/`.task(id:)` per `async-state.md` — skeleton placeholders in lists, a top-of-sheet inline error for save failures.
3. **Accessibility** per `better-accessibility`:
   - VoiceOver labels on all icon-only buttons (already partial — complete it).
   - `.accessibilityRotor` for swipe actions on `TaskRow` (complete/snooze/waiting) and `ClientRow` (call/message).
   - Dynamic Type sanity (verify with Large / Accessibility sizes).
   - Keyboard: full tab order through every sheet, `.submitLabel`, focus management.
   - `prefers-reduced-motion` respected for the capture pulse animation.
4. **Offline/disabled states** where relevant to a save action (grey + explain, not silent).

**Definition of done**: every list has a real empty state; no unlabeled icon-only control; `xcodebuild` clean; no accessibility warning in the console.

---

### WS-3 — Persistence (SwiftData)
**Agent**: `fixer` · **Skills**: `swiftui-view-refactor` (Observation ownership), `swiftui-ui-patterns`

Move from in-memory `AppStore` to durable on-device storage. Keep the `AppStore` API surface so no screen changes are required (deferral principle):

1. Convert `Client`, `ContactPerson`, `ClientProject`, `TaskItem`, `Finding`, `Decision`, `PaymentRecord`, `ActivityEvent`, `Note` to SwiftData `@Model` (iOS 17+; target is 26 so fully available).
2. Stand up `ModelContainer` + a `Persistence.swift` service. Keep `@Observable AppStore` as the in-memory facade that seeds from seed data on first launch and flushes through the model.
3. Preserve computed fields (`remaining`, lookups, aggregates) as non-persisted convenience.
4. Seed data migration: keep the sample Roscoe/Rockford clients as the initial dataset.

**Definition of done**: app persists across relaunch; all existing mutations (add task/note/finding/decision/payment, status change, toggle) survive; `xcodebuild` clean. **This is the gate for WS-5.**

---

### WS-4 — Finding→Project Pipeline + Command-Enabled Search
**Agent**: `fixer` · **Skills**: `swiftui-ui-patterns` (searchable, navigationstack, deeplinks), `swiftui-design-skill`

Two user-visible wins that directly serve Audit→Optimize→Automate:

1. **Finding → Optimization Opportunity → Project**: On `FindingRow` add a "Promote to project" action that creates a `ClientProject` from the finding (status `inProgress`), logs an `ActivityEvent` linking finding→project, and lets the user give it a name/phase. This closes the audit loop.
2. **True command palette search** (`SearchSheet`): "Search or do anything" becomes a first-class command surface — recent searches, and **actions as first-class results** (e.g. "Add task for Pietro's", "Record payment", "Call X") that dispatch into Quick Capture prefilled with the matched client. Follow `searchable.md` + `deeplinks.md` routing patterns.

**Definition of done**: a finding can become a project in ≤3 taps; `SearchSheet` returns actions alongside rich results; `xcodebuild` clean.

---

### WS-5 — Twenty CRM Backend Sync *(after WS-3)*
**Agent**: `librarian` (design) → `fixer` (implement) · **Skills**: `engineering-workflow`

Make Twenty CRM the durable source of truth without slowing the UI (doctrine §15: software should feel faster than its backend):

1. **Research phase (`librarian`)**: confirm the Twenty CRM public REST/GraphQL API + auth method; document the endpoint surface for clients/projects/tasks/findings/payments.
2. **Implement phase (`fixer`)**:
   - `App/Sync/TwentySyncEngine.swift` — background sync: push mutations, pull changes.
   - **Optimistic updates**: local mutation applies instantly, sync reconciles later; conflict resolution favors most-recent.
   - **Visible sync state**: a quiet status indicator (green Synced / amber Syncing / red Offline) + "last synced" — per doctrine §17 Trust.
   - Never fake success for payments (financially meaningful) — those require confirmed write before showing success.
3. Add `NSAppTransportSecurity`/network usage description to `Info.plist` as needed.

**Definition of done**: mutations survive relaunch locally *and* reach Twenty (or clearly report offline); sync status is visible; payments only succeed on confirmed write; `xcodebuild` clean.

---

### WS-6 — Design Direction, Signature Detail & Liquid Glass Polish *(after WS-1)*
**Agent**: `designer` (direction) → `fixer` (implement) · **Skills**: `swiftui-design-skill`, `swiftui-liquid-glass`, `swiftui-view-refactor`

The "delve-able delight" layer. Two optional-but-powerful iOS 26 moves plus a signature detail per screen:

1. **Design review first (`designer`)**: score the current screens on the 5-Dimension Review; identify the *one signature detail per screen* (doctrine §3, §21: one thing at 120%).
2. **Implement polish (`fixer`)**:
   - Refactor the largest screens (`TodayView`, `ClientDetailView`, `ProjectDetailView`) into small dedicated subview types per `swiftui-view-refactor` (they exceed the ~300-line guideline and mix layout+logic). Do **not** change behavior.
   - **Liquid Glass chipping** (`swiftui-liquid-glass`): glass treatment for the capture pill, status chips, and project link capsules — gated `#available(iOS 26, *)` with non-glass fallback (doctrine §4 native-first, §21 avoid glass-everywhere).
   - Apply the signature detail(s) chosen by the designer.
3. **Re-run the 5-Dimension Review** — every dimension ≥ 7, none below 5 (shipping threshold).

**Definition of done**: screens refactored into small views (no giant computed-`some View` screens); Liquid Glass present with fallback; design review avg ≥ 7; `xcodebuild` clean.

---

### WS-7 — App Intents & System Surfaces
**Agent**: `fixer` · **Skill**: `ios-app-intents`

Expose the highest-value verbs to Shortcuts/Siri/Spotlight (doctrine §6, §12 — capture beyond the app UI). Start narrow per `ios-app-intents`:

1. **One open-app intent**: "Open [client] in Relay" → routes to `ClientDetailView` (runtime handoff via the root router).
2. **One inline action intent**: "Add task to [client]" completing within the shortcut without opening the app.
3. **One entity**: `Client` as an `AppEntity` with an `EntityQuery` for disambiguation.
4. **`AppShortcutsProvider`** with task-oriented phrases + SF Symbols.
5. Wire a single predictable intent-routing surface into `RootTabView`/`ContentView`.

**Definition of done**: intents target compiles; opening the app routes to the right place; shortcuts phrases discoverable; `xcodebuild` clean.

---

### WS-8 — Build, Run & QA Gate *(final integration)*
**Agent**: orchestrator + `observer` · **Skills**: `ios-debugger-agent` (+`xcodebuildmcp`), `ios-simulator-browser`, `ios-ettrace-performance`, `swiftui-performance-audit`

The merge gate. Sequence:

1. **Build + run** on a booted simulator via `ios-debugger-agent` (`xcodebuildmcp`).
2. **UI QA**: walk Today → Clients → ClientDetail → ProjectDetail → Quick Capture (all stages) → Search → Findings → Money. Capture screenshots (`ios-simulator-browser` for proof).
3. **Focused perf** (`ios-ettrace-performance`) on the capture flow: Quick Capture open → save → dismiss. Report one clean trace.
4. **Leak check** (`ios-memgraph-leaks`) on the capture/dismiss and sheet open/close flows. Prove no app-owned leaks on the common paths.
5. **Code-first perf review** (`swiftui-performance-audit`) of the Now-scrolling list screens (Today, Clients) for invalidation storms / unstable identity.
6. **Design review re-run** (`better-interface` holistic audit) for the final cross-discipline pass.

**Definition of done**: all flows work on simulator; screenshots captured; capture-flow trace clean; no app-owned leaks; design audit green.

---

## Execution & Orchestration

### Recommended launch order (parallel where the Conflict Map allows)

```
Wave A (parallel):  WS-1 Design System  |  WS-2 A11y & States  |  WS-7 App Intents
Wave B (parallel):  WS-3 Persistence (needs nothing from A)   |  WS-4 Pipeline+Search
Wave C (parallel):  WS-6 Design Polish (after WS-1)           |  WS-5 Twenty Sync (after WS-3)
Wave D (gate):      WS-8 Build/Run/QA (all above)
```

Dispatch each as a separate `Task` call with the correct `subagent_type`, giving each stream:
- Its **file-ownership boundary** (from the Conflict Map).
- The **skills to load** and the exact reference file(s) to follow.
- Its **Definition of done** (verify with a clean `xcodebuild`).
- The instruction: **do not commit**, leave changes on disk.
- The instruction to **not touch** other streams' files.

### Merge gate (Step 9)
Before any commit:
1. Review the full diff across all streams (`oracle` for final advisory read of architecture + diff).
2. Resolve cross-stream touch points (WS-1 tokens consumed by WS-6; WS-3 persistence consumed by WS-5).
3. Only on **explicit user approval** run the commit(s) — match repo style, stage only intended files, never commit secrets (Twenty credentials stay in keychain/env, not source).

---

## Verification Checklist (run at the merge gate)

- [ ] `xcodebuild -scheme Relay -destination 'generic/platform=iOS Simulator' build` passes clean.
- [ ] App persists across relaunch (WS-3).
- [ ] Findings can promote to projects; Search returns actions (WS-4).
- [ ] Twenty sync shows green/amber/red status; payments never fake success (WS-5).
- [ ] Liquid Glass present with non-glass fallback; Design Tokens consumed everywhere (WS-1+6).
- [ ] All screens have empty/loading/error states (WS-2).
- [ ] App Intents compile; open/action intents route correctly (WS-7).
- [ ] Simulator screenshots captured (WS-8); capture-flow trace clean; no app-owned leaks.
- [ ] 5-Dimension Design Review avg ≥ 7 across key screens (WS-6).
- [ ] No unlabeled icon-only controls; Dynamic Type OK; reduced-motion respected (WS-2).
- [ ] No secrets committed (WS-5).

---

## Anti-Pattern Guardrails (from the Doctrines — keep visible while working)

- ❌ No purple-blue gradients, no glass-everywhere, no card-inside-card, no giant gradient CTAs.
- ❌ No mandatory-metadata capture — root capture stays "just type/speak it", organize later.
- ❌ No full-screen navigation for tiny contextual tasks — bottom sheets are the "doing" layer.
- ❌ No CRM-database terminology in everyday navigation (keep Today/Clients/Projects/Capture).
- ❌ No asking the user to experience backend latency the UI can safely absorb.
- ✅ Calm. Structured. Immediate. Native-feeling. Information-rich without clutter.

---

*Generated as the working orchestration plan for Relay. Each stream is independently verifiable; the merge gate is the only serialization point that requires human decision.*
