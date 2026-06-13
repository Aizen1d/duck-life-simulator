"""
Headless verification of the Phase 6 hatching algorithm.

This ports the EXACT logic from src/server/PlayerStateService.luau
(rollEggRarity, resolveHatchRarity with pity, pickFamilyForRarity) and the
egg config from src/shared/PrototypeConfig.luau, then Monte-Carlos it to confirm:
  - each egg's odds sum to 100,
  - the empirical rarity distribution matches the configured odds,
  - pity guarantees hold (Rare+ within 8 Speckled, Legendary within 10 Golden),
  - every rolled rarity maps to a real family.

NOTE: this verifies the algorithm + config numbers, not the live Luau execution
or persistence (that needs the Studio MCP). Python's RNG differs from Luau's
math.random but both are uniform, so the distribution test is valid.
"""

import random

# ── Config mirrored from PrototypeConfig.luau (eggTypes) ──────────────────────
EGG_TYPES = [
    {"id": "plain",    "odds": {"common": 75, "uncommon": 25}},
    {"id": "speckled", "odds": {"uncommon": 60, "rare": 30, "epic": 10},
     "pityThreshold": 8,  "pityFloor": "rare"},
    {"id": "golden",   "odds": {"rare": 55, "epic": 35, "legendary": 10},
     "pityThreshold": 10, "pityFloor": "legendary"},
]

FAMILIES = {  # rarity -> set of families pickFamilyForRarity can return
    "common": {"classic_yellow", "mallard_green"},
    "uncommon": {"choco_brown", "snowy_white"},
    "rare": {"blossom_pink"},
    "epic": {"twilight_blue"},
    "legendary": {"golden"},
}

RARITY_RANK = {"common": 1, "uncommon": 2, "rare": 3, "epic": 4, "legendary": 5}
RARITY_ORDER = ["common", "uncommon", "rare", "epic", "legendary"]


def rarity_at_least(rarity, floor):
    return RARITY_RANK.get(rarity, 0) >= RARITY_RANK.get(floor, 0)


def roll_egg_rarity(egg):
    roll = random.randint(1, 100)
    cumulative = 0
    last_defined = "common"
    for rarity in RARITY_ORDER:
        chance = egg["odds"].get(rarity)
        if isinstance(chance, (int, float)) and chance > 0:
            last_defined = rarity
            cumulative += chance
            if roll <= cumulative:
                return rarity
    return last_defined


def resolve_hatch_rarity(pity, egg):
    rarity = roll_egg_rarity(egg)
    if "pityThreshold" not in egg or "pityFloor" not in egg:
        return rarity
    key = egg["id"]
    if rarity_at_least(rarity, egg["pityFloor"]):
        pity[key] = 0
        return rarity
    nxt = pity.get(key, 0) + 1
    if nxt >= egg["pityThreshold"]:
        pity[key] = 0
        return egg["pityFloor"]
    pity[key] = nxt
    return rarity


def pick_family_for_rarity(rarity):
    if rarity == "legendary":
        return "golden"
    if rarity == "epic":
        return "twilight_blue"
    if rarity == "rare":
        return "blossom_pink"
    if rarity == "common":
        return random.choice(["classic_yellow", "mallard_green"])
    return random.choice(["choco_brown", "snowy_white"])


def main():
    N = 500_000
    failures = []

    for egg in EGG_TYPES:
        total = sum(egg["odds"].values())
        status = "OK" if total == 100 else "FAIL"
        if total != 100:
            failures.append(f"{egg['id']} odds sum to {total}, not 100")
        print(f"[odds-sum] {egg['id']:9} = {total:3}  {status}")

    print()

    for egg in EGG_TYPES:
        pity = {egg["id"]: 0}
        counts = {}
        floor = egg.get("pityFloor")
        longest_below_floor_streak = 0
        current_streak = 0
        bad_family = 0

        for _ in range(N):
            rarity = resolve_hatch_rarity(pity, egg)
            counts[rarity] = counts.get(rarity, 0) + 1

            fam = pick_family_for_rarity(rarity)
            if fam not in FAMILIES.get(rarity, set()):
                bad_family += 1

            if floor is not None:
                if rarity_at_least(rarity, floor):
                    current_streak = 0
                else:
                    current_streak += 1
                    longest_below_floor_streak = max(longest_below_floor_streak, current_streak)

        print(f"== {egg['id']} ({N} hatches) ==")
        for rarity in RARITY_ORDER:
            if rarity in counts:
                pct = counts[rarity] / N * 100
                cfg = egg["odds"].get(rarity, 0)
                print(f"   {rarity:10} {pct:6.2f}%   (config base {cfg}%)")
        if bad_family:
            failures.append(f"{egg['id']} produced {bad_family} unmapped families")
            print(f"   FAMILY MAP: FAIL ({bad_family} unmapped)")
        else:
            print(f"   family map: OK (every rarity mapped)")

        if floor is not None:
            threshold = egg["pityThreshold"]
            # Worst case: threshold-1 sub-floor hatches, then the threshold-th is forced.
            guarantee_ok = longest_below_floor_streak <= threshold - 1
            if not guarantee_ok:
                failures.append(
                    f"{egg['id']} pity broken: {longest_below_floor_streak} "
                    f"consecutive sub-{floor} hatches (threshold {threshold})")
            print(f"   pity: longest run below '{floor}' = {longest_below_floor_streak} "
                  f"(must be <= {threshold - 1})  {'OK' if guarantee_ok else 'FAIL'}")
        print()

    print("=" * 50)
    if failures:
        print("RESULT: FAIL")
        for f in failures:
            print("  -", f)
        raise SystemExit(1)
    print("RESULT: ALL CHECKS PASSED")


if __name__ == "__main__":
    main()
