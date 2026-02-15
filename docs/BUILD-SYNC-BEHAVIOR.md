# Comportement de Synchronisation des Scripts de Build

## Vue d'Ensemble

Les scripts de build de vibe-kanban détectent **automatiquement** toutes les modifications, créations et suppressions de fichiers dans `bmad-templates/stories/`.

## Synchronisation Automatique

### Script : `build-vibe-kanban.sh`

```bash
rsync -a --delete \
  "$PROJECT_ROOT/bmad-templates/stories/" \
  "$PROJECT_ROOT/frontend/public/stories/"
```

### Options rsync

| Option | Comportement |
|--------|--------------|
| `-a` | Archive mode (préserve permissions, timestamps, récursif) |
| `--delete` | **Supprime les fichiers de destination qui n'existent plus dans la source** |

### Détection Automatique

✅ **Modifications** :
- Fichiers modifiés dans `bmad-templates/stories/` → copiés vers `frontend/public/stories/`
- Timestamps mis à jour
- Contenu synchronisé

✅ **Créations** :
- Nouveaux fichiers `.md` dans `bmad-templates/stories/` → copiés automatiquement
- Ajoutés au manifeste dans `storyParser.ts`

✅ **Suppressions** :
- Fichiers supprimés de `bmad-templates/stories/` → **supprimés automatiquement** de `frontend/public/stories/`
- Retirés du manifeste dans `storyParser.ts`

## Génération du Manifeste

### Code (lignes 36-75)

```bash
generate_manifest() {
  local workflow_dir="$1"
  local workflow_key="$2"

  # Liste tous les fichiers .md SAUF ceux qui commencent par X- (templates)
  files=$(cd "$PROJECT_ROOT/frontend/public/stories/$workflow_dir" && ls *.md 2>/dev/null | grep -v '^X-' | sort || true)

  if [ -z "$files" ]; then
    return
  fi

  echo "    '$workflow_key': ["
  for file in $files; do
    echo "      '$file',"
  done
  echo "    ],"
}
```

### Comportement

1. **Scanne** le répertoire `frontend/public/stories/{workflow}/`
2. **Filtre** les fichiers template (X-*.md)
3. **Liste** tous les `.md` restants
4. **Génère** le manifeste TypeScript

### Mise à Jour Automatique

Le manifeste dans `frontend/src/services/storyParser.ts` est **remplacé** à chaque build :

```typescript
const workflowManifests: Record<string, string[]> = {
    'quick-flow': [
      '1-1-0-quick-spec.md',
      '1-2-1-dev.md',
      '1-3-0-quick-commit.md',
      '1-4-0-quick-pr.md',
    ],
    'workflow-complet': [
      '0-0-0-bmad-setup.md',
      '1-1-0-brainstorm.md',
      // ... tous les fichiers détectés
    ],
  };
```

## Workflow Complet

### 1. Vous Modifiez les Stories

```bash
# Exemple : vous avez modifié 2-1-0-prd.md
vim bmad-templates/stories/workflow-complet/2-1-0-prd.md

# Et ajouté 1-1-3-advanced-elicitation.md
vim bmad-templates/stories/workflow-complet/1-1-3-advanced-elicitation.md

# Et supprimé 6-1-0-deploy-old.md (exemple)
rm bmad-templates/stories/workflow-complet/6-1-0-deploy-old.md
```

### 2. Build

```bash
./build-vibe-kanban.sh
```

### 3. Ce qui se passe automatiquement

**Étape 1/3 - Synchronisation** :
```
[1/3] Syncing BMAD stories from bmad-templates...
      Source: bmad-templates/stories/
      Target: frontend/public/stories/

      ✓ 40 stories synced  # Nouveau total après vos changements
      ✓ Story manifests updated in storyParser.ts
```

**Actions automatiques** :
- ✅ `2-1-0-prd.md` → copié avec nouveaux contenus
- ✅ `1-1-3-advanced-elicitation.md` → créé dans frontend/public/
- ✅ `6-1-0-deploy-old.md` → **supprimé** de frontend/public/
- ✅ Manifeste mis à jour avec la nouvelle liste

**Étape 2/3 - Build Frontend** :
```
[2/3] Building frontend...
      ✓ Frontend built: frontend/dist/
```

**Actions** :
- Frontend compile avec les stories synchronisées
- RustEmbed va embarquer `frontend/dist/` dans le binaire

**Étape 3/3 - Build Backend** :
```
[3/3] Building Rust backend...
      ✓ Backend built: target/release/server
```

