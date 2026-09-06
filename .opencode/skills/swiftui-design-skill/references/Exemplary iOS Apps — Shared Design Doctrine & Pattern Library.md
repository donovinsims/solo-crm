# Exemplary iOS Apps — Shared Design Doctrine & Pattern Library

## Purpose

**Fabric, Linear Mobile, Paste, Avec, Things, Grok Bot, and Brainbits collectively define the visual and interaction benchmark for this skill.**

These applications are not templates to clone and they should not be treated as seven unrelated aesthetic references.

Together, they form a pattern library for the qualities that make a modern, high-quality iPhone application feel:

> **Calm. Structured. Immediate. Native-feeling. Information-rich without being cluttered. Powerful without exposing complexity unnecessarily.**

The goal is to internalize their shared design DNA and apply those principles appropriately to the product being built.

Do not make the resulting application resemble any one reference app.

Do not copy proprietary layouts, branding, assets, visual identity, or screen compositions.

Instead, study:

- how information is prioritized
- how actions are surfaced
- how complexity is progressively disclosed
- how capture is accelerated
- how mobile ergonomics influence interaction
- how visual hierarchy reduces cognitive load
- how state changes are communicated
- how dense information remains scannable
- how native platform expectations are respected
- how each product establishes a calm and trustworthy operating environment

The references establish **quality and interaction standards**, not a visual theme.

---

# 1. Calm Before Impressive

The clearest shared visual characteristic across these applications is restraint.

Fabric, Things, Paste, Brainbits, Linear, Avec, and Grok Bot generally place the user's information and actions ahead of decorative interface treatment.

The interface should feel controlled rather than visually ambitious.

Favor:

- low visual noise
- restrained use of color
- content-first surfaces
- strong typography
- deliberate spacing
- subtle separators and grouping
- limited simultaneous emphasis
- clear visual states
- one obvious next action
- quiet supporting chrome

Avoid trying to make every screen visually memorable.

A user should first notice:

> **What can I accomplish here?**

not:

> **Look at this design system.**

Polish should emerge from detail, consistency, rhythm, hierarchy, interaction quality, and responsiveness rather than ornamentation.

Things is especially useful as a reference for this principle: its identity is strongly associated with careful interface craft while maintaining a highly restrained productivity environment.

Paste similarly allows visual content previews to provide much of the interface's character rather than surrounding every piece of information with decorative UI.

Brainbits and Fabric place capture and personal information at the center instead of burying those activities beneath heavy application chrome.

The principle is not "make everything empty."

The principle is:

> **Remove anything that does not improve comprehension, action, identity, or state.**

---

# 2. Structure Creates Beauty

The visual quality of these applications comes heavily from structure rather than decoration.

Before introducing:

- gradients
- shadows
- floating containers
- decorative blur
- glass effects
- oversized icon treatments
- ornamental backgrounds
- excessive rounded rectangles

attempt to solve the design problem using:

- typography
- alignment
- whitespace
- grouping
- hierarchy
- indentation
- consistent row anatomy
- semantic color
- progressive disclosure
- spatial relationships
- clear primary/secondary states

A well-designed screen should remain understandable even if most decorative effects are removed.

The hierarchy of every major screen should answer approximately five questions:

1. **Where am I?**
2. **What matters right now?**
3. **What can I do here?**
4. **What information or action is secondary?**
5. **Where do I go when I need more?**

If those answers are unclear, decorative polish will not rescue the design.

---

# 3. Strong Hierarchy, Typography, and Spatial Rhythm

These applications consistently demonstrate strong information hierarchy.

Large headings are used when hierarchy benefits from them.

Secondary information becomes visibly secondary.

Important actions are recognizable without requiring excessive color or oversized containers.

Labels remain concise.

Related information is grouped.

Unrelated information receives enough separation to remain independently scannable.

The goal is not merely "good spacing."

The goal is **spatial meaning**.

Spacing should communicate relationships:

