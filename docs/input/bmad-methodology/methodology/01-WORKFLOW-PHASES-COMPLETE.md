# Phases Completes du Workflow BMAD + TEA

Ce document decrit toutes les phases du workflow, incluant les phases preliminaires (Product Brief, PM, UX, Architecture, Scrum) et les phases de test.

---

## Choix de la Configuration Projet

Avant de commencer, identifier votre type de projet:

| # | Situation | Configuration | Phases | Section |
|---|-----------|---------------|--------|---------|
| 1 | Nouveau projet OU projet existant avec documentation BMAD | `WORKFLOW_COMPLET` | 1→2→3→Sprint0→4→5 | [Workflow Complet](#vue-densemble-des-phases) |
| 2 | Projet existant SANS documentation BMAD (necesssite regeneration) | `DOCUMENT_PROJECT` | 0→2→3→Sprint0→4→5 | [Document Project](#workflow-document-project) |
| 3 | Projet existant AVEC documentation BMAD pour petite feature | `QUICK_FLOW` | QuickSpec→Stories→Dev | [Quick Flow](#quick-flow---petites-fonctionnalites-feature_small) |
| 4 | Correction de bug (sans story) | `DEBUG` | Diagnostic→Fix→Regression | [Debug](#workflow-debug---correction-de-bug) |

### Resume des Phases TEA par Workflow

| Workflow | Test Design | NFR Assess | Framework | ATDD | Test Review | Trace | Automate E2E |
|----------|-------------|------------|-----------|------|-------------|-------|--------------|
| **WORKFLOW_COMPLET** | Phase 3 (system) + Phase 4 (epic) | Phase 3 + Fin Epic | Sprint 0 | Avant chaque dev-story | Apres chaque dev-story | Phase 1 par story + Phase 2 fin epic | Fin Epic |
| **DOCUMENT_PROJECT** | Phase 3 (system) + Phase 4 (epic) | Phase 3 + Fin Epic | Sprint 0 | Avant chaque dev-story | Apres chaque dev-story | Phase 1 par story + Phase 2 fin epic | Fin Epic |
| **QUICK_FLOW** | N/A (deja fait) | N/A | N/A (deja en place) | Avant chaque dev-story | Apres chaque dev-story | Phase 1 par story | N/A |
| **DEBUG** | N/A | N/A | N/A | write-bug-test | N/A | N/A | regression-report |

---

## Vue d'ensemble des Phases

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        WORKFLOW COMPLET BMAD + TEA                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 0: INITIALISATION                                                    │
│  ════════════════════════                                                   │
│  • Choix configuration projet (Greenfield/Brownfield/Feature)               │
│  • Setup environnement                                                      │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 0: BROWNFIELD ONBOARDING (Brownfield uniquement)                     │
│  ═══════════════════════════════════════════════════════                    │
│                                                                             │
│  Deux cas possibles:                                                        │
│                                                                             │
│  ┌─ CAS A: Aucune documentation existante ──────────────────────────────┐   │
│  │                                                                      │   │
│  │  0.A.1 analyze-cdoc
document proejt                 │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  OUTPUT: Base documentaire pour Phase 2                                     │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 1: ANALYSIS (Greenfield uniquement)                                  │
│  ═════════════════════════════════════════                                  │
│                                                                             │
│  Acteur: Business Analyst                                                   │
│                                                                             │
│  1.1 brainstorm                                                             │
│      └─→ docs/brainstorm-report.md                                          │
│           │                                                                 │
│  1.2 research                                                               │
│      └─→ docs/research-findings.md                                          │
│           │                                                                 │
│  1.3 create-product-brief                                                   │
│      └─→ docs/product-brief.md                                              │
│                                                                             │
│  OUTPUT: Vision produit validee                                             │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 2: PLANNING                                                          │
│  ═════════════════                                                          │
│                                                                             │
│  2.1 PRD - Product Manager                                                  │
│  ─────────────────────────                                                  │
│  Commande: create-prd                                                       │
│  Output: docs/prd.md                                                        │
│                                                                             │
│  Contenu:                                                                   │
│  ┌────────────────────────────────────────┐                                 │
│  │ • Vision et objectifs                  │                                 │
│  │ • Functional Requirements (FR)         │                                 │
│  │ • Non-Functional Requirements (NFR)    │                                 │
│  │ • User personas                        │                                 │
│  │ • Success metrics                      │                                 │
│  │ • Scope et limitations                 │                                 │
│  │ • Timeline et milestones               │                                 │
│  └────────────────────────────────────────┘                                 │
│                                                                             │
│  2.2 UX Design - UX Designer                                                │
│  ───────────────────────────                                                │
│  Commande: create-ux-design                                                 │
│  Output: docs/ux-specification.md, designs/                                 │
│                                                                             │
│  Contenu:                                                                   │
│  ┌────────────────────────────────────────┐                                 │
│  │ • User flows                           │                                 │
│  │ • Wireframes                           │                                 │
│  │ • UI Components                        │                                 │
│  │ • Design system                        │                                 │
│  │ • Accessibility requirements           │                                 │
│  │ • Responsive breakpoints               │                                 │
│  └────────────────────────────────────────┘                                 │
│                                                                             │
│  OUTPUT: Specifications completes                                           │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 3: SOLUTIONING                                                       │
│  ═════════════════════                                                      │
│                                                                             │
│  3.1 Architecture - Architect                                               │
│  ────────────────────────────                                               │
│  Commande: create-architecture                                              │
│  Output: docs/architecture.md, docs/adrs/                                   │
│                                                                             │
│  Contenu:                                                                   │
│  ┌────────────────────────────────────────┐                                 │
│  │ • System overview                      │                                 │
│  │ • Component diagram                    │                                 │
│  │ • Data model                           │                                 │
│  │ • API design                           │                                 │
│  │ • Security architecture                │                                 │
│  │ • Infrastructure                       │                                 │
│  │ • ADRs (Architecture Decision Records) │                                 │
│  └────────────────────────────────────────┘                                 │
│                                                                             │
│  3.2 TEA: Test Design (System) - Test Architect                             │
│  ──────────────────────────────────────────────                             │
│  Commande: tea → test-design (system-level)                                 │
│  Output: docs/test-design-architecture.md                                   │
│          docs/test-design-qa.md                                             │
│                                                                             │
│  Contenu:                                                                   │
│  ┌────────────────────────────────────────┐                                 │
│  │ • Risk assessment                      │                                 │
│  │ • Test priorities (P0-P3)              │                                 │
│  │ • Coverage strategy                    │                                 │
│  │ • Test environment requirements        │                                 │
│  │ • Sprint 0 checklist                   │                                 │
│  └────────────────────────────────────────┘                                 │
│                                                                             │
│  3.3 TEA: NFR Assessment (Initial) - Test Architect                         │
│  ───────────────────────────────────────────────────                        │
│  Commande: tea → nfr-assess                                                 │
│  Output: docs/nfr-requirements.md                                           │
│                                                                             │
│  Contenu:                                                                   │
│  ┌────────────────────────────────────────┐                                 │
│  │ • Security requirements                │                                 │
│  │ • Performance thresholds               │                                 │
│  │ • Reliability targets                  │                                 │
│  │ • Maintainability criteria             │                                 │
│  └────────────────────────────────────────┘                                 │
│                                                                             │
│  3.4 Epics & Stories - Scrum Master                                         │
│  ──────────────────────────────────                                         │
│  Commande: create-epics-and-stories                                         │
│  Output: backlog/epics/, backlog/stories/                                   │
│                                                                             │
│  Contenu:                                                                   │
│  ┌────────────────────────────────────────┐                                 │
│  │ • Epics decomposes                     │                                 │
│  │ • Stories avec numerotation X.Y.Z      │                                 │
│  │ • Criteres d'acceptation               │                                 │
│  │ • Dependencies                         │                                 │
│  │ • TEST REQUIREMENTS integres           │                                 │
│  │ • Definition of Done                   │                                 │
│  │ • Post-Implementation Steps (voir 3.5) │                                 │
│  └────────────────────────────────────────┘                                 │
│  Test framewok à executer avant sprint planning 

                                                                           │
│  3.5 Post-Implementation Steps (Inclus dans chaque Story)                   │
│  ────────────────────────────────────────────────────────                   │
│                                                                             │
│  Chaque story generee DOIT inclure une section "Post-Implementation         │
│  Steps" a la fin, documentant les workflows de verification a executer      │
│  apres l'implementation:                                                    │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │ ## Post-Implementation Steps                                       │     │
│  │                                                                    │     │
│  │ | Step | Agent | Workflow    | Path                              | │     │
│  │ |------|-------|-------------|-----------------------------------| │     │
│  │ | 1    | TEA   | test-review | workflows/testarch/test-review/   | │     │
│  │ | 2    | DEV   | code-review | workflows/4-implementation/code-  | │     │
│  │ |      |       |             | review/                           | │     │
│  │ | 3    | TEA   | trace       | workflows/testarch/trace/         | │     │
│  │                                                                    │     │
│  │ ### Commands                                                       │     │
│  │ ```bash                                                            │     │
│  │ # 1. Test Review - Validate test quality                           │     │
│  │ tea -> test-review                                                 │     │
│  │                                                                    │     │
│  │ # 2. Code Review - Review implementation                           │     │
│  │ dev -> code-review                                                 │     │
│  │                                                                    │     │
│  │ # 3. Trace - Update traceability matrix                            │     │
│  │ tea -> trace                                                       │     │
│  │ ```                                                                │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  3.6 Implementation Readiness - Architect + Scrum Master                    │
│  ───────────────────────────────────────────────────────                    │
│  Commande: check-implementation-readiness                                   │
│  Output: docs/implementation-readiness-checklist.md                         │
│                                                                             │
│  GATE: Validation avant implementation                                      │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SPRINT 0: SETUP (une seule fois)                                           │
│  ════════════════════════════════                                           │
│                                                                             │
│  S0.1 TEA: Framework - Test Architect                                       │
│  ─────────────────────────────────────                                      │
│  Commande: tea → framework                                                  │
│  Output: tests/ structure, config files                                     │
│                                                                             │
│  S0.2 TEA: CI Pipeline - Test Architect                                     │
│  ──────────────────────────────────────                                     │
│  Commande: tea → setup-ci                                                   │
│  Output: .github/workflows/test.yml                                         │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 4: IMPLEMENTATION                                                    │
│  ════════════════════════                                                   │
│                                                                             │
│  ┌─ DEBUT EPIC ─────────────────────────────────────────────────────────┐   │
│  │                                                                      │   │
│  │  E.1 TEA: Test Design (Epic) - Test Architect                        │   │
│  │  Commande: tea → test-design (epic-level)                            │   │
│  │  Output: docs/test-design-epic-{N}.md                                │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  SP.1 Sprint Planning - Scrum Master                                        │
│  Commande: sprint-planning                                                  │
│                                                                             │
│  ┌─ SP.2 POST-STORIES STRUCTURATION (Scrum Master) ────────────────────┐   │
│  │                                                                      │   │
│  │  Commande: structure-waves-for-parallel                              │   │
│  │  Agent: sm (Scrum Master)                                            │   │
│  │  Input: _bmad-output/epics-stories-tasks/stories/                    │   │
│  │  Output: _bmad-output/epics-stories-tasks/parallel-waves/            │   │
│  │                                                                      │   │
│  │  OBJECTIF: Reorganiser les stories en taches parallelisables         │   │
│  │  pour integration avec des outils type vibe-kanban                   │   │
│  │                                                                      │   │
│  │  ETAPES:                                                             │   │
│  │                                                                      │   │
│  │  1. VALIDATION PARALLELISME INTRA-WAVE                               │   │
│  │     └─ Verifier que toutes les stories d'une wave peuvent            │   │
│  │        s'executer en parallele (pas de dependance intra-wave)        │   │
│  │     └─ Si violation: restructurer les waves                          │   │
│  │                                                                      │   │
│  │  2. RENOMMAGE SEQUENTIEL DES WAVES                                   │   │
│  │     └─ Remplacer les numeros decimaux par des entiers                │   │
│  │        (ex: 1.1, 1.2 → 1, 2, 3...)                                   │   │
│  │     └─ Format fichier: {Wave}-{Epic}-{Story}.md                      │   │
│  │     └─ Tous les fichiers dans le meme repertoire                     │   │
│  │                                                                      │   │
│  │  3. AJOUT WAVES DE VERIFICATION (par wave dev X)                     │   │
│  │     ┌────────────────────────────────────────────────────────┐       │   │
│  │     │ Wave X    : Stories de developpement (parallelisables) │       │   │
│  │     │ Wave X.1  : test-review par story (tea → test-review)  │       │   │
│  │     │ Wave X.2  : code-review par story (dev → code-review)  │       │   │
│  │     │ Wave X.3  : trace par story (tea → trace Phase 1)      │       │   │
│  │     └────────────────────────────────────────────────────────┘       │   │
│  │                                                                      │   │
│  │     Chaque story de verification DOIT contenir:                      │   │
│  │     • Agent responsable (tea ou dev)                                 │   │
│  │     • Workflow BMAD a appeler                                        │   │
│  │     • Reference a la story source (X-Y-Z)                            │   │
│  │     • Output attendu                                                 │   │
│  │                                                                      │   │
│  │  4. AJOUT WAVES DE FIN D'EPIC (quand epic terminee)                  │   │
│  │     ┌────────────────────────────────────────────────────────┐       │   │
│  │     │ Si Epic N terminee dans Wave X:                        │       │   │
│  │     │ Wave X.4  : tea → automate (combler couverture)        │       │   │
│  │     │ Wave X.5  : tea → nfr-assess (validation NFRs)         │       │   │
│  │     │ Wave X.6  : sm → retrospective (retour experience)     │       │   │
│  │     └────────────────────────────────────────────────────────┘       │   │
│  │                                                                      │   │
│  │     Ces 3 etapes sont SEQUENTIELLES (X.4 → X.5 → X.6)                │   │
│  │     Chaque story DOIT indiquer l'epic concernee                      │   │
│  │                                                                      │   │
│  │  5. GENERATION FORMAT PARALLELISABLE                                 │   │
│  │     └─ Fichier de synthese: parallel-waves-summary.md                │   │
│  │     └─ Export JSON pour vibe-kanban: waves-kanban.json               │   │
│  │                                                                      │   │
│  │  FORMAT STORY VERIFICATION:                                          │   │
│  │  ┌────────────────────────────────────────────────────────────────┐  │   │
│  │  │ # Story X.1-Y-Z: Test Review for Story X-Y-Z                   │  │   │
│  │  │ **Wave:** X.1 | **Type:** Verification | **Source:** X-Y-Z     │  │   │
│  │  │                                                                │  │   │
│  │  │ ## Agent & Workflow                                            │  │   │
│  │  │ - **Agent:** tea (Test Architect)                              │  │   │
│  │  │ - **Workflow:** bmad-bmm-testarch-test-review                  │  │   │
│  │  │ - **Source Story:** X-Y-Z                                      │  │   │
│  │  │                                                                │  │   │
│  │  │ ## Acceptance Criteria                                         │  │   │
│  │  │ - Score qualite tests >= 80/100                                │  │   │
│  │  │ - Output: reviews/test-review-{X.Y.Z}.md                       │  │   │
│  │  └────────────────────────────────────────────────────────────────┘  │   │
│  │                                                                      │   │
│  │  FORMAT STORY FIN EPIC:                                              │   │
│  │  ┌────────────────────────────────────────────────────────────────┐  │   │
│  │  │ # Story X.4-N-0: Automate Coverage for Epic N                  │  │   │
│  │  │ **Wave:** X.4 | **Type:** Epic Completion | **Epic:** N        │  │   │
│  │  │                                                                │  │   │
│  │  │ ## Agent & Workflow                                            │  │   │
│  │  │ - **Agent:** tea (Test Architect)                              │  │   │
│  │  │ - **Workflow:** bmad-bmm-testarch-automate                     │  │   │
│  │  │ - **Epic concernee:** Epic N - [Nom Epic]                      │  │   │
│  │  │                                                                │  │   │
│  │  │ ## Acceptance Criteria                                         │  │   │
│  │  │ - Lacunes couverture comblees                                  │  │   │
│  │  │ - Tests automatises ajoutees                                   │  │   │
│  │  └────────────────────────────────────────────────────────────────┘  │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ╔══════════════════════════════════════════════════════════════════════╗   │
│  ║                                                                      ║   │
│  ║  BOUCLE PAR STORY (Chain of Verification)                            ║   │
│  ║                                                                      ║   │
│  ╠══════════════════════════════════════════════════════════════════════╣   │
│  ║                                                                      ║   │
│  ║  ST.1 create-story                                                   ║   │
│  ║       └─→ stories/story-{X.Y.Z}.md                                   ║   │
│  ║            │                                                         ║   │
│  ║  ST.2 tea → atdd                           ┌─────────────────┐       ║   │
│  ║       └─→ tests/stories/{X.Y.Z}/*.spec.ts  │   RED PHASE     │       ║   │
│  ║       └─→ npm test → TOUS ECHOUENT         │   Tests fail    │       ║   │
│  ║            │                               └─────────────────┘       ║   │
│  ║  ST.3 dev-story                            ┌─────────────────┐       ║   │
│  ║       └─→ Implementation                   │  GREEN PHASE    │       ║   │
│  ║       └─→ npm test → TOUS PASSENT          │  Tests pass     │       ║   │
│  ║            │                               └─────────────────┘       ║   │
│  ║  ST.4 tea → test-review                    ┌─────────────────┐       ║   │
│  ║       └─→ reviews/test-review-{X.Y.Z}.md   │  Score >= 80    │       ║   │
│  ║            │                               └─────────────────┘       ║   │
│  ║  ST.5 code-review                          ┌─────────────────┐       ║   │
│  ║       └─→ reviews/code-review-{X.Y.Z}.md   │  PR approved    │       ║   │
│  ║            │                               └─────────────────┘       ║   │
│  ║  ST.6 tea → trace (Phase 1)                ┌─────────────────┐       ║   │
│  ║       └─→ docs/traceability-matrix.md      │  P0-P1 = FULL   │       ║   │
│  ║                                            └─────────────────┘       ║   │
│  ║                                                                      ║   │
│  ╚══════════════════════════════════════════════════════════════════════╝   │
│                                                                             │
│  ┌─ FIN EPIC ───────────────────────────────────────────────────────────┐   │
│  │                                                                      │   │
│  │  EE.1 tea → automate                                                 │   │
│  │       └─→ Combler lacunes couverture                                 │   │
│  │                                                                      │   │
│  │  EE.2 tea → nfr-assess                                               │   │
│  │       └─→ Validation NFRs (PASS/WAIVED)                              │   │
│  │                                                                      │   │
│  │  EE.3 retrospective                                                  │   │
│  │       └─→ Retour d'experience                                        │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 5: RELEASE                                                           │
│  ════════════════                                                           │
│                                                                             │
│  R.1 TEA: Trace Gate Decision - Test Architect                              │
│  ─────────────────────────────────────────────                              │
│  Commande: tea → trace (Phase 2)                                            │
│  Output: docs/gate-decision-release.md                                      │
│  GATE: PASS / CONCERNS / FAIL / WAIVED                                      │
│                                                                             │
│  R.2 Deploy - DevOps                                                        │
│  ───────────────────                                                        │
│  Commande: deploy                                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Phases TEA pour WORKFLOW_COMPLET (Recapitulatif Exhaustif)

| Phase | Workflow TEA | Commande | Quand | Output |
|-------|--------------|----------|-------|--------|
| **Phase 3** | [TD] Test Design (system) | `tea → test-design` | Apres Architecture | docs/test-design-architecture.md |
| **Phase 3** | [NR] NFR Assessment | `tea → nfr-assess` | Apres PRD | docs/nfr-requirements.md |
| **Sprint 0** | [TF] Test Framework | `tea → framework` | Une fois au debut | tests/, playwright.config.ts |
| **Sprint 0** | [CI] CI Pipeline | `tea → setup-ci` | Une fois au debut | .github/workflows/test.yml |
| **Phase 4 (Epic)** | [TD] Test Design (epic) | `tea → test-design` | Debut de chaque Epic | docs/test-design-epic-{N}.md |
| **Phase 4 (Story)** | [AT] ATDD | `tea → atdd` | **AVANT** dev-story | tests/stories/{X.Y.Z}/*.spec.ts |
| **Phase 4 (Story)** | [RV] Test Review | `tea → test-review` | **APRES** dev-story | reviews/test-review-{X.Y.Z}.md (Score >= 80) |
| **Phase 4 (Story)** | [TR] Trace Phase 1 | `tea → trace` | **APRES** test-review | docs/traceability-matrix.md |
| **Fin Epic** | [TA] Test Automation | `tea → automate` | Apres toutes stories Epic | tests/e2e/epic-{N}/*.spec.ts |
| **Fin Epic** | [NR] NFR Assessment | `tea → nfr-assess` | Avant cloture Epic | Validation NFRs (PASS/WAIVED) |
| **Fin Epic** | [TR] Trace Phase 2 | `tea → trace` | Decision qualite Epic | docs/gate-decision-epic-{N}.md |
| **Phase 5** | [TR] Trace Phase 2 | `tea → trace` | Avant release | docs/gate-decision-release.md (PASS/FAIL) |

### Ordre d'Execution des Phases TEA

```
PHASE 3 (Solutioning)
├── [TD] Test Design (system) ← Strategie globale, risques, couverture
├── [NR] NFR Assessment ← Exigences non-fonctionnelles
└── create-epics-and-stories

SPRINT 0 (Setup)
├── [TF] Test Framework ← Structure tests, config Playwright
└── [CI] CI Pipeline ← GitHub Actions, quality gates

PHASE 4 (Implementation)
├── DEBUT EPIC
│   └── [TD] Test Design (epic) ← Strategie pour cette epic
│
├── BOUCLE PAR STORY (Chain of Verification)
│   ├── create-story
│   ├── [AT] ATDD ← Tests qui ECHOUENT (RED)
│   ├── dev-story ← Implementation (GREEN)
│   ├── [RV] Test Review ← Score >= 80
│   ├── code-review
│   └── [TR] Trace Phase 1 ← Mise a jour tracabilite
│
└── FIN EPIC
    ├── [TA] Test Automation ← Tests E2E inter-stories
    ├── [NR] NFR Assessment ← Validation finale NFRs
    └── [TR] Trace Phase 2 ← Decision quality gate

PHASE 5 (Release)
└── [TR] Trace Phase 2 ← Decision finale release
```

---

## WORKFLOW DOCUMENT_PROJECT

Workflow pour projet existant SANS documentation BMAD. Regenere la documentation avant de suivre le workflow standard.

### Quand utiliser DOCUMENT_PROJECT

| Utiliser DOCUMENT_PROJECT si... | NE PAS utiliser si... |
|---------------------------------|----------------------|
| Projet existant avec code fonctionnel | Nouveau projet (utiliser WORKFLOW_COMPLET) |
| Pas de documentation BMAD (PRD, Architecture) | Documentation BMAD deja presente |
| Besoin de documenter avant d'ajouter des features | Petite correction (utiliser DEBUG) |
| Code legacy a analyser et documenter | Documentation traditionnelle suffisante a importer |

### Workflow DOCUMENT_PROJECT

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      WORKFLOW DOCUMENT_PROJECT                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 0: ANALYSE DU PROJET EXISTANT                                        │
│  ═══════════════════════════════════                                        │
│                                                                             │
│  0.1 analyze-codebase (Architect)                                           │
│      └─→ docs/codebase-analysis.md                                          │
│      Contenu:                                                               │
│      • Structure du projet                                                  │
│      • Technologies utilisees                                               │
│      • Patterns identifies                                                  │
│      • Dette technique                                                      │
│                                                                             │
│  0.2 document-project (Business Analyst + PM)                               │
│      └─→ docs/product-brief.md (genere depuis le code)                      │
│      └─→ docs/prd.md (genere depuis le code)                                │
│      Contenu:                                                               │
│      • Vision produit deduite du code                                       │
│      • Fonctionnalites existantes                                           │
│      • User personas identifies                                             │
│                                                                             │
│  OUTPUT: Base documentaire BMAD pour Phase 2                                │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 2-5: WORKFLOW STANDARD                                               │
│  ════════════════════════════                                               │
│                                                                             │
│  A partir de la Phase 2, suivre le WORKFLOW_COMPLET:                        │
│                                                                             │
│  Phase 2: Planning (PRD existe deja, UX si necessaire)                      │
│  Phase 3: Solutioning (Architecture, Test Design, NFR, Epics/Stories)       │
│  Sprint 0: Setup (Framework, CI)                                            │
│  Phase 4: Implementation (Story Loop avec Chain of Verification)            │
│  Phase 5: Release (Trace Gate, Deploy)                                      │
│                                                                             │
│  VOIR: Section "Vue d'ensemble des Phases" pour le detail                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Phases TEA pour DOCUMENT_PROJECT

| Phase | Workflow TEA | Quand | Output |
|-------|--------------|-------|--------|
| Phase 0 | N/A | - | - |
| Phase 3 | [TD] Test Design (system) | Apres Architecture | docs/test-design-architecture.md |
| Phase 3 | [NR] NFR Assessment | Apres PRD | docs/nfr-requirements.md |
| Sprint 0 | [TF] Test Framework | Une fois | tests/, config |
| Sprint 0 | [CI] CI Pipeline | Une fois | .github/workflows/ |
| Phase 4 (par story) | [AT] ATDD | Avant dev-story | tests/stories/{X.Y.Z}/*.spec.ts |
| Phase 4 (par story) | [RV] Test Review | Apres dev-story | reviews/test-review-{X.Y.Z}.md |
| Phase 4 (par story) | [TR] Trace Phase 1 | Apres dev-story | docs/traceability-matrix.md |
| Fin Epic | [TA] Test Automation | Apres toutes stories | tests/e2e/epic-{N}/*.spec.ts |
| Fin Epic | [NR] NFR Assessment | Avant cloture | Validation NFRs |
| Fin Epic | [TR] Trace Phase 2 | Decision qualite | docs/gate-decision-epic-{N}.md |
| Phase 5 | [TR] Trace Phase 2 | Avant release | docs/gate-decision-release.md |

### Commandes DOCUMENT_PROJECT

```bash
# PHASE 0 - Analyse
analyze-codebase              # Analyser le code existant
document-project              # Generer PRD et Product Brief

# PHASE 2+ - Comme WORKFLOW_COMPLET
# Voir section "Commandes Recapitulatives"
```

---

## QUICK FLOW - Petites Fonctionnalites (FEATURE_SMALL)

Workflow accelere pour ajouts mineurs (1-3 stories) sur projet deja documente.

### Criteres d'Eligibilite

| Utiliser Quick Flow si... | NE PAS utiliser si... |
|---------------------------|----------------------|
| Fonctionnalite simple et bien definie | Nouvelle integration externe |
| Pas de changement architectural | Changement de modele de donnees |
| 1 a 3 stories maximum | Plus de 3 stories |
| Impact localise (peu de fichiers) | Impact sur plusieurs modules |
| Framework de test deja en place | Pas de tests existants |

### Prerequisites

Avant d'utiliser Quick Flow, verifier que le projet possede:
- `docs/architecture.md` - Architecture documentee
- `docs/prd.md` ou equivalent - Specifications existantes
- `tests/` - Framework de test configure
- `.github/workflows/` ou CI equivalent - Pipeline en place

### Workflow Quick Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           QUICK FLOW WORKFLOW                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ETAPE 1: QUICK SPEC                                                        │
│  ═══════════════════                                                        │
│                                                                             │
│  QF.1 quick-spec (Developer/Scrum Master)                                   │
│       Inputs:                                                               │
│       • Description de la fonctionnalite                                    │
│       • Reference a docs/architecture.md                                    │
│       • Reference a docs/prd.md                                             │
│       └─→ specs/quick-spec-{feature-name}.md                                │
│                                                                             │
│       Contenu:                                                              │
│       ┌────────────────────────────────────────┐                            │
│       │ • Description courte de la feature     │                            │
│       │ • Criteres d'acceptation (AC)          │                            │
│       │ • Fichiers impactes                    │                            │
│       │ • Risques identifies                   │                            │
│       │ • TEST REQUIREMENTS (extrait de QA)    │                            │
│       └────────────────────────────────────────┘                            │
│                                                                             │
│  QF.2 tea → analyze-regression (Test Architect)                             │
│       └─→ specs/regression-analysis-{feature-name}.md                       │
│       Analyse des tests existants pour identifier:                          │
│       • Tests lies aux fichiers impactes                                    │
│       • Tests lies aux fonctionnalites dependantes                          │
│       • Suite de tests de non-regression a executer                         │
│       • Risques de regression identifies                                    │
│                                                                             │
│  QF.3 create-story (Developer)                                              │
│       └─→ stories/story-{X.Y.Z}.md (1-3 stories max)                        │
│       Chaque story DOIT contenir:                                           │
│       • Criteres d'acceptation                                              │
│       • TEST REQUIREMENTS section                                           │
│       • Definition of Done complete                                         │
│       • Reference a regression-analysis                                     │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ETAPE 2: STORY LOOP (par story - Chain of Verification OBLIGATOIRE)        │
│  ════════════════════════════════════════════════════════════════════       │
│                                                                             │
│  ╔══════════════════════════════════════════════════════════════════════╗   │
│  ║  POUR CHAQUE STORY (meme pour Quick Flow!)                           ║   │
│  ╠══════════════════════════════════════════════════════════════════════╣   │
│  ║                                                                      ║   │
│  ║  ST.1 tea → atdd                           ┌─────────────────┐       ║   │
│  ║       └─→ tests/{feature}/*.spec.ts        │   RED PHASE     │       ║   │
│  ║       └─→ npm test → DOIT ECHOUER          │   Tests fail    │       ║   │
│  ║            │                               └─────────────────┘       ║   │
│  ║       Niveaux de test:                                               ║   │
│  ║       • Recommande: Component tests, API tests                       ║   │
│  ║       • Optionnel: E2E tests (si UI critique)                        ║   │
│  ║            │                                                         ║   │
│  ║  ST.2 quick-dev                            ┌─────────────────┐       ║   │
│  ║       └─→ Implementation                   │  GREEN PHASE    │       ║   │
│  ║       └─→ npm test → DOIT PASSER           │  Tests pass     │       ║   │
│  ║            │                               └─────────────────┘       ║   │
│  ║  ST.3 tea → test-review                    ┌─────────────────┐       ║   │
│  ║       └─→ Score qualite tests              │  Score >= 80    │       ║   │
│  ║       Scope: nouveaux tests uniquement     └─────────────────┘       ║   │
│  ║            │                                                         ║   │
│  ║  ST.4 code-review                          ┌─────────────────┐       ║   │
│  ║       Focus:                               │  PR approved    │       ║   │
│  ║       • Coherence avec architecture        └─────────────────┘       ║   │
│  ║       • Qualite des tests                                            ║   │
│  ║       • Pas de regression                                            ║   │
│  ║            │                                                         ║   │
│  ║  ST.5 tea → trace (Phase 1)                ┌─────────────────┐       ║   │
│  ║       └─→ Mise a jour incremental          │  Trace updated  │       ║   │
│  ║            tracabilite                     └─────────────────┘       ║   │
│  ║            │                                                         ║   │
│  ║  ST.6 npm test:regression                  ┌─────────────────┐       ║   │
│  ║       └─→ Tests de non-regression          │  No regression  │       ║   │
│  ║       Basé sur regression-analysis         │  detected       │       ║   │
│  ║       Si ECHEC → corriger avant merge      └─────────────────┘       ║   │
│  ║                                                                      ║   │
│  ╚══════════════════════════════════════════════════════════════════════╝   │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ETAPE 3: COMPLETION                                                        │
│  ═══════════════════                                                        │
│                                                                             │
│  FC.1 Integration Test                                                      │
│       Commande: npm test                                                    │
│       Validation:                                                           │
│       • Tous les tests passent                                              │
│       • Pas de regression                                                   │
│                                                                             │
│  FC.2 Merge                                                                 │
│       Commande: git merge                                                   │
│       └─→ Feature integree                                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Checklist Quick Flow

```
AVANT DE COMMENCER
[ ] Fonctionnalite < 3 stories?
[ ] Pas de changement architectural?
[ ] Framework de test en place?
[ ] CI/CD configure?

PAR STORY (OBLIGATOIRE - meme pour petit ajout!)
[ ] Tests ATDD ecrits (tea → atdd)
[ ] Tests echouent (RED phase verifiee)
[ ] Implementation faite (quick-dev)
[ ] Tests passent (GREEN phase verifiee)
[ ] Score test-review >= 80/100
[ ] Code review approuve
[ ] Tracabilite mise a jour

AVANT MERGE
[ ] Suite de tests complete passe
[ ] Pas de regression detectee
```

### Phases TEA pour QUICK_FLOW

| Etape | Workflow TEA | Quand | Output |
|-------|--------------|-------|--------|
| Quick Spec | [analyze-regression] | Apres quick-spec | specs/regression-analysis-{feature}.md |
| Par Story | [AT] ATDD | Avant quick-dev | tests/{feature}/*.spec.ts |
| Par Story | [RV] Test Review | Apres quick-dev | Score >= 80 |
| Par Story | [TR] Trace Phase 1 | Apres test-review | docs/traceability-matrix.md (incremental) |
| Completion | npm test:regression | Avant merge | Pas de regression |

**Note:** Les phases Test Design, NFR Assessment, Framework et CI ne sont PAS necessaires car elles ont deja ete faites lors du setup initial du projet.

### Commandes Quick Flow

```bash
# QUICK SPEC + REGRESSION ANALYSIS
quick-spec
tea → analyze-regression    # Identifier tests de non-regression
create-story                # Repeter 1-3x

# PAR STORY (Chain of Verification)
tea → atdd
npm test                    # Verifier RED
quick-dev
npm test                    # Verifier GREEN
tea → test-review
code-review
tea → trace (Phase 1)
npm test:regression         # Tests de non-regression

# COMPLETION
npm test                    # Suite complete
git merge
```

---

## PHASE SP.2: POST-STORIES STRUCTURATION

Phase intermediaire entre la planification des stories (SP.1) et leur execution.
Objectif: reorganiser les stories en taches parallelisables pour outils type vibe-kanban.

### Quand executer SP.2

| Situation | Action |
|-----------|--------|
| Apres `create-epics-and-stories` | Executer SP.2 pour structurer |
| Apres `sprint-planning` | Executer SP.2 avant dev |
| Stories deja structurees | Sauter SP.2 |

### Workflow SP.2

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SP.2: POST-STORIES STRUCTURATION                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ETAPE 1: VALIDATION PARALLELISME                                           │
│  ═════════════════════════════════                                          │
│                                                                             │
│  Regle d'or: Toutes les stories d'une meme wave PEUVENT s'executer          │
│              en parallele (aucune dependance intra-wave)                    │
│                                                                             │
│  1.1 Analyser les dependances de chaque story                               │
│      └─ Lire le champ "Dependencies" de chaque story                        │
│      └─ Construire le graphe de dependances                                 │
│                                                                             │
│  1.2 Verifier l'absence de dependances intra-wave                           │
│      └─ Si story A depend de story B dans la meme wave → VIOLATION          │
│      └─ Deplacer story A vers wave suivante                                 │
│                                                                             │
│  1.3 Generer rapport de validation                                          │
│      └─ parallel-validation-report.md                                       │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ETAPE 2: RENOMMAGE SEQUENTIEL                                              │
│  ═════════════════════════════                                              │
│                                                                             │
│  2.1 Renommer les waves avec entiers sequentiels                            │
│      └─ Wave 1.1 → Wave 1                                                   │
│      └─ Wave 1.2 → Wave 2                                                   │
│      └─ etc.                                                                │
│                                                                             │
│  2.2 Renommer les fichiers stories                                          │
│      └─ Format: {Wave}-{Epic}-{Story}.md                                    │
│      └─ Exemple: 1-1-2.md (Wave 1, Epic 1, Story 2)                         │
│                                                                             │
│  2.3 Regrouper tous les fichiers dans un seul repertoire                    │
│      └─ _bmad-output/epics-stories-tasks/stories/                           │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  
│                                                                             │
│  ETAPE 4: GENERATION WAVES DE FIN D'EPIC                                    │
│  ═══════════════════════════════════════                                    │
│                                                                             │
│  Quand une Epic N est terminee dans Wave X, ajouter:                        │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                                                                      │   │
│  │  Wave X.{Epic}: )          │   │
│  │  ──────────────────────────────────────────────────────────          │   │
│  │  • Creer story: X.{Epic}-automate.md                             │   │
│  │  • Agent: tea (Test Architect)                                       │   │
│  │  • Workflow: bmad-bmm-testarch-automate                              │   │
│  │  • Epic concernee: Epic N                                            │   │
│  │  • Objectif: Combler lacunes couverture tests                        │   │
│  │                                                                      │   │
│  │  ─────────────────────────────────────────────                       │   │
│  │  • Creer story: X.{Epic}-nfr-assess.md                           │   │
│  │  • Agent: tea (Test Architect)                                       │   │
│  │  • Workflow: bmad-bmm-testarch-nfr                                   │   │
│  │  • Epic concernee: Epic N                                            │   │
│  │  • Gate: PASS / WAIVED                                               │   │
│  │  • Bloquee par: X.{Epic}-0-automate                                │   │
│  │                                                                      │   │
│  │  ────────────────────────────────────────────────                    │   │
│  │  • Creer story: X.{Epic}-retrospective.md                        │   │
│  │  • Agent: sm (Scrum Master)                                          │   │
│  │  • Workflow: bmad-bmm-retrospective                                  │   │
│  │  • Epic concernee: Epic N                                            │   │
│  │  • Output: docs/retrospective-epic-{N}.md                            │   │
│  │  • Bloquee par: X.{Epic}-0-nfr-assess                              │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ETAPE 5: EXPORT FORMAT PARALLELISABLE                                      │
│  ═════════════════════════════════════                                      │
│                                                                             │
│  5.1 Generer synthese                                                       │
│      └─ _bmad-output/epics-stories-tasks/parallel-waves-summary.md          │
│                                                                             │
│  5.2 Generer export JSON pour vibe-kanban                                   │
│      └─ _bmad-output/epics-stories-tasks/waves-kanban.json                  │
│                                                                             │
│  5.3 Format JSON:                                                           │
│      {                                                                      │
│        "waves": [                                                           │
│          {                                                                  │
│            "id": 1,                                                         │
│            "type": "development",                                           │
│            "parallel": true,                                                │
│            "stories": [...],                                                │
│            "blockedBy": []                                                  │
│          },                                                                 │
│          {                                                                  │
│            "id": 1.1,                                                       │
│            "type": "verification-test-review",                              │
│            "parallel": true,                                                │
│            "stories": [...],                                                │
│            "blockedBy": [1]                                                 │
│          }                                                                  │
│        ]                                                                    │
│      }                                                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Checklist SP.2

```
AVANT SP.2
[ ] Stories generees (create-epics-and-stories termine)
[ ] Sprint planning fait (sprint-planning termine)

ETAPE 1: VALIDATION
[ ] Graphe de dependances construit
[ ] Aucune dependance intra-wave
[ ] Violations corrigees (stories deplacees)
[ ] Rapport de validation genere

ETAPE 2: RENOMMAGE
[ ] Waves numerotees sequentiellement (entiers)
[ ] Fichiers renommes au format {Wave}-{Epic}-{Story}.md
[ ] Tous fichiers dans le meme repertoire



ETAPE 3: WAVES FIN EPIC
[ ] Wave X.Epic avec automate nfr assess et retro

ETAPE 5: EXPORT
[ ] parallel-waves-summary.md genere
[ ] waves-kanban.json genere
[ ] Format JSON valide

APRES SP.2
[ ] Pret pour integration vibe-kanban
[ ] Toutes les taches parallelisables identifiees
```

### Commandes SP.2

```bash
# Executer la structuration complete
sm → structure-waves-for-parallel

# OU etape par etape:

# 1. Valider le parallelisme
sm → validate-wave-parallelism

# 2. Renommer les waves
sm → renumber-waves

# 4. Generer les waves de fin d'epic
sm → generate-epic-completion-waves

# 5. Exporter pour vibe-kanban
sm → export-waves-kanban
```

---

## WORKFLOW DEBUG - Correction de Bug

Workflow special pour la correction de bugs SANS creation de story, avec interaction directe utilisateur.

### Quand utiliser DEBUG

| Utiliser DEBUG si... | NE PAS utiliser si... |
|----------------------|----------------------|
| Bug identifie en production/test | Le "bug" est une nouvelle fonctionnalite |
| Correction rapide necessaire | Changements architecturaux requis |
| Comportement existant a restaurer | Multiple bugs lies (utiliser epic) |
| Pas de nouvelle fonctionnalite | Bug complexe (utiliser FEATURE_SMALL) |

### Workflow DEBUG

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          WORKFLOW DEBUG                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 1: DIAGNOSTIC (Interactif)                                           │
│  ════════════════════════════════                                           │
│                                                                             │
│  D.1 debug-start (Developer)                                                │
│      Echange avec utilisateur:                                              │
│      • Decrivez le bug observe                                              │
│      • Etapes de reproduction?                                              │
│      • Comportement attendu?                                                │
│      └─→ debug/bug-report-{timestamp}.md                                    │
│                                                                             │
│  D.2 debug-analyze (Developer)                                              │
│      └─→ debug/analysis-{timestamp}.md                                      │
│      • Fichiers identifies comme concernes                                  │
│      • Fonctions suspectes                                                  │
│      • Historique git recent                                                │
│                                                                             │
│  D.3 tea → analyze-regression --debug-mode (TEA)                            │
│      └─→ debug/related-tests-{timestamp}.md                                 │
│      • Tests existants pour code concerne                                   │
│      • Couverture actuelle du code suspect                                  │
│      • Tests qui auraient du detecter le bug                                │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 2: CORRECTION (Interactif)                                           │
│  ════════════════════════════════                                           │
│                                                                             │
│  F.1 tea → write-bug-test                     ┌─────────────────┐           │
│      └─→ tests/bugs/bug-{timestamp}.spec.ts   │   RED PHASE     │           │
│      Test qui reproduit le bug                │   DOIT ECHOUER  │           │
│      CE TEST EST CRUCIAL!                     └─────────────────┘           │
│           │                                                                 │
│  F.2 dev-fix (Developer)                      ┌─────────────────┐           │
│      Implementer la correction                │  GREEN PHASE    │           │
│      └─→ npm test → Le test du bug PASSE      │   Bug corrige   │           │
│           │                                   └─────────────────┘           │
│  F.3 debug-verify (Developer + User)                                        │
│      Confirmer avec utilisateur:                                            │
│      • Le bug est-il resolu?                                                │
│      • Comportement conforme aux attentes?                                  │
│      GATE: FIX_CONFIRMED / FIX_INCOMPLETE / NEW_ISSUE                       │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 3: NON-REGRESSION (OBLIGATOIRE!)                                     │
│  ══════════════════════════════════════                                     │
│                                                                             │
│  ⚠️  CETTE PHASE NE PEUT PAS ETRE SAUTEE!                                   │
│                                                                             │
│  R.1 npm test -- --scope=related              ┌─────────────────┐           │
│      Tests lies au code modifie               │  Related pass   │           │
│           │                                   └─────────────────┘           │
│  R.2 npm test -- --scope=module               ┌─────────────────┐           │
│      Tests du module concerne                 │  Module pass    │           │
│           │                                   └─────────────────┘           │
│  R.3 npm test:integration                     ┌─────────────────┐           │
│      Tests d'integration                      │  Integration OK │           │
│           │                                   └─────────────────┘           │
│  R.4 npm test (SI code critique)              ┌─────────────────┐           │
│      Suite complete                           │  Full suite OK  │           │
│           │                                   └─────────────────┘           │
│  R.5 tea → regression-report                                                │
│      └─→ reports/regression-debug-{timestamp}.md                            │
│                                                                             │
│  SI REGRESSION DETECTEE → STOP! Corriger avant de continuer                 │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 4: FINALISATION                                                      │
│  ═════════════════════                                                      │
│                                                                             │
│  C.1 tea → update-test-suite                                                │
│      Integrer le test du bug dans suite permanente                          │
│           │                                                                 │
│  C.2 debug-document                                                         │
│      └─→ debug/fix-documentation-{timestamp}.md                             │
│      • Cause racine                                                         │
│      • Solution implementee                                                 │
│      • Lecons apprises                                                      │
│           │                                                                 │
│  C.3 code-review --quick                                                    │
│      Review rapide de la correction                                         │
│           │                                                                 │
│  C.4 git merge                                                              │
│      Integration de la correction                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Checklist DEBUG

```
DIAGNOSTIC
[ ] Bug clairement decrit
[ ] Etapes de reproduction documentees
[ ] Code impacte identifie
[ ] Tests existants recenses

CORRECTION
[ ] Test du bug ecrit (DOIT ECHOUER - RED)
[ ] Correction implementee
[ ] Test du bug passe (GREEN)
[ ] Correction confirmee par utilisateur

NON-REGRESSION (OBLIGATOIRE!)
[ ] Tests lies passent
[ ] Tests module passent
[ ] Tests integration passent
[ ] Rapport de regression genere

FINALISATION
[ ] Test integre dans suite permanente
[ ] Correction documentee
[ ] Code review approuve
[ ] Merge effectue
```

### Phases TEA pour DEBUG

| Phase | Workflow TEA | Quand | Output |
|-------|--------------|-------|--------|
| Diagnostic | [analyze-regression --debug] | Apres debug-analyze | debug/related-tests-{timestamp}.md |
| Correction | [write-bug-test] | Avant dev-fix | tests/bugs/bug-{timestamp}.spec.ts (RED) |
| Non-Regression | [regression-report] | Apres tous tests | reports/regression-debug-{timestamp}.md |
| Finalisation | [update-test-suite] | Avant merge | Test integre dans suite permanente |

**Note:** Les phases Test Design, NFR Assessment, ATDD standard, Test Review et Trace ne sont PAS utilisees dans DEBUG car:
- C'est une correction ponctuelle, pas une nouvelle fonctionnalite
- Le focus est sur la reproduction du bug + non-regression
- Le test du bug devient un test permanent pour eviter la reapparition

### Commandes DEBUG

```bash
# DIAGNOSTIC
debug-start                         # Collecter info bug
debug-analyze                       # Analyser code impacte
tea → analyze-regression --debug    # Identifier tests existants

# CORRECTION
tea → write-bug-test                # Test reproduisant le bug (RED)
npm test                            # Verifier que test echoue
dev-fix                             # Corriger le bug
npm test                            # Verifier que test passe (GREEN)
debug-verify                        # Confirmer avec utilisateur

# NON-REGRESSION
npm test -- --scope=related         # Tests lies
npm test -- --scope=module          # Tests module
npm test:integration                # Tests integration
npm test                            # Suite complete (si critique)
tea → regression-report             # Rapport

# FINALISATION
tea → update-test-suite             # Integrer test permanent
debug-document                      # Documenter
code-review --quick                 # Review
git merge                           # Integrer
```

---

## Acteurs et Responsabilites

| Acteur | Phases | Responsabilites |
|--------|--------|-----------------|
| **Business Analyst** | 0.B, 1 | Import docs, Brainstorming, Research, Product Brief |
| **Product Manager** | 2 | PRD, Requirements, Success Metrics |
| **UX Designer** | 2 | User Flows, Wireframes, Design System |
| **Architect** | 0.A, 0.B, 3 | Codebase Analysis, Architecture, ADRs |
| **Test Architect (TEA)** | 3, 4, SP.2, QF, DEBUG | Test Design, ATDD, Review, Trace, Regression Analysis |
| **Scrum Master** | 3, 4, SP.2 | Epics, Stories, Sprint Planning, Waves Structuration |
| **Developer** | 4, QF, DEBUG | Implementation, Code Review, Quick Flow, Bug Fix |
| **DevOps** | 5 | Deployment, Infrastructure |

---

## Documents Generes par Phase

### Phase 0: Brownfield Onboarding
- `docs/imported/` (documents projet existants)
- `docs/project-synthesis.md` (synthese BMAD des docs)
- `docs/codebase-analysis.md`
- `docs/technical-debt-report.md`
- `docs/doc-code-reconciliation.md`

### Phase 1: Analysis (Greenfield)
- `docs/brainstorm-report.md`
- `docs/research-findings.md`
- `docs/product-brief.md`

### Phase 2: Planning
- `docs/prd.md`
- `docs/ux-specification.md`
- `designs/wireframes/`
- `designs/mockups/`

### Phase 3: Solutioning
- `docs/architecture.md`
- `docs/adrs/adr-{NNN}-*.md`
- `docs/test-design-architecture.md`
- `docs/test-design-qa.md`
- `docs/nfr-requirements.md`
- `backlog/epics/epic-{N}-*.md`
- `backlog/stories/story-{X.Y.Z}-*.md` (avec section Post-Implementation Steps)

### Sprint 0: Setup
- `tests/` (structure)
- `.github/workflows/test.yml`

### Phase SP.2: Post-Stories Structuration
- `_bmad-output/epics-stories-tasks/parallel-validation-report.md`
- `_bmad-output/epics-stories-tasks/parallel-waves-summary.md`
- `_bmad-output/epics-stories-tasks/waves-kanban.json`

- Stories fin epic: `{Wave}.{Epic}'

### Phase 4: Implementation
- `docs/test-design-epic-{N}.md`
- `tests/stories/{X.Y.Z}/*.spec.ts`
- `reviews/test-review-{X.Y.Z}.md`
- `reviews/code-review-{X.Y.Z}.md`
- `docs/traceability-matrix.md`

### Phase 5: Release
- `docs/gate-decision-release.md`

### Quick Flow (FEATURE_SMALL)
- `specs/quick-spec-{feature-name}.md`
- `specs/regression-analysis-{feature-name}.md`
- `stories/story-{X.Y.Z}.md` (1-3 stories)
- `tests/{feature}/*.spec.ts`
- `reviews/test-review-{X.Y.Z}.md`
- `reviews/code-review-{X.Y.Z}.md`

### DEBUG (Correction de bug)
- `debug/bug-report-{timestamp}.md`
- `debug/analysis-{timestamp}.md`
- `debug/related-tests-{timestamp}.md`
- `tests/bugs/bug-{timestamp}.spec.ts` → integre ensuite dans suite permanente
- `reports/regression-debug-{timestamp}.md`
- `debug/fix-documentation-{timestamp}.md`

---

## Commandes Recapitulatives

### GREENFIELD (Nouveau projet)

```bash
# PHASE 1 - Analysis
brainstorm
research
create-product-brief

# PHASE 2 - Planning
create-prd
create-ux-design

# PHASE 3 - Solutioning
create-architecture
tea → test-design (system-level)
tea → nfr-assess
create-epics-and-stories
check-implementation-readiness

# SPRINT 0 - Setup
tea → framework
tea → setup-ci

# PHASE 4 - Epic
tea → test-design (epic-level)
sprint-planning

# PHASE SP.2 - Post-Stories Structuration (avant execution)
sm → structure-waves-for-parallel    # Structuration complete
# OU etape par etape:
# sm → validate-wave-parallelism     # Valider parallelisme intra-wave
# sm → renumber-waves                # Renommer waves en entiers
# sm → generate-verification-waves   # Generer waves X.1, X.2, X.3
# sm → generate-epic-completion-waves # Generer waves X.4, X.5, X.6
# sm → export-waves-kanban           # Export pour vibe-kanban

# PHASE 4 - Story Loop
create-story
tea → atdd
npm test  # RED
dev-story
npm test  # GREEN
tea → test-review
code-review
tea → trace (Phase 1)

# PHASE 4 - Epic End
tea → automate
tea → nfr-assess
retrospective

# PHASE 5 - Release
tea → trace (Phase 2)
deploy
```

### BROWNFIELD_INITIAL (Projet existant)

```bash
# PHASE 0.A - Sans documentation existante
analyze-codebase

# PHASE 0.B - Avec documents projet traditionnels
import-project-docs           # Importer cahier des charges, specs...
analyze-project-documentation # Synthese vers format BMAD
analyze-codebase             # Analyse du code
reconcile-documentation      # Reconciliation doc vs code

# PHASE 2+ - Comme Greenfield (voir ci-dessus)
# Mais avec adaptation aux documents existants
```

### QUICK FLOW (Petit ajout 1-3 stories)

```bash
# QUICK SPEC
quick-spec                   # Specification rapide
create-story                 # 1-3 stories max

# STORY LOOP (OBLIGATOIRE pour chaque story!)
tea → atdd                   # Creer tests
npm test                     # Verifier RED
quick-dev                    # Implementation
npm test                     # Verifier GREEN
tea → test-review            # Score >= 80
code-review                  # Revue code
tea → trace (Phase 1)        # Tracabilite

# COMPLETION
npm test                     # Suite complete
git merge                    # Integration
```

---

## Integration Vibe Kanban

Le workflow BMAD peut etre integre avec **Vibe Kanban** pour la gestion visuelle des stories et taches.

### Workflow d'Integration

```
┌───────────────────────────────────────────────────────────────┐
│                   WORKFLOW D'INTEGRATION                       │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  1. LANCER VIBE KANBAN                                        │
│     └─ pnpm run dev (dans le repertoire vibe-kanban)          │
│                                                               │
│  2. CREER/OUVRIR UN PROJET                                    │
│     └─ Ouvrir le navigateur sur http://localhost:3000         │
│     └─ Creer ou selectionner un projet                        │
│                                                               │
│  3. (OPTIONNEL) LIER A UN SERVEUR DISTANT                     │
│     └─ Si collaboration multi-utilisateurs                    │
│                                                               │
│  4. IMPORTER LES STORIES BMAD                                 │
│     └─ ./scripts/workflow-runner.sh --export-kanban           │
│                                                               │
│  5. EXECUTER LES WORKFLOWS DEPUIS VIBE KANBAN                 │
│     └─ Chaque tache contient les instructions BMAD            │
│     └─ Lancer un Workspace pour execution automatique         │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

### Commandes d'Export

```bash
# Export simple vers le projet actif
./scripts/workflow-runner.sh --export-kanban

# Simulation (sans creer de taches)
./scripts/workflow-runner.sh --export-kanban --dry-run

# Specifier un repertoire de stories different
./scripts/workflow-runner.sh --export-kanban --stories-dir backlog/stories

# Specifier un projet cible
./scripts/workflow-runner.sh --export-kanban --project-id "uuid-du-projet"

# Script d'import direct
./scripts/import-to-vibe-kanban.sh --help
```

### Format des Taches Importees

Chaque story BMAD est convertie en tache Vibe Kanban avec:

| Element Story BMAD | Element Tache Vibe Kanban |
|--------------------|---------------------------|
| ID (X.Y.Z) | Prefixe du titre `[X.Y.Z]` |
| Titre | Titre de la tache |
| User Story | Description - section User Story |
| Criteres d'acceptation | Description - section AC |
| Fichiers impactes | Description - section technique |
| Dependencies | Description - section dependencies |
| Workflow BMAD | Description - instructions d'execution |

### Execution Automatique

Les taches importees contiennent les instructions pour l'agent Claude Code:

```markdown
## Workflow BMAD:
1. `tea → atdd` - Creer les tests (RED)
2. `dev → story` - Implementer la story (GREEN)
3. `tea → test-review` - Review des tests
4. `tea → trace` - Mise a jour tracabilite
5. `tea → regression` - Tests de non-regression
```

Lorsqu'un Workspace est lance sur une tache, l'agent execute automatiquement le workflow BMAD correspondant.

### Prerequis

- **Vibe Kanban** doit etre lance (`pnpm run dev`)
- **jq** doit etre installe (`brew install jq`)
- Les stories doivent etre au format `stories/story-X.Y.Z-*.md`
