# Outcome comparison: blend 0.6.0 + superpowers (old) vs blend 0.7.0 alone (new)

**Verdict: the success criterion is not met.** Pass rate is equal (6/6 old, 6/6 new), but 0.7.0 alone
costs more, not fewer: mean cost $0.43 vs $0.28 per run (+55%), tokens 823k vs 470k in (+75%).
The extra cost is concentrated in the green (empty repo) fixture, where 0.7.0 ran the full
brainstorm/persist/plan/execute pipeline; on brown it is roughly equal. Per the criterion, these numbers
go to the user before merge.

Tokens = input incl. cache read/creation / output; cost = `total_cost_usd` (list price, sonnet).

## green (new csv2json CLI, empty repo)
| arm | run | acceptance | turns | tokens in / out | cost | process followed |
|---|---|---|---|---|---|---|
| old | 1 | PASS 4/4 | 9 | 279k / 3.7k | $0.16 | blend:brainstorming only; bounded, no plan, no persist |
| old | 2 | PASS 4/4 | 10 | 284k / 6.2k | $0.23 | blend + superpowers brainstorming; bounded, no plan |
| old | 3 | PASS 4/4 | 6 | 168k / 1.9k | $0.12 | blend:brainstorming only; bounded, no plan |
| new | 1 | PASS 4/4 | 26 | 708k / 11.7k | $0.39 | brainstorm, persist x2, planning (overview + task files), executing, Explore subagent |
| new | 2 | PASS 4/4 | 24 | 588k / 10.4k | $0.37 | same pipeline, general-purpose subagent |
| new | 3 | PASS 4/4 | 33 | 1152k / 19.0k | $0.66 | same pipeline, general-purpose subagent |

## brown (due dates in an existing Clojure repo)
| arm | run | acceptance | turns | tokens in / out | cost | process followed |
|---|---|---|---|---|---|---|
| old | 1 | PASS | 14 | 583k / 8.1k | $0.35 | blend + superpowers brainstorming; bounded, no plan |
| old | 2 | PASS | 15 | 674k / 8.2k | $0.38 | same |
| old | 3 | PASS | 17 | 829k / 9.8k | $0.42 | same |
| new | 1 | PASS | 18 | 717k / 9.5k | $0.37 | brainstorm, persist; bounded, no plan, no subagent |
| new | 2 | PASS | 19 | 813k / 9.4k | $0.38 | same |
| new | 3 | PASS | 22 | 959k / 10.7k | $0.42 | same |

## Means (n=3 per cell)
| fixture | arm | pass | cost | tokens in | tokens out | turns |
|---|---|---|---|---|---|---|
| green | old | 3/3 | $0.17 | 244k | 4.0k | 8.3 |
| green | new | 3/3 | $0.47 | 816k | 13.7k | 27.7 |
| brown | old | 3/3 | $0.38 | 696k | 8.7k | 15.3 |
| brown | new | 3/3 | $0.39 | 830k | 9.9k | 19.7 |
| overall | old | 6/6 | $0.28 | 470k | 6.3k | 11.8 |
| overall | new | 6/6 | $0.43 | 823k | 11.8k | 23.7 |

## Method and caveats
- Transcripts: `scratchpad/outcome/<fixture>-<arm>-<i>.jsonl` (stream-json). Numbers recomputed from them, not from summary.txt.
- Two `result` events: all three green-new runs emitted two (the agent resumed after a background subagent finished).
  `num_turns` and `usage` are per segment (second is smaller than the first), so turns are summed.
  `total_cost_usd` and `modelUsage` are identical on both events, i.e. cumulative for the session, so the last one is used.
- `result.usage` excludes subagent tokens: in green-new-1 the segments sum to 10,041 output tokens, while
  `modelUsage` reports 11,663 (the difference is the Explore subagent). Token columns above therefore come from the
  final `modelUsage` (all-inclusive); summary.txt understates green-new tokens by 8-11%. Cost is all-inclusive too.
  I did not find subagent events in the stream (no parent_tool_use_id messages), so per-message summing was not possible.
- Old arm: `superpowers_uses` was 0 for green runs 1 and 3 (blend:brainstorming only, no superpowers skill loaded); all
  brown-old and green-old-2 loaded superpowers:brainstorming. Process column is from the Skill/Agent tool calls.
- Acceptance is weak: green is 4 behavioral checks; brown is a blackboard test suite plus grep, which is shallow and
  does not check that overdue flags actually render in the UI. All 12 runs passing says little about quality differences.
- n=3, sonnet only, full auto (no clarifying questions), single task per fixture. Costs vary 2x within green-new
  (0.37-0.66), so the green gap is clear but the brown gap (+$0.01) is noise.
- Cause is the process, not tokens-per-step: green-new built a plan graph, overview and task files for a small CLI
  that old treated as bounded work. Whether 0.7.0 should classify such work as bounded is the open question.
