# Outil d'Analyse de Synchronisation Workflow ↔ Story

## Vue d'Ensemble

L'outil **Workflow Sync Analyzer** est un script Python qui analyse sémantiquement les workflows BMAD par rapport aux stories existantes pour identifier les désynchronisations.

## Problème Résolu

Avec l'évolution du framework BMAD, les workflows et stories peuvent se désynchroniser :
- Workflows ajoutés sans stories correspondantes
- Stories obsolètes qui ne correspondent plus aux workflows actuels
- Stories nécessitant des mises à jour suite à l'évolution des workflows

Identifier manuellement ces désynchronisations est :
- ⏰ Chronophage (40+ stories × 20+ workflows)
- 🐛 Source d'erreurs humaines
- 📊 Difficile à documenter

## Solution Apportée

Le script utilise l'intelligence artificielle (LLM) pour :
1. **Scanner** automatiquement tous les workflows et stories
2. **Analyser** sémantiquement le contenu (pas juste les noms de fichiers)
3. **Identifier** les désynchronisations avec précision
4. **Proposer** des actions concrètes (delete/modify/add)
5. **Générer** un rapport markdown détaillé avec diffs

## Fonctionnalités Clés

### ✅ Analyse Sémantique

- Utilise GPT-4, Claude Opus, ou autre LLM
- Comprend le **sens** des workflows et stories, pas juste les mots-clés
- Détecte les doublons sémantiques
- Identifie les workflows non couverts

### 📦 Cache Intelligent

- Checksums SHA256 des workflows et stories
- Cache invalidé automatiquement si fichiers modifiés
- Économise les coûts LLM (analyses identiques gratuites)
- Stocké dans `_bmad-output/.cache/workflow-sync/`

### 🌐 Conscience Cross-Scenario

- Détecte si une story existe dans plusieurs scénarios
- Avertit avant suppression cross-scenario
- Propose les bons scénarios pour nouvelles stories

### 💰 Modes d'Exécution

| Mode | Coût | Utilisation |
|------|------|-------------|
| `--dry-run` | Gratuit | Validation, utilise cache ou mock |
| Standard | ~$0.18/scenario | Analyse réelle avec LLM |
| Complet (3 scenarios) | ~$0.54 | Analyse complète |

### 📊 Rapports Détaillés

Génère un rapport markdown avec :
- Métadonnées (date, commit git, stats)
- Stories à supprimer (avec raisons)
- Stories à modifier (avec diffs)
- Stories à ajouter (avec résumés)
- Nouveaux scénarios proposés

## Installation

### 1. Prérequis

- Python 3.8 ou supérieur
- Accès à une API LLM (OpenAI, OpenRouter, proxy local)

### 2. Environnement Virtuel

```bash
cd tools/workflow-sync
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Configuration

Créer le fichier `.env` :

```bash
cp .env.example .env
```

Éditer `.env` :

```env
BASE_URL=https://api.openai.com/v1
BASE_KEY=sk-your-api-key-here
BASE_MODEL=gpt-4
```

**Providers supportés :**
- OpenAI : `https://api.openai.com/v1`
- OpenRouter : `https://openrouter.ai/api/v1`
- Proxy local : `http://localhost:8000/v1`

## Utilisation

### Détection Automatique du Projet

Le script détecte automatiquement la racine du projet vibe-kanban :
- Recherche les marqueurs : `bmad-templates/`, `frontend/`, `crates/`
- Fonctionne depuis n'importe quel sous-répertoire du projet
- Génère toujours les rapports dans `vibe-kanban/_bmad-output/planning-artifacts/`

**Message de détection :**
```
[INFO] Detected project root: /path/to/vibe-kanban
[INFO] Detected project root: /path/to/vibe-kanban (from /path/to/vibe-kanban/tools)
```

### Workflow Recommandé

#### 1. Dry-Run Initial (Gratuit)

```bash
# Depuis n'importe où dans le projet vibe-kanban
cd /path/to/vibe-kanban  # ou cd /path/to/vibe-kanban/tools
source tools/workflow-sync/.venv/bin/activate
python3 tools/workflow-sync/analyze-workflow-sync.py --dry-run
```

Vérifie que l'outil fonctionne sans coût LLM.

#### 2. Analyse Réelle

```bash
python3 tools/workflow-sync/analyze-workflow-sync.py
```

Génère un rapport complet (~$0.54 avec Claude Opus).

#### 3. Révision du Rapport

```bash
open _bmad-output/planning-artifacts/workflow-sync-report-*.md
```

Lire attentivement les propositions.

#### 4. Application des Changements

Appliquer manuellement :
- Supprimer stories obsolètes
- Modifier stories avec les diffs fournis
- Créer nouvelles stories

#### 5. Vérification

```bash
python3 tools/workflow-sync/analyze-workflow-sync.py --dry-run
```

Le cache sera invalidé (checksums changés), confirmant les modifications.

### Commandes Utiles

```bash
# Analyser un seul scénario (économie)
python3 tools/workflow-sync/analyze-workflow-sync.py --scenario workflow-complet

# Mode verbeux (voir prompts, tokens)
python3 tools/workflow-sync/analyze-workflow-sync.py --verbose

# Forcer réanalyse (ignorer cache)
rm -rf _bmad-output/.cache/workflow-sync/
python3 tools/workflow-sync/analyze-workflow-sync.py
```

