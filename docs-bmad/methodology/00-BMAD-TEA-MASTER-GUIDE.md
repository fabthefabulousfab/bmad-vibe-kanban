# BMAD + TEA Master Guide
## Guide Complet du Workflow de Developpement avec Chain of Verification

---

## Table des Matieres

1. [Vue d'ensemble](#vue-densemble)
2. [Les 4 Configurations de Projet](#les-4-configurations-de-projet)
3. [Phases du Workflow](#phases-du-workflow)
4. [Systeme de Numerotation X.Y.Z](#systeme-de-numerotation-xyz)
5. [Integration avec Outils Kanban](#integration-avec-outils-kanban)

---

## Vue d'ensemble

Ce guide definit le workflow complet BMAD (Business, Marketing, Architecture, Development) integre avec TEA (Test Architect) pour garantir une **Chain of Verification** complete sur tous les developpements.

### Objectifs

- **Qualite garantie** : Chaque ligne de code est validee par des tests
- **Tracabilite complete** : Chaque exigence est mappee a des tests
- **Parallelisation optimale** : Les taches independantes sont identifiees
- **Documentation exhaustive** : Chaque story contient sa Definition of Done

### Acteurs du Workflow

| Acteur | Role | Phases principales |
|--------|------|-------------------|
| **Business Analyst** | Brainstorming, Product Brief | Phase 1 |
| **Product Manager (PM)** | PRD, Specifications | Phase 2 |
| **UX Designer** | Design UX/UI | Phase 2 |
| **Architect** | Architecture, ADRs | Phase 3 |
| **Scrum Master** | Epics, Stories, Sprint | Phase 3-4 |
| **Test Architect (TEA)** | Test Design, ATDD, Review | Phase 3-4 |
| **Developer** | Implementation | Phase 4 |

---

## Les 4 Configurations de Projet

| # | Configuration | Situation | Phases | Section |
|---|---------------|-----------|--------|---------|
| 1 | `WORKFLOW_COMPLET` | Nouveau projet OU projet existant avec documentation BMAD | 1→2→3→Sprint0→4→5 | Voir 01-WORKFLOW-PHASES-COMPLETE.md |
| 2 | `DOCUMENT_PROJECT` | Projet existant SANS documentation BMAD | 0→2→3→Sprint0→4→5 | Voir 01-WORKFLOW-PHASES-COMPLETE.md |
| 3 | `QUICK_FLOW` | Projet existant AVEC documentation BMAD pour petite feature | QuickSpec→Stories→Dev | Voir 01-WORKFLOW-PHASES-COMPLETE.md |
| 4 | `DEBUG` | Correction de bug (sans story) | Diagnostic→Fix→Regression | Voir 01-WORKFLOW-PHASES-COMPLETE.md |

### Configuration 1: WORKFLOW_COMPLET
> Nouveau projet OU projet existant avec documentation BMAD

```
Phases requises: 1 → 2 → 3 → Sprint0 → 4 → 5 (toutes)
Estimation: Workflow complet
Cas d'usage: Greenfield, ou ajout majeur sur projet BMAD existant
```

### Configuration 2: DOCUMENT_PROJECT
> Projet existant SANS documentation BMAD (necessite regeneration)

```
Phases requises: 0 → 2 → 3 → Sprint0 → 4 → 5
Estimation: Analyse + Documentation + Implementation
Cas d'usage: Code legacy a documenter, projet sans PRD/Architecture BMAD
```

### Configuration 3: QUICK_FLOW
> Ajout fonctionnalite mineure sur projet BMAD existant

```
Phases requises: QuickSpec → Stories → Dev (bypass phases 1-3)
Estimation: 1-3 stories, quelques jours
Prerequis: Documentation BMAD et framework de test deja en place
```

### Configuration 4: DEBUG
> Correction de bug (sans story, interaction directe utilisateur)

```
Phases requises: Diagnostic → Fix → Regression
Estimation: Quelques heures a 1-2 jours
Particularite: PAS DE STORY, echanges directs avec utilisateur
```

---

## Phases du Workflow

### PHASE 0: INITIALISATION
- Choix de la configuration
- Setup environnement

### PHASE 1: ANALYSIS (Greenfield uniquement)
- Brainstorming
- Research
- Product Brief

### PHASE 2: PLANNING
- PRD (Product Requirements Document)
- UX Design
- Specifications fonctionnelles

### PHASE 3: SOLUTIONING
- Architecture
- ADRs (Architecture Decision Records)
- Test Design (System-level)
- Epics & Stories
- Implementation Readiness

### SPRINT 0: SETUP
- Framework de test
- Pipeline CI/CD

### PHASE 4: IMPLEMENTATION
- Sprint Planning
- Boucle Story (ATDD → Dev → Review → Trace)
- Retrospective

### PHASE 5: RELEASE
- Gate Decision
- Deployment

---

## Systeme de Numerotation X.Y.Z

### Format: `X.Y.Z`

| Composant | Signification | Exemple |
|-----------|---------------|---------|
| **X** | Numero d'Epic | 1, 2, 3... |
| **Y** | Bloc parallelisable | 1, 2, 3... |
| **Z** | Sequence dans le bloc | 0, 1, 2... |

### Regles

1. **Z = 0** : Premiere tache du bloc (peut demarrer immediatement)
2. **Z > 0** : Depend de la tache Z-1 du meme bloc Y
3. **Blocs Y differents** : Parallelisables entre eux
4. **Epic X+1** : Ne peut commencer que si Epic X est termine

### Exemple

```
Epic 1: Authentification
├── 1.1.0 → Story: Login UI (parallele)
├── 1.1.1 → Story: Login API (sequentiel apres 1.1.0)
├── 1.1.2 → Story: Login Integration (sequentiel apres 1.1.1)
├── 1.2.0 → Story: Register UI (parallele avec bloc 1.1)
├── 1.2.1 → Story: Register API (sequentiel apres 1.2.0)
└── 1.2.2 → Story: Register Integration (sequentiel apres 1.2.1)
```

**Parallelisation possible:**
- 1.1.0 et 1.2.0 peuvent etre faits en parallele
- 1.1.1 attend 1.1.0, 1.2.1 attend 1.2.0

---

## Integration avec Outils Kanban

### Export vers Vibe Kanban

Chaque fichier story genere contient:
- Titre avec numerotation X.Y.Z
- Description complete
- Criteres d'acceptation
- Definition of Done avec tests
- Dependances (blocked_by, blocks)

### Format d'import

```yaml
id: "1.1.0"
title: "Login UI"
epic: "1-authentification"
blocked_by: []
blocks: ["1.1.1"]
status: "todo"
```

---

## Fichiers de Reference

| Fichier | Description |
|---------|-------------|
| `configs/workflow-*.yaml` | Configuration par type de projet |
| `templates/story-template.md` | Template story avec DoD |
| `templates/task-template.md` | Template tache test/review |
| `prompts/*.md` | Prompts pour chaque etape |
| `scripts/generate-*.sh` | Scripts d'automatisation |

---

## Prochaines Etapes

1. Lire le fichier de configuration correspondant a votre projet
2. Suivre les etapes du workflow
3. Utiliser les prompts pour generer les artefacts
4. Exporter vers l'outil Kanban