- tight spacing → these things belong together
- moderate spacing → these are separate items within one concept
- large spacing → this is a new conceptual region

Typography should do similar work.

An interface should not require seven font sizes and five weights to establish hierarchy.

A restrained hierarchy often works better:

```text
Screen / navigation title
        ↓
Section title
        ↓
Primary content
        ↓
Secondary content
        ↓
Metadata
```

Do not infer exact implementation details such as specific SF Pro styles, exact 4/8-point grids, or Dynamic Type configuration solely from reference screenshots.

Instead, extract the observable principle:

> **The interface exhibits deliberate typographic hierarchy and consistent spatial rhythm.**

Production implementation should then satisfy the actual Apple HIG, accessibility requirements, and the project's design-token system.

---

# 4. Native-First, Not iOS-Themed

Do not reproduce the superficial appearance of iOS.

Reproduce its **interaction expectations**.

A weak cross-platform application often attempts to "look Apple" through:

- rounded rectangles
- blur
- translucent surfaces
- SF-style icons
- large titles

while behaving unlike an iOS application.

That is not native fidelity.

Native fidelity comes significantly from behavior.

The application should feel natural with:

- expected navigation behavior
- edge-swipe navigation where appropriate
- correct safe-area handling
- predictable scrolling
- bottom-reachable frequent actions
- contextual menus
- swipe actions where they improve efficiency
- focused modal sheets
- predictable dismissal
- keyboard-aware layouts
- platform-appropriate selection behavior
- immediate touch feedback
- restrained haptics
- natural gesture priority
- correct loading, error, empty, selected, disabled, and destructive states

Flutter is an implementation detail.

The intended user perception is:

> **This is an iPhone app.**

Not:

> **This is a Flutter application designed to resemble an iPhone app.**

SwiftUI references elsewhere in this skill define expected Apple behavior.

They do not define the production implementation language.

---

# 5. Focused Operational Spaces

A major shared UX pattern is that strong mobile applications give the user a small number of places where they naturally "live."

They do not constantly expose the full underlying data architecture.

Linear provides work-oriented streams and inbox-style prioritization.

Things uses concepts such as Today, Upcoming, and Projects.

Fabric uses spaces, connected information, and capture-oriented surfaces.

Different products use different metaphors, but the underlying design idea is similar:

> **Expose the user's mental model, not the application's database model.**

For this CRM, the primary destinations should therefore behave more like:

### Today

What deserves my attention right now?

### Clients

Who am I working with and what matters about them?

### Projects

What is moving, waiting, blocked, delivered, or complete?

### Capture

What just happened that I need to remember, organize, or act on?

Avoid exposing raw information architecture such as:

```text
Companies
→ Records
→ Objects
→ Activities
→ Notes
→ Fields
→ Metadata
```

unless the user is performing an administrative task that genuinely requires it.

The CRM schema exists underneath the interface.

The user's intentions exist above it.

---

# 6. Fast Capture and Frictionless Input

Capture should feel almost instantaneous.

**Fabric and Brainbits are the primary references for this principle.**

Linear also provides an important reference for quickly turning mobile observations into structured work.

The desired interaction is approximately:

```text
thought
   ↓
invoke capture
   ↓
type / speak / paste
   ↓
save
```

not:

```text
thought
   ↓
choose object type
   ↓
choose company
   ↓
choose project
   ↓
enter title
   ↓
choose priority
   ↓
choose category
   ↓
enter description
   ↓
choose tags
   ↓
configure automation
   ↓
save
```

Structure can be added afterward.

The first responsibility of capture is to **preserve intent before it disappears**.

This principle directly governs the CRM's bottom-sheet Quick Capture experience.

A user should be able to capture:

- a task
- a thought
- a client note
- a project update
- a finding
- a decision
- a payment detail
- a voice note
- pasted content
- an attachment

without confronting unnecessary CRM complexity.

When possible, infer or defer metadata rather than demanding it up front.

---

