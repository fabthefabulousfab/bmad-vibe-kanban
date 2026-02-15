# Task: Code Review - Story {X.Y.Z}

## Metadata

| Champ | Valeur |
|-------|--------|
| **Task ID** | CODE-REVIEW-{X.Y.Z} |
| **Type** | Code Quality |
| **Story** | {X.Y.Z} - {STORY_TITLE} |
| **Actor** | Developer + Reviewer |
| **Status** | `todo` / `in_progress` / `done` |

## Dependencies

```yaml
blocked_by: ["TEST-REVIEW-{X.Y.Z}"]
blocks: ["TRACE-{X.Y.Z}"]
```

**Prerequis:** Test review complete avec score >= 80

---

## Objectif

Valider la qualite du code et son alignement avec l'architecture et les standards du projet.

---

## Procedure

### Step 1: Preparer la revue

#### Verifier les prerequis

- [ ] Story `{X.Y.Z}` implementation complete
- [ ] Tous les tests passent
- [ ] Test review score >= 80

#### Rassembler les documents de reference

- Story: `stories/story-{X.Y.Z}.md`
- Architecture: `docs/architecture.md`
- Test Review: `reviews/test-review-{X.Y.Z}.md`

### Step 2: Lancer la revue de code

```bash
code-review
```

Ou via PR:
```bash
gh pr create --title "Story {X.Y.Z}: {STORY_TITLE}"
```

### Step 3: Checklist de revue

#### Architecture & Design

- [ ] Code conforme a l'architecture documentee
- [ ] Patterns existants respectes
- [ ] Pas de duplication de code
- [ ] Separation des responsabilites correcte
- [ ] Nommage clair et consistant

#### Qualite du Code

- [ ] Code lisible et auto-documente
- [ ] Fonctions courtes et focalisees
- [ ] Gestion des erreurs appropriee
- [ ] Pas de code mort ou commente
- [ ] Pas de TODO laisses sans tracking

#### Securite

- [ ] Pas de donnees sensibles en dur
- [ ] Inputs valides et sanitises
- [ ] Pas de vulnerabilites OWASP
- [ ] Authentification/autorisation correcte

#### Performance

- [ ] Pas de requetes N+1
- [ ] Pas de boucles inefficaces
- [ ] Ressources liberees correctement
- [ ] Pas de memory leaks evidents

#### Tests

- [ ] Tests couvrent les criteres d'acceptation
- [ ] Tests lisibles et maintenables
- [ ] Edge cases couverts
- [ ] Test review score >= 80 confirme

### Step 4: Documenter les findings

Pour chaque probleme trouve:

| # | Severite | Fichier:Ligne | Description | Resolution |
|---|----------|---------------|-------------|------------|
| 1 | {BLOCKER/MAJOR/MINOR} | `path:line` | {DESCRIPTION} | {SUGGESTION} |

### Step 5: Decision

| Verdict | Condition | Action |
|---------|-----------|--------|
| **APPROVED** | Aucun blocker, mineurs acceptables | Merger |
| **CHANGES_REQUESTED** | Blockers ou majeurs presents | Corriger et re-review |
| **NEEDS_DISCUSSION** | Questions architecturales | Reunir l'equipe |

### Step 6: Finalisation

Si APPROVED:
```bash
gh pr merge --squash
```

Si CHANGES_REQUESTED:
1. Developeur corrige les issues
2. Push des corrections
3. Retour a Step 3

---

## Validation Checklist

- [ ] Tous les fichiers revus
- [ ] Checklist complete
- [ ] Findings documentes
- [ ] Decision prise
- [ ] PR mergee (si approved)

---

## Output

### Rapport de revue

```
Date: {DATE}
Story: {X.Y.Z} - {STORY_TITLE}
Reviewer: {NAME}

FILES REVIEWED:
- {FILE_1}: {STATUS}
- {FILE_2}: {STATUS}

FINDINGS:
- Blockers: {N}
- Majors: {N}
- Minors: {N}

VERDICT: {APPROVED/CHANGES_REQUESTED/NEEDS_DISCUSSION}

COMMENTS:
{COMMENTS}
```

### Fichier rapport

- [ ] `reviews/code-review-{X.Y.Z}.md` genere

---

## Problemes Courants

| Probleme | Solution |
|----------|----------|
| Desaccord sur implementation | Referer a l'architecture/ADRs |
| Scope creep | Creer nouvelle story pour ajouts |
| Tests insuffisants | Retour a ATDD pour completer |

---

## Next Task

Une fois cette tache terminee, la tache suivante est:
→ `TRACE-{X.Y.Z}` - Mise a jour tracabilite
