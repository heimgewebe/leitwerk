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

## Erledigt
- [x] Phase-1-Checkliste konkretisiert. (Siehe: `notes/phase-1-checklist.md`)

## Nächster Schritt
- [ ] Artefakt-Schemas formalisieren (JSON-Schema für `plan.v1`, `patch.v1` etc. im metarepo).

Notizstatus: nicht normativ (Arbeitsstand).
