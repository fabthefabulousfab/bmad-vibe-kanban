# BMAD Workflow Sync Analyzer

Analyse sémantique des workflows BMAD par rapport aux stories existantes pour identifier les désynchronisations et proposer des corrections.

## Fonctionnement

Cet outil utilise un LLM (Large Language Model) pour :
1. Scanner tous les workflows BMAD dans `bmad-templates/_bmad/*/workflows/`
2. Scanner toutes les stories dans `bmad-templates/stories/`
3. Comparer sémantiquement workflows vs stories
4. Générer un rapport détaillé avec :
   - Stories à supprimer (obsolètes, doublons)
   - Stories à modifier (mises à jour nécessaires)
   - Stories à ajouter (workflows non couverts)
   - Nouveaux scénarios à créer

## Prérequis

### Python 3.8+

Vérifier votre version :
```bash
python3 --version
```

### Environnement virtuel

L'outil nécessite un environnement virtuel Python pour isoler les dépendances :

```bash
cd tools/workflow-sync
python3 -m venv .venv
source .venv/bin/activate  # Sur Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### Configuration API

Créer un fichier `.env` depuis le template :

```bash
cp .env.example .env
```

Éditer `.env` et renseigner :
- `BASE_URL` : URL de l'API LLM (OpenAI, OpenRouter, proxy local, etc.)
- `BASE_KEY` : Clé API
- `BASE_MODEL` : Modèle à utiliser (ex: `gpt-4`, `claude-opus-4`)

**IMPORTANT** : Le fichier `.env` est déjà dans `.gitignore` pour éviter de committer vos clés API.

## Utilisation

**Détection Automatique du Projet** : Le script détecte automatiquement la racine du projet `vibe-kanban` en cherchant les marqueurs `bmad-templates/` et `frontend/`. Vous pouvez l'exécuter depuis n'importe quel sous-répertoire du projet. Les rapports seront toujours générés dans `vibe-kanban/_bmad-output/planning-artifacts/`.

### Mode Dry-Run (Recommandé pour débuter)

Prévisualise l'analyse sans appeler le LLM (utilise le cache ou données mock) :

```bash
# Depuis n'importe où dans vibe-kanban (racine ou sous-répertoire)
cd /path/to/vibe-kanban
source tools/workflow-sync/.venv/bin/activate
python3 tools/workflow-sync/analyze-workflow-sync.py --dry-run

