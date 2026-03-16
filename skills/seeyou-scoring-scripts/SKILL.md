---
name: seeyou-scoring-scripts
description: Analyze, explain, and modify SeeYou competition scoring scripts written in Pascal Script, including daily or total scoring, class rule customizations, and use of the SeeYou data model (Task, Pilots, DayTag, etc.). Use when working with scoring formulas, rule tweaks, or debugging SeeYou script output.
---

# SeeYou Scoring Scripts

## Overview
Use this skill to understand and edit SeeYou scoring scripts (Pascal Script). Focus on mapping formulas to the SeeYou data model and keeping units and validity rules consistent.

## Workflow
1. Identify script type (day vs total) and locate the main scoring loop and outputs (Points, Info1..Info3).
2. Load the data model reference in `references/seeyou_data_model.md` and map each field used in the script to the SeeYou structures.
3. Trace the scoring pipeline:
   - Validation checks and early exits.
   - Class-specific parameters (min distance, 1000-point distance, handicaps).
   - Day factors (max distance/time, completion ratios).
   - Provisional score calculation and any normalization or compression.
   - Final points and penalties.
4. Verify units: distances in meters, times in seconds, speeds in m/s unless explicitly converted.
5. Ensure no divide-by-zero or invalid array access; preserve existing guard clauses.

## Editing Guidelines
- Keep outputs limited to fields SeeYou expects (e.g., `Pilots[i].Points`, `Info1..Info3`).
- If adding tags or parameters, parse them defensively (missing or malformed values should not crash).
- When changing class logic, update both minimum distance and 1000-point distance rules consistently.
- Preserve handicapping behavior unless the rule change explicitly requires altering it.

## Common Pitfalls
- Changing `UseHandicaps` without handling `Auto_Hcaps_on`.
- Using `Task.TaskTime` when the task is not AAT.
- Treating `Pilots[i].start` and `finish` as valid without checking for > 0 (or >= 0 where intended).

## References
- Data model and field definitions: `references/seeyou_data_model.md`.
