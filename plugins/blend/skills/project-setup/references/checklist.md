# Project setup checklist

Each row: what counts as present, then the fix. n/a only for the reason
given.

## Supply chain and CI

| Item | Present when | Fix |
| --- | --- | --- |
| Vulnerability gate | CI builds an SBOM, scans it, and fails on the KEV/EPSS policy | [vuln-gate.md](vuln-gate.md) |
| Dependency updates | `.github/dependabot.yml` or `renovate.json` covers every detected stack, CI config included | see SKILL.md, Stacks and update tools |
| Required checks | a ruleset (or protected branch) on the default branch requires PRs, the gate and the tests as status checks, and blocks force pushes | GitHub: Settings → Rules → Rulesets; GitLab: protected branches + "Pipelines must succeed". Without it the gate is only a report |
| Secret scanning | GitHub secret scanning and push protection on, or gitleaks in CI (and pre-commit); GitLab: Secret Detection template | private GitHub repos may need Secret Protection; gitleaks works everywhere |
| SAST | CodeQL (default setup) or GitLab SAST for the supported languages | Clojure has no CodeQL support: clj-kondo in CI is the floor |
| Workflow hygiene | workflows set least-privilege `permissions:` (default `contents: read`), pin third-party actions to full commit SHAs, never check out PR code under `pull_request_target` | the update tool keeps SHA pins current |
| Tests in CI | every PR runs the test suite | — |

## Legal

| Item | Present when | Fix |
| --- | --- | --- |
| Code license | `LICENSE` with a recognisable SPDX license, the same id in the manifests' license field and the README | ask the user which; no license means all rights reserved |
| Data license | every non-code part (datasets, docs, images, fonts, models, fixtures copied from elsewhere) has a stated license, often different from the code's (e.g. CC-BY-4.0, CC0-1.0, ODbL-1.0) | `LICENSES/<SPDX>.txt` plus `REUSE.toml` mapping paths to licenses, or a README section that does the same. n/a: code only |
| Third-party notices | `THIRD_PARTY_NOTICES.md` lists copied or adapted code with its license text, and, when an artifact ships, the bundled dependencies | generate the dependency part from the CycloneDX SBOM (it carries license ids); keep copied code by hand. Flag copyleft (GPL, AGPL, SSPL), unknown or missing licenses for review |
| Privacy | personal data handled (accounts, analytics, telemetry, logs with IPs or emails) → `PRIVACY.md` or a linked privacy notice: what is collected, why, legal basis, retention, processors, user rights, contact | n/a: handles no personal data — say so in the README |

## Policy and repo

| Item | Present when | Fix |
| --- | --- | --- |
| Security policy | `SECURITY.md` (root, `.github/` or `docs/`): supported versions, how to report, expected response time, disclosure | GitHub: enable private vulnerability reporting and point to it; else a security email |
| CODEOWNERS | `CODEOWNERS` covers at least CI config and security-relevant paths | — |
| README | says what it is, how to install, build, test, and the license | — |
| Community files | public repo: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, issue and PR templates | n/a: private |
| Releases | `CHANGELOG.md` or release notes, semver tags; published artifacts get build provenance (`actions/attest-build-provenance`) or signed tags | n/a: nothing released |
| Hygiene | `.gitignore` covers build output, IDE files and `.env`; `.env.example` instead of committed secrets; `.editorconfig` | — |
