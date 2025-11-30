#!/bin/bash

# Backfill Git Commits Script
# Generates backdated commits with realistic messages to simulate steady project progress
# Usage: bash backfill_commits.sh

set -e

# Configuration
START_DATE="2025-11-06"  # November 6th, 2025
END_DATE=$(date +%Y-%m-%d)  # Today's date
INTERVAL_DAYS=6  # Weekly (5-7 days)
LOG_FILE="PROGRESS_LOG.md"

# Commit message templates
COMMIT_MESSAGES=(
    "Frontend tweaks: improve component responsiveness"
    "Frontend tweaks: refine animation timing"
    "Google AI Studio prompt updates: enhance model context"
    "Bug fix: resolve state management issue"
    "Bug fix: fix memory leak in WebGL renderer"
    "UI optimization: streamline navigation flow"
    "UI optimization: improve loading state indicators"
    "Frontend tweaks: update styling for better accessibility"
    "Google AI Studio prompt updates: add example use cases"
    "Bug fix: correct event listener cleanup"
    "UI optimization: enhance mobile responsiveness"
    "Frontend tweaks: refactor component hierarchy"
)

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function: format date for git operations
format_git_date() {
    local date=$1
    date -j -f "%Y-%m-%d" -u "$date" "+%s" 2>/dev/null || date -d "$date" "+%s" 2>/dev/null
}

# Helper function: get random commit message
get_random_message() {
    local index=$((RANDOM % ${#COMMIT_MESSAGES[@]}))
    echo "${COMMIT_MESSAGES[$index]}"
}

# Helper function: add days to a date
add_days_to_date() {
    local date=$1
    local days=$2
    date -j -v+${days}d -f "%Y-%m-%d" "$date" "+%Y-%m-%d" 2>/dev/null || date -d "$date + $days days" "+%Y-%m-%d" 2>/dev/null
}

# Main backfill logic
main() {
    echo -e "${BLUE}🚀 Starting Git Commit Backfill${NC}"
    echo -e "${BLUE}Start Date: $START_DATE${NC}"
    echo -e "${BLUE}End Date: $END_DATE${NC}"
    echo -e "${BLUE}Interval: $INTERVAL_DAYS days${NC}"
    echo ""

    # Initialize log file if it doesn't exist
    if [ ! -f "$LOG_FILE" ]; then
        {
            echo "# Project Progress Log"
            echo ""
            echo "This file tracks development progress with timestamped entries."
            echo ""
        } > "$LOG_FILE"
    fi

    # Generate commits
    current_date="$START_DATE"
    commit_count=0

    while [[ $(date -j -f "%Y-%m-%d" "$current_date" "+%s") -le $(date -j -f "%Y-%m-%d" "$END_DATE" "+%s") ]]; do
        # Generate random interval (5-7 days)
        random_interval=$((RANDOM % 3 + 5))  # 5-7 days
        
        # Get random commit message
        message=$(get_random_message)
        
        # Create timestamp for log entry
        timestamp=$(date -j -f "%Y-%m-%d" "$current_date" "+%Y-%m-%d %H:%M:%S")
        
        # Append to log file
        {
            echo "## Entry: $timestamp"
            echo "- $message"
            echo ""
        } >> "$LOG_FILE"

        # Format dates for git
        git_timestamp=$(date -j -f "%Y-%m-%d" "$current_date" "+%a, %d %b %Y %H:%M:%S +0000")

        # Create/update a marker file to show commit activity
        echo "$timestamp: $message" >> COMMIT_HISTORY.txt

        # Stage the changes
        git add "$LOG_FILE" COMMIT_HISTORY.txt

        # Create commit with backdated timestamps
        GIT_AUTHOR_DATE="$git_timestamp" \
        GIT_COMMITTER_DATE="$git_timestamp" \
        git commit -m "$message" --quiet

        commit_count=$((commit_count + 1))
        echo -e "${GREEN}✓ Commit $commit_count: $current_date - $message${NC}"

        # Move to next date
        current_date=$(add_days_to_date "$current_date" "$random_interval")
    done

    echo ""
    echo -e "${GREEN}✅ Backfill Complete!${NC}"
    echo -e "${BLUE}Total commits created: $commit_count${NC}"
    echo -e "${BLUE}Log file: $LOG_FILE${NC}"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Review the commits: git log --oneline --graph"
    echo "  2. Push to remote: git push origin main"
}

# Safety checks
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not a git repository${NC}"
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}❌ Error: Working directory has uncommitted changes${NC}"
    echo "Please commit or stash changes before running this script."
    exit 1
fi

# Run main function
main
