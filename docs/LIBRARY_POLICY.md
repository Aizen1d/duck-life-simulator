# Library Policy

Libraries are allowed in this project when they make development easier, reduce project risk, or avoid rebuilding proven systems from scratch.

Do not add a library just because it exists. Each dependency must have a clear purpose and must fit the Rojo/Luau workflow.

## Official Roblox GitHub

The Roblox GitHub organization is an official source for Roblox open source libraries and tools:

- https://github.com/Roblox
- https://github.com/orgs/Roblox/repositories

A repository being under the Roblox organization means it is first-party Roblox open source work. It does not automatically mean the repo is active, stable, intended for game runtime use, or the best fit for `Duck`.

Before depending on any repo, check:

- README usage instructions.
- License.
- Archive status.
- Recent maintenance activity.
- Whether it is a read-only mirror.
- Whether it supports normal Roblox/Rojo development.
- Whether it has a package or installation path that works for this project.

## Dependency Selection Rules

Before adding a library, document:

- What problem it solves.
- Why the project should not implement that part directly.
- Where it will be used.
- How it will be installed and updated.
- Any new commands developers must run.
- Any risks, limitations, or migration cost.

Prefer libraries that are small, focused, documented, actively maintained, and compatible with Luau and Rojo.

Avoid dependencies that are abandoned, unclear, too broad for the current prototype, or require a workflow the project has not approved.

## Good Candidate Areas

Libraries may be useful for:

- UI/state management.
- Signals/events.
- Promises or async flow.
- Testing.
- Data validation.
- Utility functions.
- Animation helpers.

For the first prototype, prioritize only what helps build the 2D UI simulator loop faster.

## Approval Rule

The user has approved using libraries in general. Agents may recommend libraries, but should still name and justify each new dependency before installing it.

Reviewed candidates should be recorded in `docs/LIBRARY_CANDIDATES.md` so agents do not repeat repository scans.

Adding a package manager, changing tool versions, or adding a dependency that affects build setup requires documentation updates in `README.md`, `docs/WORKFLOW.md`, `docs/CODING_STANDARDS.md`, `docs/TASKS.md`, and `docs/CHANGELOG.md` as needed.