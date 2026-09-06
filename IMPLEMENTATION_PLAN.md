# Relay — Implementation Plan (Updated)
## Parallel Sub-Agent Build Toward "Exemplary iOS" Parity

**App**: Relay (solo-crm) — Donovin's personal Client Operations / Business OS
**Philosophy**: Audit → Optimize → Automate · Full screens to understand, bottom sheets to do
**Design Benchmark**: [Exemplary iOS Apps — Shared Design Doctrine & Pattern Library](../../.opencode/skills/swiftui-design-skill/references/Exemplary%20iOS%20Apps%20—%20Shared%20Design%20Doctrine%20&%20Pattern%20Library.md)
**Toolchain**: Xcode 26.6 · iOS 26 deployment target · SwiftUI · `@Observable` AppStore · SwiftData

---

## Current Status (as of commit `918a3c1` + local changes)

| Stream | Status | Key Deliverables |
|--------|--------|------------------|
| **WS-1: Design System** | ✅ **DONE** | `App/DesignTokens.swift` (terracotta accent `#E06C4A`), `brand-spec.md`, all 6 shared components refactored to tokens |
| **WS-2: Accessibility & States** | ✅ **DONE** | 10/10 sheets + 8/8 screens: empty/loading/error states, VoiceOver labels, rotor actions, Dynamic Type ready, reduced-motion respected |
| **WS-7: App Intents** | ✅ **DONE** | `AddTaskIntent` (inline), `OpenClientIntent` (open-app), `ClientEntity` + query, `RelayShortcuts` provider in `App/Intents/` |
| **WS-3: SwiftData Persistence** | 🔴 **BLOCKED** | Models converted to `@Model`, `Persistence.swift`, `AppStore` uses `@Query` + `ModelContext` — **circular relationship crash** |
| **WS-4: Finding→Project + Command Search** | 🟡 **90% DONE** | `PromoteFindingSheet`, `FindingRow` swipe action, `SearchSheet` as command palette — **missing `promoteFindingToProject` in AppStore** |

---

## The Blocker: SwiftData Circular Relationships

**Error**: SwiftData `@Relationship(inverse:)` macro creates circular references when *both* sides declare the inverse. Current models have bidirectional `@Relationship` on every pair (Client↔Tasks, ClientProject↔Tasks, Client↔Findings, ClientProject↔Findings, etc.).

**Fix Required**: Remove `inverse` from the **child side** (the optional single reference), keep it only on the **parent side** (the array). Pattern:

```swift
// PARENT (Client) — KEEP inverse
@Relationship(deleteRule: .cascade, inverse: \TaskItem.client)
var tasks: [TaskItem] = []

// CHILD (TaskItem) — REMOVE inverse
@Relationship var client: Client?
```

**Affected pairs** (8 total):
- Client.tasks ↔ TaskItem.client
- ClientProject.tasks ↔ TaskItem.project
- Client.findings ↔ Finding.client
- ClientProject.findings ↔ Finding.project
- Client.decisions ↔ Decision.client
- ClientProject.decisions ↔ Decision.project
- Client.payments ↔ PaymentRecord.client
- ClientProject.payments ↔ PaymentRecord.project
- Client.activity ↔ ActivityEvent.client
- ClientProject.activity ↔ ActivityEvent.project
- Client.notes ↔ Note.client

---

## Updated Wave Plan

### Wave B — Fix WS-3 + Complete WS-4 (PARALLEL)

| Stream | Agent | Dependencies | Files |
|--------|-------|--------------|-------|
| **WS-3-FIX** | `fixer` | None | All `App/Models/*.swift` (remove inverse from child sides) |
| **WS-4-COMPLETE** | `fixer` | None | `App/Store/AppStore.swift` (add `promoteFindingToProject`), `App/Screens/Work/ProjectDetailView.swift` (navigation after promote) |

**WS-3-FIX Definition of Done**:
- `xcodebuild` clean
- All models compile without circular reference errors
- App persists across simulator relaunch
- All existing mutations work identically

**WS-4-COMPLETE Definition of Done**:
- `promoteFindingToProject` method added to `AppStore`
- Finding → Promote → name/phase → save → lands in `ProjectDetailView` (≤3 taps)
- `SearchSheet` actions execute + dismiss correctly
- `xcodebuild` clean

---

### Wave C — WS-5 + WS-6 (PARALLEL, after Wave B)

