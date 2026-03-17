# New Zealand Annex A scoring 2020.pas — Input Variables

This list includes only variables that are *not initialized in the script* and are therefore supplied by the hosting system (SeeYou). Descriptions come from `skills/seeyou-scoring-scripts/references/seeyou_data_model.md`. Anything not described there is marked **undocumented**.

## General units
- Times: seconds since midnight.
- Distances: meters.
- Speeds: meters per second.

## Top-level inputs
| Variable | Description |
| --- | --- |
| `DayTag` | undocumented |
| `Task` | SeeYou task object (fields listed below) |
| `Pilots[]` | Array of pilot objects (fields listed below) |

## Outputs (for clarity)
| Variable | Description |
| --- | --- |
| `Info1` | output text shown to user |
| `Info2` | output text shown to user |
| `Info3` | output text shown to user |

## Task fields used
| Variable | Description |
| --- | --- |
| `Task.TaskTime` | task time for AAT |
| `Task.NoStartBeforeTime` | start opening time |
| `Task.ClassID` | class id enum |

## Pilot fields used (from `Pilots[i]`)
| Variable | Description |
| --- | --- |
| `Hcap` | handicap (1.0 if no handicaps) |
| `isHC` | boolean flag for hors concours |
| `dis` | calculated flight distance |
| `takeoff` | takeoff time |
| `start` | calculated flight start time |
| `finish` | calculated flight finish time |
| `speed` | calculated flight speed |
| `sfinish` | value shown on score sheets |
| `Penalty` | point penalty |
