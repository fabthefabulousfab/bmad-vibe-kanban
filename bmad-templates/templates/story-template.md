# Story {X.Y.Z}: {STORY_TITLE}

## Metadata

| Champ | Valeur |
|-------|--------|
| **ID** | {X.Y.Z} |
| **Epic** | {X} - {EPIC_NAME} |
| **Bloc parallele** | {Y} |
| **Sequence** | {Z} |
| **Status** | `todo` / `in_progress` / `done` |
| **Assignee** | |
| **Sprint** | |
| **Points** | |

## Dependencies

```yaml
blocked_by: [{LIST_OF_X.Y.Z}]  # Stories qui doivent etre terminees avant
blocks: [{LIST_OF_X.Y.Z}]       # Stories qui attendent celle-ci
```

**Peut demarrer quand:** {CONDITION_OU_IMMEDIATE}

---

## Description

{DESCRIPTION_DETAILLEE_DE_LA_STORY}

### Contexte

{CONTEXTE_BUSINESS_ET_TECHNIQUE}

### User Story Format

> **En tant que** {PERSONA}
> **Je veux** {ACTION}
> **Afin de** {BENEFICE}

---

## Criteres d'Acceptation

### AC-1: {TITRE_CRITERE_1}
- [ ] {CONDITION_VERIFIABLE_1}
- [ ] {CONDITION_VERIFIABLE_2}

### AC-2: {TITRE_CRITERE_2}
- [ ] {CONDITION_VERIFIABLE_1}
- [ ] {CONDITION_VERIFIABLE_2}

### AC-3: {TITRE_CRITERE_3}
- [ ] {CONDITION_VERIFIABLE_1}
- [ ] {CONDITION_VERIFIABLE_2}

---

## Specifications Techniques

### Fichiers Impactes

| Fichier | Type de changement |
|---------|-------------------|
| `{PATH}` | Create / Modify / Delete |

### API Changes (si applicable)

```
METHOD /api/endpoint
Request: { ... }
Response: { ... }
```

### Data Model Changes (si applicable)

```
Entity: {NAME}
Fields: { ... }
```

---

## TEST REQUIREMENTS

> Cette section est generee par TEA `test-design` et doit etre completee avant implementation.

### Niveau de Risque

| Critere | Valeur |
|---------|--------|
| **Probabilite d'echec** | Low / Medium / High |
| **Impact business** | Low / Medium / High |
| **Priorite test** | P0 / P1 / P2 / P3 |

### Tests API Requis

```typescript
// Fichier: tests/api/{X.Y.Z}/api.spec.ts

describe('{STORY_TITLE} API', () => {

  test('AC-1: {DESCRIPTION}', async () => {
    // Given: {PRECONDITION}
    // When: {ACTION}
    // Then: {EXPECTED_RESULT}
  });

  test('AC-2: {DESCRIPTION}', async () => {
    // Given: {PRECONDITION}
    // When: {ACTION}
    // Then: {EXPECTED_RESULT}
  });

  test('Error case: {DESCRIPTION}', async () => {
    // Given: {PRECONDITION}
    // When: {ACTION}
    // Then: {EXPECTED_ERROR}
  });

});
```

### Tests E2E Requis

```typescript
// Fichier: tests/e2e/{X.Y.Z}/e2e.spec.ts

describe('{STORY_TITLE} E2E', () => {

  test('User flow: {DESCRIPTION}', async () => {
    // Step 1: {ACTION}
    // Step 2: {ACTION}
    // Verify: {EXPECTED_STATE}
  });

});
```

### Tests Composants Requis (si UI)

```typescript
// Fichier: tests/components/{X.Y.Z}/component.spec.ts

describe('{COMPONENT_NAME}', () => {

  test('renders correctly', () => {
    // ...
  });

  test('handles {INTERACTION}', () => {
    // ...
  });

});
```

### Couverture Requise

| Type de test | Nombre min | Priorite |
|--------------|------------|----------|
| API tests | {N} | {P} |
| E2E tests | {N} | {P} |
| Component tests | {N} | {P} |

---

## DEFINITION OF DONE

### Pre-Implementation

- [ ] **Story preparee** - Criteres d'acceptation clairs et valides
- [ ] **Tests ATDD crees** - `tea → atdd` execute
- [ ] **Tests echouent (RED)** - `npm test` confirme echec

### Implementation

- [ ] **Code implemente** - Fonctionnalite complete
- [ ] **Tests passent (GREEN)** - `npm test` confirme succes
- [ ] **Pas de regression** - Suite complete passe

### Quality

- [ ] **Test review OK** - `tea → test-review` score >= 80/100
  - Score obtenu: ___/100
  - Issues critiques resolues: [ ]
- [ ] **Code review OK** - PR approuvee
  - Reviewer: ___
  - Date: ___

### Traceability

- [ ] **Tracabilite maj** - `tea → trace` execute
  - AC-1 → Test: ___
  - AC-2 → Test: ___
  - AC-3 → Test: ___
- [ ] **Documentation maj** - Si necessaire

### Validation Finale

- [ ] **Tous les criteres AC valides**
- [ ] **Merge dans branche principale**
- [ ] **Story fermee**

---

## Historique

| Date | Action | Par |
|------|--------|-----|
| {DATE} | Story creee | {AUTHOR} |
| | Tests ATDD crees | |
| | Implementation commencee | |
| | Tests passent | |
| | Code review OK | |
| | Story terminee | |

---

## Notes

{NOTES_ADDITIONNELLES}

---

## References

- Epic: `backlog/epics/epic-{X}-{EPIC_NAME}.md`
- PRD: `docs/prd.md#section`
- Architecture: `docs/architecture.md#section`
- Test Design: `docs/test-design-epic-{X}.md`