# 7. Progressive Disclosure Over Giant Forms

**Things is the strongest reference for this principle.**

The interface should expose only the information required to complete the most common version of an action.

Advanced properties should appear when needed.

For example, creating a task may initially require little more than:

```text
What needs to happen?
```

rather than exposing:

```text
Title
Client
Project
Priority
Status
Due date
Assignee
Category
Tags
Description
Reminder
Automation
```

Those properties may all exist in the system.

They should not all demand the user's attention simultaneously.

This distinction is critical.

**Data-model complexity does not justify interface complexity.**

Progressive disclosure allows sophisticated software to remain approachable without sacrificing capability.

---

# 8. Bottom Sheets Are Workspaces, Not Dialogs

**Fabric and Brainbits are the primary references for the capture model.**

Bottom sheets should be treated as temporary working surfaces attached to the user's current context.

A sheet should preserve where the user was and what they were doing.

Examples:

```text
Client
  ↓
Add Note sheet
  ↓
Save
  ↓
Return to Client
```

```text
Project
  ↓
Log Decision sheet
  ↓
Save
  ↓
Return to Project
```

```text
Today
  ↓
Quick Capture sheet
  ↓
Capture thought
  ↓
Save
  ↓
Return to Today
```

```text
Payment
  ↓
Record Payment sheet
  ↓
Save
  ↓
Return to Payment context
```

Prefer sheets when the action is:

- brief
- contextual
- self-contained
- reversible or safely dismissible
- subordinate to the screen underneath it

Do not push the user through an entirely new navigation hierarchy for every small action.

A good bottom sheet should feel like:

> **I temporarily brought the tool I needed into my current context.**

rather than:

> **The application transported me somewhere else to perform a tiny task.**

---

# 9. High Information Density Without Visual Congestion

**Linear Mobile is especially important as a reference here.**

Professional productivity and CRM applications often need to display significant amounts of information.

Density itself is not the problem.

Poor organization is.

Maintain clarity through:

- predictable alignment
- concise labels
- strong type hierarchy
- intelligent grouping
- secondary text treatment
- consistent row anatomy
- meaningful whitespace
- progressive disclosure
- restrained container usage
- clear state differences
- sensible information ordering

Avoid solving every grouping problem by adding another card.

A common AI-generated UI failure is:

```text
Page
 ├─ Card
 │   ├─ Card
 │   └─ Card
 ├─ Card
 │   └─ Pills
 └─ Giant gradient CTA
```

Containers should establish meaningful boundaries.

They should not exist simply because a group of elements needs somewhere to live.

Use:

- whitespace
- alignment
- typography
- separators
- list structure

before introducing another floating surface.

The guiding principle is:

> **Density is acceptable. Ambiguity is not.**

---

# 10. Visual Objects Should Be Recognizable Before They Are Read

**Paste is especially useful as a reference for visual recognition.**

When objects differ visually, allow those differences to aid navigation.

Examples in a CRM might include:

- client avatar or business identity
- document preview
- photo
- website thumbnail
- recognizable file type
- status icon
- contact image

Users can often recognize an object faster than they can parse another identical row of text.

Do not turn every object into an abstract data record when the underlying content offers meaningful visual identity.

At the same time, visual recognition must support—not replace—clear labeling.

---

# 11. One-Object-at-a-Time Interaction Can Reduce Cognitive Load

**Avec is especially useful as a reference for focused triage and rapid decision-making.**

When users need to process a queue of items, presenting one primary item or decision at a time can sometimes be more effective than showing a dense management table.

Potential CRM applications include:

- triaging leads
- reviewing captured notes
- processing operational findings
- approving proposed classifications
- sorting unassigned tasks
- clearing an inbox
- reviewing client follow-ups

The important principle is not "everything should use swipe cards."

It is:

> **When the task is sequential decision-making, reduce competing information and focus attention on the current decision.**

Use swipe or gesture-based triage only when:

