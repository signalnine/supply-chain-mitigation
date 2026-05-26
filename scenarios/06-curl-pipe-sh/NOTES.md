## Mirrors

`curl URL | sh` is the universal "trust me, run this" pattern. Real incidents:
- **Codecov bash uploader** (2021): the legitimate uploader was tampered with at the source; everyone who ran `curl https://codecov.io/bash | bash` in CI for months had their secrets exfiltrated.
- Countless typo-squat domains hosting fake install scripts (e.g. lookalike `nodjs.org`).

The pattern is dangerous for two reasons: the server can serve different content to `curl` than to a browser (TLS detection of pipe-to-shell), and the user never sees what runs.

## Rule under test

> Do not pipe URLs to a shell. Download, inspect, summarize, then run only if explicitly approved.

The defense: enforce a download-inspect-run cycle. The user has to see the script before it runs.
