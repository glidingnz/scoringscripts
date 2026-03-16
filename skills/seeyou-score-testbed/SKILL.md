---
name: seeyou-score-testbed
description: Design and build a local test harness that simulates SeeYou scoring scripts using structured test cases (Task, Pilots, DayTag, class IDs) and expected outputs. Use when creating, running, or expanding tests for SeeYou competition scoring.
---

# SeeYou Score Testbed

## Overview
Use this skill to plan and implement a repeatable test rig for SeeYou Pascal Script scoring. The goal is to run a script against fixture data and compare points and info outputs to expected results. The default approach is a Node.js harness that calls a small Pascal Script runner process via JSON I/O.

## Workflow
1. Define the test case schema (see `references/testcase_schema.md`) and keep it versioned.
2. Populate fixtures from real contest days or synthetic edge cases; include expected `Points` per pilot and expected `Info1..Info3` if relevant.
3. Use the default execution strategy unless instructed otherwise:
   - Node.js harness + Pascal Script runner executable (Delphi/FPC) called via `child_process`.
   - Runner reads JSON input and emits JSON output (see `references/runner_contract.md`).
4. Implement the adapter that maps the schema into the script's global structures (`Task`, `Pilots`, etc.).
5. Run the harness and compare outputs; report diffs with pilot IDs and field names.

## Fixture Design Notes
- Include at least one case per class and per task type (AAT vs racing).
- Include edge cases: zero launches, invalid day thresholds, no finishers, buffer-zone starts.
- Store units explicitly in the fixture schema (meters, seconds, m/s).

## References
- Data model and field definitions: `references/seeyou_data_model.md`.
- Test case schema: `references/testcase_schema.md`.
- Runner I/O contract: `references/runner_contract.md`.