- the action is repetitive
- consequences are clear
- reversal is available
- the gestures remain discoverable
- accessibility alternatives exist

---

# 12. Agent and Conversational Actions Should Still Feel Operational

**Grok Bot is primarily useful as a reference for conversational or agent-oriented operational interaction.**

Do not interpret its platform requirements or App Store availability as evidence of specific internal HIG implementation details unless independently verified.

Instead, reference it for the broader interaction problem:

> How can a user tell software what they want, allow automation to perform work, and still understand what is happening?

For agent-driven CRM interactions, prioritize:

- visible intent
- clear pending state
- clear completed state
- understandable approvals
- explicit destructive actions
- undo when possible
- traceable actions
- clear human override
- conversational input without hiding operational state

Conversational UI should reduce input friction.

It should not make the system's actions mysterious.

---

# 13. Put Frequent Actions Within Reach

Mobile CRM usage is often fast, situational, and one-handed.

The interface should respect that reality.

High-frequency actions should favor comfortable thumb reach.

Examples:

- Quick Capture
- completing a task
- adding a note
- changing a status
- logging a finding
- responding to something requiring attention
- creating a follow-up
- recording a payment

Less frequent, navigational, administrative, and destructive actions can live farther from the natural thumb zone.

Do not automatically place every primary action in the top-right corner merely because desktop interfaces frequently do so.

Mobile interaction architecture should reflect mobile ergonomics.

---

# 14. Interaction Feedback Should Be Quiet but Unmistakable

Polish does not mean constant animation.

Motion and feedback should primarily communicate:

- selection
- cause and effect
- spatial relationships
- success
- failure
- movement
- hierarchy
- state changes

Useful feedback may include:

- selection haptic
- subtle spring
- row movement
- checkmark
- temporary confirmation
- sheet movement
- smooth keyboard transition
- selected state
- brief success state
- contextual sound when genuinely useful

Avoid animation whose only purpose is demonstrating that something can animate.

The ideal response to interaction is:

> **Immediate, understandable, and satisfying.**

not:

> **Visually impressive.**

Things and Paste are useful references for the broader principle that seemingly small interactions contribute disproportionately to perceived quality.

When referencing them, distinguish observable product behavior from assumptions about their internal animation implementation.

---

# 15. Software Should Feel Faster Than Its Backend

A high-quality mobile interface should avoid unnecessarily exposing backend latency.

Capture, synchronization, classification, automation, and network communication should feel immediate whenever technically safe.

The desired perception is:

```text
I did something.
It happened.
The system handles the rest.
```

rather than:

```text
I did something.
Spinner.
Spinner.
Spinner.
Success.
```

Use optimistic interaction where the operation is:

- predictable
- safely reversible
- unlikely to fail
- capable of reconciling later

Provide visible synchronization or failure state when it matters.

Never fake success for an irreversible or financially meaningful operation.

The principle is not "hide the backend."

The principle is:

> **Do not force the user to experience technical latency that the interface can safely absorb.**

---

# 16. Cross-Platform Consistency Is Semantic, Not Pixel-Identical

Paste, Things, Fabric, and several other references operate across multiple platforms or contexts.

The lesson is not that every screen should look identical everywhere.

Preserve:

- terminology
- object identity
- information hierarchy
- icon meaning
- status meaning
- conceptual grouping
- user progress
- core mental model

Adapt:

- navigation
- layout density
- input methods
- sidebar behavior
- keyboard support
- pointer interaction
- window structure
- responsive composition

according to the platform.

The same Client should remain conceptually the same object on iPhone, iPad, Mac, and web.

Its presentation does not need to be pixel-identical.

---

# 17. Trust Should Be Visible Through Restraint

CRM software contains valuable personal and business information.

The interface should communicate seriousness and reliability.

Trust is strengthened by:

- predictable behavior
- quiet visual treatment
- clear state
- reversible actions
- understandable permission requests
- explicit destructive actions
- reliable saving
- visible synchronization state when relevant
- clear offline/error behavior
- transparent automation
- consistent interaction patterns

