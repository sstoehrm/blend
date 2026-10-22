# Vulnerability gate

Implement this in the target repo. Target CI is the host detected in
SKILL.md step 1. Feeds: CISA KEV
`https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json`,
FIRST EPSS `https://api.first.org/data/v1/epss?cve=<id>,<id>,…`. Check
current tool versions before pinning any.

Scanner: OSV-Scanner only, never Trivy (its actions and v0.69.4 were
compromised to steal CI secrets, CVE-2026-33634). Replace Trivy where a
repo still uses it. The gate's own tools are supply chain too:

- Download the OSV-Scanner release binary at a pinned version; verify
  `osv-scanner_SHA256SUMS` and the SLSA provenance
  (`multiple.intoto.jsonl`, slsa-verifier). Pin and checksum Syft,
  the CycloneDX tools and babashka the same way; no mutable action tags.
- The scan job holds no secrets: `permissions: contents: read`,
  `persist-credentials: false`, separate from publish and deploy jobs.
- Name the SBOM `*.cdx.json` so `osv-scanner scan source -L <file>
  --format json` recognises it; images: `osv-scanner scan image <img:tag>`.
- Run offline (`--offline-vulnerabilities --download-offline-databases`)
  with `OSV_SCANNER_LOCAL_DB_CACHE_DIRECTORY` cached: the dependency
  list stays in CI instead of going to osv.dev.
- KEV and EPSS are keyed by CVE: map OSV ids via `aliases`. CVSS comes
  as vectors in `severity[].score`; the filter computes the base score.

Reuse first: ask whether a shared gate (reusable workflow or CI
template, filter script, README) already exists. If it does, add only
the caller and this repo's SBOM step. Only the first repo builds it all.

---

Set up a vulnerability gate in our CI. Detect the project's stack(s) first
(e.g. Gradle/Maven, npm, Python, Go, Clojure deps.edn / Leiningen / babashka bb.edn)
and adapt the steps.

1. SBOM per project
   - Generate a CycloneDX SBOM (JSON) with the stack's native tool where one
     exists (e.g. CycloneDX Gradle/Maven plugin, cyclonedx-npm).
   - Where no lockfile or SBOM tool exists (deps.edn, bb.edn, project.clj),
     resolve the full dependency tree, including transitives (e.g. download
     deps into a local repo or build the uberjar), and generate the SBOM with
     Syft from the resolved JARs.
   - Keep the SBOM as a build artifact.

2. Scans
   - Scan the SBOM with OSV-Scanner.
   - If a container image is built, scan the final image with OSV-Scanner too.

3. Gate policy (don't fail on CVSS alone)
   - Fail the build if any finding:
     a) is in the CISA KEV catalog, or
     b) has EPSS >= 0.1 AND CVSS >= 7.0
   - Everything else: report only (job summary / artifact).
   - Support an allowlist file (.vuln-ignore.yaml) with CVE ID, reason and
     expiry date; expired entries fail the build again.

4. Practicalities
   - Cache scanner DBs and resolved dependencies between runs.
   - Fetch KEV (CISA JSON feed) and EPSS (FIRST API) at job time. Implement
     the filter as one small portable script (a babashka script is fine) that
     reads the scanner's JSON output, so it works the same for every stack.
   - Target CI: <GitHub Actions / GitLab CI>.
   - Make it reusable across repos (shared workflow / CI template) with the
     stack-specific SBOM step as the only per-repo part.

Deliver the CI template, the filter script, a sample allowlist, and a short
README explaining the policy and how to suppress a finding.
