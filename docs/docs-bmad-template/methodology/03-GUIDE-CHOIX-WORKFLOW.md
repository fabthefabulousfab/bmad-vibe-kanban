# Guide de Choix du Workflow

Ce guide vous aide a identifier le workflow BMAD+TEA adapte a votre situation.

---

## Les 4 Workflows BMAD+TEA

| # | Workflow | Situation | Phases |
|---|----------|-----------|--------|
| 1 | `WORKFLOW_COMPLET` | Nouveau projet OU projet existant avec documentation BMAD | 1→2→3→Sprint0→4→5 |
| 2 | `DOCUMENT_PROJECT` | Projet existant SANS documentation BMAD | 0→2→3→Sprint0→4→5 |
| 3 | `QUICK_FLOW` | Projet existant AVEC documentation BMAD pour petite feature (1-3 stories) | QuickSpec→Stories→Dev |
| 4 | `DEBUG` | Correction de bug (sans story) | Diagnostic→Fix→Regression |

---

## Questionnaire Rapide (3 questions)

Repondez a ces questions pour identifier votre workflow:

### Question 1: Quel est l'etat de votre projet?

```
[ ] A - Je demarre un NOUVEAU projet (pas de code existant)
[ ] B - J'ai un projet EXISTANT sans documentation BMAD
[ ] C - J'ai un projet EXISTANT avec documentation BMAD
[ ] D - Je dois corriger un BUG dans un projet existant
```

**Si A** → `WORKFLOW_COMPLET`
**Si B** → `DOCUMENT_PROJECT`
**Si C** → Continuer Question 2
**Si D** → `DEBUG`

---

### Question 2: (Si projet existant avec doc BMAD) Quelle est l'ampleur du travail?

```
[ ] A - Petit ajout: 1 a 3 stories, pas de changement d'architecture
[ ] B - Gros ajout: 4+ stories, possible impact architectural
```

**Si A** → Continuer Question 3
**Si B** → `WORKFLOW_COMPLET` (traiter comme un nouveau projet/epic)

---

### Question 3: (Pour confirmer QUICK_FLOW) Verifications

Cochez TOUTES les cases pour confirmer QUICK_FLOW:

```
[ ] La fonctionnalite est simple et bien definie
[ ] Pas de nouvelle integration externe (API tierce, service)
[ ] Pas de changement du modele de donnees
[ ] Maximum 3 stories
[ ] Impact localise (peu de fichiers)
[ ] Framework de test deja en place
```

**Si TOUTES cochees** → `QUICK_FLOW` confirme
**Si UNE ou plus non cochee** → `WORKFLOW_COMPLET`

---

## Arbre de Decision Visuel

```
                    ┌─────────────────┐
                    │ Type de travail │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   ▼
   ┌───────────┐      ┌───────────┐       ┌───────────┐
   │  Nouveau  │      │ Existant  │       │   Bug     │
   │  projet   │      │  projet   │       │  a fixer  │
   └─────┬─────┘      └─────┬─────┘       └─────┬─────┘
         │                  │                   │
         ▼                  │                   ▼
   ┌─────────────┐          │            ┌───────────┐
   │ WORKFLOW    │          │            │   DEBUG   │
   │ COMPLET     │          │            └───────────┘
   └─────────────┘          │
                            │
               ┌────────────┴────────────┐
               │                         │
               ▼                         ▼
         ┌───────────┐            ┌───────────┐
         │  Pas de   │            │    Doc    │
         │ doc BMAD  │            │   BMAD    │
         └─────┬─────┘            └─────┬─────┘
               │                        │
               ▼                        │
         ┌─────────────┐        ┌───────┴───────┐
         │  DOCUMENT   │        │               │
         │  PROJECT    │        ▼               ▼
         └─────────────┘   ┌────────┐      ┌────────────┐
                           │ 1-3    │      │   4+       │
                           │stories │      │ stories    │
                           └───┬────┘      └─────┬──────┘
                               │                 │
                               ▼                 ▼
                          ┌──────────┐     ┌─────────────┐
                          │  QUICK   │     │  WORKFLOW   │
                          │  FLOW    │     │  COMPLET    │
                          └──────────┘     └─────────────┘
```

---

