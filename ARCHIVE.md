# Archivierungsbeleg

Leitwerk wurde für die Archivierung eingefroren, nachdem die noch tragfähigen providerneutralen Änderungsgrenzen nach Metarepo übertragen wurden.

## Entscheidung

- **Behalten:** historische Herkunft im schreibgeschützten Repository.
- **Migrieren:** nur allgemeine Grenzen zwischen Agentenvorschlag und Wirkung.
- **Stilllegen:** Leitwerk-Runtime, ACS-/WGX-Autorität, Agentenstart, Task-/Claim-Zustand, Leitwerk-Events, Phase-1-Artefaktschemas und Mirror-Automation.

## Gebundene Belege

- eingefrorener Ausgangsstand: `heimgewebe/leitwerk@c241244d8e7613f6d4eaff7a6686c841444f1ade`
- kanonische Migration: `heimgewebe/metarepo@74ce9202952d00b0d2fef0587255c92a9cd05dee`
- Metarepo-PR: `heimgewebe/metarepo#667`
- Bureau-Aufgabe: `OPERATOR-ECOSYSTEM-REDUNDANCY-V1-T037`

Das Metarepo-Inventar klassifiziert alle 40 Dateien und 24 historischen Remote-Branches. Die Schemas bleiben bytegetreu in der Git-Historie, werden jedoch nicht als heutige Verträge übernommen. Das betrifft ausdrücklich auch die algorithmusunabhängig verkürzbaren Digests im historischen Artefaktkopf.

## Nicht übertragen

Die Archivierung überträgt keine Leitwerk-Autorität auf Bureau, Grabowski, Systemkatalog, Chronik oder Konvergenzregelkreis. Diese Komponenten besitzen ausschließlich ihre jeweils aktuellen, eigenen Verträge.
