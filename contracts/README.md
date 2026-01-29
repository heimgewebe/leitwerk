# Contracts

## Ownership

Primäre Quelle der Wahrheit für organismenweite Contracts ist das **metarepo**.
`leitwerk` hält hier **nur Referenzen und Spiegelungen**, damit Normen lesbar bleiben.

Wenn ein Schema hier liegt, gilt:
- **Owner:** metarepo
- **Status:** spiegelnd / dokumentierend
- **Änderungen:** zuerst im metarepo, dann spiegeln
- **$id:** kanonische URN (metarepo-Quelle), nicht lokaler Pfad

## Zweck

Dieses Verzeichnis dient der Auffindbarkeit und normativen Einordnung.
Es ersetzt keine zentrale Contract-Registry.

## Sync-Regel

`contracts/` ist ein read-only Spiegel der kanonischen Contracts aus dem **metarepo**.
Änderungen erfolgen **zuerst im metarepo**, danach werden sie hier gespiegelt.

PRs, die Dateien in `contracts/` ändern, müssen enthalten:
- eine Sync-Begründung (warum dieser Spiegelstand nötig ist) und
- eine Referenz auf die metarepo-Quelle (Commit/SHA/Tag oder ein Feld wie `SYNC_SOURCE`).
Direkte inhaltliche Contract-Änderungen in diesem Repo sind unerwünscht; nur Spiegelstände.
Die Sync-Quelle wird im PR-/Commit-Text oder in `contracts/SYNC_SOURCE.txt` bzw.
`.sync/contracts_source.txt` erwartet.

## Validator-Hinweis

Schemas nutzen URN-`$ref` (z. B. `urn:heimgewebe:contracts:fragments:...`).
Validatoren müssen dafür eine Schema-Registry laden (z. B. Ajv über `addSchema`,
`getSchema`, die `schemas`-Option oder asynchrones `loadSchema`), sonst schlagen
lokale Validierungen ohne Registry fehl.