## Description de Chaque Workflow

### 1. WORKFLOW_COMPLET

**Situation**: Nouveau projet OU projet existant avec documentation BMAD pour ajout majeur.

**Exemple concret**:
> "On lance une nouvelle application de gestion de taches pour notre equipe."
> "On veut ajouter l'authentification 2FA a notre projet existant (4+ stories)."

**Ce que vous allez faire**:
1. Phase 1: Brainstorming, Research, Product Brief (si nouveau projet)
2. Phase 2: PRD, UX Design
3. Phase 3: Architecture, Test Design, NFR Assessment, Epics/Stories
4. Sprint 0: Framework de test, Pipeline CI/CD
5. Phase 4: Story Loop (ATDD → Dev → Review → Trace)
6. Phase 5: Quality Gate, Deploy

**Duree typique**: Plusieurs semaines a mois

**Phases TEA**:
| Phase | Workflow TEA |
|-------|--------------|
| Phase 3 | [TD] Test Design (system), [NR] NFR Assessment |
| Sprint 0 | [TF] Framework, [CI] Pipeline |
| Phase 4 (par story) | [AT] ATDD, [RV] Test Review, [TR] Trace Phase 1 |
| Fin Epic | [TA] Automate E2E, [NR] NFR, [TR] Trace Phase 2 |
| Phase 5 | [TR] Trace Phase 2 (Quality Gate) |

---

### 2. DOCUMENT_PROJECT

**Situation**: Projet existant SANS documentation BMAD. Necessite de documenter avant d'ajouter des features.

**Exemple concret**:
> "On a une appli legacy que personne ne comprend vraiment. On veut la documenter et ajouter des tests."
> "On a un projet avec du code mais pas de PRD ni d'architecture documentee."

**Ce que vous allez faire**:
1. Phase 0: Analyser le code existant, generer PRD et Product Brief depuis le code
2. Phase 2+: Continuer comme WORKFLOW_COMPLET

**Duree typique**: 1-2 semaines pour l'analyse, puis implementation normale

**Phases TEA**: Identiques a WORKFLOW_COMPLET (apres Phase 0)

---

### 3. QUICK_FLOW

**Situation**: Ajout d'une petite fonctionnalite (1-3 stories) sur un projet BMAD existant.

**Exemple concret**:
> "On veut ajouter un bouton 'Se souvenir de moi' sur le login. C'est 2 stories max."

**Criteres d'eligibilite**:
- 1 a 3 stories maximum
- Pas de changement d'architecture
- Pas de nouvelle integration externe
- Impact localise
- Framework de test deja en place

**Ce que vous allez faire**:
1. Quick Spec (pas de PRD complet)
2. Analyser les tests de regression
3. Creer les stories (1-3 max)
4. Story Loop: ATDD → Dev → Review → Trace
5. Tests de regression
6. Merge

**Duree typique**: Quelques jours

**Phases TEA**:
| Etape | Workflow TEA |
|-------|--------------|
| Quick Spec | [analyze-regression] |
| Par Story | [AT] ATDD, [RV] Test Review, [TR] Trace Phase 1 |
| Completion | npm test:regression |

---

### 4. DEBUG

**Situation**: Correction de bug sans ajouter de nouvelle fonctionnalite.

**Exemple concret**:
> "Les utilisateurs se plaignent que la session expire apres 5 minutes au lieu de 30. Il faut corriger ca."

**Criteres**:
- C'est un BUG (comportement incorrect), pas une feature
- Pas de changement architectural
- Correction localisee

