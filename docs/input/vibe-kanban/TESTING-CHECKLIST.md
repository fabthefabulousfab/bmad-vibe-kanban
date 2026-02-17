# Testing Checklist - Post-Migration Validation

Exécuter ces tests dans l'ordre pour valider la migration complète.

## Phase 1: Structure et Configuration

### Test 1.1: Structure du Repository
```bash
# Vérifier la structure
ls -la bmad-templates/
ls -la scripts/
ls -la test-tools/post-migration/

# Vérifier les fichiers clés
cat README.md | head -20
cat FORK.md | head -20
```

**Attendu:**
- bmad-templates/ existe avec stories/, _bmad/, scripts/, templates/, .claude/
- scripts/ contient sync-stories.sh, build-vibe-kanban.sh, build-installer.sh
- README mentionne "BMAD Vibe Kanban" et "fork of Vibe Kanban 0.1.4"

### Test 1.2: Compter les Stories
```bash
# Compter les stories par workflow
find bmad-templates/stories/workflow-complet -name "*.md" -not -name "X-*" | wc -l
find bmad-templates/stories/quick-flow -name "*.md" -not -name "X-*" | wc -l
find bmad-templates/stories/document-project -name "*.md" -not -name "X-*" | wc -l
find bmad-templates/stories/debug -name "*.md" -not -name "X-*" | wc -l
```

**Attendu:**
- workflow-complet: 18 stories
- quick-flow: 4 stories
- document-project: 10 stories
- debug: 7 stories

### Test 1.3: Scripts Exécutables
```bash
# Vérifier permissions
ls -la scripts/*.sh

# Vérifier syntaxe bash
bash -n scripts/sync-stories.sh
bash -n scripts/build-vibe-kanban.sh
bash -n scripts/build-installer.sh
```

**Attendu:** Tous les scripts sont exécutables (x) et sans erreur de syntaxe

---

## Phase 2: Synchronisation des Stories

### Test 2.1: Story Sync
```bash
# Nettoyer d'abord
rm -rf frontend/public/stories/*

# Synchroniser
./scripts/sync-stories.sh

# Vérifier le résultat
ls frontend/public/stories/
find frontend/public/stories -name "*.md" | wc -l
```

**Attendu:**
- 4 dossiers: debug, document-project, quick-flow, workflow-complet
- 45 fichiers .md au total
- Message "[OK] Stories synchronized and manifests updated"

### Test 2.2: Manifests Updated
```bash
# Vérifier que les manifests incluent les nouvelles stories
grep "0-0-0-bmad-setup" frontend/src/services/storyParser.ts
grep "4-3-0-create-stories" frontend/src/services/storyParser.ts

# Vérifier les counts
grep -A 20 "const workflowManifests" frontend/src/services/storyParser.ts
```

**Attendu:**
- 0-0-0-bmad-setup.md présent
- 4-3-0-create-stories.md présent
- workflow-complet a ~18 entrées

### Test 2.3: Freshness Check
```bash
# Vérifier si stories sont à jour
./scripts/check-story-freshness.sh
echo "Exit code: $?"
```

**Attendu:** Exit code 0 (stories à jour après sync)

---

## Phase 3: Build Vibe Kanban

### Test 3.1: Dependencies
```bash
# Vérifier dépendances
command -v pnpm && echo "✓ pnpm" || echo "✗ pnpm missing"
command -v cargo && echo "✓ cargo" || echo "✗ cargo missing"
command -v rustc && echo "✓ rustc" || echo "✗ rustc missing"

# Vérifier versions
pnpm --version
cargo --version
rustc --version
```

**Attendu:** Toutes les commandes présentes

### Test 3.2: Frontend Build (Quick Test)
```bash
# Build frontend seulement
cd frontend
pnpm install  # Si pas déjà fait
pnpm run build

# Vérifier output
ls -la dist/
ls -la dist/stories/
```

**Attendu:**
- dist/ créé
- dist/stories/ contient les 4 workflows
- dist/index.html existe

