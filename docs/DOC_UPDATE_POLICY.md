# Documentation Update Policy

Agents must keep the project docs current when they change the game, workflow, architecture, or known bug history.

## Required Check

Before finishing any task, run this documentation impact check:

1. Did the change add, remove, or modify a game mechanic?
2. Did the change affect UI screens, player flow, economy, rewards, upgrades, ducks, eggs, or progression?
3. Did the change alter project structure, Rojo mappings, source folders, remotes, modules, or data flow?
4. Did the change alter setup, commands, tools, or Roblox Studio workflow?
5. Did the change fix a bug, close a task, add a known issue, or introduce follow-up work?
6. Did the change create a decision future agents need to know?

If any answer is yes, update the relevant docs in the same change.

## Which Docs to Update

- `docs/GAME_BRIEF.md`: confirmed game mechanics, UI direction, player loop, progression, economy, duck systems, or undecided design questions.
- `docs/GAMEPLAY_RESEARCH.md`: gameplay research notes, comparable mechanics, recommendation buckets, and mechanic evaluation notes.
- `docs/DESIGN_INPUTS.md`: design checklist, visual references, UI layout needs, asset requirements, and missing user-provided design inputs.
- `docs/DESIGN_PROMPTS.md`: image-generation prompts, prompt status, prompt review notes, and approved or rejected visual directions.
- `docs/ASSET_WORKFLOW.md`: asset folder rules, image size expectations, generated-output handling, and promotion flow.
- `docs/ROADMAP.md`: phase changes, feature priorities, or major scope changes.
- `docs/PRODUCT_PLAN.md`: monetization products, prices, or rules; analytics targets or instrumentation; marketing, store presence, or launch decisions; community policy; localization; trust/safety/compliance; operations and decision gates.
- `docs/TASKS.md`: new follow-up work, completed tasks, known issues, testing gaps, or bugs that need regression coverage.
- `docs/CHANGELOG.md`: meaningful additions, behavior changes, bug fixes, documentation milestones, and tooling changes.
- `docs/PROJECT_STRUCTURE.md`: Rojo mappings, folder layout, new services, new top-level modules, or generated/local file rules.
- `docs/project-map/script.js`: the interactive project map's node data when Rojo mappings, source modules, remotes, save schema version, or module relationships change. Keep its snapshot stats (module count, remote count, schema version) matching the real code.
- `docs/WORKFLOW.md`: setup steps, build commands, Studio sync steps, testing process, or release flow.
- `docs/CODING_STANDARDS.md`: architecture rules, security rules, client/server boundaries, naming, dependencies, or testing expectations.
- `docs/REFERENCE_POLICY.md`: official source rules for Roblox, Rojo, Aftman, and API verification behavior.
- `docs/LIBRARY_POLICY.md`: dependency selection, source checks, approval rules, and package workflow decisions.
- `docs/LIBRARY_CANDIDATES.md`: reviewed dependency candidates, rejected libraries, and current library recommendations.
- `docs/AI_AGENT_ROLES.md`: niche agent mode definitions, responsibilities, and coordination rules.
- `README.md`: project overview, quickstart commands, links, or important entry-point guidance.
- `AGENTS.md`: rules that future AI agents must follow.

## Bug Fix Rule

When fixing a bug:

- Add a short entry under `Fixed` in `docs/CHANGELOG.md`.
- Add or update a task in `docs/TASKS.md` if follow-up work or regression testing remains.
- Update `docs/CODING_STANDARDS.md` or `docs/WORKFLOW.md` if the bug exposed a repeatable rule agents should follow.
- Mention the verification step used, or clearly state what was not tested.

## When Docs Do Not Need Changes

Docs usually do not need changes for:

- Pure formatting that does not change behavior.
- Internal cleanup that does not change names, APIs, structure, workflow, or player-facing behavior.
- Temporary exploration with no committed project change.

When docs are intentionally not changed, the final summary should say why.