**Ce que vous allez faire**:
1. Documenter le bug (avec l'utilisateur)
2. Analyser le code impacte
3. Identifier les tests existants
4. Ecrire un test qui reproduit le bug (DOIT ECHOUER - RED)
5. Corriger le bug (test DOIT PASSER - GREEN)
6. Confirmer avec l'utilisateur
7. Executer les tests de regression
8. Documenter et merger

**Duree typique**: Quelques heures a 1-2 jours

**Particularite**: PAS DE STORY - Echanges directs avec l'utilisateur

**Phases TEA**:
| Phase | Workflow TEA |
|-------|--------------|
| Diagnostic | [analyze-regression --debug] |
| Correction | [write-bug-test] |
| Non-Regression | [regression-report] |
| Finalisation | [update-test-suite] |

---

## Tableau Comparatif

| Aspect | WORKFLOW_COMPLET | DOCUMENT_PROJECT | QUICK_FLOW | DEBUG |
|--------|------------------|------------------|------------|-------|
| **Code existant** | Non ou Oui | Oui | Oui | Oui |
| **Doc BMAD** | Non ou Oui | Non | Oui | Oui |
| **Stories** | Full | Full | 1-3 | 0 |
| **Architecture** | Full | Reverse eng. | Aucune | Aucune |
| **Test Design** | Oui | Oui | Non | Non |
| **NFR Assessment** | Oui | Oui | Non | Non |
| **Framework Setup** | Sprint 0 | Sprint 0 | Deja fait | Deja fait |
| **ATDD par story** | Oui | Oui | Oui | write-bug-test |
| **Test Review** | Oui | Oui | Oui | Non |
| **Trace** | Phase 1 + 2 | Phase 1 + 2 | Phase 1 | Non |
| **E2E Epic** | Fin Epic | Fin Epic | Non | regression-report |
| **Interactif** | Non | Non | Non | **Oui** |

---

## Comment Savoir si Vous Etes au Milieu d'un Workflow?

### Verifier l'Etat

```bash
# Si le fichier existe, un workflow est en cours
ls .bmad/workflow-state.yaml
```

Ou demander:
```
"Quel est l'etat du workflow en cours?"
```

### Indicateurs qu'un Workflow est en Cours

| Indicateur | Signification |
|------------|---------------|
| `.bmad/workflow-state.yaml` existe | Workflow initialise |
| `docs/prd.md` existe sans stories | Phase 2-3 en cours |
| `stories/` non vide avec stories `in_progress` | Phase 4 en cours |
| `debug/bug-report-*.md` existe | DEBUG en cours |
| `specs/quick-spec-*.md` existe | QUICK_FLOW en cours |

### Reprendre un Workflow Interrompu

```bash
./scripts/workflow-runner.sh --resume
```

---

## Changer de Workflow en Cours de Route

### Escalade QUICK_FLOW → WORKFLOW_COMPLET

Si en cours de Quick Flow vous realisez que c'est plus gros:

1. Sauvegarder l'etat actuel
2. Convertir la quick-spec en PRD
3. Continuer avec WORKFLOW_COMPLET

### Transformation DEBUG → QUICK_FLOW

Si le "bug" est en fait une feature manquante:

1. Documenter la decouverte
2. Creer une story a partir du bug report
3. Continuer avec QUICK_FLOW

---

## FAQ

### "J'ai un doute entre QUICK_FLOW et WORKFLOW_COMPLET"

**Regle simple**: En cas de doute, choisir WORKFLOW_COMPLET. C'est plus sur et vous pouvez accelerer si c'est finalement plus simple.

### "J'ai plusieurs bugs a corriger"

**Si lies**: Creer un epic de correction avec QUICK_FLOW
**Si independants**: Plusieurs DEBUG successifs

### "Je ne sais pas si mon projet a de la documentation BMAD"

Verifier la presence de:
- `docs/prd.md`
- `docs/architecture.md`
- `backlog/epics/` ou `backlog/stories/`

Si au moins 2 de ces elements existent → Doc BMAD presente → QUICK_FLOW ou WORKFLOW_COMPLET
Sinon → DOCUMENT_PROJECT

### "Comment visualiser mes stories dans un Kanban?"

Utiliser l'integration **Vibe Kanban**:

```bash
# 1. Lancer Vibe Kanban
npx vibe-kanban

# 2. Importer les stories BMAD (via UI)
# Ouvrir http://localhost:3001
# Cliquer sur le bouton "+" orange dans "To Do"
# Sélectionner le workflow et cliquer "Execute"

# Legacy: ./scripts/import-bmad-workflow.sh (deprecated)
```

---

## Reference Croisee

Pour le detail complet de chaque workflow, voir:
- **01-WORKFLOW-PHASES-COMPLETE.md** - Phases detaillees avec diagrammes
- **00-BMAD-TEA-MASTER-GUIDE.md** - Vue d'ensemble et principes