| Stream | Agent | Dependencies | Files |
|--------|-------|--------------|-------|
| **WS-5: Twenty CRM Sync** | `librarian` → `fixer` | WS-3-FIX | New `App/Sync/`, `AppStore` sync hooks, `Info.plist` |
| **WS-6: Design Polish + Liquid Glass** | `designer` → `fixer` | WS-1 (tokens) | `App/Root/RootTabView.swift`, `App/Screens/*`, `App/Sheets/*` |

**WS-5**: Optimistic sync with visible status (green/amber/red), payments never fake success.
**WS-6**: Refactor large screens into subviews, add Liquid Glass to capture pill/chips (iOS 26 gated), one signature detail per screen, 5-Dimension Review ≥ 7.

---

### Wave D — WS-8 (FINAL GATE)

| Stream | Agent | Dependencies |
|--------|-------|--------------|
| **WS-8: Build/Run/QA** | orchestrator + `observer` | All above |

- `ios-debugger-agent` + `xcodebuildmcp`: build, run, simulator walkthrough
- `ios-simulator-browser`: screenshot proof
- `ios-ettrace-performance`: capture flow trace
- `ios-memgraph-leaks`: capture/dismiss leak check
- `swiftui-performance-audit`: list screen invalidation review
- `better-interface`: final holistic design audit

---

## Detailed Workstream Specs

---

### WS-3-FIX: Resolve SwiftData Circular References
**Agent**: `fixer` · **Skill**: `swiftui-view-refactor`

**Files to modify** (all in `App/Models/`):
- `Client.swift`
- `ClientProject.swift`
- `TaskItem.swift`
- `Finding.swift`
- `Decision.swift`
- `PaymentRecord.swift`
- `ActivityEvent.swift`
- `Note.swift`

**Pattern for each pair**:
```swift
// Parent side (array) — KEEP @Relationship(deleteRule: .cascade, inverse: \Child.parent)
@Relationship(deleteRule: .cascade, inverse: \TaskItem.client)
var tasks: [TaskItem] = []

// Child side (optional single) — REMOVE inverse, just @Relationship
@Relationship var client: Client?
```

**Exception**: `ContactPerson.client` — keep inverse on both sides (1:1-ish, no cascade issue typically).

**Verification**:
```bash
xcodebuild -scheme Relay -destination 'generic/platform=iOS Simulator' build
```
Must pass clean. Then: quit simulator, relaunch app — all seed data + any new entries must persist.

---

### WS-4-COMPLETE: Wire Promote Flow + Polish Search
**Agent**: `fixer` · **Skills**: `swiftui-ui-patterns` (navigationstack, sheets)

#### 1. Add `promoteFindingToProject` to `AppStore.swift`
```swift
func promoteFindingToProject(_ finding: Finding, name: String, phase: String) -> ClientProject {
    let project = ClientProject(
        client: finding.client!,
        name: name,
        phase: phase,
        status: .inProgress,
        nextAction: "Scope automation",
        projectValue: 0,
        paidAmount: 0,
        links: []
    )
    modelContext.insert(project)
    
    // Link finding to new project
    finding.project = project
    finding.status = .investigating
    
    // Activity + Decision
    let activityEvent = ActivityEvent(client: finding.client!, project: project, text: "Promoted finding to project: \(name)")
    modelContext.insert(activityEvent)
    
    let decision = Decision(client: finding.client!, project: project, text: "Automation opportunity identified from: \(finding.text)")
    modelContext.insert(decision)
    
    try? modelContext.save()
    return project
}
```

#### 2. Navigation after promote
In `PromoteFindingSheet.save()`: after `store.promoteFindingToProject`, the sheet dismisses. Need to push `ProjectDetailView` for the new project.

**Option A** (simplest): `PromoteFindingSheet` takes a callback `(ClientProject) -> Void` that the parent (`FindingsView` or `ClientDetailView`) uses to push navigation.

**Option B**: Use a shared navigation path in `RootTabView` (like `deepLinkClientID`).

**Recommended**: Add `@Binding var navigationPath: NavigationPath` to `PromoteFindingSheet` and push the project.

---

### WS-5: Twenty CRM Sync
**Agent**: `librarian` (research) → `fixer` (implement)

**Research** (`librarian`):
- Twenty CRM API endpoints (REST/GraphQL), auth, rate limits
- Document: `/Users/forex/solo-crm/TWENTY_API.md`

