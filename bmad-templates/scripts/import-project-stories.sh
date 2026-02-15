#!/bin/bash
# ===========================================================================
# Script: import-project-stories.sh
# Purpose: Import project-generated stories into Vibe Kanban
# Story: 3.1-3.3 - Project Story Import
# Usage: ./scripts/import-project-stories.sh [OPTIONS]
# ===========================================================================

set -euo pipefail

# Source shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/api.sh"
source "${SCRIPT_DIR}/lib/story-parser.sh"
source "${SCRIPT_DIR}/lib/project-story-parser.sh"

log_debug "import-project-stories.sh starting"

# ===========================================================================
# Configuration
# ===========================================================================

DEFAULT_STORIES_DIR="${SCRIPT_DIR}/../_bmad-output/epics-stories-tasks/stories"
STORIES_DIR="${DEFAULT_STORIES_DIR}"
PROJECT_ID=""
PROJECT_NAME=""
DRY_RUN="${DRY_RUN:-0}"
TEST_MODE="${TEST_MODE:-0}"

# ===========================================================================
# Help
# ===========================================================================

show_help() {
    log_debug "Showing help"
    cat << 'EOF'
Usage: import-project-stories.sh [OPTIONS]

Import project-generated stories into Vibe Kanban.

Options:
    --help              Show this help message
    --project-id ID     Use existing project ID
    --project-name NAME Create or use project with this name
    --stories-dir DIR   Path to stories directory
                        (default: _bmad-output/epics-stories-tasks/stories)
    --dry-run           Preview import without creating tasks
    --test-mode         Enable test mode (non-interactive)

Examples:
    ./import-project-stories.sh
    ./import-project-stories.sh --project-name "My Project"
    ./import-project-stories.sh --project-id abc123 --dry-run
    ./import-project-stories.sh --stories-dir ./custom/stories
EOF
}

# ===========================================================================
# Parse Arguments
# ===========================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --project-id)
            PROJECT_ID="$2"
            shift 2
            ;;
        --project-name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --stories-dir)
            STORIES_DIR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --test-mode)
            TEST_MODE=1
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# ===========================================================================
# Input Functions
# ===========================================================================

read_input() {
    local prompt="$1"
    local input=""

    if [[ "$TEST_MODE" == "1" ]]; then
        read -r input || true
    else
        read -r -p "$prompt" input
    fi

    echo "$input"
}

# ===========================================================================
# Project Selection
# ===========================================================================

select_or_create_project() {
    log_debug "select_or_create_project called"

    # If project ID already provided, use it
    if [[ -n "$PROJECT_ID" ]]; then
        log_info "Using provided project ID: $PROJECT_ID"
        return 0
    fi

    # If project name provided, get or create it
    if [[ -n "$PROJECT_NAME" ]]; then
        PROJECT_ID=$(get_or_create_project "$PROJECT_NAME")
        if [[ -z "$PROJECT_ID" ]]; then
            log_error "Failed to get or create project: $PROJECT_NAME"
            exit 1
        fi
        return 0
    fi

    # Interactive selection
    echo ""
    log_info "Fetching projects from Vibe Kanban..."

    local projects_response
    projects_response=$(get_projects) || {
        log_error "Failed to fetch projects"
        exit 1
    }

    local -a project_ids
    local -a project_names
    local project_count=0
    project_ids=()
    project_names=()

    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            project_ids+=($(echo "$line" | cut -d'|' -f1))
            project_names+=($(echo "$line" | cut -d'|' -f2))
            project_count=$((project_count + 1))
        fi
    done < <(echo "$projects_response" | jq -r '.data[] | "\(.id)|\(.name)"' 2>/dev/null || true)

    echo ""
    echo "Select a project for story import:"
    echo ""
    echo "  0) Create new project"

    local i=1
    if [[ ${#project_names[@]} -gt 0 ]]; then
        for name in "${project_names[@]}"; do
            echo "  $i) $name"
            i=$((i + 1))
        done
    fi

    echo ""

    local choice
    choice=$(read_input "Select [0-$project_count]: ")

    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        log_error "Invalid selection: $choice"
        exit 1
    fi

    if [[ "$choice" -eq 0 ]]; then
        echo ""
        echo "Enter name for new project:"
        PROJECT_NAME=$(read_input "Project name: ")

        if [[ -z "$PROJECT_NAME" ]]; then
            log_error "Project name cannot be empty"
            exit 1
        fi

        if [[ "$DRY_RUN" == "1" ]]; then
            PROJECT_ID="dry-run-project-id"
            log_info "[dry-run] Would create project: $PROJECT_NAME"
        else
            PROJECT_ID=$(get_or_create_project "$PROJECT_NAME")
            if [[ -z "$PROJECT_ID" ]]; then
                log_error "Failed to create project"
                exit 1
            fi
        fi
    elif [[ "$choice" -ge 1 && "$choice" -le "$project_count" ]]; then
        local idx=$((choice - 1))
        PROJECT_ID="${project_ids[$idx]}"
        PROJECT_NAME="${project_names[$idx]}"
        log_success "Selected project: $PROJECT_NAME (ID: $PROJECT_ID)"
    else
        log_error "Invalid selection: $choice"
        exit 1
    fi
}

# ===========================================================================
# Main
# ===========================================================================

main() {
    log_debug "main() called"

    echo "=========================================="
    echo "  Project Story Import"
    echo "=========================================="

    # Step 1: Check Vibe Kanban is running
    echo ""
    log_info "Checking Vibe Kanban connection..."

    if ! check_vibe_kanban_running; then
        log_error "Vibe Kanban is not running!"
        echo ""
        echo "Please start Vibe Kanban first:"
        echo "  cd /path/to/vibe-kanban && npm start"
        exit 1
    fi

    log_success "Vibe Kanban is running"

    # Step 2: Verify stories directory
    if [[ ! -d "$STORIES_DIR" ]]; then
        log_error "Stories directory not found: $STORIES_DIR"
        echo ""
        echo "Run BMAD planning phases first to generate stories, or specify"
        echo "a custom directory with --stories-dir"
        exit 1
    fi

    # Step 3: Select or create project
    select_or_create_project

    # Step 4: Import stories
    echo ""
    echo "=========================================="
    echo "  Importing Project Stories"
    echo "=========================================="

    log_info "Importing from: $STORIES_DIR"
    log_info "Target project: ${PROJECT_NAME:-$PROJECT_ID}"
    echo ""

    import_project_stories "$PROJECT_ID" "$STORIES_DIR" "$DRY_RUN"

    echo "=========================================="

    log_debug "main() completed"
}

# Run main
main

log_debug "import-project-stories.sh completed"
