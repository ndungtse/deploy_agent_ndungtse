# Attendance Tracker — Project Factory

`setup_project.sh` bootstraps a Student Attendance Tracker workspace. It builds the
directory layout, copies the source files into place, lets you adjust the alert
thresholds, runs a quick environment check, and cleans up safely if you cancel.

## What it builds

```
attendance_tracker_{name}/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
```

## How to run

The four source files (`attendance_checker.py`, `assets.csv`, `config.json`,
`reports.log`) must sit next to the script.

```bash
bash setup_project.sh
```

You will be asked for:

1. **Project name** — used to name the workspace, e.g. `2026` creates
   `attendance_tracker_2026/`.
2. **Whether to update thresholds** — answer `y` to set new **warning** and
   **failure** percentages. The prompts default to the project's current values
   (75 / 50 for a brand-new project) and reject anything that isn't a whole number
   0–100 before writing them into `Helpers/config.json` with `sed`. Press Enter to
   keep the shown default.

At the end it checks that `python3` is installed and that the structure is complete.

To run the tracker afterwards (it uses paths relative to the project root):

```bash
cd attendance_tracker_2026
python3 attendance_checker.py
```

## Re-running: resume & recover

Running the script again with a name that already exists **does not reset your
config** — it picks up where you left off:

- **Directory exists** → the project is reused with its current `warning`, `failure`
  and `total_sessions` values kept as-is. Any missing files are filled back in.
- **Only the archive exists** → the archive is extracted to restore the project, then
  you can keep editing its thresholds.
- **Neither exists** → a fresh project is created from the source files.

This means updates and recovery always continue from the real state, not the defaults.

## Archive feature (Ctrl+C)

If you cancel with **Ctrl+C** while the script is running, the signal trap bundles the
current state of `attendance_tracker_{name}/` into
`attendance_tracker_{name}_archive.tar.gz` and then removes the partial directory, so
the workspace is never left half-built.

Inspect or recover the archive:

```bash
tar -tzf attendance_tracker_{name}_archive.tar.gz   # list contents
tar -xzf attendance_tracker_{name}_archive.tar.gz   # restore the directory
```

You can also just re-run `bash setup_project.sh` with the same name — it detects the
archive and restores it for you.
