#!/bin/bash
# ===========================================================================
# File: import-bmad-workflow.sh
# Purpose: Import BMAD workflow stories into Vibe Kanban
# Stories: 2.1 - Questionnaire, 2.2 - Project Selection
# ===========================================================================

set -euo pipefail

# Source shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/api.sh"
source "${SCRIPT_DIR}/lib/story-parser.sh"

log_debug "import-bmad-workflow.sh starting"

# ===========================================================================
# Configuration
# ===========================================================================

STORIES_DIR="${SCRIPT_DIR}/../stories"
TEMPLATES_DIR="${SCRIPT_DIR}/../templates"
TEST_MODE="${TEST_MODE:-0}"
DRY_RUN="${DRY_RUN:-0}"
CLEAN_MODE="${CLEAN_MODE:-0}"
QUIET="${QUIET:-1}"  # Quiet mode by default (only show errors/warnings)
SELECTED_WORKFLOW=""
SELECTED_PROJECT_ID=""
SELECTED_PROJECT_NAME=""
VIBE_KANBAN_URL="http://localhost:${BACKEND_PORT:-3001}"

# ===========================================================================
# Help
# ===========================================================================

show_help() {
    log_debug "Showing help"
    cat << 'EOF'
Usage: import-bmad-workflow.sh [OPTIONS]

Import BMAD workflow stories into Vibe Kanban.

Options:
    --help          Show this help message
    --dry-run       Preview import without creating tasks
    --clean         Delete existing stories before importing
    --verbose       Show detailed progress logs
    --test-mode     Enable test mode (non-interactive)

Workflows:
    WORKFLOW_COMPLET    Full BMAD workflow for new projects
    DOCUMENT_PROJECT    Document existing codebase
    QUICK_FLOW          Quick feature addition
    DEBUG               Bug fix workflow

Examples:
    ./import-bmad-workflow.sh
    ./import-bmad-workflow.sh --dry-run
    ./import-bmad-workflow.sh --clean
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
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --clean)
            CLEAN_MODE=1
            shift
            ;;
        --verbose)
            QUIET=0
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

# Read user input (handles test mode)
read_input() {
    local prompt="$1"
    local input=""

    if [[ "$TEST_MODE" == "1" ]]; then
        # In test mode, read from stdin without prompt
        read -r input || true
    else
        # Interactive mode
        read -r -p "$prompt" input
    fi

    echo "$input"
}

# ===========================================================================
# Questionnaire Function (Story 2.1)
# ===========================================================================

ask_workflow_type() {
    log_debug "ask_workflow_type called"

    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           What would you like to do today?                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    printf "  \033[1m1) ──► NEW PROJECT\033[0m\n"
    echo "     Start from scratch with complete BMAD methodology"
    echo "     (Brainstorm -> PRD -> Architecture -> Implementation)"
    echo ""
    printf "  \033[1m2) ──► DOCUMENT PROJECT\033[0m\n"
    echo "     Generate PRD and architecture docs for existing codebase"
    echo "     (Analyze code -> Generate docs -> Ready for new features)"
    echo ""
    printf "  \033[1m3) ──► SIMPLE FEATURE\033[0m  \033[1;33m[Requires: option 2 first]\033[0m\n"
    echo "     Quick implementation for small changes (1-3 stories)"
    echo "     (Spec -> ATDD -> Dev -> Review)"
    echo ""
    printf "  \033[1m4) ──► COMPLEX FEATURE\033[0m  \033[1;33m[Requires: option 2 first]\033[0m\n"
    echo "     Full planning for significant changes"
    echo "     (PRD update -> Architecture -> Stories -> Implementation)"
    echo ""
    printf "  \033[1m5) ──► BUG FIX\033[0m\n"
    echo "     Structured diagnostic and fix workflow"
    echo "     (Analyze -> Write failing test -> Fix -> Verify)"
    echo ""

    local choice
    choice=$(read_input "Select [1-5]: ")

    case "$choice" in
        1)
            SELECTED_WORKFLOW="WORKFLOW_COMPLET"
            log_info "Selected: New project from scratch -> WORKFLOW_COMPLET"
            ;;
        2)
            SELECTED_WORKFLOW="DOCUMENT_PROJECT"
            log_info "Selected: Generate documentation -> DOCUMENT_PROJECT"
            ;;
        3)
            SELECTED_WORKFLOW="QUICK_FLOW"
            log_info "Selected: Simple feature -> QUICK_FLOW"
            ;;
        4)
            SELECTED_WORKFLOW="WORKFLOW_COMPLET"
            log_info "Selected: Complex feature -> WORKFLOW_COMPLET"
            ;;
        5)
            SELECTED_WORKFLOW="DEBUG"
            log_info "Selected: Fix a bug -> DEBUG"
            ;;
        *)
            log_error "Invalid selection: $choice"
            exit 1
            ;;
    esac
}

