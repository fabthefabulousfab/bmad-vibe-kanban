# Modifications Fork - vibe-kanban

Ce document liste les modifications apportées à ce fork de vibe-kanban par rapport à la version originale.

## Version de base

- **Version:** 0.1.4
- **Tag Git:** `v0.1.4-20260205093507`
- **Branche fork:** `fix/move-to-old-ui`

---

## Modification 1: Bouton "Open in Old UI"

### Description

Le bouton "Open in Old UI" dans la navbar du nouveau design (workspaces) permet de naviguer vers l'ancienne interface utilisateur pour voir le projet associé au workspace courant.

### Problème initial

Le bouton utilisait `ctx.navigate()` de React Router, qui ne fonctionnait pas correctement pour la navigation entre le nouveau design (`/workspaces/*`) et l'ancien design (`/local-projects/*`). De plus, la navigation vers une URL d'attempt spécifique (`/local-projects/{project_id}/tasks/{task_id}/attempts/{attempt_id}`) déclenchait une redirection automatique vers la nouvelle UI quand `beta_workspaces` est activé.

### Solution appliquée

1. **Utilisation de `window.location.href`** au lieu de `ctx.navigate()` pour forcer un rechargement complet de la page lors de la navigation entre les deux designs (scopes React différents).

2. **Navigation vers la page des tâches du projet** (`/local-projects/{project_id}/tasks`) au lieu d'un attempt spécifique, ce qui évite la redirection automatique et affiche toutes les stories du projet.

### Fichier modifié

**`frontend/src/components/ui-new/actions/index.ts`**

#### Code original (lignes ~788-815):

```typescript
OpenInOldUI: {
  id: 'open-in-old-ui',
  label: 'Open in Old UI',
  icon: SignOutIcon,
  requiresTarget: ActionTargetType.NONE,
  isVisible: (ctx) => ctx.layoutMode === 'workspaces',
  execute: async (ctx) => {
    // If no workspace is selected, navigate to root
    if (!ctx.currentWorkspaceId) {
      ctx.navigate('/');
      return;
    }

    const workspace = await getWorkspace(
      ctx.queryClient,
      ctx.currentWorkspaceId
    );
    if (!workspace?.task_id) {
      ctx.navigate('/');
      return;
    }

    // Fetch task lazily to get project_id
    const task = await tasksApi.getById(workspace.task_id);
    if (task?.project_id) {
      ctx.navigate(
        `/local-projects/${task.project_id}/tasks/${workspace.task_id}/attempts/${ctx.currentWorkspaceId}`
      );
    } else {
      ctx.navigate('/');
    }
  },
},
```

#### Code modifié:

```typescript
OpenInOldUI: {
  id: 'open-in-old-ui',
  label: 'Open in Old UI',
  icon: SignOutIcon,
  requiresTarget: ActionTargetType.NONE,
  isVisible: (ctx) => ctx.layoutMode === 'workspaces',
  execute: async (ctx) => {
    // If no workspace is selected, navigate to root (legacy design)
    if (!ctx.currentWorkspaceId) {
      // Use window.location for cross-design navigation (new design -> legacy design)
      window.location.href = '/';
      return;
    }

    const workspace = await getWorkspace(
      ctx.queryClient,
      ctx.currentWorkspaceId
    );
    if (!workspace?.task_id) {
      window.location.href = '/';
      return;
    }

    // Fetch task to get project_id
    const task = await tasksApi.getById(workspace.task_id);
    if (task?.project_id) {
      // Navigate to the project tasks page (shows all stories)
      // Use window.location for cross-design navigation (new design -> legacy design)
      window.location.href = `/local-projects/${task.project_id}/tasks`;
    } else {
      window.location.href = '/';
    }
  },
},
```

### Diff

```diff
-      ctx.navigate('/');
+      window.location.href = '/';

-      ctx.navigate(
-        `/local-projects/${task.project_id}/tasks/${workspace.task_id}/attempts/${ctx.currentWorkspaceId}`
-      );
+      window.location.href = `/local-projects/${task.project_id}/tasks`;
```

### Script de patch

Un script est fourni pour appliquer automatiquement cette modification:

```bash
./scripts/patch-open-in-old-ui.sh
```

Le script:
- Vérifie si le fichier cible existe
- Vérifie si le patch a déjà été appliqué
- Crée une sauvegarde du fichier original
- Applique les modifications
- Vérifie que le patch a été correctement appliqué

---

## Notes techniques

### Pourquoi `window.location.href` au lieu de `ctx.navigate()`?

React Router utilise la navigation côté client (SPA). Cependant, quand on navigue entre deux "scopes" de design différents (`LegacyDesignScope` vs nouveau design), les composants de layout sont complètement différents. `window.location.href` force un rechargement complet de la page, ce qui:

1. Réinitialise correctement le contexte React
2. Charge le bon layout (ancien vs nouveau)
3. Évite les problèmes de state React incohérent

### Pourquoi `/tasks` au lieu de `/tasks/{task_id}/attempts/{attempt_id}`?

Quand `beta_workspaces` est activé dans la configuration, le composant `ProjectTasks.tsx` contient un `useEffect` qui redirige automatiquement les URLs d'attempt vers la nouvelle UI:

```typescript
// frontend/src/pages/ProjectTasks.tsx (lignes 247-254)
useEffect(() => {
  if (!isLoaded) return;
  if (!config?.beta_workspaces) return;
  if (!attemptId || attemptId === 'latest') return;

  navigate(`/workspaces/${attemptId}`, { replace: true });
}, [isLoaded, config?.beta_workspaces, attemptId, navigate]);
```

En naviguant vers `/local-projects/{project_id}/tasks` (sans `attemptId`), cette redirection n'est pas déclenchée.

---

---

## Construction (Build)

### macOS (Apple Silicon / Intel)

```bash
# Construire le frontend et le backend
pnpm install
pnpm run build:npx

# Les binaires sont dans npx-cli/dist/macos-arm64/ (ou macos-x64/)
```

### Linux (Ubuntu x86_64)

**Option 1: Build sur une machine Linux native** (recommandé)

```bash
# Sur une machine Ubuntu x86_64
pnpm install
pnpm run build:npx
# Les binaires sont dans npx-cli/dist/linux-x64/
```

**Option 2: Build via Docker** (requiert Docker Desktop avec support QEMU)

```bash
# Depuis macOS avec Docker Desktop
./scripts/build-linux.sh
```

> ⚠️ Note: La compilation via Docker/QEMU sur Apple Silicon peut être instable
> en raison de l'émulation x86_64. Il est recommandé d'utiliser un serveur CI
> (GitHub Actions) ou une VM Linux pour les builds de production.

### Fichiers produits

```
npx-cli/dist/
├── macos-arm64/
│   ├── vibe-kanban.zip       # Serveur principal
│   ├── vibe-kanban-mcp.zip   # Serveur MCP
│   └── vibe-kanban-review.zip # Outil de review
└── linux-x64/
    ├── vibe-kanban.zip
    ├── vibe-kanban-mcp.zip
    └── vibe-kanban-review.zip
```

### Lancement

```bash
# Extraire et lancer
unzip vibe-kanban.zip
./vibe-kanban

# L'application sera accessible sur http://localhost:3000
# Voir la documentation officielle pour la configuration
```

---

## Historique des modifications

| Date | Version | Description |
|------|---------|-------------|
| 2026-02-12 | 0.1.4-fork | Correction du bouton "Open in Old UI" |
