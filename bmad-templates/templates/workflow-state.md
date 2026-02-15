# Template: Etat d'Execution du Workflow

Ce fichier trace l'etat d'execution du workflow BMAD+TEA en cours.
Il permet de savoir ou l'on se trouve et de reprendre apres une interruption.

---

## Fichier d'Etat: `.bmad/workflow-state.yaml`

```yaml
# =============================================================================
# BMAD + TEA Workflow State
# Ce fichier est genere et mis a jour automatiquement
# NE PAS MODIFIER MANUELLEMENT sauf pour correction
# =============================================================================

# Metadata
metadata:
  version: "1.0"
  created_at: "{date_creation}"
  updated_at: "{date_mise_a_jour}"
  project_name: "{nom_projet}"

# Configuration du Workflow
workflow:
  type: "{greenfield|brownfield_initial|brownfield_with_docs|feature_small|feature_large|debug}"
  config_file: "configs/workflow-{type}.yaml"
  started_at: "{date_debut}"
  estimated_completion: "{date_estimee}"

# Etat Global
status:
  current_phase: "{phase_en_cours}"
  current_step: "{etape_en_cours}"
  overall_progress: "{pourcentage}%"
  state: "{not_started|in_progress|paused|completed|failed|blocked}"
  last_action: "{derniere_action}"
  last_action_at: "{timestamp}"

# Historique des Phases
phases:
  phase_0:
    name: "Brownfield Onboarding"
    status: "{skipped|not_started|in_progress|completed}"
    started_at: "{timestamp}"
    completed_at: "{timestamp}"
    steps:
      - id: "0.A.1"
        name: "analyze-codebase"
        status: "{pending|in_progress|completed|skipped}"
        completed_at: "{timestamp}"
      - id: "0.B.1"
        name: "import-project-docs"
        status: "{pending|in_progress|completed|skipped}"
      # ...

  phase_1:
    name: "Analysis"
    status: "{skipped|not_started|in_progress|completed}"
    # ...

  phase_2:
    name: "Planning"
    status: "{not_started|in_progress|completed}"
    steps:
      - id: "P2.1"
        name: "create-prd"
        status: "completed"
        completed_at: "2024-01-15T10:30:00Z"
        output: "docs/prd.md"
      - id: "P2.2"
        name: "create-ux-design"
        status: "in_progress"
        started_at: "2024-01-15T11:00:00Z"

  phase_3:
    name: "Solutioning"
    status: "{not_started|in_progress|completed}"
    # ...

  sprint_0:
    name: "Setup"
    status: "{not_started|in_progress|completed|skipped}"
    # ...

  phase_4:
    name: "Implementation"
    status: "{not_started|in_progress|completed}"
    current_epic: "{epic_id}"
    current_story: "{X.Y.Z}"
    current_story_step: "{step_id}"
    epics:
      - id: "1"
        name: "Authentication"
        status: "in_progress"
        stories_total: 5
        stories_completed: 2
        stories:
          - id: "1.1.0"
            status: "completed"
          - id: "1.1.1"
            status: "completed"
          - id: "1.1.2"
            status: "in_progress"
            current_step: "ST.4"  # test-review
          - id: "1.2.0"
            status: "pending"
          - id: "1.2.1"
            status: "pending"

  phase_5:
    name: "Release"
    status: "{not_started|in_progress|completed}"
    # ...

# Quick Flow (pour FEATURE_SMALL)
quick_flow:
  status: "{not_started|in_progress|completed|n/a}"
  quick_spec: "{pending|completed}"
  regression_analysis: "{pending|completed}"
  stories_created: 0
  stories:
    - id: "X.Y.0"
      status: "pending"
    # ...

# Debug Flow (pour DEBUG)
debug_flow:
  status: "{not_started|in_progress|completed|n/a}"
  bug_id: "BUG-{timestamp}"
  phase: "{diagnostic|fix|regression|finalization}"
  current_step: "{step_id}"
  steps:
    diagnostic:
      - id: "D.1"
        name: "bug-report"
        status: "completed"
      - id: "D.2"
        name: "analyze-code"
        status: "completed"
      - id: "D.3"
        name: "identify-tests"
        status: "in_progress"
    fix:
      - id: "F.1"
        name: "write-bug-test"
        status: "pending"
      # ...
    regression:
      - id: "R.1"
        name: "related-tests"
        status: "pending"
      # ...
    finalization:
      - id: "C.1"
        name: "integrate-test"
        status: "pending"
      # ...

# Chain of Verification (pour story en cours)
current_story_chain:
  story_id: "{X.Y.Z}"
  steps:
    - id: "ST.1"
      name: "create-story"
      status: "completed"
      completed_at: "{timestamp}"
    - id: "ST.2"
      name: "atdd"
      status: "completed"
      red_verified: true
      completed_at: "{timestamp}"
    - id: "ST.3"
      name: "dev-story"
      status: "completed"
      green_verified: true
      completed_at: "{timestamp}"
    - id: "ST.4"
      name: "test-review"
      status: "in_progress"
      score: null
      started_at: "{timestamp}"
    - id: "ST.5"
      name: "code-review"
      status: "pending"
    - id: "ST.6"
      name: "trace"
      status: "pending"
    - id: "ST.7"
      name: "regression-test"
      status: "pending"

# Artefacts Generes
artifacts:
  docs:
    - path: "docs/prd.md"
      created_at: "{timestamp}"
      phase: "phase_2"
    - path: "docs/architecture.md"
      created_at: "{timestamp}"
      phase: "phase_3"
    # ...
  stories:
    - path: "stories/story-1.1.0-login-ui.md"
      created_at: "{timestamp}"
  tests:
    - path: "tests/stories/1.1.0/login.spec.ts"
      created_at: "{timestamp}"
  reviews:
    - path: "reviews/test-review-1.1.0.md"
      created_at: "{timestamp}"

# Blockers et Issues
blockers:
  - id: "BLOCK-001"
    description: "Attente validation PO"
    created_at: "{timestamp}"
    blocking_step: "P2.1"
    status: "active"
  # ...

# Checkpoints (pour reprise)
checkpoints:
  - id: "CP-001"
    description: "Phase 2 complete"
    created_at: "{timestamp}"
    can_resume_from: true
  - id: "CP-002"
    description: "Story 1.1.0 complete"
    created_at: "{timestamp}"
    can_resume_from: true

# Historique des Actions
history:
  - timestamp: "2024-01-15T09:00:00Z"
    action: "workflow_started"
    details: "Started greenfield workflow"
  - timestamp: "2024-01-15T09:30:00Z"
    action: "step_completed"
    step: "P1.1"
    details: "Brainstorm completed"
  - timestamp: "2024-01-15T10:00:00Z"
    action: "step_started"
    step: "P1.2"
    details: "Research started"
  # ...
```

