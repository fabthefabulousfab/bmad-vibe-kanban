#!/bin/bash
# ===========================================================================
# Script: project-story-parser.sh
# Purpose: Parse project-generated story files from _bmad-output
# Usage: source scripts/lib/project-story-parser.sh
# Dependencies: scripts/lib/common.sh and scripts/lib/story-parser.sh
# Story: 3.1-3.3 - Project Story Import
# ===========================================================================

log_debug "project-story-parser.sh: Loading project story parser library"

# ===========================================================================
# Project Story File Discovery
# ===========================================================================

# get_project_story_files - Get project story files sorted by X.Y.Z order
# Arguments:
#   $1 - Directory containing project story files
# Returns:
#   List of story file paths, one per line, sorted by X.Y.Z
get_project_story_files() {
    log_debug "project-story-parser.sh: get_project_story_files called with dir=$1"
    local story_dir="$1"

    if [[ ! -d "$story_dir" ]]; then
        log_error "Project stories directory not found: $story_dir"
        return 1
    fi

    # Find all .md files and sort by the numeric X-Y-Z prefix
    local files
    files=$(find "$story_dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | \
        sort -t'-' -k1,1n -k2,2n -k3,3n)

    if [[ -z "$files" ]]; then
        log_warning "No story files found in: $story_dir"
        return 0
    fi

    echo "$files"
    log_debug "project-story-parser.sh: get_project_story_files completed"
    return 0
}

# ===========================================================================
# Project Story Parsing
# ===========================================================================

# parse_project_story_wes - Extract X.Y.Z identifier from filename
# Arguments:
#   $1 - Path to story file
# Returns:
#   X.Y.Z string (e.g., "1-1-1")
parse_project_story_wes() {
    log_debug "project-story-parser.sh: parse_project_story_wes called with file=$1"
    local file_path="$1"

    local basename
    basename=$(basename "$file_path")

    # Extract X-Y-Z from filename format: X-Y-Z-slug.md
    local wes
    wes=$(echo "$basename" | sed -E 's/^([0-9]+-[0-9]+-[0-9]+)-.*/\1/')

    if [[ -z "$wes" ]] || [[ "$wes" == "$basename" ]]; then
        # Try to extract from content if filename doesn't match
        wes=$(grep -m1 "Story [0-9]\+\.[0-9]\+\.[0-9]\+:" "$file_path" 2>/dev/null | \
            sed -E 's/.*Story ([0-9]+)\.([0-9]+)\.([0-9]+):.*/\1-\2-\3/')

        if [[ -z "$wes" ]] || [[ "$wes" == *"Story"* ]]; then
            log_warning "Could not parse X.Y.Z from: $basename"
            echo ""
            return 1
        fi
    fi

    echo "$wes"
    log_debug "project-story-parser.sh: parse_project_story_wes returning $wes"
    return 0
}

# parse_project_story_title - Extract title from story file
# Arguments:
#   $1 - Path to story file
# Returns:
#   Story title (from first H1 heading)
parse_project_story_title() {
    log_debug "project-story-parser.sh: parse_project_story_title called with file=$1"
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        log_error "Story file not found: $file_path"
        return 1
    fi

    # Extract title from first H1 heading
    # Format: "# Story X.Y.Z: Title" or "# Title"
    local raw_title
    raw_title=$(grep -m1 "^# " "$file_path" | sed 's/^# //')

    if [[ -z "$raw_title" ]]; then
        # Fallback: use filename slug
        local basename
        basename=$(basename "$file_path" .md)
        raw_title=$(echo "$basename" | sed -E 's/^[0-9]+-[0-9]+-[0-9]+-//' | tr '-' ' ')
    fi

    # Clean up title - remove "Story X.Y.Z: " prefix if present
    local title
    title=$(echo "$raw_title" | sed -E 's/^Story [0-9]+\.[0-9]+\.[0-9]+: //')

    echo "$title"
    log_debug "project-story-parser.sh: parse_project_story_title returning: $title"
    return 0
}

# parse_project_story_description - Extract user story description
# Arguments:
#   $1 - Path to story file
# Returns:
#   User story description (As a... I want... So that...)
parse_project_story_description() {
    log_debug "project-story-parser.sh: parse_project_story_description called with file=$1"
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        log_error "Story file not found: $file_path"
        return 1
    fi

    # Use existing story-parser function if available
    if type parse_story_description &>/dev/null; then
        parse_story_description "$file_path"
        return $?
    fi

    # Fallback: Extract As a/I want/So that
    local as_a i_want so_that

    as_a=$(grep -m1 "^\*\*As a\*\*" "$file_path" | sed 's/^\*\*As a\*\* /As a /' | sed 's/,$//')
    i_want=$(grep -m1 "^\*\*I want\*\*" "$file_path" | sed 's/^\*\*I want\*\* /I want /' | sed 's/,$//')
    so_that=$(grep -m1 "^\*\*So that\*\*" "$file_path" | sed 's/^\*\*So that\*\* /So that /')

    local description=""
    [[ -n "$as_a" ]] && description="$as_a"
    [[ -n "$i_want" ]] && description="${description:+$description, }$i_want"
    [[ -n "$so_that" ]] && description="${description:+$description, }$so_that"

    echo "$description"
    log_debug "project-story-parser.sh: parse_project_story_description completed"
    return 0
}

# parse_project_story_criteria - Extract acceptance criteria
# Arguments:
#   $1 - Path to story file
# Returns:
#   Acceptance criteria text
parse_project_story_criteria() {
    log_debug "project-story-parser.sh: parse_project_story_criteria called with file=$1"
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        log_error "Story file not found: $file_path"
        return 1
    fi

    # Extract content between ## Acceptance Criteria and next ##
    local criteria
    criteria=$(sed -n '/^## Acceptance Criteria/,/^##/p' "$file_path" | \
        grep -v "^##" | \
        grep -v "^$" | \
        head -10 | \
        tr '\n' ' ' | \
        sed 's/  */ /g')

    echo "$criteria"
    log_debug "project-story-parser.sh: parse_project_story_criteria completed"
    return 0
}

# parse_project_story_metadata - Extract wave/epic/story metadata
# Arguments:
#   $1 - Path to story file
# Returns:
#   Metadata line (Wave: X | Epic: Y | Story: Z)
parse_project_story_metadata() {
    log_debug "project-story-parser.sh: parse_project_story_metadata called with file=$1"
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        log_error "Story file not found: $file_path"
        return 1
    fi

    # Extract Wave/Epic/Story line
    local metadata
    metadata=$(grep -m1 "^\*\*Wave:\*\*" "$file_path" || echo "")

    if [[ -z "$metadata" ]]; then
        # Fallback: construct from filename
        local wes
        wes=$(parse_project_story_wes "$file_path")
        if [[ -n "$wes" ]]; then
            local wave epic story
            wave=$(echo "$wes" | cut -d'-' -f1)
            epic=$(echo "$wes" | cut -d'-' -f2)
            story=$(echo "$wes" | cut -d'-' -f3)
            metadata="Wave: $wave | Epic: $epic | Story: $story"
        fi
    fi

    echo "$metadata"
    log_debug "project-story-parser.sh: parse_project_story_metadata completed"
    return 0
}

# ===========================================================================
# Project Story Import
# ===========================================================================

# import_project_stories - Import all project stories from directory
# Arguments:
#   $1 - Project ID
#   $2 - Stories directory path
#   $3 - Dry run flag (1 = dry run, 0 = real import)
# Returns:
#   0 - Success
#   1 - Failure
import_project_stories() {
    log_debug "project-story-parser.sh: import_project_stories called"
    local project_id="$1"
    local story_dir="$2"
    local dry_run="${3:-0}"

    local files
    files=$(get_project_story_files "$story_dir")

    if [[ -z "$files" ]]; then
        log_warning "No project stories to import from: $story_dir"
        return 0
    fi

    local total_files=0
    local imported_count=0
    local skipped_count=0

    # Count total files
    total_files=$(echo "$files" | wc -l | tr -d ' ')

    log_info "Found $total_files project stories to import"

    # Process each story file
    while IFS= read -r file_path; do
        if [[ -z "$file_path" ]]; then
            continue
        fi

        local wes title description id_prefix

        wes=$(parse_project_story_wes "$file_path")
        title=$(parse_project_story_title "$file_path")
        description=$(parse_project_story_description "$file_path")
        id_prefix="[$wes]"

        if [[ -z "$wes" ]] || [[ -z "$title" ]]; then
            log_warning "Skipping malformed story file: $file_path"
            continue
        fi

        if [[ "$dry_run" == "1" ]]; then
            log_info "[dry-run] Would import: $id_prefix $title"
            imported_count=$((imported_count + 1))
        else
            # Use deduplication-aware import
            if import_task_if_new "$project_id" "$id_prefix" "$title" "$description"; then
                imported_count=$((imported_count + 1))
            else
                skipped_count=$((skipped_count + 1))
            fi
        fi
    done <<< "$files"

    echo ""
    log_success "Project story import completed: $imported_count stories processed"
    if [[ $skipped_count -gt 0 ]]; then
        log_info "Skipped (already exist): $skipped_count"
    fi

    log_debug "project-story-parser.sh: import_project_stories completed"
    return 0
}

log_debug "project-story-parser.sh: Project story parser library loaded successfully"
