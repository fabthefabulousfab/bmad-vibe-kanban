# Template: Tache de Test de Non-Regression

## Metadata

```yaml
task_id: REGRESSION-{X.Y.Z}
story_id: {X.Y.Z}
type: regression-test
actor: Developer | Test Architect
status: pending | in_progress | passed | failed | blocked
created: {date}
updated: {date}
```

## Objectif

Executer les tests de non-regression identifies lors de l'analyse pour verifier que les modifications n'impactent pas les fonctionnalites existantes.

---

## Prerequisites

Avant de commencer cette tache:

- [ ] Story implementee (dev-story termine)
- [ ] Tests de la story passent (GREEN)
- [ ] Test review effectue (score >= 80)
- [ ] Code review approuve
- [ ] Tracabilite mise a jour
- [ ] Fichier `regression-analysis-{feature}.md` disponible

---

## Inputs

| Input | Chemin | Description |
|-------|--------|-------------|
| Analyse de regression | `specs/regression-analysis-{feature}.md` | Liste des tests a executer |
| Story | `stories/story-{X.Y.Z}.md` | Reference de la story |
| Code modifie | `src/{files}` | Fichiers impactes |

---

## Procedure

### Etape 1: Charger l'Analyse de Regression

```bash
# Consulter l'analyse
cat specs/regression-analysis-{feature}.md
```

Identifier:
- [ ] Tests de Niveau 1 (lies au code modifie)
- [ ] Tests de Niveau 2 (module)
- [ ] Tests de Niveau 3 (integration) - si applicable
- [ ] Tests de Niveau 4 (suite complete) - si code critique

### Etape 2: Executer les Tests par Niveau

#### Niveau 1: Tests Lies (OBLIGATOIRE)

```bash
# Executer les tests directement lies aux fichiers modifies
npm test -- --grep "{pattern}" {fichiers_tests_niveau1}

# OU avec scope
npm test -- --scope=related
```

**Validation:**
- [ ] Tous les tests Niveau 1 PASSENT
- [ ] Duree d'execution acceptable

Si ECHEC:
1. Identifier le test en echec
2. Analyser la cause (regression ou test obsolete)
3. Si regression → corriger le code
4. Si test obsolete → adapter le test (avec justification)
5. Re-executer

#### Niveau 2: Tests Module (OBLIGATOIRE)

```bash
# Executer tous les tests du module modifie
npm test -- --scope=module:{module_name}

# OU specifier le repertoire
npm test tests/{module}/
```

**Validation:**
- [ ] Tous les tests Niveau 2 PASSENT

#### Niveau 3: Tests Integration (Si Epic ou Feature Large)

```bash
npm test:integration
```

**Validation:**
- [ ] Tests d'integration PASSENT
- [ ] Pas de regression inter-modules

#### Niveau 4: Suite Complete (Si Code Critique)

Criteres pour executer la suite complete:
- [ ] Modification de code de securite
- [ ] Modification de modele de donnees
- [ ] Modification de core business logic
- [ ] Demande explicite dans l'analyse

```bash
npm test
```

**Validation:**
- [ ] Suite complete PASSE

### Etape 3: Documenter les Resultats

Remplir le tableau de resultats:

```markdown
## Resultats d'Execution

| Niveau | Tests | Pass | Fail | Skip | Duree | Status |
|--------|-------|------|------|------|-------|--------|
| 1 - Lies | {n} | {n} | 0 | 0 | {s}s | PASS |
| 2 - Module | {n} | {n} | 0 | 0 | {s}s | PASS |
| 3 - Integration | {n} | {n} | 0 | 0 | {s}s | PASS |
| 4 - Complet | {n} | {n} | 0 | {n} | {s}s | PASS |

**RESULTAT GLOBAL: PASS / FAIL**
```

### Etape 4: Gerer les Echecs (si applicable)

Si des tests echouent:

```markdown
## Analyse des Echecs

### Test: {nom_du_test}
- **Fichier**: {chemin}
- **Erreur**: {message}
- **Cause**: [ ] Regression | [ ] Test obsolete | [ ] Flaky
- **Action**: {action prise}
- **Resolution**: {description}
```

**Arbre de decision:**

```
Test echoue
    │
    ├─ C'est une regression?
    │   ├─ OUI → Corriger le code → Re-tester
    │   └─ NON → Continuer
    │
    ├─ Test obsolete?
    │   ├─ OUI → Adapter le test (documenter pourquoi)
    │   └─ NON → Continuer
    │
    ├─ Test flaky?
    │   ├─ OUI → Marquer @flaky, creer ticket
    │   └─ NON → Investiguer plus
    │
    └─ Autre probleme?
        └─ Escalader a l'equipe
```

---

## Output

### Fichier de Rapport (optionnel pour story simple)

Si demande, generer: `reports/regression-{X.Y.Z}.md`

Utiliser le prompt `prompt-regression-report.md` pour le format complet.

### Mise a Jour du Status

Dans le fichier de story `stories/story-{X.Y.Z}.md`, mettre a jour:

```markdown
## Definition of Done

### Quality
- [x] Test review >= 80
- [x] Code review approved
- [x] **Regression tests PASS** ← METTRE A JOUR
```

---

## Validation

### Checklist de Completion

- [ ] Niveau 1 (tests lies) execute et PASS
- [ ] Niveau 2 (tests module) execute et PASS
- [ ] Niveau 3 (integration) execute si applicable
- [ ] Niveau 4 (complet) execute si code critique
- [ ] Aucune regression detectee
- [ ] Echecs analyses et resolus (si applicable)
- [ ] Story mise a jour
- [ ] Status de la tache: `passed`

### Criteres de Succes

| Critere | Requis | Status |
|---------|--------|--------|
| Tous tests Niveau 1 PASS | Obligatoire | [ ] |
| Tous tests Niveau 2 PASS | Obligatoire | [ ] |
| Tests integration PASS | Si Epic | [ ] |
| Pas de regression | Obligatoire | [ ] |

---

## Problemes Courants

### Tests qui echouent pour raison non liee

**Symptome**: Test echoue mais pas lie aux modifications
**Cause probable**: Test flaky, environnement, donnees
**Solution**:
1. Re-executer le test seul
2. Verifier l'environnement
3. Si persistant, marquer comme flaky et creer ticket

### Regression inattendue

**Symptome**: Test d'une feature non modifiee echoue
**Cause probable**: Effet de bord non anticipe
**Solution**:
1. Analyser le lien avec les modifications
2. Corriger le code ou adapter l'approche
3. Re-executer depuis Niveau 1

### Tests trop lents

**Symptome**: Suite de regression prend trop de temps
**Cause probable**: Trop de tests ou tests non optimises
**Solution**:
1. Verifier le scope de l'analyse de regression
2. Paralleliser si possible
3. Prioriser par niveau

---

## Tache Suivante

Apres completion:
- **Si PASS**: Story complete → Merge possible
- **Si FAIL**: Retour a la correction → Re-tester
