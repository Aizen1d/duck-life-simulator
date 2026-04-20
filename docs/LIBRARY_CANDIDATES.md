# Library Candidates

This file records reviewed Roblox organization repositories that may be useful for `Duck`. It is a shortlist, not an install list.

Sources checked:

- Roblox GitHub organization: https://github.com/Roblox
- Roblox repositories list: https://github.com/orgs/Roblox/repositories

## Best First Candidates

### React Luau

- Source: https://github.com/Roblox/react-luau
- Purpose: Declarative UI library for Roblox/Luau.
- License: MIT.
- Status notes: Public Roblox repo and read-only mirror. The documentation describes Roact 17+ as the Luau port of React and identifies `React` and `ReactRoblox` as top-level packages.
- Fit for `Duck`: Strong candidate because this game is planned as a 2D UI simulator. It can make screens, reusable components, and state-driven UI easier to manage.
- Decision: Approved as the first library stack using Wally packages `jsdotlua/react` and `jsdotlua/react-roblox`.
- Risk: More setup and learning cost than plain Roblox UI Instances. Keep the first UI simple.

### Roblox Signals

- Source: https://github.com/Roblox/signals
- Purpose: Fine-grained reactive state management for Luau.
- License: MIT.
- Status notes: Public Roblox repo with Wally and Creator Store badges. No GitHub release was listed at the time of review.
- Fit for `Duck`: Useful for reactive egg, coin, upgrade, and UI state if the project wants a small state layer.
- Risk: Newer and less proven than older Roblox libraries. Review install path before adopting.

### Dash

- Source: https://github.com/Roblox/dash
- Purpose: Core utility functions for Luau.
- License: MIT.
- Status notes: Public Roblox repo and read-only mirror. README shows rotriever usage.
- Fit for `Duck`: Useful only if utility needs become repetitive. Not needed for the first prototype unless it removes real duplication.
- Risk: Utility libraries can hide simple logic and increase dependency surface.

### Otter

- Source: https://github.com/Roblox/otter
- Purpose: Declarative animation library for Roblox Lua/Luau, especially spring-based animation.
- License: MIT.
- Status notes: Public Roblox repo and read-only mirror.
- Fit for `Duck`: Good later for polished UI transitions, counters, buttons, popups, or duck animations.
- Risk: Not needed for the first functional loop. Add after UI behavior is stable.

## Useful Later

### Jest Roblox

- Source: https://github.com/Roblox/jest-roblox
- Purpose: Luau testing framework.
- License: MIT.
- Status notes: Public Roblox repo and read-only mirror.
- Fit for `Duck`: Useful once shared economy, upgrade, and validation modules exist.
- Risk: Requires deciding a test runner workflow.

### Roblox Lua Promise

- Source: https://github.com/Roblox/roblox-lua-promise
- Purpose: Promise implementation for Roblox async workflows.
- License: MIT.
- Status notes: Public Roblox fork of `evaera/roblox-lua-promise`; latest GitHub release listed was v3.4.0 from 2022 at review time.
- Fit for `Duck`: Useful later for DataStore, MarketplaceService, loading flows, or other async systems.
- Risk: The upstream `evaera` repo appears more active and may be a better package source. Re-check before installing.

### rbxasset

- Source: https://github.com/Roblox/rbxasset
- Purpose: Deploy `.rbxm` files from GitHub to the Creator Store.
- License: MIT.
- Status notes: Public Roblox repo. README says it requires Lute and Open Cloud API key scopes for publishing.
- Fit for `Duck`: Useful later for publishing packages/plugins, not for the first game prototype.
- Risk: Adds deployment complexity and credentials. Do not use until publishing workflow is needed.

## Avoid for This Project Right Now

### Roact

- Source: https://github.com/Roblox/roact
- Reason: Archived and deprecated. The repo points users to React Luau instead.

### Roact-Rodux

- Source: https://github.com/Roblox/roact-rodux
- Reason: Built for Roact and Rodux. Avoid unless the project intentionally chooses the older Roact/Rodux stack.

### Roact Navigation

- Source: https://github.com/Roblox/roact-navigation
- Reason: Built on Roact and mostly useful for app-style navigation. Too much for the first UI simulator prototype.

### TestEZ

- Source: https://github.com/Roblox/testez
- Reason: Archived in 2024. Prefer Jest Roblox or another actively maintained test workflow if tests are added.

## Current Recommendation

For the first prototype, use no more than one or two libraries.

Recommended path:

1. Use Wally for package workflow.
2. Use React Luau as the first UI library stack.
3. Consider Roblox Signals only if plain state management becomes messy.
4. Delay Otter, Promises, and testing libraries until the prototype has real systems to support.