---

## Commandes de Gestion de l'Etat

### Initialiser un Nouveau Workflow

```bash
bmad-init --type=greenfield --project="MonProjet"
```

Cree `.bmad/workflow-state.yaml` avec l'etat initial.

### Consulter l'Etat Actuel

```bash
bmad-status
```

Affiche:
```
=== BMAD Workflow Status ===

Project: MonProjet
Type: GREENFIELD
Started: 2024-01-15

Current Phase: Phase 4 - Implementation
Current Step: ST.4 - test-review
Current Story: 1.1.2

Progress: 45%

Chain of Verification for 1.1.2:
  [x] create-story
  [x] atdd (RED verified)
  [x] dev-story (GREEN verified)
  [ ] test-review (IN PROGRESS)
  [ ] code-review
  [ ] trace
  [ ] regression-test

Next Action: Complete test-review with score >= 80
```

### Marquer une Etape Complete

```bash
bmad-complete --step=ST.4 --score=85
```

### Reprendre apres Interruption

```bash
bmad-resume
```

Analyse l'etat et propose la prochaine action.

### Lister les Checkpoints

```bash
bmad-checkpoints
```

### Revenir a un Checkpoint

```bash
bmad-rollback --checkpoint=CP-002
```

---

## Integration avec le Script Runner

Le script `workflow-runner.sh` doit:

1. **Verifier l'existence de l'etat** au demarrage
2. **Mettre a jour l'etat** apres chaque etape
3. **Creer des checkpoints** aux moments cles
4. **Permettre la reprise** si interrompu

---

## Affichage de l'Etat dans Claude Code

Quand l'utilisateur demande le status ou lance une commande:

```
┌─────────────────────────────────────────────────────────────┐
│  BMAD Workflow: GREENFIELD                                  │
│  Project: MonProjet                                         │
│  Progress: ████████████░░░░░░░░ 45%                        │
├─────────────────────────────────────────────────────────────┤
│  Phase: Implementation (4/5)                                │
│  Epic: 1 - Authentication (3/5 stories)                     │
│  Story: 1.1.2 - Login Integration                           │
│  Step: test-review (4/7)                                    │
├─────────────────────────────────────────────────────────────┤
│  Chain of Verification:                                     │
│  [✓] create-story  [✓] atdd  [✓] dev  [●] review  [ ]...   │
└─────────────────────────────────────────────────────────────┘
```
