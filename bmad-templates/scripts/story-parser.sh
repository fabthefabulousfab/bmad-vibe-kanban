#!/bin/bash
# ===========================================================================
# Script: story-parser.sh
# Purpose: Parse BMAD story markdown files for import
# Usage: source scripts/lib/story-parser.sh
# Dependencies: scripts/lib/common.sh must be sourced first
# ===========================================================================

log_debug "story-parser.sh: Loading story parser library"

# ===========================================================================
# Story File Discovery
# ===========================================================================

# get_sorted_story_files - Get story files sorted by W-E-S order
# Arguments:
#   $1 - Directory containing story files
# Returns:
#   List of story file paths, one per line, sorted by W-E-S
get_sorted_story_files() {
    log_debug "story-parser.sh: get_sorted_story_files called with dir=$1"
    local story_dir="$1"

    if [[ ! -d "$story_dir" ]]; then
        log_error "Story directory not found: $story_dir"
        return 1
    fi

    # Find all .md files except templates (X-X-X-*)
    # Sort by filename (not full path) to correctly sort by W-E-S prefix
    local files
    files=$(find "$story_dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | \
        grep -v "X-X-X-" | \
        awk -F'/' '{print $NF "|" $0}' | \
        sort -t'-' -k1,1n -k2,2n -k3,3n | \
        cut -d'|' -f2)

    if [[ -z "$files" ]]; then
        log_warning "No story files found in: $story_dir"
        return 0
    fi

    echo "$files"
    log_debug "story-parser.sh: get_sorted_story_files completed"
    return 0
}

# ===========================================================================
# Story File Parsing
# ===========================================================================

# parse_story_wes - Extract W-E-S identifier from filename
# Arguments:
#   $1 - Path to story file
# Returns:
#   W-E-S string (e.g., "1-1-0")
parse_story_wes() {
    log_debug "story-parser.sh: parse_story_wes called with file=$1"
    local file_path="$1"

    local basename
    basename=$(basename "$file_path")

    # Extract W-E-S from filename format: W-E-S-slug.md
    local wes
    wes=$(echo "$basename" | sed -E 's/^([0-9]+-[0-9]+-[0-9]+)-.*/\1/')

    if [[ -z "$wes" ]] || [[ "$wes" == "$basename" ]]; then
        log_warning "Could not parse W-E-S from filename: $basename"
        echo ""
        return 1
    fi

    echo "$wes"
    log_debug "story-parser.sh: parse_story_wes returning $wes"
    return 0
}

# parse_story_title - Extract title from story file
# Arguments:
#   $1 - Path to story file
# Returns:
#   Story title (from first H1 heading, cleaned up)
parse_story_title() {
    log_debug "story-parser.sh: parse_story_title called with file=$1"
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        log_error "Story file not found: $file_path"
        return 1
    fi

    # Extract title from first H1 heading (# Title)
    # Format is usually: "# Story W-E/S: Title"
    local raw_title
    raw_title=$(grep -m1 "^# " "$file_path" | sed 's/^# //')

    if [[ -z "$raw_title" ]]; then
        # Fallback: use filename slug
        local basename
        basename=$(basename "$file_path" .md)
        raw_title=$(echo "$basename" | sed -E 's/^[0-9]+-[0-9]+-[0-9]+-//' | tr '-' ' ')
    fi

    # Clean up title - remove "Story X-X/X: " prefix if present
    local title
    title=$(echo "$raw_title" | sed -E 's/^Story [0-9]+-[0-9]+\/[0-9]+: //')

    echo "$title"
    log_debug "story-parser.sh: parse_story_title returning: $title"
    return 0
}

# parse_story_description - Extract user story description (short summary)
# Arguments:
#   $1 - Path to story file
# Returns:
#   User story description (As a... I want... So that...)
parse_story_description() {
    log_debug "story-parser.sh: parse_story_description called with file=$1"
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        log_error "Story file not found: $file_path"
        return 1
    fi

    # Extract the User Story section
    # Look for lines starting with **As a**, **I want**, **So that**
    local as_a i_want so_that

    as_a=$(grep -m1 "^\*\*As a\*\*" "$file_path" | sed 's/^\*\*As a\*\* /As a /' | sed 's/,$//')
    i_want=$(grep -m1 "^\*\*I want\*\*" "$file_path" | sed 's/^\*\*I want\*\* /I want /' | sed 's/,$//')
    so_that=$(grep -m1 "^\*\*So that\*\*" "$file_path" | sed 's/^\*\*So that\*\* /So that /')

    local description=""

    if [[ -n "$as_a" ]]; then
        description="$as_a"
    fi

    if [[ -n "$i_want" ]]; then
        if [[ -n "$description" ]]; then
            description="$description, $i_want"
        else
            description="$i_want"
        fi
    fi

    if [[ -n "$so_that" ]]; then
        if [[ -n "$description" ]]; then
            description="$description, $so_that"
        else
            description="$so_that"
        fi
    fi

    # If no user story found, extract first paragraph after ## User Story
    if [[ -z "$description" ]]; then
        description=$(sed -n '/^## User Story/,/^##/p' "$file_path" | \
            grep -v "^##" | \
            grep -v "^$" | \
            head -3 | \
            tr '\n' ' ' | \
            sed 's/  */ /g')
    fi

    echo "$description"
    log_debug "story-parser.sh: parse_story_description completed"
    return 0
}

# parse_story_full_content - Extract full story content (everything after H1 title)
# Arguments:
#   $1 - Path to story file
# Returns:
#   Full markdown content of the story (excluding title)
parse_story_full_content() {
    log_debug "story-parser.sh: parse_story_full_content called with file=$1"
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        log_error "Story file not found: $file_path"
        return 1
    fi

    # Read file content, skip the first H1 line (title)
    # Keep everything else as the full description
    local content
    content=$(sed '1{/^# /d;}' "$file_path")

    echo "$content"
    log_debug "story-parser.sh: parse_story_full_content completed"
    return 0
}

# ===========================================================================
# Story Import Functions
# ===========================================================================

# import_stories_from_directory - Import all stories from a workflow directory
# Arguments:
#   $1 - Project ID
#   $2 - Workflow directory path
#   $3 - Dry run flag (1 = dry run, 0 = real import)
# Returns:
#   0 - Success
#   1 - Failure
import_stories_from_directory() {
    log_debug "story-parser.sh: import_stories_from_directory called"
    local project_id="$1"
    local story_dir="$2"
    local dry_run="${3:-0}"

    local files
    files=$(get_sorted_story_files "$story_dir")

    if [[ -z "$files" ]]; then
        log_warning "No stories to import from: $story_dir"
        return 0
    fi

    local total_files=0
    local imported_count=0
    local skipped_count=0

    # Count total files
    total_files=$(echo "$files" | wc -l | tr -d ' ')

    log_info "Found $total_files stories to import"

    # Start sequence from total and count down
    # This ensures [1] is created last, appearing first in "most recent" view
    local sequence_number=$total_files

    # Reverse the file order so highest numbers are created first
    # Use tail -r on macOS or tac on Linux
    local reversed_files
    if command -v tac &> /dev/null; then
        reversed_files=$(echo "$files" | tac)
    else
        # macOS fallback using tail -r
        reversed_files=$(echo "$files" | tail -r)
    fi

    # Process each story file (in reverse order)
    while IFS= read -r file_path; do
        if [[ -z "$file_path" ]]; then
            continue
        fi

        local wes title full_content id_prefix full_description

        wes=$(parse_story_wes "$file_path")
        title=$(parse_story_title "$file_path")
        full_content=$(parse_story_full_content "$file_path")

        # Use sequential numbering instead of W-E-S
        id_prefix="[$sequence_number]"

        # Include original W-E-S reference and full content
        full_description="[Original ID: $wes]

$full_content"

        if [[ -z "$wes" ]] || [[ -z "$title" ]]; then
            log_warning "Skipping malformed story file: $file_path"
            continue
        fi

        if [[ "$dry_run" == "1" ]]; then
            log_info "[dry-run] Would import: $id_prefix $title"
            imported_count=$((imported_count + 1))
            sequence_number=$((sequence_number - 1))
        else
            # Use deduplication-aware import
            if import_task_if_new "$project_id" "$id_prefix" "$title" "$full_description"; then
                imported_count=$((imported_count + 1))
                sequence_number=$((sequence_number - 1))
            else
                skipped_count=$((skipped_count + 1))
            fi
        fi
    done <<< "$reversed_files"

    echo ""
    log_success "Import completed: $imported_count stories processed"
    if [[ $skipped_count -gt 0 ]]; then
        log_info "Skipped (already exist): $skipped_count"
    fi

    log_debug "story-parser.sh: import_stories_from_directory completed"
    return 0
}

log_debug "story-parser.sh: Story parser library loaded successfully"
