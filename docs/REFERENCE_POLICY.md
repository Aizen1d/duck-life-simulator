# Reference Policy

Agents must verify Roblox platform facts against official sources when the answer is not already confirmed in this repository.

## Official Sources

Use these sources first:

- Roblox Creator Docs: https://create.roblox.com/docs
- Roblox Engine API Reference: https://create.roblox.com/docs/reference/engine
- Roblox GitHub organization: https://github.com/Roblox
- Roblox GitHub repositories: https://github.com/orgs/Roblox/repositories
- Rojo docs: https://rojo.space/docs
- Aftman project docs: https://github.com/LPGhatguy/aftman

Prefer official Roblox, Rojo, and Aftman sources over forum posts, videos, old tutorials, or third-party mirrors. Third-party sources can provide context, but they should not be treated as authoritative for current API behavior.

## When to Check Roblox Docs

Check official Roblox docs before implementing or reviewing work involving:

- Roblox services, classes, properties, methods, events, callbacks, data types, enums, globals, or libraries.
- DataStore, MemoryStore, MessagingService, TeleportService, MarketplaceService, badges, analytics, moderation, text filtering, or policy-sensitive features.
- RemoteEvents, RemoteFunctions, networking, replication, or client/server security boundaries.
- UI APIs, input behavior, device compatibility, accessibility, or localization.
- Deprecated APIs, new APIs, beta APIs, permissions, limits, rate limits, or behavior that may have changed.
- Any Roblox behavior the agent is not certain about.

## How to Report Source Checks

When Roblox docs were checked, the final summary should mention the source or page used. If docs could not be checked because network access was unavailable, say that clearly and mark the Roblox-specific behavior as unverified.

## When Local Knowledge Is Enough

Agents do not need to browse for every common Luau syntax choice or project-local decision. Local code and project docs are enough when the task only changes repository documentation, names, comments, or already-confirmed project behavior.

If an agent is unsure whether a Roblox API detail is current, it must check the official docs or ask before implementing.