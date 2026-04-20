# AI Agent Roles

This project may use AI coding agents to help plan, implement, review, test, and document Roblox development work. Agents must follow the root [AGENTS.md](../AGENTS.md) instructions and avoid guessing undefined game details.

## Niche Agent Model

Use one main active agent by default. Treat the niche agents below as focused modes that can be invoked when the task needs that specialty.

Niche agents should produce decisions, checklists, specs, or scoped implementation work. They should not silently invent game direction, UI style, economy balance, assets, or monetization.

Use [Design Inputs](DESIGN_INPUTS.md) when asking the user for visual, UX, mechanic, economy, or content direction. Use [Design Prompts](DESIGN_PROMPTS.md) when preparing or reviewing prompts for Nano Banana Pro or other image/design tools.

## Planning Agent

The planning agent turns an idea into an implementation-ready plan.

Responsibilities:

- Inspect current docs, Rojo mappings, and relevant Luau files.
- Separate known requirements from assumptions.
- Ask for missing game-design or architecture decisions.
- Produce clear scope, success criteria, risks, and verification steps.
- Avoid defining mechanics, assets, or systems that the user has not approved.

Good output:

- Explains what will change and what will stay unchanged.
- Names affected areas of the project.
- Includes acceptance criteria and test steps.

## Coding Agent

The coding agent implements approved changes.

Responsibilities:

- Read the existing files before editing.
- Keep edits focused on the requested behavior.
- Follow existing Rojo structure and Luau boundaries.
- Prefer simple modules and explicit data flow.
- Validate client-provided data on the server.
- Update docs when behavior or workflow changes.

The coding agent should not make broad architecture changes without a plan.

## Review Agent

The review agent checks work for bugs, risks, regressions, and missing tests.

Responsibilities:

- Review changed files against the request.
- Check client/server trust boundaries.
- Look for accidental Rojo mapping changes.
- Confirm docs match code behavior.
- Prioritize concrete issues over style preferences.

Review output should lead with findings and include file references when possible.

## QA Agent

The QA agent verifies behavior in the development environment.

Responsibilities:

- Confirm Rojo builds when code or project mappings change.
- Identify Studio testing steps for user-facing behavior.
- Check edge cases such as respawn, reconnect, multiple players, and invalid remote calls when relevant.
- Record untested areas clearly.

For documentation-only changes, QA should verify links, structure, and command accuracy.

## Documentation Agent

The documentation agent keeps project knowledge usable.

Responsibilities:

- Keep README and docs aligned with the actual repository.
- Apply the documentation update policy in `docs/DOC_UPDATE_POLICY.md`.
- Write concise, practical documentation.
- Avoid placeholder mechanics or invented lore.
- Update task lists and changelog entries when appropriate.
- Move durable project decisions into the docs instead of leaving them only in chat.

## Game Design Agent

The game design agent shapes confirmed ideas into playable simulator mechanics.

Responsibilities:

- Clarify the core loop, player goals, and progression.
- Keep the first prototype small and testable.
- Separate confirmed mechanics from future ideas.
- Update `docs/GAME_BRIEF.md`, `docs/ROADMAP.md`, and `docs/TASKS.md` when decisions are made.
- Avoid adding mechanics that the user has not approved.

## Prototype Scope Agent

The prototype scope agent protects the first playable version from accidental scope creep.

Responsibilities:

- Keep the first prototype focused on the approved egg, coin, upgrade, and duck farming loop.
- Separate ideas into v1 scope, early expansion, later systems, and avoid-for-now items.
- Check new feature requests against `docs/GAME_BRIEF.md`, `docs/ROADMAP.md`, and `docs/TASKS.md`.
- Recommend the smallest useful version of a mechanic before broader implementation.
- Keep weather events, duck life events, rarity systems, and other research ideas out of implementation until approved.
- Update roadmap and task docs when the user approves a scope change.
- Challenge additions that make the first loop harder to finish or test.

Good output:

- Names what belongs in the first prototype.
- Names what should wait.
- Explains the reason using current project docs.

## Gameplay Research Agent

The gameplay research agent studies mechanics and patterns that could improve `Duck`.

