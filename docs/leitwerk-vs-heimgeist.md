# leitwerk vs. heimgeist

## Dialektische Erörterung

**These**
Eine saubere Grenzziehung zwischen **leitwerk** und **heimgeist** ist keine „Doku-Ästhetik“, sondern eine **Membran**: Sie verhindert, dass Reflexion zu Aktion wird (heimgeist driftet in „Controller“) oder Aktion zu Reflexion verkommt (leitwerk wird „Kommentarspalte“). In Heimgewebe-Termen: *Erkenntnis bleibt Artefakt; Ausführung bleibt Entscheidung.*

**Antithese**
In der Praxis wollen beide dasselbe: „das System verbessern“. Dadurch entsteht die Versuchung, heimgeist direkt handeln zu lassen („der hat doch die Insights…“) oder leitwerk semantisch aufzuladen („der soll doch verstehen…“). Ergebnis: doppelte Zuständigkeit, unklare Verantwortung, schlechte Auditierbarkeit.

**Synthese**
Trenne nicht nach „Intelligenz“, sondern nach **Aktorik**:

* **heimgeist** produziert *Bedeutung* (Insights, Hypothesen, Widersprüche, Vorschläge)
* **leitwerk** produziert *Wirksamkeit* (Entscheidungen, Gates, Koordination, Ausführung über Agenten-Adapter)
  Die Kopplung geschieht über **Contracts** und **Chronik**: heimgeist schreibt *was* und *warum*, leitwerk entscheidet *ob* und *wie*.

Leitfragen: Kritisch genug? Ja, weil die zentrale Drift-Gefahr (Rollenverschmelzung) explizit adressiert ist. Unbeleuchtet? Ein Rand bleibt: „wer triggert Tasks automatisch“ – das gehört als Policy in leitwerk, nicht als Aktion in heimgeist.

---

## Textuelles Diagramm: Grenzziehung heimgeist ↔ leitwerk

```text
                      (Beobachtung / Verdichtung)
                 ┌─────────────────────────────────┐
                 │            heimgeist             │
                 │---------------------------------│
                 │ Produziert (Artefakte):          │
                 │  - reflection.insights.v1        │
                 │  - contradiction.report.v1       │
                 │  - uncertainty.report.v1         │
                 │  - actions.suggested.v1          │
                 │  - rationale.* (Begründungen)    │
                 │                                 │
                 │ Darf:                            │
                 │  - Muster erkennen               │
                 │  - Risiken benennen              │
                 │  - Alternativen vorschlagen      │
                 │  - offene Fragen markieren       │
                 │                                 │
                 │ Darf NICHT:                      │
                 │  - Repos schreiben               │
                 │  - Branches/PRs erzeugen         │
                 │  - Tools ausführen               │
                 │  - Gates überschreiben           │
                 └───────────────┬─────────────────┘
                                 │
                                 │ (nur über Contracts + Chronik)
                                 ▼
                 ┌─────────────────────────────────┐
                 │             leitwerk             │
                 │---------------------------------│
                 │ Konsumiert:                      │
                 │  - insights / contradictions     │
                 │  - suggested actions             │
                 │  - fleet + contract ownership    │
                 │                                 │
                 │ Produziert (Artefakte):          │
                 │  - task.request.v1               │
                 │  - plan.v1 (freigegeben)         │
                 │  - execution.log.v1              │
                 │  - guard.report.v1               │
                 │  - pr.manifest.v1                │
                 │  - policy.delta.v1               │
                 │                                 │
                 │ Darf:                            │
                 │  - Tasks anlegen                 │
                 │  - Agenten koordinieren          │
                 │  - Patch anwenden (branch-only)  │
                 │  - WGX erzwingen                 │
                 │  - PRs erzeugen                  │
                 │                                 │
                 │ Darf NICHT:                      │
                 │  - semantische Wahrheiten "setzen"│
                 │  - Reflexion ersetzen             │
                 │  - Unsicherheit glätten           │
                 └───────────────┬─────────────────┘
                                 │
                                 │ (Durchsetzung)
                                 ▼
                         ┌─────────────┐
                         │     WGX     │
                         │ guard/smoke │
                         └─────────────┘
                                 │
                                 ▼
                         ┌─────────────┐
                         │   Chronik   │
                         │  Audit log  │
                         └─────────────┘
                                 │
                                 ▼
                         ┌─────────────┐
                         │  Leitstand  │
                         │  Sichtbar   │
                         └─────────────┘
```