# ===========================================================================
# Project Selection Functions (Story 2.2)
# ===========================================================================

# Check if Vibe Kanban is running
check_vibe_kanban() {
    log_debug "check_vibe_kanban called"

    if ! check_vibe_kanban_running; then
        log_error "Vibe Kanban is not running!"
        echo ""
        echo "Start Vibe Kanban with: npx vibe-kanban"
        echo ""
        exit 1
    fi

    log_success "Vibe Kanban is running"
}

# Ensure repository is linked to project
# Arguments:
#   $1 - Project ID
ensure_repository_linked() {
    log_debug "ensure_repository_linked called with project_id=$1"
    local project_id="$1"

    if [[ "$DRY_RUN" == "1" ]]; then
        log_info "[dry-run] Would check/link repository"
        return 0
    fi

    # Check if project already has repositories
    local repos_response
    repos_response=$(call_api GET "/repos?project_id=$project_id") || {
        log_warning "Failed to check existing repositories"
        return 1
    }

    local repo_count
    repo_count=$(echo "$repos_response" | jq -r '.data | length' 2>/dev/null || echo "0")

    if [[ "$repo_count" -gt 0 ]]; then
        log_debug "Project already has $repo_count repository(ies)"
        return 0
    fi

    # No repositories - add current directory as repository
    local current_path
    current_path=$(pwd)
    local repo_name
    repo_name=$(basename "$current_path")

    log_info "Linking repository: $current_path"

    local json_data
    json_data=$(jq -n \
        --arg project_id "$project_id" \
        --arg path "$current_path" \
        --arg name "$repo_name" \
        '{
            project_id: $project_id,
            path: $path,
            name: $name,
            display_name: $name,
            git_repo_path: $path
        }')

    local response
    response=$(call_api POST "/repos" "$json_data") || {
        log_warning "Failed to link repository (may need to be done manually)"
        return 1
    }

    log_success "Repository linked successfully"
    return 0
}