### Test 3.3: Stories dans le Build
```bash
# Vérifier que les stories sont dans le dist
cd frontend
find dist/stories -name "*.md" | wc -l
ls dist/stories/workflow-complet/ | wc -l
```

**Attendu:**
- 45 fichiers .md
- workflow-complet a 18 fichiers

---

## Phase 4: Build Complet (OPTIONNEL - Long)

⚠️ **Attention:** Le build complet prend 5-10 minutes

### Test 4.1: Full Vibe Kanban Build
```bash
# Retour à la racine
cd ~/Dev/agents/vibe-kanban

# Build complet (frontend + backend + binary)
./scripts/build-vibe-kanban.sh
```

**Attendu:**
- Frontend build successful
- Cargo build successful
- Binary créé dans npx-cli/dist/

### Test 4.2: Vérifier Binary
```bash
# Vérifier le binary
ls -lh npx-cli/dist/macos-arm64/vibe-kanban.zip
# ou pour Linux:
# ls -lh npx-cli/dist/linux-x64/vibe-kanban.zip

# Vérifier la date
stat -f "%Sm" npx-cli/dist/macos-arm64/vibe-kanban.zip
```

**Attendu:**
- Binary existe
- Taille raisonnable (20-50 MB)
- Date récente (aujourd'hui)

---

## Phase 5: Build Installer (OPTIONNEL - Très Long)

⚠️ **Attention:** Nécessite que Phase 4 soit complète

### Test 5.1: Build Installer
```bash
# Build installer
./scripts/build-installer.sh

# Vérifier output
ls -lh dist/install-bmad-vibe-kanban.sh
stat -f "%z" dist/install-bmad-vibe-kanban.sh
```

**Attendu:**
- Installer créé dans dist/
- Taille: 50-100 MB
- Exécutable

### Test 5.2: Test Installer (Extraction Only)
```bash
# Test extraction dans /tmp
mkdir -p /tmp/test-install-$$
cd /tmp/test-install-$$

# Extraire seulement
~/Dev/agents/vibe-kanban/dist/install-bmad-vibe-kanban.sh --help
~/Dev/agents/vibe-kanban/dist/install-bmad-vibe-kanban.sh --extract-only

# Vérifier structure extraite
ls -la
```

**Attendu:**
- _bmad/ extrait
- stories/ extrait
- scripts/ extrait
- .claude/ extrait
- Structure BMAD native présente

---

## Phase 6: Tests Automatisés

### Test 6.1: BATS Tests
```bash
cd ~/Dev/agents/vibe-kanban

# Si bats installé
bats test-tools/post-migration/01-structure.bats
```

**Attendu:** 12/12 tests passent

---

## Quick Validation (Minimum)

Si vous manquez de temps, exécutez au minimum:

```bash
cd ~/Dev/agents/vibe-kanban

# 1. Structure
ls bmad-templates/ scripts/ | grep -E "stories|sync"

# 2. Sync stories
./scripts/sync-stories.sh

# 3. Vérifier frontend a les stories
ls frontend/public/stories/workflow-complet/ | wc -l

# 4. Test structure
bats test-tools/post-migration/01-structure.bats || echo "BATS not installed"
```

**Si ces 4 étapes passent, la migration est OK!**

---

## Commandes Claude Code Suggérées

Quand vous relancez Claude Code dans vibe-kanban:

```
# Vérification rapide
"Exécute les tests de Phase 1 et Phase 2 du fichier TESTING-CHECKLIST.md"

# Vérification complète
"Exécute toutes les phases du TESTING-CHECKLIST.md et reporte les résultats"

# Build test
"Build le frontend selon Phase 3 du TESTING-CHECKLIST.md"

# Si problème détecté
"Analyse les erreurs et propose des corrections"
```

---

## Checklist Résumé

- [ ] Phase 1: Structure validée
- [ ] Phase 2: Story sync fonctionne
- [ ] Phase 3: Frontend build OK
- [ ] Phase 4: Full build OK (optionnel)
- [ ] Phase 5: Installer OK (optionnel)
- [ ] Phase 6: BATS tests OK

**Minimum requis pour GitHub:** Phase 1 + 2 + 3

**Pour release complète:** Toutes les phases
