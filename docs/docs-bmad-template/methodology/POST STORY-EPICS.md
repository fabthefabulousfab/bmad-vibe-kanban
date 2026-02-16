# POST STORY-EPICS - Notes de conception

> **STATUT:** Formalise et integre dans `01-WORKFLOW-PHASES-COMPLETE.md`
>
> Voir la section **PHASE SP.2: POST-STORIES STRUCTURATION** dans le document principal.

---

## Resume des exigences (archivees)

Ce fichier contenait les notes brutes pour la phase post-generation des stories.
Ces exigences ont ete formalisees comme suit:

### 1. Validation parallelisme intra-wave
- Toutes les stories d'une wave doivent pouvoir s'executer en parallele
- Aucune dependance entre stories de la meme wave

### 2. Renommage sequentiel
- Waves numerotees en entiers (pas de decimaux)
- Format fichier: `{Wave}-{Epic}-{Story}.md`
- Tous les fichiers dans un seul repertoire

### 3. A rajouter dans chaque story à la fin
#### Post-Implementation Steps

After completing this story, execute the following BMAD workflows in order:

| Step | Agent | Workflow | Path |
|------|-------|----------|------|
| 1 | TEA | test-review | `_bmad/bmm/workflows/testarch/test-review/workflow.yaml` |
| 2 | DEV | code-review | `_bmad/bmm/workflows/4-implementation/code-review/workflow.yaml` |
| 3 | TEA | trace | `_bmad/bmm/workflows/testarch/trace/workflow.yaml` |

#### Commands

```bash
# 1. Test Review - Validate test quality
tea -> test-review

# 2. Code Review - Review implementation
dev -> code-review

# 3. Trace - Update traceability matrix
tea -> trace
```


### 4. Waves de fin d'epic
- Wave X.4: automate (tea → automate)
- Wave X.5: nfr-assess (tea → nfr-assess) - bloquee par X.4
- Wave X.6: retrospective (sm → retrospective) - bloquee par X.5

### 5. Export format parallelisable
- `parallel-waves-summary.md`
- `waves-kanban.json`

---

## Reference

Document principal: [01-WORKFLOW-PHASES-COMPLETE.md](./01-WORKFLOW-PHASES-COMPLETE.md)

Sections concernees:
- **Vue d'ensemble des Phases** → SP.2 POST-STORIES STRUCTURATION
- **PHASE SP.2: POST-STORIES STRUCTURATION** → Workflow complet
- **Documents Generes par Phase** → Phase SP.2
- **Commandes Recapitulatives** → PHASE SP.2
