#!/bin/bash
# ===========================================================================
# Script: api.sh
# Purpose: Vibe Kanban API functions for all import scripts
# Usage: source scripts/lib/api.sh
# Dependencies: scripts/lib/common.sh must be sourced first
# ===========================================================================

# ===========================================================================
# Configuration
# ===========================================================================

# API base URL - configurable via environment variable
API_BASE="${API_BASE:-http://127.0.0.1:${BACKEND_PORT:-3001}/api}"

# ===========================================================================
# Core API Functions
# ===========================================================================

# call_api - Make a REST API call to Vibe Kanban
# Arguments:
#   $1 - HTTP method (GET, POST, PUT, DELETE)
#   $2 - Endpoint path (e.g., /projects, /tasks)
#   $3 - JSON data for POST/PUT (optional)
# Returns:
#   0 - Success, outputs response JSON
#   1 - Failure
call_api() {
    log_debug "api.sh: call_api called with method=$1 endpoint=$2"
    local method="$1"
    local endpoint="$2"
    local data="${3:-}"

    local response
    local curl_exit_code

    if [[ -n "$data" ]]; then
        response=$(curl -s -X "$method" "${API_BASE}${endpoint}" \
            -H "Content-Type: application/json" \
            -d "$data" 2>&1)
        curl_exit_code=$?
    else
        response=$(curl -s -X "$method" "${API_BASE}${endpoint}" \
            -H "Content-Type: application/json" 2>&1)
        curl_exit_code=$?
    fi

    # Check for curl errors (network issues)
    if [[ $curl_exit_code -ne 0 ]]; then
        log_error "API call failed: $response"
        log_debug "api.sh: call_api failed with curl exit code $curl_exit_code"
        return 1
    fi

    # Check for API errors in response (error field exists and is not null)
    local error_field
    error_field=$(echo "$response" | jq -r '.error // empty' 2>/dev/null)
    if [[ -n "$error_field" ]]; then
        log_error "API error: $error_field"
        log_debug "api.sh: call_api failed with API error"
        return 1
    fi

    echo "$response"
    log_debug "api.sh: call_api completed successfully"
    return 0
}

# ===========================================================================
# Health Check Functions
# ===========================================================================

# check_vibe_kanban_running - Verify Vibe Kanban API is accessible
# Returns:
#   0 - API is running
#   1 - API is not accessible
check_vibe_kanban_running() {
    log_debug "api.sh: check_vibe_kanban_running called"

    local response
    response=$(curl -s "${API_BASE}/health" 2>&1)
    local curl_exit_code=$?

    if [[ $curl_exit_code -ne 0 ]]; then
        # Error message handled by caller
        log_debug "api.sh: check_vibe_kanban_running failed"
        return 1
    fi

    log_debug "api.sh: check_vibe_kanban_running succeeded"
    return 0
}

# ===========================================================================
# Project Functions
# ===========================================================================

# get_projects - Get list of all projects
# Returns:
#   0 - Success, outputs project list
#   1 - Failure
get_projects() {
    log_debug "api.sh: get_projects called"

    local response
    response=$(call_api GET /projects)
    local api_exit_code=$?

    if [[ $api_exit_code -ne 0 ]]; then
        log_debug "api.sh: get_projects failed"
        return 1
    fi

    echo "$response"
    log_debug "api.sh: get_projects completed"
    return 0
}

# get_or_create_project - Get existing project or create new one
# Arguments:
#   $1 - Project name
# Returns:
#   0 - Success, outputs project ID
#   1 - Failure
get_or_create_project() {
    log_debug "api.sh: get_or_create_project called with name=$1"
    local project_name="$1"

    # First, try to find existing project
    local projects_response
    projects_response=$(get_projects)

    if [[ $? -eq 0 ]]; then
        local existing_id
        existing_id=$(echo "$projects_response" | jq -r ".data[] | select(.name == \"$project_name\") | .id" 2>/dev/null)

        if [[ -n "$existing_id" ]]; then
            log_info "Using existing project: $project_name ($existing_id)"
            echo "$existing_id"
            return 0
        fi
    fi

    # Create new project
    local create_response
    create_response=$(call_api POST /projects "{\"name\": \"$project_name\"}")

    if [[ $? -ne 0 ]]; then
        log_error "Failed to create project: $project_name"
        return 1
    fi

    local new_id
    new_id=$(echo "$create_response" | jq -r '.data.id')
    log_success "Created new project: $project_name ($new_id)"
    echo "$new_id"
    log_debug "api.sh: get_or_create_project completed"
    return 0
}

# ===========================================================================
# Task Functions
# ===========================================================================

# create_task - Create a new task in Vibe Kanban
# Arguments:
#   $1 - Project ID
#   $2 - Task title
#   $3 - Task description
# Returns:
#   0 - Success (outputs task data only if QUIET!=1)
#   1 - Failure
create_task() {
    log_debug "api.sh: create_task called with project_id=$1 title=$2"
    local project_id="$1"
    local title="$2"
    local description="${3:-}"

    local json_data
    json_data=$(jq -n \
        --arg project_id "$project_id" \
        --arg title "$title" \
        --arg description "$description" \
        --arg status "todo" \
        '{project_id: $project_id, title: $title, description: $description, status: $status}')

    local response
    response=$(call_api POST /tasks "$json_data")

    if [[ $? -ne 0 ]]; then
        log_error "Failed to create task: $title"
        return 1
    fi

    # Only output response in verbose mode
    if [[ "${QUIET:-0}" != "1" ]]; then
        echo "$response"
    fi
    log_debug "api.sh: create_task completed"
    return 0
}

# ===========================================================================
# Deduplication Functions (ADR-003)
# ===========================================================================

# task_exists - Check if a task with the given ID prefix exists
# Arguments:
#   $1 - Project ID
#   $2 - Task ID prefix (e.g., "[1-1-0]")
# Returns:
#   0 - Task exists
#   1 - Task does not exist
task_exists() {
    log_debug "api.sh: task_exists called with project_id=$1 id_prefix=$2"
    local project_id="$1"
    local id_prefix="$2"

    # Get all tasks for the project
    local response
    response=$(call_api GET "/tasks?project_id=$project_id")

    if [[ $? -ne 0 ]]; then
        log_debug "api.sh: task_exists failed to get tasks"
        return 1
    fi

    # Check if any task title starts with the ID prefix
    local matches
    matches=$(echo "$response" | jq -r ".data[] | select(.title | startswith(\"$id_prefix\")) | .id" 2>/dev/null)

    if [[ -n "$matches" ]]; then
        log_debug "api.sh: task_exists found matching task"
        return 0
    fi

    log_debug "api.sh: task_exists no matching task found"
    return 1
}

# import_task_if_new - Import a task only if it doesn't already exist
# Arguments:
#   $1 - Project ID
#   $2 - Task ID prefix (e.g., "[1-1-0]")
#   $3 - Task title (without prefix)
#   $4 - Task description
# Returns:
#   0 - Task created or already exists
#   1 - Failure
import_task_if_new() {
    log_debug "api.sh: import_task_if_new called with project_id=$1 id_prefix=$2"
    local project_id="$1"
    local id_prefix="$2"
    local title="$3"
    local description="${4:-}"

    # Check if task already exists
    if task_exists "$project_id" "$id_prefix"; then
        log_info "Task already exists, skipping: $id_prefix $title"
        return 0
    fi

    # Create the task with ID prefix in title
    local full_title="${id_prefix} ${title}"
    create_task "$project_id" "$full_title" "$description"

    return $?
}

log_debug "api.sh: API library loaded successfully"
