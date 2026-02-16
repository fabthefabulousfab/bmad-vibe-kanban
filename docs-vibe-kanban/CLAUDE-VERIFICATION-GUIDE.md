# Guide de Vérification pour Claude Code

Quand vous relancez Claude Code dans `~/Dev/agents/vibe-kanban`, utilisez ces commandes pour valider la migration.

## Commandes Rapides à Donner à Claude

### Vérification Rapide (2 minutes)
```
Exécute le script quick-check pour valider la migration:
./scripts/quick-check.sh

Puis montre-moi le résultat et confirme que tout est OK.
```

### Vérification Complète des Stories (5 minutes)
```
Exécute les phases 1 et 2 du fichier TESTING-CHECKLIST.md:
1. Vérifie la structure
2. Teste le sync des stories
3. Compte les stories par workflow

Reporte tous les résultats.
```

### Test du Build Frontend (15 minutes)
```
Exécute la Phase 3 du TESTING-CHECKLIST.md:
1. Vérifie les dépendances (pnpm, cargo)
2. Build le frontend
3. Vérifie que les stories sont dans dist/

Reporte les résultats et toute erreur.
```

### Validation Complète (Si tu as le temps - 30+ minutes)
```
Exécute toutes les phases du TESTING-CHECKLIST.md de 1 à 6 et crée un rapport de validation complet avec:
- Résultats de chaque test
- Erreurs rencontrées
- Recommandations

Sauvegarde le rapport dans _bmad-output/migration-validation-report.md
```

## Tests Spécifiques

### Vérifier les Stories
```
Vérifie que toutes les stories BMAD sont présentes:
1. Liste les stories dans bmad-templates/stories/
2. Compare avec frontend/public/stories/
3. Vérifie que les manifests dans storyParser.ts sont corrects
4. Confirme les counts: workflow-complet=18, quick-flow=4, document-project=10, debug=7
```

### Vérifier la Configuration
```
Vérifie la configuration du projet:
1. Lis README.md et confirme qu'il mentionne le fork
2. Lis FORK.md et vérifie les infos upstream
3. Vérifie que .gitignore inclut _bmad-output/ et dist/
4. Confirme que tous les scripts dans scripts/ sont exécutables
```

### Tester le Sync
```
Teste le sync des stories:
1. Supprime frontend/public/stories/*
2. Exécute ./scripts/sync-stories.sh
3. Vérifie que 45 fichiers ont été copiés
4. Confirme que les manifests ont été mis à jour
5. Vérifie que les counts sont corrects
```

## Prompts de Debugging

### Si Erreur de Sync
```
Il y a une erreur dans le sync des stories.
1. Lis le script scripts/sync-stories.sh
2. Exécute-le avec set -x pour voir le détail
3. Identifie l'erreur
4. Propose une correction
```

### Si Erreur de Build
```
Le build échoue.
1. Lis les logs d'erreur
2. Identifie la cause
3. Vérifie les dépendances (pnpm list, cargo check)
4. Propose une solution
```

### Si Manifests Incorrects
```
Les manifests dans storyParser.ts sont incorrects.
1. Compare les fichiers dans bmad-templates/stories/ avec le manifest
2. Identifie les différences
3. Régénère le manifest avec sync-stories.sh
4. Vérifie que c'est corrigé
```

## Workflow de Vérification Recommandé

### Étape 1: Quick Check (OBLIGATOIRE)
```bash
./scripts/quick-check.sh
```
**Temps:** 5 secondes
**Valide:** Structure, scripts, stories de base

### Étape 2: Test Sync (OBLIGATOIRE)
```bash
./scripts/sync-stories.sh
```
**Temps:** 10 secondes
**Valide:** Sync fonctionne, manifests updated

### Étape 3: Frontend Build (RECOMMANDÉ)
```bash
cd frontend && pnpm run build
```
**Temps:** 2-5 minutes
**Valide:** Stories dans le build, frontend compile

### Étape 4: Full Build (OPTIONNEL)
```bash
./scripts/build-vibe-kanban.sh
```
**Temps:** 5-10 minutes
**Valide:** Backend compile, binary créé

### Étape 5: Installer Build (OPTIONNEL)
```bash
./scripts/build-installer.sh
```
**Temps:** 5-10 minutes
**Valide:** Installer se génère correctement

## Critères de Validation

### Pour GitHub Push
Minimum requis:
- ✅ quick-check.sh passe
- ✅ sync-stories.sh fonctionne
- ✅ Frontend build réussit
- ✅ Stories présentes dans frontend/dist/

### Pour Release
En plus du minimum:
- ✅ Full build réussit
- ✅ Binary créé
- ✅ Installer se génère
- ✅ Test extraction de l'installer

## Commandes de Cleanup

Si vous devez nettoyer et recommencer:

```bash
# Nettoyer les builds
rm -rf frontend/dist
rm -rf frontend/node_modules/.vite
rm -rf target/

# Resync stories
./scripts/sync-stories.sh

# Rebuild
cd frontend && pnpm run build
```

## Aide-Mémoire Git

```bash
# Voir le commit de migration
git log --oneline -1

# Voir les fichiers modifiés
git show --stat

# Voir la diff d'un fichier spécifique
git show HEAD:frontend/src/services/storyParser.ts | head -50
```

## Que Faire en Cas de Problème

1. **Exécuter quick-check:**
   ```bash
   ./scripts/quick-check.sh
   ```

2. **Si quick-check échoue:**
   - Lire le message d'erreur
   - Vérifier la structure avec `ls -la bmad-templates/ scripts/`
   - Relancer le sync: `./scripts/sync-stories.sh`

3. **Si le build échoue:**
   - Vérifier les dépendances: `pnpm --version`, `cargo --version`
   - Nettoyer et rebuilder: `rm -rf frontend/dist && cd frontend && pnpm run build`

4. **Si les tests BATS échouent:**
   - Lire le test qui échoue
   - Vérifier manuellement la condition
   - Corriger ou mettre à jour le test

## Validation Finale Avant GitHub

Avant de pusher sur GitHub, exécuter:

```bash
# 1. Quick check
./scripts/quick-check.sh

# 2. Verify git status
git status

# 3. Verify commit
git log -1 --stat

# 4. Run tests
bats test-tools/post-migration/01-structure.bats

# Si tout passe ✅ → Prêt pour GitHub!
```
