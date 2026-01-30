# Phase 1 Checkliste: Konkretisierung

Basierend auf `docs/leitwerk.md`, `policies/` und `interfaces/`.

## 1. Erforderliche Artefakte (Minimum)

Diese Artefakte müssen physisch (als Datei oder Objekt) existieren, bevor eine Ausführung stattfinden darf.

- [ ] **`context.bundle.v1`**
    - Inhalt: Relevante Files, Pfade, Contracts, User-Prompt.
    - Zweck: Input für den Agenten, Reproduzierbarkeit.
- [ ] **`plan.v1`**
    - Inhalt: Sequenz von Schritten, die der Agent plant.
- [ ] **`patch.v1`**
    - Inhalt: Der konkrete Code-Change (Diff).
    - Format: Git-kompatibler Patch.
- [ ] **`rationale.v1`**
    - Inhalt: Begründung für Plan und Patch (Warum?).
- [ ] **`uncertainty.report.v1`**
    - Inhalt: Unsicherheits-Score (0.0-1.0), benannte Risiken.

## 2. Gate-Prüfungen (Logik)

Diese Prüfungen müssen `TRUE` ergeben, sonst Abbruch.

- [ ] **Git-Pre-Flight**
    - `git apply --check` läuft erfolgreich durch.
    - Target-Branch ist NICHT `main` / `master` / protected.
- [ ] **Invarianz-Check**
    - Patch enthält keine Änderungen an `policies/` oder `leitwerk` selbst (außer via Meta-Prozess).
- [ ] **WGX-Guard**
    - Alle definierten WGX-Policies für den Scope sind erfüllt.
- [ ] **Unsicherheits-Schwelle**
    - Wenn Uncertainty > Threshold (z.B. 0.3) -> **Erzwinge** explizite Zusatz-Bestätigung (Mensch).

## 3. Mindestfelder pro Interface

### ACS (Input/Output)
- **Input:**
    - `prompt`: String (Die Aufgabe)
    - `context_scope`: Liste von Pfaden/Files (Worauf bezieht sich die Aufgabe?)
- **Output:**
    - `status`: `PENDING` | `APPROVED` | `REJECTED` | `FAILED`
    - `artifacts`: Links/Pfade zu den erzeugten Artefakten.
    - `logs`: Verweis auf `execution.log`.

### Agent (Input/Output)
- **Input:**
    - `context.bundle.v1`
- **Output:**
    - `plan`: Text/Liste
    - `patch`: Diff-String
    - `rationale`: Text
    - `uncertainty`:
        - `score`: Float
        - `reasons`: Liste von Strings

### WGX (Input/Output)
- **Input:**
    - `patch.v1`
    - `context.scope`
- **Output:**
    - `verdict`: `PASS` | `BLOCK`
    - `violations`: Liste von Regel-Verstößen (wenn BLOCK).

---
Status: Entwurf zur Ratifizierung.