**Actions** :
- Binaire Rust créé avec frontend embarqué
- **Toutes vos modifications** sont dans le binaire

### 4. Test

```bash
./target/release/server
# Ouvrir http://127.0.0.1:3001
# Cliquer '+' → Select Workflow
# → Vous verrez vos modifications !
```

## Cas Particuliers

### Templates (X-*.md)

Les fichiers commençant par `X-` sont **copiés mais exclus du manifeste** :

```bash
files=$(... | grep -v '^X-' | ...)
```

**Raison** : Ce sont des templates, pas des stories exécutables.

**Fichiers template** :
- `X-X-X-start-epic-template.md`
- `X-X-X-fin-epic-template.md`

### Fichiers Cachés (.*)

Les fichiers cachés sont **ignorés** par `ls *.md` :

- `.gitkeep` → ignoré
- `.DS_Store` → ignoré

### Sous-Répertoires

`rsync -a` est **récursif** :

```
bmad-templates/stories/
├── workflow-complet/
│   ├── 1-1-0-brainstorm.md      → copié
│   └── subfolder/
│       └── test.md               → copié aussi
```

**Note** : Actuellement pas de sous-répertoires dans stories/, mais supporté.

## Vérification

### Avant Build

```bash
# Combien de stories dans bmad-templates ?
find bmad-templates/stories -name "*.md" | wc -l
```

### Après Build

```bash
# Combien de stories dans frontend/public ?
find frontend/public/stories -name "*.md" | wc -l

# Doivent être IDENTIQUES
```

### Différences

```bash
# Voir les différences entre source et destination
rsync -a --delete --dry-run -v \
  bmad-templates/stories/ \
  frontend/public/stories/

# --dry-run : simule sans modifier
# -v : verbeux, montre ce qui serait fait
```

## Rebuild Après Modifications

### Rebuild Complet

```bash
./build-vibe-kanban.sh  # Synchronise + Build tout
./build-installer.sh    # Crée l'installer avec les nouvelles stories
```

### Rebuild Frontend Seulement

```bash
# Si vous avez seulement modifié des stories (pas de code Rust)
rsync -a --delete bmad-templates/stories/ frontend/public/stories/
cd frontend && npm run build
# Puis rebuild Rust pour embarquer
cargo build --release
```

## Cache et Invalidation

### Cache du Workflow Sync Tool

Le script d'analyse de synchronisation utilise des **checksums SHA256** :

```bash
# Si vous modifiez une story, le cache est invalidé
python3 tools/workflow-sync/analyze-workflow-sync.py --dry-run
# → Cache MISS (fichier modifié)
```

### Build Cache Rust

Rust détecte automatiquement les changements dans `frontend/dist/` grâce à RustEmbed :

```rust
#[derive(RustEmbed)]
#[folder = "frontend/dist"]
struct Asset;
```

Si `frontend/dist/` change → Rust rebuild automatiquement.

## Problèmes Courants

### ❌ Stories pas mises à jour dans le binaire

**Cause** : Frontend pas rebuildi

**Solution** :
```bash
./build-vibe-kanban.sh  # Rebuild complet
```

### ❌ Ancienne story encore visible

**Cause** : Story supprimée de `bmad-templates/` mais binaire pas rebuildi

**Solution** :
```bash
./build-vibe-kanban.sh  # rsync --delete va la supprimer
```

### ❌ Nouvelle story pas visible

**Cause** : Fichier créé mais pas buildi

**Solution** :
```bash
./build-vibe-kanban.sh  # rsync va la copier
```

### ❌ Manifeste désynchronisé

**Symptôme** : Story existe dans fichier mais pas dans UI

**Cause** : `storyParser.ts` pas mis à jour

**Solution** :
```bash
./build-vibe-kanban.sh  # Régénère le manifeste
```

## Résumé

| Action | Détection | Script Responsable |
|--------|-----------|-------------------|
| **Modifier** story | ✅ Automatique | rsync (timestamp) |
| **Créer** story | ✅ Automatique | rsync + generate_manifest |
| **Supprimer** story | ✅ Automatique | rsync --delete |
| **Mettre à jour** manifeste | ✅ Automatique | generate_manifest |
| **Embarquer** dans binaire | ✅ Automatique | cargo build (RustEmbed) |

**Conclusion** : Vous n'avez qu'à modifier les fichiers dans `bmad-templates/stories/` et lancer `./build-vibe-kanban.sh`. Tout le reste est automatique ! ✅
