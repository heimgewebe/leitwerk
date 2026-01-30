# Fortschritt leitwerk (Phase 1)

## Abgehakt (gelesen/verstanden, mit Belegen)
- [x] Grundbeschreibung und Rollenbild gesichtet. (Beleg: `README.md`, `docs/leitwerk.md`)
- [x] Policies geprüft: Invarianten, Agent-Grenzen, Write-Gates. (Beleg: `policies/invariants.md`, `policies/agent-boundaries.md`, `policies/write-gates.md`)
- [x] Interfaces geprüft: ACS, Agent, WGX. (Beleg: `interfaces/acs.md`, `interfaces/agent.md`, `interfaces/wgx.md`)

## Abgeleitete Phase-1-Anforderungen (Arbeitsannahmen, noch zu ratifizieren)
- [ ] Branch-only-Workflow erzwingen (Policy/CI, z. B. Branch-Protection; kein Direkt-Write auf Hauptzweige).
- [ ] WGX-Guards als Pflicht-Gate für PRs und alle ACS-triggered Runs (CI + optional lokal).
- [ ] Agenten liefern mindestens: Plan, Patch, Begründung, Unsicherheiten (Contract/Owner noch festzulegen).
- [ ] Artefaktstatus + Guard-Feedback an ACS zurückmelden.
- [ ] Unsicherheit persistieren (als Artefakt; Schema folgt).

## Nächster Schritt
- [ ] Phase-1-Checkliste konkretisieren: Welche Artefakte, welche Gate-Prüfungen, welche Mindestfelder pro Interface.

Notizstatus: nicht normativ (Arbeitsstand).