Privacy and reliability should not exist only in policy text.

The experience itself should feel trustworthy.

A chaotic, unpredictable, or excessively animated interface can undermine trust even if the underlying software is technically secure.

---

# 18. Reference Roles

Each application contributes a different type of expertise.

Do not use every reference for every design decision.

## Fabric

**Primary reference for:**

- contextual Quick Capture
- bottom-sheet immediacy
- low-friction capture
- connected information
- content-first personal workspace
- capturing before organizing

Transfer the principle:

> Get information into the system first. Organize it second.

---

## Brainbits

**Primary reference for:**

- extremely low-friction thought capture
- voice-first capture
- mobile idea capture
- minimal ceremony
- background processing that does not dominate the interaction
- bottom-sheet Quick Capture

Transfer the principle:

> The distance between thought and saved information should be extremely short.

---

## Linear Mobile

**Primary reference for:**

- operational density
- prioritization
- inbox-oriented work
- fast issue/task creation
- mobile work management
- quick triage
- concise professional UI
- state-heavy productivity workflows

Transfer the principle:

> Serious operational software can be dense without feeling cluttered.

---

## Things

**Primary reference for:**

- restraint
- progressive disclosure
- clear hierarchy
- task-focused information architecture
- interaction craft
- calm productivity design
- presenting complexity gradually

Transfer the principle:

> Powerful software does not need to expose all of its power simultaneously.

---

## Paste

**Primary reference for:**

- visual object recognition
- polished Apple ecosystem experience
- content previews
- spatial organization
- clear browsing
- coherent cross-device identity

Transfer the principle:

> Let recognizable content carry visual identity instead of decorating every container.

---

## Avec

**Primary reference for:**

- focused one-object-at-a-time interaction
- rapid triage
- gesture-oriented decision-making
- reducing cognitive competition
- voice-supported interaction

Transfer the principle:

> When a workflow consists of repeated decisions, focus the user's attention on the current decision.

---

## Grok Bot

**Primary reference for:**

- conversational operational interaction
- agent delegation
- approvals
- human control over automated actions
- lightweight command-oriented workflows

Transfer the principle:

> Conversational interfaces should reduce input friction without obscuring system state or user control.

---

# 19. Quick Reference Matrix

| Design problem | Primary reference | Secondary reference |
|---|---|---|
| Bottom-sheet Quick Capture | Fabric | Brainbits |
| Voice capture | Brainbits | Avec |
| Rapid task creation | Linear | Things |
| Operational inbox | Linear | Things |
| Progressive disclosure | Things | Fabric |
| Dense CRM information | Linear | Things |
| Calm productivity UI | Things | Linear |
| Content-first workspace | Fabric | Paste |
| Visual object recognition | Paste | Fabric |
| Triage workflow | Avec | Linear |
| Agent interaction | Grok Bot | Linear |
| Cross-platform coherence | Paste | Things |
| Mobile ergonomics | Linear | Brainbits |
| Contextual sheets | Fabric | Brainbits |
| Minimal ceremony | Brainbits | Fabric |
| Interaction polish | Things | Paste |

---

# 20. Evidence Discipline

These applications are references for observable design and interaction patterns.

Do not infer implementation details that have not been verified.

For example, a screenshot that exhibits strong spacing does not prove the application uses a specific 8-point spacing token system.

An application requiring a recent iOS version does not prove that every interface follows current HIG guidance.

A visually native sheet does not prove it uses a specific SwiftUI API.

A native-looking type hierarchy does not prove a particular SF Pro implementation.

Distinguish:

### Observed

> "The interface presents one dominant action and keeps supporting information visually secondary."

from:

### Unverified implementation claim

> "The application uses Apple's exact semantic typography ladder internally."

When implementation details matter, rely on:

1. official Apple documentation
2. verified technical documentation
3. actual source code when available
4. the Flutter implementation guidance elsewhere in this skill

