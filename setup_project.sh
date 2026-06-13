#!/usr/bin/env bash

# Where the source files live
src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

build_structure() {
    mkdir -p "$project/Helpers" "$project/reports"
    cp "$src_dir/attendance_checker.py" "$project/attendance_checker.py"
    cp "$src_dir/assets.csv"            "$project/Helpers/assets.csv"
    cp "$src_dir/config.json"           "$project/Helpers/config.json"
    cp "$src_dir/reports.log"           "$project/reports/reports.log"
    echo "Created $project with Helpers/ and reports/."
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
    local answer warning failure

    read -p "Update attendance thresholds? (y/n) " answer
    if [ "$answer" != "y" ]; then
        echo "Keeping default thresholds (warning 75, failure 50)."
        return
    fi

    warning="$(read_threshold 'Warning threshold' 75)"
    failure="$(read_threshold 'Failure threshold' 50)"

    sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" "$config"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" "$config"
    echo "Thresholds set to warning $warning, failure $failure."
}

main() {
    read -p "Project name: " name
    project="attendance_tracker_${name}"

    build_structure
    configure_thresholds

    echo "Done. Workspace ready at $project."
}

main