# Le script affichera : [INFO] Detected project root: /path/to/vibe-kanban
```

### Analyse Complète

Analyse tous les scénarios (coût ~$0.54 avec Claude Opus 4) :

```bash
cd /path/to/vibe-kanban
source tools/workflow-sync/.venv/bin/activate
python3 tools/workflow-sync/analyze-workflow-sync.py
```

### Analyse d'un Scénario Spécifique

Pour réduire les coûts, analyser un seul scénario :

```bash
python3 tools/workflow-sync/analyze-workflow-sync.py --scenario workflow-complet
```

Scénarios disponibles :
- `workflow-complet` : Cycle complet de développement
- `quick-flow` : Ajouts atomiques rapides
- `document-project` : Documentation de projet brownfield

### Mode Verbeux

Pour déboguer ou voir les détails (prompts, tokens, opérations) :

```bash
python3 tools/workflow-sync/analyze-workflow-sync.py --verbose
```

## Sorties

### Rapport Généré

Le rapport est sauvegardé dans :
```
_bmad-output/planning-artifacts/workflow-sync-report-YYYY-MM-DD-HHMM.md
```

Structure du rapport :
- **Métadonnées** : date, commit git, statistiques
- **Sommaire** : nombre d'actions par type
- **Par scénario** :
  - Stories à supprimer (avec raisons)
  - Stories à modifier (avec diffs)
  - Stories à ajouter (avec résumés)
- **Nouveaux scénarios** : propositions de scénarios manquants

### Cache

Les résultats sont mis en cache dans :
```
_bmad-output/.cache/workflow-sync/
```

Le cache utilise des checksums SHA256 des workflows et stories. Si rien n'a changé, l'analyse réutilise le cache (gratuit, instantané).

Pour forcer une nouvelle analyse, supprimer le cache :
```bash
rm -rf _bmad-output/.cache/workflow-sync/
```

## Coûts Estimés

Avec Claude Opus 4.5 ($15/1M tokens in, $75/1M tokens out) :

| Analyse | Tokens | Coût approx. |
|---------|--------|--------------|
| 1 scénario | ~15K | $0.18 |
| 3 scénarios | ~45K | $0.54 |
| Nouveau scénario | ~10K | $0.12 |

**Conseil** : Toujours commencer par `--dry-run` pour valider avant de dépenser.

## Workflow Recommandé

1. **Dry-run initial** :
   ```bash
   python3 tools/workflow-sync/analyze-workflow-sync.py --dry-run
   ```
   → Vérifie que l'outil fonctionne, utilise cache si disponible

2. **Analyse réelle** :
   ```bash
   python3 tools/workflow-sync/analyze-workflow-sync.py
   ```
   → Génère rapport avec LLM (~$0.54)

3. **Révision du rapport** :
   ```bash
   open _bmad-output/planning-artifacts/workflow-sync-report-*.md
   ```
   → Lire les propositions de l'outil

4. **Application des changements** :
   - Supprimer les stories obsolètes
   - Modifier les stories avec les diffs proposés
   - Créer les nouvelles stories

5. **Nouvelle analyse** :
   ```bash
   python3 tools/workflow-sync/analyze-workflow-sync.py --dry-run
   ```
   → Vérifier que cache invalide (checksums changés)
   → Réanalyser pour confirmer sync

## Sécurité

### Protection des Clés API

- ✅ `.env` est dans `.gitignore`
- ✅ Script vérifie que `.env` est bien exclu de git
- ✅ Clés masquées dans les logs (sk-****...****)
- ⚠️ Sur Unix, script avertit si `.env` est world-readable
- 💡 Recommandation : `chmod 600 .env`

### Validation des Chemins

- ✅ Tous les chemins validés (prévention directory traversal)
- ✅ Vérification que fichiers référencés existent
- ✅ Validation schéma JSON des réponses LLM

## Dépannage

### Erreur "Missing required dependency"

```bash
pip install -r tools/workflow-sync/requirements.txt
```

### Erreur ".env file not found"

```bash
cp tools/workflow-sync/.env.example tools/workflow-sync/.env
# Éditer .env avec vos clés API
```

### Erreur "SECURITY: .env file is NOT in .gitignore"

Ajouter `.env` au `.gitignore` :
```bash
echo "tools/workflow-sync/.env" >> .gitignore
```

### Erreur LLM "Authentication failed"

Vérifier dans `.env` :
- `BASE_URL` correspond bien à votre provider
- `BASE_KEY` est valide et actif
- `BASE_MODEL` est supporté par le provider

### Cache invalide après modifications

Normal ! Le cache utilise des checksums. Si vous modifiez workflows ou stories, le cache est automatiquement invalidé.

## Développement

### Activer/Désactiver le Cache

Le cache est toujours actif. Pour forcer réanalyse :
```bash
rm -rf _bmad-output/.cache/workflow-sync/
```

### Ajouter un Nouveau Scénario

Modifier `analyze-workflow-sync.py` ligne ~995 :
```python
scenarios = {
    'workflow-complet': stories_base / 'workflow-complet',
    'quick-flow': stories_base / 'quick-flow',
    'document-project': stories_base / 'document-project',
    'new-scenario': stories_base / 'new-scenario'  # ← Ajouter ici
}
```

### Modifier le Prompt

Le prompt LLM se trouve dans la fonction `analyze_scenario()` ligne ~452.

## Structure des Fichiers

```
tools/workflow-sync/
├── analyze-workflow-sync.py  # Script principal
├── requirements.txt           # Dépendances Python
├── .env.example              # Template configuration
├── .env                      # Configuration (git-ignored)
├── .venv/                    # Environnement virtuel (git-ignored)
└── README.md                 # Ce fichier
```

## Licence

Même licence que le projet vibe-kanban (Apache 2.0).

## Support

Questions ou problèmes ? Voir la documentation principale du projet.
