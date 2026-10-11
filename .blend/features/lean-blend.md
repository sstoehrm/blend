# Lean blend (0.8.0)

Do less, leave more freedom. Brainstorming is a conversation whose results
land in feature files and the two graphs; building is one full-auto step.

Touches: architecture#brainstorm, architecture#build, architecture#persist, modules#brainstorming, modules#build, modules#persist, modules#use-blend

## Decisions
- Features are free markdown, one file per feature; no features graph.
  Graph nodes link to a feature with `:md-ref` only while `:state :new`;
  the feature's `Touches:` line is the reverse link.
- Six skills became four: planning + executing → build; debugging → rules
  in use-blend. No involvement levels, paths or gates; system.md dropped.
- persist merges derived modules (planned nodes survive) and only updates
  architecture, never redraws it. Marker: first line of modules.edn.
- build branches before committing anything, updates graphs only when the
  repo has them, reviews once on the session model, never merges or pushes.

## Outcome (2026-10-11, sonnet, headless, 3 runs per cell, all PASS)
| Fixture | 0.6.0 + superpowers | 0.7.0 | 0.8.0 |
| --- | --- | --- | --- |
| green: new csv2json CLI | $0.17 | $0.47 | $0.22 |
| brown: due dates in smpl-blackboard | $0.38 | $0.39 | $0.42 |
| mean | $0.28 | $0.43 | $0.32 |

- 0.8.0 adds a whole-branch review that 0.6.0 never ran; on brown it costs
  about $0.20 (the one brown run that skipped it cost $0.29).
- Prompts differ by arm (0.8.0 names blend:build), so the comparison is
  indicative, not controlled. Acceptance is shallow (4 CLI checks; the
  blackboard suite plus grep).
- Reliability: the review was skipped in 1 of 6 final runs.
