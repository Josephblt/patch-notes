# Patch Notes Game Design

## Concept

Patch Notes is a satirical text/card game about shipping game updates under pressure from two stakeholders:

- Players want Fun.
- Investors want Money.

The player reads proposed update cards, chooses what to ship or discard, and watches how those decisions affect the game's relationship with both groups.

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
5. Repeat for 10 releases.
6. Receive an ending based on the final state of Fun and Money.

## Rules

- Fun starts at 0.
- Money starts at 0.
- Hand size is 3 cards.
- The full possible deck has 144 unique cards.
- No card can be drawn twice.
- Each card affects one Fun node and one Money node.
- Level 2 node effects are +/- 3.
- Level 3 node effects are +/- 1.
- Tree nodes are categories only. They do not store values or propagate effects.

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

## Card Format

```text
CARD TITLE

Short description of the update.

SIGNAL
Short poetic or satirical consequence line.

Fun - Level N - Node - Positive/Negative (+/-points)
Money - Level N - Node - Positive/Negative (+/-points)
```

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

- Whether the player should ship exactly one card per release.
- Whether discarded cards should have any delayed consequences.
- Whether ending bands should use only final Fun/Money totals or also track the path taken.
- How much friction is needed to keep scores from climbing too easily.