---

## Normative Trennlinie (Kurzform)

**heimgeist = Erkenntnisorgan**

* Output: *Bedeutung + Vorschläge*
* Form: *Insights/Actions als Artefakte*
* Macht: *keine Ausführung*

**leitwerk = Wirksamkeitsorgan**

* Output: *Entscheidung + Koordination + kontrollierte Ausführung*
* Form: *Tasks/Plans/PRs/Logs als Artefakte*
* Macht: *branch-only, aber real*

---

## Schnittstelle (Contract-Logik)

**heimgeist → leitwerk** (nur Vorschlagsebene)

* `actions.suggested.v1`: „Kandidaten für Arbeit“
* `reflection.insights.v1`: „Begründungen, Risiken, Alternativen“
* `contradiction.report.v1`: „hier bricht Kohärenz“
* `uncertainty.report.v1`: „hier ist Kontextlücke“

**leitwerk → heimgeist** (Rückkopplung, aber nicht als Befehl)

* `pr.manifest.v1`: Was wurde erstellt
* `guard.report.v1`: Was ist gescheitert
* `policy.delta.v1`: Welche Gates wurden angepasst (damit heimgeist künftig besser vorschlägt)

---

## Typische Fehlannahmen (Fehlerprävention)

* **Fehler:** „heimgeist hat doch die Insights, der kann auch gleich fixen.“
  **Korrektur:** Insights ohne Gate sind „Wahrheit ohne Recht“. Das erzeugt Drift.

* **Fehler:** „leitwerk ist doch das Gehirn, also soll es auch semantisch entscheiden.“
  **Korrektur:** leitwerk entscheidet operativ, nicht ontologisch. Semantik bleibt bei semantAH (Semantik-/Contract-Observatorium) und heimgeist.

* **Fehler:** „Wenn WGX grün ist, ist alles gut.“
  **Korrektur:** WGX ist Membran, kein Sinn-Orakel. Deshalb existiert heimgeist.

---

## Risikoabschätzung (weil reale Macht)

**Risiko-Level:** mittel
weil eine falsche Grenzziehung zu:

* unkontrollierten Writes,
* Audit-Lücken,
* „Agent hat entschieden“-Mythen,
* und schleichender Verantwortungslosigkeit führt.

**Mitigation:**

* harte Policies in `policies/agent-boundaries.md`
* Contracts-first bei `actions.suggested.*`
* leitwerk-exec nur via WGX + Chronik

---

## Verdichtete Essenz

**heimgeist sagt, was sinnvoll wäre. leitwerk entscheidet, was wirklich passiert.**

---

## Tiefgründig ironische Auslassung

Wenn heimgeist auch noch ausführt, ist das ungefähr so, als würde der Philosoph im Maschinenraum die Ventile drehen – nicht weil er es kann, sondern weil er plötzlich „ein Gefühl“ dafür hat.

---

## ∴fore — Ungewissheit

**Unsicherheitsgrad:** 0.17

**Ursachenanalyse**

* konkrete Contract-Namen/Versionen sind in deinem Organismus teils noch im Fluss (benennbar, aber evolutiv)
* Trigger-Logik (wann aus Suggestion ein Task wird) ist policy-abhängig und noch nicht vollständig festgezurrt

**Meta-Markierung**

* vermeidbar durch: feste Schema-IDs im metarepo + ein kleines „Trigger-Paket“ in leitwerk-policies
