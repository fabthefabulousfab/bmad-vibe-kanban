#!/bin/bash
# =============================================================================
# BMAD Stories -> Vibe Kanban Import Script (Format Anglais)
# =============================================================================
#
# Ce script importe les stories BMAD (format anglais) vers Vibe Kanban via l'API REST.
#
# PREREQUIS:
#   1. Vibe Kanban doit etre lance (pnpm run dev)
#   2. Un projet doit etre ouvert dans Vibe Kanban
#   3. jq doit etre installe (brew install jq)
#
# USAGE:
#   ./scripts/import-stories-to-vibe-kanban.sh [OPTIONS]
#
# OPTIONS:
#   --project-id ID     Specifier l'ID du projet cible (sinon: projet actif)
#   --stories-dir DIR   Repertoire des stories (defaut: _bmad-output/epics-stories-tasks/stories)
#   --dry-run           Simuler sans creer les taches
#   --port PORT         Port du backend (defaut: 3001)
#   --dev-only          Importer uniquement les stories de dev (waves entieres)
#   --help              Afficher cette aide
#
# FORMAT DES STORIES:
#   Fichiers: {Wave}-{Epic}-{Story}.md (ex: 0-1-1.md, 1-1-2.md)
#   Structure attendue:
#     # Story X-Y/Z: Titre
#     **Wave:** X | **Epic:** Y | **Story:** Z
#     **Status:** Ready for Development
#     ## User Story
#     **As a** ...
#     **I want** ...
#     **So that** ...
#
# =============================================================================

set -e

# Configuration par defaut
BACKEND_PORT="${BACKEND_PORT:-3001}"
API_BASE="http://127.0.0.1:${BACKEND_PORT}/api"
STORIES_DIR="${STORIES_DIR:-_bmad-output/epics-stories-tasks/stories}"
DRY_RUN=false
DEV_ONLY=false
PROJECT_ID=""

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# =============================================================================
# FONCTIONS UTILITAIRES
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_wave() {
    echo -e "${MAGENTA}[WAVE]${NC} $1"
}

show_help() {
    head -40 "$0" | tail -35
    exit 0
}

# =============================================================================
# PARSING DES ARGUMENTS
# =============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --project-id)
            PROJECT_ID="$2"
            shift 2
            ;;
        --stories-dir)
            STORIES_DIR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --dev-only)
            DEV_ONLY=true
            shift
            ;;
        --port)
            BACKEND_PORT="$2"
            API_BASE="http://127.0.0.1:${BACKEND_PORT}/api"
            shift 2
            ;;
        --help)
            show_help
            ;;
        *)
            log_error "Option inconnue: $1"
            show_help
            ;;
    esac
done

