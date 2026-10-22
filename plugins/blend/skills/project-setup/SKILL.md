---
name: project-setup
description: Use when setting up a new repo or auditing an existing one for the basics a project should have — vulnerability gate in CI, dependency updates (Dependabot or Renovate), branch protection, secret scanning, licenses for code and data, third-party notices, SECURITY.md, privacy — or when the user asks what a project is missing.
---

# Project setup

A checklist run against the current repo. Report first; change only
the rows the user picks.

1. **Detect.** Host from `git remote -v` (github.com → GitHub, gitlab →
   GitLab, none → ask). Stacks from the manifests below. Public or
   private (`gh repo view --json visibility`). Whether it ships an
   artifact (package, uberjar, binary, container image), handles
   personal data, or contains data or content beyond code.
2. **Check** every row of [references/checklist.md](references/checklist.md):
   present, missing, partial or n/a, with the evidence (path, setting).
   Repo settings (rulesets, secret scanning, private vulnerability
   reporting): read them with `gh api` when it is authenticated, else
   mark them "check by hand".
3. **Report** one table — item | status | evidence | fix — missing rows
   first. Below it, one line per detected stack saying which update tool
   covers it.
4. **Ask** which rows to add. Then implement only those, on a branch.
   The vulnerability gate follows
   [references/vuln-gate.md](references/vuln-gate.md). Never pick a
   license, a privacy statement's content or a security contact for the
   user: ask, then write.
5. **End** with what is still open, settings that must be changed by
   hand first, each with its exact settings page.

## Stacks and update tools

| Manifest | Stack | Dependabot `package-ecosystem` | Renovate manager |
| --- | --- | --- | --- |
| `build.gradle(.kts)`, `settings.gradle(.kts)` | Gradle | `gradle` | `gradle` |
| `pom.xml` | Maven | `maven` | `maven` |
| `package.json` + lockfile | npm | `npm` | `npm` |
| `pyproject.toml`, `requirements*.txt` | Python | `pip` | `pep621`, `poetry`, `pip_requirements` |
| `go.mod` | Go | `gomod` | `gomod` |
| `deps.edn`, `bb.edn` | Clojure, babashka | — | `deps-edn` (matches both) |
| `project.clj` | Leiningen | — | `leiningen` |
| `Dockerfile` | container | `docker` | `dockerfile` |
| `.github/workflows/*.yml` | GitHub Actions | `github-actions` | `github-actions` |
| `.gitlab-ci.yml` | GitLab CI | — | `gitlabci` |

Choose one update tool per repo:

- GitHub and every stack has a Dependabot row → Dependabot
  (`.github/dependabot.yml`, one entry per ecosystem and directory,
  weekly, minor and patch grouped).
- Any Clojure stack, or GitLab → Renovate (`renovate.json`; on GitHub
  the Renovate app, on GitLab a scheduled Renovate runner job).
  Dependabot alerts may stay on. Turn off Dependabot's security and
  version update PRs so the two tools don't open duplicates.

Before writing either config, check the tool's docs for the current
ecosystem list; the table above was checked in October 2026.