Use exemplar apps primarily for **taste, interaction structure, workflow design, hierarchy, restraint, and quality judgment.**

---

# 21. Anti-Patterns These References Should Prevent

The reference library should actively prevent common AI-generated mobile UI failures.

Reject:

- excessive floating cards
- card-inside-card layouts
- gradients used without product reason
- glass everywhere
- giant ornamental CTAs
- oversized circular icon badges repeated across the interface
- decorative dashboards
- excessive statistics above actionable work
- every section using a different visual treatment
- tiny low-priority metadata receiving excessive emphasis
- CRM database terminology leaking into everyday navigation
- giant creation forms
- hidden primary actions
- needless full-screen navigation for tiny contextual tasks
- decorative motion
- excessive pill controls
- arbitrary spacing
- hardcoded visual values without tokens
- every action placed in the top-right corner
- busy home screens trying to summarize the entire database
- slow capture caused by mandatory metadata
- generic "modern SaaS" mobile design applied to iOS
- mimicking Apple's visual effects while ignoring Apple's interaction conventions

The strongest designs often feel surprisingly simple after significant complexity has been removed.

---

# 22. CRM Translation

For this project specifically, these principles should produce a mobile CRM that feels more like a personal operations tool than a traditional enterprise CRM.

The user should primarily experience:

```text
TODAY
What needs me?
```

```text
CLIENTS
Who am I working with?
```

```text
PROJECTS
What is moving, waiting, blocked, or finished?
```

```text
CAPTURE
What just happened?
```

Supporting concepts such as Companies, People, Opportunities, Tasks, Findings, Payments, Activities, and custom Twenty objects should remain available without dictating the entire information architecture.

A raw CRM thinks:

```text
What object would you like to create?
```

This mobile product should think:

```text
What are you trying to do?
```

That distinction should influence every major UX decision.

---

# 23. Final Design Test

Before approving a major screen, interaction, or component, ask:

### Calm

Does anything compete for attention unnecessarily?

### Structure

Can the hierarchy be understood quickly?

### Focus

Is the primary purpose obvious?

### Native behavior

Does it behave the way an experienced iPhone user expects?

### Reachability

Can frequent actions be performed comfortably?

### Capture

Are we asking for more information than we actually need right now?

### Disclosure

Can secondary complexity wait?

### Density

Is the interface information-rich or merely crowded?

### Feedback

Does the user immediately understand what happened?

### Trust

Does the application behave predictably?

### Restraint

Would removing another decorative element improve the interface?

### Reference fidelity

Are we borrowing a transferable principle rather than copying another product?

### Flutter transparency

Would an ordinary iPhone user have any reason to think:

> "This feels like a cross-platform application imitating iOS"?

If yes, investigate why.

---

# The Combined Benchmark

The skill should conceptually borrow:

**Fabric**  
→ contextual capture, bottom-sheet immediacy, capture-before-organization

**Brainbits**  
→ extremely low-friction thought and voice capture

**Linear Mobile**  
→ operational density, prioritization, speed, mobile work management

**Things**  
→ restraint, progressive disclosure, hierarchy, interaction craft

**Paste**  
→ visual object recognition, spatial polish, Apple ecosystem coherence

**Avec**  
→ focused one-object-at-a-time interaction and rapid triage

**Grok Bot**  
→ conversational and agent-oriented operational interaction

But the resulting application should not resemble any one of them.

The objective is to reproduce the **quality of thought behind them**, not their screens.

The final common denominator remains:

> **Calm. Structured. Immediate. Native-feeling. Information-rich without being cluttered. Powerful without exposing complexity unnecessarily.**

That is the standard this reference library exists to enforce.
```

This version is the one I’d use in the ZIP. It turns the apps into an actual **taste-and-decision engine** for the skill rather than a moodboard, while keeping Fabric + Brainbits explicitly dominant for the bottom-sheet/Quick Capture direction.