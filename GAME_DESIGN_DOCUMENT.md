# Patch Notes Game Design

## Concept

Patch Notes is a satirical text/card game about shipping game updates under pressure from two stakeholders:

- Players want Fun.
- Investors want Money.

The player assumes the role of C.L.U.T.T.E.R. - Content Launch and Update Triage Technical Executive Representative - an important position on the team creating Eternal Realms of Feature Creep: Early Access is Forever, an open-world MMORPG roguelike survival crafting extraction soulslike deckbuilder looter shooter farming racing sim and cozy sandbox.

As C.L.U.T.T.E.R., the player decides which proposed updates make it into each release. Every card is a possible improvement to the game, at least according to someone in the meeting. Some updates are better for players, some are better for investors, and some make the word "better" depend entirely on who is reading the report.

The joke is not that every update is bad. The joke is that every update can be explained as progress, even when the cost lands somewhere inconvenient.

## In-Universe Game

Eternal Realms of Feature Creep: Early Access is Forever is the game being patched inside Patch Notes. Its genre pile is intentionally absurd:

```text
open-world MMORPG roguelike survival crafting extraction soulslike deckbuilder looter shooter farming racing sim and cozy sandbox
```

The title and genre describe a game trying to be every successful trend at once. That makes it a good target for update cards: every new feature can sound like progress while adding more pressure, clutter, monetization, confusion, or instability.

## Jam Theme