# Select or create a project
select_project() {
    log_debug "select_project called"

    # Get current directory name as default project name
    local current_dir
    current_dir=$(basename "$(pwd)")
    log_debug "Current directory: $current_dir"

    echo ""
    log_info "Fetching projects from Vibe Kanban..."

    # Get list of projects
    local projects_response
    projects_response=$(get_projects) || {
        log_error "Failed to fetch projects"
        exit 1
    }

    # Parse projects into arrays
    local -a project_ids
    local -a project_names
    local project_count=0
    project_ids=()
    project_names=()

    # Extract projects using jq
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            project_ids+=("$(echo "$line" | cut -d'|' -f1)")
            project_names+=("$(echo "$line" | cut -d'|' -f2)")
            project_count=$((project_count + 1))
        fi
    done < <(echo "$projects_response" | jq -r '.data[] | "\(.id)|\(.name)"' 2>/dev/null || true)

    log_debug "Found $project_count projects"

    # Check if a project with the current directory name already exists
    local existing_project_idx=-1
    if [[ $project_count -gt 0 ]]; then
        for i in "${!project_names[@]}"; do
            if [[ "${project_names[$i]}" == "$current_dir" ]]; then
                existing_project_idx=$i
                log_debug "Found existing project matching directory name"
                break
            fi
        done
    fi

    # If project exists with current directory name, use it automatically
    if [[ $existing_project_idx -ge 0 ]]; then
        SELECTED_PROJECT_ID="${project_ids[$existing_project_idx]}"
        SELECTED_PROJECT_NAME="${project_names[$existing_project_idx]}"
        log_success "Using existing project: $SELECTED_PROJECT_NAME (ID: $SELECTED_PROJECT_ID)"
        # Ensure repository is linked
        ensure_repository_linked "$SELECTED_PROJECT_ID"
        return
    fi

    # Otherwise, offer to create it or select another
    echo ""
    echo "Project Selection"
    echo "════════════════════════════════════════"
    echo ""
    echo "  0) Create new project: '$current_dir' (recommended)"

    local i=1
    if [[ ${#project_names[@]} -gt 0 ]]; then
        echo ""
        echo "Or select an existing project:"
        echo ""
        for name in "${project_names[@]}"; do
            echo "  $i) $name"
            i=$((i + 1))
        done
    fi

    echo ""

    local choice
    choice=$(read_input "Select [0-$project_count] (Enter for 0): ")

    # Default to 0 if empty
    if [[ -z "$choice" ]]; then
        choice=0
    fi

    # Validate selection
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        log_error "Invalid selection: $choice"
        exit 1
    fi

    if [[ "$choice" -eq 0 ]]; then
        # Create new project with current directory name
        create_new_project "$current_dir"
    elif [[ "$choice" -ge 1 && "$choice" -le "$project_count" ]]; then
        # Select existing project
        local idx=$((choice - 1))
        SELECTED_PROJECT_ID="${project_ids[$idx]}"
        SELECTED_PROJECT_NAME="${project_names[$idx]}"
        log_success "Selected project: $SELECTED_PROJECT_NAME (ID: $SELECTED_PROJECT_ID)"
    else
        log_error "Invalid selection: $choice (must be 0-$project_count)"
        exit 1
    fi
}

# Create a new project
# Usage: create_new_project [default_name]
create_new_project() {
    log_debug "create_new_project called"

    local default_name="${1:-}"
    local project_name=""

    if [[ -n "$default_name" ]]; then
        # Use default name automatically
        project_name="$default_name"
        log_info "Creating project: $project_name (from directory name)"
    else
        # Ask for name
        echo ""
        echo "Enter name for new project:"
        project_name=$(read_input "Project name: ")

        if [[ -z "$project_name" ]]; then
            log_error "Project name cannot be empty"
            exit 1
        fi
    fi

    log_info "Creating project: $project_name"

    # Get current directory as git repo path
    local current_path
    current_path=$(pwd)

    if [[ "$DRY_RUN" == "1" ]]; then
        SELECTED_PROJECT_ID="dry-run-project-id"
        SELECTED_PROJECT_NAME="$project_name"
        log_info "[dry-run] Would create project: $project_name with repo: $current_path"
    else
        # Create project via API with repository linked to current directory
        local json_data
        json_data=$(jq -n \
            --arg name "$project_name" \
            --arg path "$current_path" \
            --arg repo_name "$project_name" \
            '{
                name: $name,
                repositories: [{
                    path: $path,
                    name: $repo_name,
                    display_name: $repo_name,
                    git_repo_path: $path
                }]
            }')

        local response
        response=$(call_api POST "/projects" "$json_data") || {
            log_error "Failed to create project"
            exit 1
        }

        SELECTED_PROJECT_ID=$(echo "$response" | jq -r '.data.id // .id // empty')
        SELECTED_PROJECT_NAME="$project_name"

        if [[ -z "$SELECTED_PROJECT_ID" ]]; then
            log_error "Failed to get project ID from response"
            exit 1
        fi

        log_success "Created project: $SELECTED_PROJECT_NAME (ID: $SELECTED_PROJECT_ID)"
        log_info "Linked repository: $current_path"
    fi
}

# ===========================================================================
# Clean Stories Function
# ===========================================================================

# clean_project_tasks - Delete all tasks from a project
# Arguments:
#   $1 - Project ID
# Returns:
#   0 - Success
#   1 - Failure
clean_project_tasks() {
    log_debug "clean_project_tasks called with project_id=$1"
    local project_id="$1"

    if [[ "$DRY_RUN" == "1" ]]; then
        log_info "[dry-run] Would delete all tasks from project"
        return 0
    fi

    # Get all tasks for the project
    local response
    response=$(call_api GET "/tasks?project_id=$project_id")

    if [[ $? -ne 0 ]]; then
        log_warning "Failed to fetch tasks for cleanup"
        return 1
    fi

    # Extract task IDs
    local task_ids
    task_ids=$(echo "$response" | jq -r '.data[].id' 2>/dev/null)

    if [[ -z "$task_ids" ]]; then
        log_info "No existing tasks to delete"
        return 0
    fi

    local delete_count=0
    while IFS= read -r task_id; do
        if [[ -n "$task_id" ]]; then
            if call_api DELETE "/tasks/$task_id" > /dev/null 2>&1; then
                delete_count=$((delete_count + 1))
            fi
        fi
    done <<< "$task_ids"

    log_success "Deleted $delete_count existing tasks"
    return 0
}

# ===========================================================================
# Finalization Functions
# ===========================================================================

# copy_workflow_guide - Copy the BMAD workflow guide to the project root
copy_workflow_guide() {
    log_debug "copy_workflow_guide called"

    local source_file="${TEMPLATES_DIR}/HOW TO - BMAD-VIBE-KANBAN.md"
    local target_file="$(pwd)/HOW TO - BMAD-VIBE-KANBAN.md"

    if [[ ! -f "$source_file" ]]; then
        log_warning "Workflow guide template not found: $source_file"
        return 1
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        log_info "[dry-run] Would copy HOW TO - BMAD-VIBE-KANBAN.md to project root"
        return 0
    fi

    cp "$source_file" "$target_file"
    log_success "Created HOW TO - BMAD-VIBE-KANBAN.md in project root"
    return 0
}

# show_completion_message - Display final instructions
show_completion_message() {
    log_debug "show_completion_message called"

    # Show completion message
    echo ""
    echo "Import complete! Open Vibe Kanban: ${VIBE_KANBAN_URL}"
    echo ""
}

# ===========================================================================
# Main
# ===========================================================================

main() {
    log_debug "main() called"

    # Show deprecation notice directing users to UI
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  BMAD Workflow Import - Use the Vibe Kanban UI              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "This shell script is deprecated. Please use the Vibe Kanban UI instead:"
    echo ""
    echo "  1. Open Vibe Kanban: http://127.0.0.1:${BACKEND_PORT:-3001}"
    echo "  2. Create or select a project"
    echo "  3. Click the orange '+' button in the 'To Do' column"
    echo "  4. Select a workflow and click 'Execute'"
    echo ""
    echo "The UI provides a better experience with:"
    echo "  - Real-time progress tracking"
    echo "  - Duplicate detection"
    echo "  - Better error handling"
    echo "  - No manual terminal commands"
    echo ""

    # Ask if user wants to continue anyway
    if [[ "$TEST_MODE" != "1" ]]; then
        read -r -p "Continue with legacy shell import anyway? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo ""
            log_info "Cancelled. Please use the Vibe Kanban UI for story import."
            echo ""
            exit 0
        fi
        echo ""
        log_warning "Proceeding with legacy import..."
        echo ""
    fi

    # Step 1: Check Vibe Kanban is running (silent in quiet mode)
    check_vibe_kanban

    # Step 2: Run questionnaire to select workflow
    ask_workflow_type

    # Step 3: Select or create project
    select_project

    # Step 4: Clean existing stories if requested
    if [[ "$CLEAN_MODE" == "1" ]]; then
        clean_project_tasks "$SELECTED_PROJECT_ID"
    fi

    # Step 5: Import stories
    # Convert workflow name to directory path
    local workflow_lower
    workflow_lower=$(echo "$SELECTED_WORKFLOW" | tr '[:upper:]' '[:lower:]')
    workflow_lower="${workflow_lower//_/-}"
    local story_dir="${STORIES_DIR}/${workflow_lower}"

    log_info "Importing from: stories/${workflow_lower}/"
    log_info "Target project: $SELECTED_PROJECT_NAME (ID: $SELECTED_PROJECT_ID)"
    echo ""

    # Import stories
    import_stories_from_directory "$SELECTED_PROJECT_ID" "$story_dir" "$DRY_RUN"

    # Step 6: Copy workflow guide to project root
    copy_workflow_guide

    # Step 7: Show completion message
    show_completion_message

    log_debug "main() completed"
}

# Run main
main

log_debug "import-bmad-workflow.sh completed"