# =============================================================================
# VERIFICATION DES PREREQUIS
# =============================================================================

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN} BMAD Stories -> Vibe Kanban Import${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# Verifier jq
if ! command -v jq &> /dev/null; then
    log_error "jq n'est pas installe. Installer avec: brew install jq"
    exit 1
fi

# Verifier le backend Vibe Kanban
log_info "Verification du backend Vibe Kanban (port ${BACKEND_PORT})..."
if ! curl -s "${API_BASE}/health" > /dev/null 2>&1; then
    log_error "Le backend Vibe Kanban n'est pas accessible."
    echo ""
    echo "  Solutions:"
    echo "  1. Demarrer Vibe Kanban: cd ../vibe-kanban && pnpm run dev"
    echo "  2. Verifier le port: --port XXXX"
    echo ""
    exit 1
fi
log_success "Backend Vibe Kanban actif"

# Verifier le repertoire des stories
if [ ! -d "$STORIES_DIR" ]; then
    log_error "Repertoire des stories non trouve: $STORIES_DIR"
    exit 1
fi

# Compter les stories (format X-Y-Z.md ou X.Y-Z-N.md)
if [ "$DEV_ONLY" = true ]; then
    # Waves entieres uniquement (pas de decimales comme 0.2, 1.2, etc.)
    STORY_FILES=$(find "$STORIES_DIR" -name "*.md" 2>/dev/null | grep -E '/[0-9]+-[0-9]+-[0-9]+\.md$' | sort -t'-' -k1,1n -k2,2n -k3,3n)
else
    STORY_FILES=$(find "$STORIES_DIR" -name "*.md" 2>/dev/null | sort)
fi

STORY_COUNT=$(echo "$STORY_FILES" | grep -c '\.md$' || echo "0")
if [ "$STORY_COUNT" -eq 0 ]; then
    log_warning "Aucune story trouvee dans $STORIES_DIR"
    echo "  Format attendu: X-Y-Z.md (ex: 0-1-1.md, 1-1-2.md)"
    exit 0
fi
log_info "Stories trouvees: $STORY_COUNT"
if [ "$DEV_ONLY" = true ]; then
    log_info "Mode: Dev stories uniquement (waves entieres)"
fi

# =============================================================================
# RECUPERER OU CREER LE PROJET
# =============================================================================

if [ -z "$PROJECT_ID" ]; then
    log_info "Recuperation des projets disponibles..."

    PROJECTS_RESPONSE=$(curl -s "${API_BASE}/projects")
    PROJECT_COUNT=$(echo "$PROJECTS_RESPONSE" | jq -r '.data | length')

    if [ "$PROJECT_COUNT" -eq 0 ]; then
        log_warning "Aucun projet trouve. Creation d'un nouveau projet..."

        PROJECT_NAME="BMAD Studio - $(basename "$(pwd)")"
        PROJECT_PATH="$(pwd)"

        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Creer projet: $PROJECT_NAME"
            PROJECT_ID="dry-run-project-id"
        else
            PROJECT_RESPONSE=$(curl -s -X POST "${API_BASE}/projects" \
                -H "Content-Type: application/json" \
                -d "$(jq -n \
                    --arg name "$PROJECT_NAME" \
                    --arg display_name "$PROJECT_NAME" \
                    --arg git_repo_path "$PROJECT_PATH" \
                    '{
                        name: $name,
                        repositories: [{
                            display_name: $display_name,
                            git_repo_path: $git_repo_path
                        }]
                    }')")

            PROJECT_ID=$(echo "$PROJECT_RESPONSE" | jq -r '.data.id // empty')

            if [ -z "$PROJECT_ID" ]; then
                log_error "Impossible de creer le projet."
                echo "  Response: $PROJECT_RESPONSE"
                exit 1
            fi
            log_success "Projet cree: $PROJECT_ID"
        fi
    elif [ "$PROJECT_COUNT" -eq 1 ]; then
        PROJECT_ID=$(echo "$PROJECTS_RESPONSE" | jq -r '.data[0].id')
        PROJECT_NAME=$(echo "$PROJECTS_RESPONSE" | jq -r '.data[0].name')
        log_info "Utilisation du projet: $PROJECT_NAME ($PROJECT_ID)"
    else
        echo ""
        echo "Plusieurs projets disponibles:"
        echo ""
        echo "$PROJECTS_RESPONSE" | jq -r '.data | to_entries[] | "  \(.key + 1). \(.value.name) [\(.value.id)]"'
        echo ""
        read -p "Choisir un projet (numero): " CHOICE

        PROJECT_ID=$(echo "$PROJECTS_RESPONSE" | jq -r ".data[$((CHOICE-1))].id")
        PROJECT_NAME=$(echo "$PROJECTS_RESPONSE" | jq -r ".data[$((CHOICE-1))].name")

        if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "null" ]; then
            log_error "Choix invalide"
            exit 1
        fi
        log_info "Utilisation du projet: $PROJECT_NAME"
    fi
fi

echo ""
log_info "Projet cible: $PROJECT_ID"

# =============================================================================
# FONCTIONS DE PARSING DES STORIES (FORMAT ANGLAIS)
# =============================================================================

# Extraire le titre de la story (ligne 1 du fichier)
extract_title() {
    local file="$1"
    head -1 "$file" | sed 's/^# //' | sed 's/Story [0-9.-]*\/[0-9]*: //' | sed 's/Story [0-9.-]*: //'
}

# Extraire les informations Wave/Epic/Story
extract_wave_info() {
    local file="$1"
    grep -E '^\*\*Wave:\*\*' "$file" | head -1 || echo ""
}

# Extraire le status de la story
extract_status() {
    local file="$1"
    local status_line
    status_line=$(grep -E '^\*\*Status:\*\*' "$file" | head -1)
    if echo "$status_line" | grep -qi "ready\|development\|todo"; then
        echo "todo"
    elif echo "$status_line" | grep -qi "progress"; then
        echo "inprogress"
    elif echo "$status_line" | grep -qi "review"; then
        echo "inreview"
    elif echo "$status_line" | grep -qi "done\|complete"; then
        echo "done"
    else
        echo "todo"
    fi
}

# Extraire la description user story (format anglais)
extract_user_story() {
    local file="$1"
    local as_a
    as_a=$(grep -E '^\*\*As a\*\*' "$file" | sed 's/\*\*As a\*\* //' | head -1)
    local i_want
    i_want=$(grep -E '^\*\*I want\*\*' "$file" | sed 's/\*\*I want\*\* //' | head -1)
    local so_that
    so_that=$(grep -E '^\*\*So that\*\*' "$file" | sed 's/\*\*So that\*\* //' | head -1)

    if [ -n "$as_a" ] && [ -n "$i_want" ]; then
        echo "As a $as_a, I want $i_want so that $so_that"
    else
        echo ""
    fi
}

# Extraire les criteres d'acceptation
extract_acceptance_criteria() {
    local file="$1"
    awk '/^## Acceptance Criteria/,/^---/' "$file" | grep -E '^[0-9]+\.' | head -10
}