## Exemples de Sorties

### Rapport - Stories à Supprimer

```markdown
### Stories to Delete

- **stories/workflow-complet/6-1-0-deploy-production.md**
  - Reason: Duplicate of 5-1-0-deploy-production.md with identical workflow coverage
  - ⚠️ **Also exists in:** document-project
```

### Rapport - Stories à Modifier

```markdown
#### stories/workflow-complet/4-2-0-import-vibe-kanban.md

**Current Summary:** Imports stories into Vibe Kanban using shell scripts

**Changes Needed:**
- Add acceptance criteria for UI-based import
- Update references from shell scripts to UI workflow

**Diff:**
\`\`\`diff
- Import stories via shell script:
+ Import stories via Vibe Kanban UI:
  1. Open Vibe Kanban
  2. Click '+' button
- 3. Run: ./scripts/import-stories.sh
+ 3. Select workflow and click Execute
\`\`\`
```

### Rapport - Stories à Ajouter

```markdown
#### New Story: 4-3-1-qa-automation.md

**Wave:** 4 | **Epic:** 3 | **Story:** 1
**Target Scenarios:** workflow-complet
**Summary:** Integrate QA automation workflows into story execution lifecycle
```

## Architecture Technique

### Flux d'Exécution

```
1. Chargement Configuration (.env)
   ↓
2. Scan Workflows (BMM + TEA)
   → Extraction frontmatter + checksums
   ↓
3. Pour chaque scénario:
   a. Scan Stories
   b. Calcul cache key (checksums)
   c. Si cache HIT → utilise cache
   d. Sinon → appel LLM → cache result
   ↓
4. Détection Nouveaux Scénarios
   ↓
5. Génération Rapport Markdown
```

### Sécurité

- ✅ `.env` vérifié dans `.gitignore`
- ✅ Clés API masquées dans logs
- ✅ Validation chemins (anti directory traversal)
- ✅ Validation schéma JSON des réponses LLM
- ⚠️ Avertissement si `.env` world-readable

### Cache

**Clé de cache :**
```
SHA256(scenario_name + sorted_checksums_of_all_workflows + sorted_checksums_of_all_stories)
```

**Invalidation :**
- Automatique si un fichier workflow/story change
- Manuel : suppression du répertoire cache

## Dépendances

Installées via `pip install -r requirements.txt` :

```
litellm==1.81.11              # LLM API wrapper
python-dotenv==1.0.1          # .env loading
python-frontmatter==1.1.0     # Markdown frontmatter parsing
pyyaml==6.0.2                 # YAML parsing
google-cloud-aiplatform>=1.38 # Vertex AI support
```

## Limites et Contraintes

### ⚠️ Coûts LLM

- Analyse complète : ~$0.54 (Claude Opus 4.5)
- Toujours utiliser `--dry-run` pour valider avant dépense
- Cache réduit coûts pour analyses répétées

### ⚠️ Qualité des Propositions

- LLM peut faire des erreurs d'interprétation
- **Toujours réviser** les propositions manuellement
- Ne pas appliquer aveuglément les suggestions

### ⚠️ Dépendance Internet

- Nécessite connexion pour API LLM
- Aucune analyse offline (sauf cache)

### ⚠️ Version Python

- Minimum : Python 3.8
- Recommandé : Python 3.10+

## Troubleshooting

### Erreur "Missing required dependency"

```bash
source tools/workflow-sync/.venv/bin/activate
pip install -r tools/workflow-sync/requirements.txt
```

### Erreur ".env file not found"

```bash
cp tools/workflow-sync/.env.example tools/workflow-sync/.env
# Éditer .env avec vos clés
```

### Erreur "Authentication failed"

Vérifier dans `.env` :
- `BASE_URL` : bon endpoint
- `BASE_KEY` : clé valide
- `BASE_MODEL` : modèle supporté par le provider

### Analyse trop longue

- Utiliser `--scenario` pour analyser un seul scénario
- Vérifier connexion internet
- Augmenter timeout si nécessaire

### Résultats incohérents

1. Vider le cache : `rm -rf _bmad-output/.cache/workflow-sync/`
2. Réanalyser : `python3 tools/workflow-sync/analyze-workflow-sync.py`
3. Si problème persiste : mode `--verbose` pour voir prompts

## Évolutions Futures

### Prévues

- [ ] Cleanup automatique du cache (>30 jours)
- [ ] Support nouveaux providers LLM
- [ ] Export rapports en JSON/YAML
- [ ] Mode interactif pour appliquer changements

### Possibles

- [ ] Détection automatique de nouveaux workflows
- [ ] Intégration CI/CD pour validation automatique
- [ ] Rapport HTML avec navigation
- [ ] API REST pour intégration externe

## Contribution

Pour améliorer l'outil :

1. Tester avec différents LLM providers
2. Améliorer les prompts (ligne ~452 dans analyze-workflow-sync.py)
3. Ajouter validation supplémentaires
4. Documenter edge cases

## Ressources

- **Documentation complète** : `tools/workflow-sync/README.md`
- **Code source** : `tools/workflow-sync/analyze-workflow-sync.py`
- **Rapports générés** : `_bmad-output/planning-artifacts/`
- **Cache** : `_bmad-output/.cache/workflow-sync/`

## Licence

Même licence que vibe-kanban (Apache 2.0).