Patch Notes is being made for [Pirate Software - Game Jam 19](https://itch.io/jam/pirate).

Theme: **The Cost of Progress**

The game interprets the theme through product updates. Every shipped change moves the product forward for someone, but that progress has a cost paid in player trust, clarity, meaning, spending, conversion, reach, retention, or whatever the current meeting has decided to value.

## Core Loop

1. Draw a hand of update cards.
2. Choose at least one update to ship.
3. Discard the rest.
4. Repeat for 4 sprints to complete a release.
5. Ship the release and apply the shipped cards' hidden effects to the active scoring trees.
6. Repeat for 4 releases.
7. Receive an ending based on the final state and path of the active scoring trees.

## Rules

- Fun starts at 0.
- Money starts at 0.
- Hand size is 3 cards.
- Each sprint requires the player to ship at least 1 card.
- The player may ship 1, 2, or all 3 cards from the sprint hand.
- Unshipped cards are discarded.
- Each release contains 4 sprints.
- A full run contains 4 releases.
- A full run contains 16 sprints total.
- A full run ships between 16 and 48 cards, depending on player choices.
- The full possible deck has 144 unique cards.
- No card can be drawn twice.
- The current scoring trees are Fun and Money.
- Additional scoring trees can be added later without changing the card metadata shape.
- Each card has hidden effects against the active scoring trees.
- Each hidden effect has a targetable level and a positive or negative direction.
- The effect level determines how many points the card adds or removes.
- Level 1 root nodes are not targetable by cards.
- The player does not see the affected nodes, positive/negative labels, or point values on the card.

## Point Formula

Point value is inversely proportional to the effect's level number. Lower-numbered levels are broader and worth more; higher-numbered levels are narrower and worth less.

Use this formula:

```text
points = 2 * (maxLevel - level) + 1
```

For the current three-level trees, Level 1 is the root and is not directly affected by cards. Valid card effects use Level 2 or Level 3:

```text
Level 2 -> 3 points
Level 3 -> 1 point
```

Each card effect also has a direction:

```text
Positive -> add points
Negative -> remove points
```

So a `Level 2 Positive` effect is `+3`, and a `Level 3 Negative` effect is `-1`.

## Score Range

Each shipped card affects Fun once and Money once. Since a sprint hand contains 3 cards and a full run contains 16 sprints, the player ships between 16 and 48 cards per run.

A single card can change each scoring tree by `-3`, `-1`, `+1`, or `+3`.

For a 16-sprint run, the theoretical raw range for each scoring tree is:

```text
Minimum: -96
Maximum: +96
```

This comes from the authored deck distribution, not from assuming every card could be worth `+3` forever. For each score tree, the 144-card deck currently contains:

```text
24 cards worth +3
48 cards worth +1
48 cards worth -1
24 cards worth -3
```

The best possible 48-card selection for one tree is:

```text
24 cards * +3 = +72
24 cards * +1 = +24
Total = +96
```

The worst possible 48-card selection mirrors that at `-96`.

Because the player can choose different numbers of cards per sprint, score interpretation should account for variable shipped-card count. The full `-96..+96` span is a theoretical authored-deck extreme, not the intended interpretation range. For the first balancing pass, final scores normalize against a tighter `-72..+72` range and clamp values beyond that.

```text
normalized_score = round(((clamp(raw_score, -72, 72) + 72) / 144) * 100)
```

This maps:

```text
-72 -> 0
  0 -> 50
+72 -> 100
```

Release score updates should use release deltas instead of final normalized totals. A release contains 4 sprints, so it ships between 4 and 12 cards. The theoretical raw delta range for each release score tree is `-36..+36`, but release reports normalize against `-30..+30` so ordinary releases produce readable movement while only the strongest release swings hit the outer bands.

Balancing audit target:

- Random or indifferent play should usually land near `Mixed`.
- Coherent player intent should visibly move final scores and release reports.
- Extreme endings should be possible, but not the default outcome of competent play.
- Release reports should vary during normal play without calling every modest swing catastrophic or miraculous.

## Score Bands

Final score interpretation starts with five equal normalized bands per scoring tree:

```text
0-19    Very Low
20-39   Low
40-59   Mixed
60-79   High
80-100  Very High
```

With the current Fun and Money trees, this creates a `5 x 5` final result grid:

```text
25 final score combinations
```

These bands remain equal-width normalized bands. The main balance lever is the raw score range used before normalization.

## Fun Tree

```text
FUN
├─ Experience
│  ├─ Feel
│  └─ Clarity
└─ Attachment
   ├─ Meaning
   └─ Trust
```

The Fun tree describes what players get from the game. It exists to keep "fun" from becoming one vague number. A card should not just make the game more or less fun; it should affect a specific kind of player value.

### Fun Levels

- Level 1 is the root: Fun. Cards do not directly affect this node.
- Level 2 nodes are broad themes.
- Level 3 nodes are specific themes.

Point values come from the point formula. Lower-numbered effects are stronger because they affect a broader part of the player experience. Higher-numbered effects are smaller because they target a narrower theme.

The tree nodes are categories only. They do not store values or propagate effects upward. If a card affects `Clarity -1`, only the hidden Fun score changes by -1. `Experience` is used to organize the theme; it does not receive its own separate value.

### Fun Themes

`Experience` is about the moment-to-moment act of playing the game.

- `Feel` covers responsiveness, satisfaction, pacing, friction, and whether the game feels good in the hands.
- `Clarity` covers whether players understand what is happening, what changed, and what the game expects from them.

`Attachment` is about the player's longer-term relationship with the game.

- `Meaning` covers whether the game feels worthwhile, expressive, memorable, or emotionally resonant.
- `Trust` covers whether players believe the game respects them, their time, and their expectations.

These themes exist to guide card writing. They force each update to have a satirical target. An update that hurts `Trust` should feel different from one that hurts `Feel`, even if both reduce Fun.

### Fun Example

Internal theme:

```text
Fun node: Experience / Clarity / Negative
```

Possible update card:

```text
STREAMLINED TOOLTIP STRATEGY

Several tutorial prompts have been removed to reduce early-session interruption.

SIGNAL
Players now reach confusion faster and with fewer clicks.
```

This card hurts `Clarity` because the update makes the game less understandable. The player sees the patch-note language and consequence line, not `Clarity -1`.

## Money Tree

```text
MONEY
├─ Revenue
│  ├─ Spending
│  └─ Conversion
└─ Growth
   ├─ Reach
   └─ Retention
```

The Money tree describes what investors get from the game. It keeps "money" from being only raw revenue. A card can improve the business by increasing spending, improving conversion, reaching more people, or keeping people in the product longer.

### Money Levels

- Level 1 is the root: Money. Cards do not directly affect this node.
- Level 2 nodes are broad themes.
- Level 3 nodes are specific themes.

Like the Fun tree, Money point values come from the point formula. Money nodes are categories only. They guide design and hidden scoring. They do not appear on player-facing cards.

### Money Themes

`Revenue` is about extracting value from the current audience.

- `Spending` covers how much players pay.
- `Conversion` covers how effectively players are moved toward payment or other business goals.

`Growth` is about expanding or preserving the audience.

- `Reach` covers discoverability, virality, marketability, and new-user acquisition.
- `Retention` covers whether players keep coming back.

These themes exist so investor pressure has different flavors. A card that improves `Reach` should feel different from one that improves `Spending`, even if both increase Money.

### Money Example

Internal theme:

```text
Money node: Revenue / Conversion / Positive
```

Possible update card:

```text
OPTIMIZED STORE RETURN PATH

Closing the shop now returns players to a curated offer instead of the previous screen.

SIGNAL
The back button has been promoted to a strategic revenue surface.
```

This card improves `Conversion` because it pushes players back toward a business goal. The player sees the update and its satirical framing, not `Conversion +1`.

## How The Trees Are Used Together

Each card has hidden effects on the active scoring trees. In the current design, that means one Fun effect and one Money effect. The pairing creates the design tension.

Example internal pairing:

```text
Fun node: Experience / Clarity / Negative
Money node: Growth / Retention / Positive
```

Possible update card:

```text
STREAMLINED ONBOARDING

New players now receive fewer prompts before reaching the store.

SIGNAL
The tutorial got shorter. So did the explanation for why the button is glowing.
```

Internally, this card makes the experience less clear for players but improves retention metrics. The card does not show `Clarity -1` or `Retention +1`.

## Player-Facing Card Format

```text
CARD TITLE

Short description of the update.

SIGNAL
Short poetic or satirical consequence line.
```

## Internal Card Metadata

Cards still need hidden metadata for scoring and balancing:

```text
Tree - Target Level - Node - Positive/Negative
```

The tree name identifies which scoring tree the effect changes. The target level must be a non-root level in that tree. The level and direction determine the signed point value through the point formula. This metadata is for the game logic and deck authoring process only.

## Tone

- Concise.
- Satirical.
- Dry and specific.
- Postmortem-like.
- Corporate enough to be plausible.
- Mean enough to have a pulse.

## Ending Format

Each ending has:

- A title.
- A short paragraph of 3-5 sentences.
- A specific verdict on what happened to players and investors.

Example voice:

```text
WHALE FARM

Most players left within the first week, loudly and permanently. The few who stayed spent enough money to make the dashboard look beautiful.

Investors called it "a focused high-value audience."
The community called it something less printable.
```

## Design Decisions

- The player does not have to ship exactly one card per sprint.
- Discarded cards do not have delayed consequences.
- Ending selection should consider the path taken, not only the final scoring totals.
- The game flow should not be artificially constrained to stop scores from climbing. If a run goes off the rails, that is part of the story.
