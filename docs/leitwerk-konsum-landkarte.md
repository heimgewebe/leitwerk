> [!IMPORTANT]
> **Historische Referenz.** Seit dem 29. Juli 2026 ist dieses Dokument nicht mehr normativ. Aktive gemeinsame Änderungsgrenzen liegen in `heimgewebe/metarepo@74ce9202952d00b0d2fef0587255c92a9cd05dee:contracts/operator/agent-change-boundaries.v1.json`. Aufgabenwahrheit liegt im Bureau, lokale Ausführung in Grabowski und Ökosystemsemantik im Systemkatalog.

# Konsum- und Wirkungslandkarte von leitwerk

## Dialektische Erörterung

**These**
leitwerk wirkt nicht durch Ausführung, sondern durch **verbindliche Lesbarkeit**.
Ein Organismus wird nicht dadurch kohärent, dass alle alles wissen – sondern dadurch, dass **jedes Organ genau weiß, *wo* es nachschlagen muss**.

**Antithese**
Wenn leitwerk „allgemein relevant“ wird, liest es niemand mehr richtig.
Wenn es als „nur Doku“ missverstanden wird, verliert es Durchsetzungskraft.

**Synthese**
leitwerk ist **adressierte Norm**:
jedes Organ konsumiert **bestimmte Dateien**, zu **bestimmten Zeitpunkten**, mit **klarer Funktion**.

---

## 1. agent-control-surface (ACS)

### Was liest ACS?

**Primär**

* `docs/leitwerk.md`
* `docs/grenzen.md`
* `docs/entscheidungslogik.md`

**Sekundär**

* Metarepo-Antipattern-Katalog (extern, metarepo)
* `contracts/*.schema.json` (zur Formvalidierung)

### Wann?

* beim Start (statisch)
* beim Anzeigen von:

  * Task-Plan-Preview
  * Kill-Switch-Warnungen
  * Policy-Level-Auswahl (dry-run / exec)

### Warum?

ACS ist **Übersetzer zwischen Mensch und Organismus**.
Es darf nichts *entscheiden*, aber alles *korrekt einordnen*.

👉 leitwerk liefert ACS:

* **Begründungstexte**
* **Verbotslogik**
* **explizite Grenzen**, die ACS UI-seitig sichtbar macht

### Wichtig

ACS **implementiert keine Regeln selbst**.
Es zeigt Regeln aus leitwerk an.

---

## 2. heimgeist

### Was liest heimgeist?

**Primär**

* `docs/grenzen.md`
* metarepo-kanonischer Contract actions.suggested.v1 (Owner: metarepo; in leitwerk nicht gespiegelt)
* `contracts/artifacts/uncertainty.report.v1.schema.json`

**Explizit nicht**

* `docs/leitwerk.md` (nur referenziert, nicht interpretiert)

### Wann?

* bei der Erzeugung von:

  * `insights.*`
  * `actions.suggested.*`
* bei Reflexionsläufen („Warum ist das schiefgelaufen?“)

### Warum?

heimgeist **erkennt und schlägt vor** – aber entscheidet nicht.

leitwerk definiert:

* welche **Form** Vorschläge haben müssen
* welche **Unsicherheit** explizit benannt werden muss
* was **keine Aktion** werden darf

👉 leitwerk ist für heimgeist **Membran**, nicht Ziel.

---

## 3. Jules CLI / andere Agenten (Copilot, lokale Agenten, später eigene)

### Was lesen Agenten?

**Primär**

* `docs/agentik.md`
* `docs/grenzen.md`
* metarepo-kanonischer Contract task.request.v1 (Owner: metarepo; in leitwerk nicht gespiegelt)
* `contracts/artifacts/uncertainty.report.v1.schema.json`

**Optional (read-only Kontext)**

* Auszüge aus `docs/leitwerk.md`
  **niemals das ganze Dokument**

### Wann?

* beim Start eines Tasks
* beim Erstellen eines Plans
* bei Unsicherheits- oder Konfliktmeldung

### Warum?

Agenten brauchen:

* **klare Rolle**
* **klaren Aufgabenrahmen**
* **klare Abbruchkriterien**

leitwerk verhindert:

* dass Agenten „mitdenken müssen“, *wo* sie sind
* dass sie implizite Macht über das System entwickeln

👉 Agenten **arbeiten innerhalb leitwerk**, nicht *für* leitwerk.

---

## 4. WGX (Guards / Smoke / Metriken)

### Was liest WGX?

**Indirekt**

* Referenzen auf:

  * `contracts/*`
  * `docs/entscheidungslogik.md` (Policy-Hinweise)

### Wann?

* vor Merge
* nach Exec
* bei Policy-Verletzungen

### Warum?

WGX ist **Durchsetzungsorgan**, kein Denkorgan.

leitwerk liefert:

* die **Begründung**, warum ein Guard existiert
* nicht die Implementierung

👉 Wenn WGX etwas blockiert, kann leitwerk erklären *warum*.

---

## 5. leitstand

### Was liest leitstand?

**Primär**

* `docs/leitwerk.md`
* `docs/entscheidungslogik.md`

**Sekundär**

* Metarepo-Changelog (extern, metarepo)
* Metarepo-Antipattern-Katalog (extern, metarepo)

### Wann?

* beim Visualisieren von:

  * Task-Timelines
  * Systemzuständen
  * Drift-Indikatoren

### Warum?

leitstand zeigt **keine Daten ohne Deutung**.
leitwerk liefert den **Deutungsrahmen**.

👉 leitstand + leitwerk = Beobachtung **mit Bedeutung**.

---

## 6. metarepo

### Was liest metarepo?

**Primär**

* `contracts/*`
* Referenzen aus `docs/leitwerk.md`

### Wann?

* bei Definition neuer Invarianten
* bei Anpassung von Fleet-Policies

### Warum?

metarepo ist **Control-Plane**, leitwerk ist **Norm-Plane**.

Beide müssen konsistent sein, aber:

* metarepo **setzt**
* leitwerk **begründet**

---

## 7. Was niemand tun darf

Das ist entscheidend.

❌ Kein Organ darf:

* leitwerk automatisch verändern
* leitwerk „interpretieren“
* leitwerk als Prompt-Futter missbrauchen

❌ leitwerk:

* führt keinen Code aus
* erzeugt keine PRs
* startet keine Agenten

Wenn das passiert → Architekturbruch.

---

## Verdichtete Essenz

**leitwerk wird nicht benutzt wie ein Tool.
Es wird konsultiert wie ein Gesetzestext.**

Wer es ignoriert, handelt blind.
Wer es automatisiert, entmachtet den Organismus.

---

## ∴fore — Ungewissheit

**Unsicherheitsgrad:** 0.14

**Ursachen**

* Feinabstimmung, *welche* Abschnitte Agenten kontextuell sehen dürfen
* UI-Kopplung in ACS noch nicht real implementiert

**Meta**
Diese Ungewissheit ist **strukturell gesund**:
sie zwingt zu expliziten Zugriffspfaden statt impliziter Allwissenheit.