**Implement** (`fixer`):
- `App/Sync/TwentySyncEngine.swift` — background actor
- Push local mutations (tasks, findings, decisions, payments) → Twenty
- Pull remote changes → merge (last-write-wins, conflict UI if needed)
- **Optimistic UI**: local mutation applies instantly, sync reconciles
- **Visible sync status**: tiny indicator in tab bar (green=Synced, amber=Syncing, red=Offline)
- **Payments**: never fake success — require confirmed write

---

### WS-6: Design Polish + Liquid Glass
**Agent**: `designer` (direction) → `fixer` (implement)

**Phase 1 — Designer Review** (1 hour):
- Score all 8 key screens on 5-Dimension Review
- Pick **one signature detail per screen** (120% effort)
- Choose Liquid Glass targets: capture pill, status chips, project link capsules

**Phase 2 — Fixer Implementation**:
1. **Refactor large screens** (`TodayView`, `ClientDetailView`, `ProjectDetailView`) into dedicated subview types per `swiftui-view-refactor` (no giant computed `some View` blocks)
2. **Liquid Glass** (iOS 26 gated):
   ```swift
   if #available(iOS 26, *) {
       CapturePill().glassEffect(.regular.interactive(), in: .circle)
       StatusChip().glassEffect(.regular, in: .capsule)
   } else {
       // material fallback
   }
   ```
3. **DesignTokens everywhere** — verify no hardcoded spacing/colors remain
4. **Re-run 5-Dimension Review** — all ≥ 7, none < 5

---

### WS-8: QA Gate
**Agent**: orchestrator + `observer` · **Skills**: `ios-debugger-agent`, `ios-simulator-browser`, `ios-ettrace-performance`, `ios-memgraph-leaks`, `swiftui-performance-audit`, `better-interface`

**Checklist**:
- [ ] Clean build (`xcodebuild` + Xcode)
- [ ] Simulator walkthrough: Today → Clients → ClientDetail → ProjectDetail → Quick Capture (all stages) → Search → Findings → Money
- [ ] Capture flow ETTrace: open → save → dismiss (no spikes)
- [ ] Memgraph: capture/dismiss + sheet open/close (no app-owned leaks)
- [ ] Perf audit: Today/Clients list scrolling (no invalidation storms)
- [ ] Design audit: `better-interface` holistic pass
- [ ] Screenshots captured via `ios-simulator-browser`

---

## File Ownership Map (for parallel agents)

| Stream | Creates/Modifies |
|--------|------------------|
| WS-3-FIX | `App/Models/*.swift` (8 files) |
| WS-4-COMPLETE | `App/Store/AppStore.swift`, `App/Sheets/PromoteFindingSheet.swift`, `App/Screens/More/FindingsView.swift` |
| WS-5 | `App/Sync/`, `App/Store/AppStore.swift` (hooks), `App/Info.plist` |
| WS-6 | `App/Root/RootTabView.swift`, `App/Screens/*`, `App/Sheets/*` (polish only) |
| WS-8 | `.xcodeproj` (simulator run only), temp profiling wiring |

---

## Anti-Pattern Guardrails (from Doctrine)

- ❌ No purple-blue gradients, no glass-everywhere, no card-in-card
- ❌ No mandatory-metadata capture — root capture = "just type/speak"
- ❌ No full-screen nav for tiny tasks — bottom sheets = doing layer
- ❌ No CRM terminology in nav (keep Today/Clients/Projects/Capture)
- ❌ No exposing backend latency UI can absorb
- ✅ Calm. Structured. Immediate. Native. Info-rich not cluttered.

---

## Handoff Notes for Grokbot

1. **Start with Wave B** — both streams independent, can run parallel
2. **WS-3-FIX is the critical path** — everything else needs clean build
3. **WS-4-COMPLETE is trivial** — just add the one AppStore method + nav callback
4. **DesignTokens.swift is the source of truth** — all visual work consumes it
5. **Run `xcodebuild` after every stream** — clean build = done
6. **Don't commit until merge gate** — leave changes on disk, human approves

---

## Quick Commands

```bash
# Build check
xcodebuild -scheme Relay -destination 'generic/platform=iOS Simulator' build

# Regenerate Xcode project (if Project.json changes)
cd /Users/forex/solo-crm && xcodegen generate --spec Project.json

# Simulator list
xcrun simctl list devices available
```

---

*This plan reflects actual repository state as of local changes on branch `improve-native-ux`. Wave A (WS-1, WS-2, WS-7) complete and building cleanly. Wave B blocked on SwiftData circular reference fix.*