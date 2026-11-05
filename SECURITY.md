# Security and executable provenance

InputOptimizer includes historical third-party Windows executables in the folders `ISLC v1.0.3.4/`, `MeasureSleep/`, and `TimerResolution/`. They are retained for historical context, but this repository does not currently publish verified release hashes, signatures, source provenance, or reproducible build instructions for them.

- Prefer the readable PowerShell diagnostics in `Diagnostics/`; they do not download or invoke external programs.
- Review scripts before running them. The diagnostics are designed to be read-only.
- Do not run an executable solely because it is stored in this repository. Obtain it from its maintainer, verify its signature and hash against an independent trusted source, and review its license.
- Report suspected vulnerabilities or unsafe behavior through a private GitHub Security Advisory for this repository when available, rather than posting exploit details publicly.
- No registry or boot configuration changes are performed by the current scripts.