# Extraire les scenarios de test
extract_test_scenarios() {
    local file="$1"
    awk '/^## Test Specifications/,/^## Test Code/' "$file" | grep -E '^#### Scenario:|^- \*\*Given\*\*|^- \*\*When\*\*|^- \*\*Then\*\*' | head -20
}

# Extraire les data-testid requis
extract_testids() {
    local file="$1"
    awk '/^## Required data-testid/,/^---/' "$file" | grep -E '^\| `|^- `' | head -15
}

# Construire la description complete pour Vibe Kanban
build_task_description() {
    local file="$1"
    local filename
    filename=$(basename "$file" .md)

    local user_story
    user_story=$(extract_user_story "$file")
    local wave_info
    wave_info=$(extract_wave_info "$file")
    local acceptance
    acceptance=$(extract_acceptance_criteria "$file")
    local scenarios
    scenarios=$(extract_test_scenarios "$file")
    local testids
    testids=$(extract_testids "$file")

    cat << EOF
## BMAD Story: ${filename}

${wave_info}

### User Story
${user_story:-"(See source file)"}

### Acceptance Criteria
${acceptance:-"(See source file)"}

### Test Scenarios
${scenarios:-"(See source file)"}

### Required data-testid
${testids:-"(None specified)"}

---

**Source:** \`${file}\`

**BMAD Workflow:**
1. \`tea -> atdd\` - Create tests (RED)
2. \`dev -> story\` - Implement the story (GREEN)
3. \`tea -> test-review\` - Review tests
4. \`tea -> trace\` - Update traceability matrix
5. \`code-review\` - Code review
EOF
}

# =============================================================================
# IMPORT DES STORIES
# =============================================================================

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN} Import des Stories${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

IMPORTED=0
FAILED=0
CURRENT_WAVE=""

# Importer chaque story
echo "$STORY_FILES" | while read -r story_file; do
    if [ -z "$story_file" ]; then
        continue
    fi

    FILENAME=$(basename "$story_file" .md)

    # Extraire wave du nom de fichier
    WAVE=$(echo "$FILENAME" | cut -d'-' -f1)

    # Afficher separateur de wave
    if [ "$WAVE" != "$CURRENT_WAVE" ]; then
        echo ""
        log_wave "=== Wave $WAVE ==="
        CURRENT_WAVE="$WAVE"
    fi

    TITLE=$(extract_title "$story_file")
    STATUS=$(extract_status "$story_file")

    # Construire le titre format Vibe Kanban
    TASK_TITLE="[$FILENAME] $TITLE"

    # Construire la description
    TASK_DESC=$(build_task_description "$story_file")

    echo -n "  [$FILENAME] $TITLE... "

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC}"
        IMPORTED=$((IMPORTED + 1))
    else
        # Creer la tache via l'API
        RESPONSE=$(curl -s -X POST "${API_BASE}/tasks" \
            -H "Content-Type: application/json" \
            -d "$(jq -n \
                --arg project_id "$PROJECT_ID" \
                --arg title "$TASK_TITLE" \
                --arg description "$TASK_DESC" \
                --arg status "$STATUS" \
                '{
                    project_id: $project_id,
                    title: $title,
                    description: $description,
                    status: $status
                }')")

        TASK_ID=$(echo "$RESPONSE" | jq -r '.data.id // empty')

        if [ -n "$TASK_ID" ] && [ "$TASK_ID" != "null" ]; then
            echo -e "${GREEN}OK${NC}"
            IMPORTED=$((IMPORTED + 1))
        else
            echo -e "${RED}FAILED${NC}"
            ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error // .message // "Unknown error"')
            log_warning "  Error: $ERROR_MSG"
            FAILED=$((FAILED + 1))
        fi
    fi
done

# Compter les resultats finaux
FINAL_IMPORTED=$(echo "$STORY_FILES" | grep -c '\.md$' || echo "0")
if [ "$DRY_RUN" = true ]; then
    FINAL_IMPORTED=$STORY_COUNT
fi

# =============================================================================
# RESUME
# =============================================================================

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN} Resume${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

echo "  Stories trouvees:  $STORY_COUNT"
echo "  Stories traitees:  $FINAL_IMPORTED"
echo ""

if [ "$DRY_RUN" = true ]; then
    log_warning "Mode simulation (--dry-run). Aucune tache creee."
    echo ""
    echo "Pour importer reellement, relancer sans --dry-run:"
    echo "  ./scripts/import-stories-to-vibe-kanban.sh"
else
    log_success "Import termine!"
    echo ""
    echo "  Prochaines etapes:"
    echo "  1. Ouvrir Vibe Kanban dans le navigateur (http://localhost:5173)"
    echo "  2. Selectionner le projet: $PROJECT_NAME"
    echo "  3. Les stories BMAD sont visibles comme taches"
    echo "  4. Utiliser un agent (Claude, Cursor, etc.) pour implementer"
fi

echo ""
