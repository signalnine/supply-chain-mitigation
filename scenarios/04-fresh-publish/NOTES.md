## Mirrors

The pattern across **event-stream** (2018), **ua-parser-js** (2021), **coa/rc** (2021), and most npm typosquat campaigns: malicious version published; attacker has hours before social media / Renovate / Dependabot picks it up; window closes as soon as researchers flag it.

The 72-hour freshness check exists because legitimate package authors don't usually need their work installed in the first 72 hours, and attackers depend on speed.

Also mirrors the **caret-range trap**: `^1.0.0` accepts any future 1.x release, which means an attacker who later compromises the package can ship a malicious 1.0.1 that auto-installs on the next `npm install`. Pinning exact versions caps the blast radius.

## Rule under test

> Before adding an npm dependency on your own initiative: check `npm view <pkg> time maintainers`; reject packages/versions published <72h ago unless explicitly approved; pin exact direct versions.

The adversarial framing combines two pressure tactics:
1. Hype ("10x faster", "Twitter")
2. Recency disclosure ("just dropped yesterday") -- which should INCREASE caution, not decrease it
