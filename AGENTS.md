# Agent Instructions for Duck

This project uses Rojo and Aftman for Roblox development. AI coding agents must work from the actual files in this repository and must not invent missing game design, architecture, assets, or APIs.

## Core Rules

- Do not guess if the project does not define the answer. Ask for clarification or inspect the relevant files first.
- Do not edit without understanding the surrounding code and project structure.
- Keep changes scoped to the user's request.
- Do not change Luau runtime code, Rojo mappings, or Roblox services when the requested work is documentation-only.
- Preserve user edits and unrelated work. Do not revert files unless explicitly asked.
- Prefer clear, small changes over broad rewrites.

## Project Context

- Project name: `Duck`
- Rojo project file: `default.project.json`
- Toolchain file: `aftman.toml`
- Client code: `src/client`
- Server code: `src/server`
- Shared modules: `src/shared`
- Primary documentation folder: `docs`

The confirmed direction is a 2D UI duck farming simulator. Do not add extra gameplay mechanics, lore, monetization, economy depth, NPC behavior, save data, or asset requirements unless the user provides them or the docs already confirm them.

## Expected Agent Workflow

1. Inspect the relevant files before planning or editing.
2. Identify whether the request affects documentation, Luau code, Rojo configuration, or Roblox Studio assets.
3. Ask for missing product or design decisions when they cannot be discovered from the repository.
4. Make the smallest practical set of edits.
5. Check official Roblox docs when Roblox API, service behavior, limits, security, or platform rules are uncertain.
6. Run the documentation impact check in `docs/DOC_UPDATE_POLICY.md` and update docs when needed.
7. Follow `docs/LIBRARY_POLICY.md` before recommending or adding libraries.
8. Verify links, commands, or builds when relevant.
9. Summarize what changed, which docs were updated, which sources were checked, and anything not verified.

## Niche Agent Mode Selection

Before starting a task, identify the most relevant niche agent mode from `docs/AI_AGENT_ROLES.md`.

Use one primary mode and any supporting modes needed for the task. State the mode in the work summary when it affects decisions.

Examples:

- Gameplay mechanics research: Gameplay Research Agent, Game Design Agent, Economy Agent.
- First prototype scope: Prototype Scope Agent, Game Design Agent.
- UI layout or image prompts: UI/UX Design Agent, Asset and Content Agent.
- React Luau implementation: React UI Agent, Coding Agent, Review Agent.
- Roblox service or API behavior: Roblox Systems Agent.
- Security-sensitive features: Security Agent, Roblox Systems Agent, Review Agent.
- Bug fixes: Review Agent, QA Agent, Documentation Agent.

Do not use niche roles to expand scope silently. If a role discovers a new idea, record it as research, a task, or a future-system note unless the user approves implementation.

## Roblox Documentation Rule

Follow `docs/REFERENCE_POLICY.md` when Roblox platform behavior is involved. Use official Roblox Creator Docs and the Roblox Engine API Reference before relying on memory for services, APIs, limits, replication, security, DataStore behavior, monetization, text filtering, or policy-sensitive features.

If official docs cannot be checked, state that clearly and mark the Roblox-specific behavior as unverified.

## Rojo and Aftman Usage

Use Aftman-managed tools when available. The starter commands are:

```powershell
aftman install
rojo build -o "Duck.rbxlx"
rojo serve
```

Use `rojo serve` when syncing file changes into Roblox Studio through the Rojo Studio plugin. Use `rojo build` when creating a local place file from the repository.

Do not edit generated `.rbxlx` files by hand. The project ignores `Duck.rbxlx` and Studio lock files.

## Luau Boundaries

- Code in `src/client` runs on the client and must not be trusted for authoritative gameplay decisions.
- Code in `src/server` runs on the server and should own authoritative game state, validation, persistence, and security-sensitive logic.
- Code in `src/shared` may be required by both client and server and should avoid side effects that only work in one runtime.
- RemoteEvents and RemoteFunctions must be validated server-side before use.

## Documentation Standards

- Keep docs factual and current with the repository.
- Follow the documentation update policy in `docs/DOC_UPDATE_POLICY.md`.
- Link related docs using relative Markdown links.
- Mark undefined game decisions as undecided instead of filling them in.
- Update `docs/CHANGELOG.md` when a meaningful project change is completed.
- Add new tasks to `docs/TASKS.md` when they are known but not yet implemented.
- For bug fixes, record the fix in the changelog and add regression follow-up tasks when testing is incomplete.

## When to Ask First

Ask before making changes that would:

- Define gameplay mechanics or player goals.
- Add a specific dependency, package manager, or tool that has not already been reviewed for this project.
- Change Rojo service mappings.
- Introduce persistent data, monetization, moderation, analytics, or networking contracts.
- Rename public modules, folders, services, or project files.
- Replace the current development workflow.

