# Patch Notes Game Design

## Concept

Patch Notes is a satirical text/card game about shipping game updates under pressure from two stakeholders:

- Players want Fun.
- Investors want Money.

The player reads proposed update cards, chooses which ones make it into the release, and watches how those decisions affect the game's relationship with both groups.

The joke is not that every update is bad. The joke is that every update can be explained as progress, even when the cost lands somewhere inconvenient.

## Jam Theme

Patch Notes is being made for [Pirate Software - Game Jam 19](https://itch.io/jam/pirate).

Theme: **The Cost of Progress**

The game interprets the theme through product updates. Every shipped change moves the product forward for someone, but that progress has a cost paid in player trust, clarity, meaning, spending, conversion, reach, retention, or whatever the current meeting has decided to value.

## Core Loop

1. Draw a hand of update cards.
2. Choose which update to ship.
3. Discard the rest.
4. Apply the shipped card's Fun and Money effects.
5. Repeat for 10 sprints.
6. Receive an ending based on the final state of Fun and Money.

## Rules

- Fun starts at 0.
- Money starts at 0.
- Hand size is 3 cards.
- The full possible deck has 144 unique cards.
- No card can be drawn twice.
- Each card has hidden effects on one Fun node and one Money node.
- The player does not see the affected nodes, positive/negative labels, or point values on the card.

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

- Level 1 is the root: Fun.
- Level 2 nodes are broad themes worth +/- 3 points.
- Level 3 nodes are specific themes worth +/- 1 point.

Level 2 effects are stronger because they affect a broad part of the player experience. Level 3 effects are smaller because they target a narrower theme.

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

- Level 1 is the root: Money.
- Level 2 nodes are broad themes worth +/- 3 points.
- Level 3 nodes are specific themes worth +/- 1 point.

Like the Fun tree, Money nodes are categories only. They guide design and hidden scoring. They do not appear on player-facing cards.

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

Each card has one hidden Fun effect and one hidden Money effect. The pairing creates the design tension.

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
Fun - Level N - Node - Positive/Negative (+/-points)
Money - Level N - Node - Positive/Negative (+/-points)
```

This metadata is for the game logic and deck authoring process only.

## Tone

- Concise.
- Satirical.
- Dry and specific.
- Postmortem-like.
- Funny, but not goofy.
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
Most players left within the first week, loudly and permanently. The few who stayed spent enough money to make the dashboard look beautiful. Investors called it "a focused high-value audience." The community called it something less printable.
```

## Open Design Questions

- Whether the player should ship exactly one card per sprint.
- Whether discarded cards should have any delayed consequences.
- Whether ending bands should use only final Fun/Money totals or also track the path taken.
- How much friction is needed to keep scores from climbing too easily.
