#!/bin/bash
# ===========================================================================
# Script: common.sh
# Purpose: Shared logging and utility functions for all scripts
# Usage: source scripts/lib/common.sh
# ===========================================================================

# ===========================================================================
# Color Configuration
# ===========================================================================

# Disable colors in CI environment or when not a terminal
if [[ "${CI:-false}" == "true" ]] || [[ ! -t 1 ]]; then
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
fi

# ===========================================================================
# Logging Functions
# Set QUIET=1 to suppress info/success logs (only show warnings/errors)
# Set DEBUG=true to show debug logs
# ===========================================================================

# log_debug - Debug level logging (only when DEBUG=true)
# Arguments:
#   $1 - Message to log
log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1" >&2
    fi
}

# log_info - Information level logging (suppressed in QUIET mode)
# Arguments:
#   $1 - Message to log
log_info() {
    if [[ "${QUIET:-0}" != "1" ]]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

# log_success - Success level logging (suppressed in QUIET mode)
# Arguments:
#   $1 - Message to log
log_success() {
    if [[ "${QUIET:-0}" != "1" ]]; then
        echo -e "${GREEN}[OK]${NC} $1"
    fi
}

# log_warning - Warning level logging (always shown)
# Arguments:
#   $1 - Message to log
log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# log_error - Error level logging (always shown)
# Arguments:
#   $1 - Message to log
log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ===========================================================================
# Prerequisite Checks
# ===========================================================================

# check_prerequisites - Verify all required dependencies are installed
# Returns:
#   0 - All prerequisites satisfied
#   1 - One or more prerequisites missing
check_prerequisites() {
    log_debug "common.sh: check_prerequisites called"
    local missing=0

    # Check jq
    if ! command -v jq &> /dev/null; then
        log_error "jq is required. Install with: brew install jq"
        missing=1
    fi

    if [[ $missing -eq 0 ]]; then
        log_success "All prerequisites satisfied"
    fi

    log_debug "common.sh: check_prerequisites completed with status $missing"
    return $missing
}

log_debug "common.sh: Shared library loaded successfully"