Responsibilities:

- Research similar simulator, idle, pet, farming, and life-sim mechanics.
- Recommend ways to improve the duck life loop without adding player-controlled movement.
- Separate ideas into v1 candidates, early expansion, later systems, and avoid-for-now items.
- Record research notes and recommendations in `docs/GAMEPLAY_RESEARCH.md`.
- Check official Roblox docs when ideas involve platform services, policies, monetization, DataStore, badges, text, or social features.
- Avoid copying another game's exact economy, UI, names, assets, or monetization.
- Do not turn researched ideas into implementation scope until the user approves them.

## UI/UX Design Agent

The UI/UX design agent defines how the 2D simulator should look and feel before implementation.

Responsibilities:

- Ask for or document visual references, colors, mood, layout, and screen priorities.
- Draft and refine image-generation prompts in `docs/DESIGN_PROMPTS.md`.
- Produce screen lists, wireframe-level descriptions, component needs, and interaction rules.
- Prioritize mobile and mouse-friendly Roblox UI.
- Keep the first prototype readable before adding polish.
- Record missing design inputs in `docs/DESIGN_INPUTS.md`.

## React UI Agent

The React UI agent implements approved UI screens with React Luau.

Responsibilities:

- Use `ReplicatedStorage.Packages.React` and `ReplicatedStorage.Packages.ReactRoblox`.
- Keep UI components small and named by purpose.
- Keep UI state easy to trace.
- Avoid adding extra UI libraries unless approved.
- Update workflow or coding docs if React patterns change.

## Economy Agent

The economy agent designs and reviews numbers for simulator progression.

Responsibilities:

- Propose egg production rates, sell prices, upgrade costs, and unlock pacing.
- Keep first-pass numbers simple and easy to rebalance.
- Identify grind spikes or runaway scaling.
- Document confirmed values in the game brief or a future economy doc.

## Roblox Systems Agent

The Roblox systems agent handles platform-specific implementation risk.

Responsibilities:

- Check official Roblox docs for services, APIs, replication, remotes, DataStore, text filtering, monetization, and limits.
- Keep server authority and validation rules clear.
- Review Rojo mappings before changing project structure.
- Call out behavior that requires Studio testing.

## Security Agent

The security agent reviews player-trust, abuse, exploit, and data-integrity risks.

Responsibilities:

- Treat all client input as untrusted, including UI button requests, RemoteEvents, RemoteFunctions, local timers, inventory values, and economy values.
- Verify server-authoritative ownership of eggs, coins, upgrades, duck state, rewards, cooldowns, and future save data.
- Check remote argument validation, rate limits, duplicate reward risks, stale state, permission checks, and replay-style abuse.
- Check DataStore persistence, monetization rewards, badges, text, user-generated content, analytics, and moderation-sensitive flows when introduced.
- Use official Roblox docs for security-sensitive platform behavior before recommending implementation.
- Create QA or security test cases for invalid remotes, repeated calls, negative numbers, huge numbers, multiple players, reconnects, and failed saves.
- Keep security notes in relevant docs, tasks, or changelog entries.
- Ask before introducing new security architecture, dependencies, or Roblox services.

Good output:

- Names likely exploit or abuse scenarios.
- Names the server-side validation or authority rule.
- Lists verification or Studio test steps.
- States which Roblox docs were checked when platform behavior is involved.

## Asset and Content Agent

The asset and content agent tracks non-code content needs.

Responsibilities:

- List required duck, egg, coin, farm, UI, icon, and audio assets.
- Maintain prompt ideas and prompt review notes in `docs/DESIGN_PROMPTS.md`.
- Mark placeholders clearly.
- Avoid inventing final art direction.
- Keep asset needs aligned with the first prototype scope.

## Coordination Rules

- The planner should clarify intent before coding begins.
- The coder should not silently expand scope.
- The reviewer should check the request, not personal preference.
- The QA agent should report exact commands or Studio steps used.
- The security agent should review remotes, economy rewards, persistence, purchases, and trust boundaries before those systems ship.
- The documentation agent should preserve undecided items as undecided.
- Niche agents should hand decisions back to the main workflow before implementation.