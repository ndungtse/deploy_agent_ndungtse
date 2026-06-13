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

main() {
    read -p "Project name: " name
    project="attendance_tracker_${name}"

    build_structure

    echo "Done. Workspace ready at $project."
}

main
