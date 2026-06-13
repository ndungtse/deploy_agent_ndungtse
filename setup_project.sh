#!/usr/bin/env bash

# Where the source files live
src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

project=""
archive=""

# On Ctrl+C, bundle whatever was created so far and remove the partial workspace.
cleanup() {
    echo
    echo "Cancelled. Cleaning up..."
    if [ -n "$project" ] && [ -d "$project" ]; then
        tar -czf "$archive" "$project"
        rm -rf "$project"
        echo "Saved progress to $archive and removed $project."
        echo "Recover it later with: tar -xzf $archive"
    fi
    exit 1
}

# Copy a source file into place only if it isn't there yet, so an existing
# config (and any edits) is never overwritten on resume.
copy_missing() {
    [ -e "$2" ] && return
    if ! cp "$1" "$2"; then
        echo "Error: could not copy $1 (check permissions)." >&2
        exit 1
    fi
}

# Make sure the directory tree and the four files exist, filling only the gaps.
ensure_structure() {
    if ! mkdir -p "$project/Helpers" "$project/reports"; then
        echo "Error: could not create '$project' (check permissions)." >&2
        exit 1
    fi
    copy_missing "$src_dir/attendance_checker.py" "$project/attendance_checker.py"
    copy_missing "$src_dir/assets.csv"            "$project/Helpers/assets.csv"
    copy_missing "$src_dir/config.json"           "$project/Helpers/config.json"
    copy_missing "$src_dir/reports.log"           "$project/reports/reports.log"
}

# Decide where the workspace comes from: an existing directory, a saved
# archive, or a fresh build. Either way we end with a complete structure.
prepare_workspace() {
    if [ -d "$project" ]; then
        echo "Found existing '$project' — resuming with its current config."
    elif [ -f "$archive" ]; then
        echo "Found archive '$archive' — restoring it."
        tar -xzf "$archive"
    else
        echo "Creating new project '$project'."
    fi
    ensure_structure
}

# Read the current integer value of a config key (e.g. warning, failure).
get_config_number() {
    grep -oE "\"$1\"[[:space:]]*:[[:space:]]*[0-9]+" "$2" | grep -oE '[0-9]+'
}

read_threshold() {
    local label="$1" default="$2" value
    while true; do
        read -p "$label [$default]: " value
        value="${value:-$default}"
        if [[ "$value" =~ ^[0-9]+$ ]] && [ "$value" -le 100 ]; then
            echo "$value"
            return
        fi
        echo "Please enter a whole number between 0 and 100." >&2
    done
}

configure_thresholds() {
    local config="$project/Helpers/config.json"
    local answer warning failure cur_warning cur_failure

    cur_warning="$(get_config_number warning "$config")"; cur_warning="${cur_warning:-75}"
    cur_failure="$(get_config_number failure "$config")"; cur_failure="${cur_failure:-50}"

    read -p "Update attendance thresholds? (y/n) " answer
    if [ "$answer" != "y" ]; then
        echo "Keeping current thresholds (warning $cur_warning, failure $cur_failure)."
        return
    fi

    warning="$(read_threshold 'Warning threshold' "$cur_warning")"
    failure="$(read_threshold 'Failure threshold' "$cur_failure")"

    sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" "$config"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" "$config"
    echo "Thresholds set to warning $warning, failure $failure."
}

health_check() {
    if python3 --version >/dev/null 2>&1; then
        echo "OK: $(python3 --version)"
    else
        echo "Warning: python3 is not installed. The tracker needs it to run."
    fi

    if [ -f "$project/attendance_checker.py" ] && \
       [ -f "$project/Helpers/config.json" ] && \
       [ -f "$project/Helpers/assets.csv" ] && \
       [ -f "$project/reports/reports.log" ]; then
        echo "OK: project structure is in place."
    else
        echo "Warning: some expected files are missing."
    fi
}

main() {
    read -p "Project name: " name
    project="attendance_tracker_${name}"
    archive="attendance_tracker_${name}_archive.tar.gz"

    trap cleanup INT

    prepare_workspace
    configure_thresholds
    health_check

    echo "Done. Workspace ready at $project."
}

main
