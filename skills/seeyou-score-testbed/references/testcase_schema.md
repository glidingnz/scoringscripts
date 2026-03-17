# SeeYou scoring test case schema (suggested)

This schema is a minimal, practical subset for daily scoring scripts.

## Top-level
- `id`: string
- `description`: string
- `class_id`: SeeYou `ClassID`
- `day_tag`: string (contents of DayTag)
- `task`: object
- `pilots`: array of pilot objects
- `expected`: object with expected outputs

## task
- `total_dis_m`: number
- `task_time_s`: number (0 for racing task)
- `no_start_before_s`: number
- `points`: optional array of task points with `lon`, `lat`, `d_m`, `crs_deg`

## pilots[] (minimum subset)
- `comp_id`: string
- `is_hc`: boolean
- `hcap`: number
- `penalty`: number
- `takeoff_s`: number
- `start_s`: number
- `finish_s`: number
- `dis_m`: number
- `speed_ms`: number
- `sfinish_s`: number (nonzero marks finisher in many scripts)

## expected
- `points`: map of `comp_id` to expected integer points
- `info1`: optional string
- `info2`: optional string
- `info3`: optional string

## Units
- Distances: meters
- Times: seconds since midnight
- Speeds: meters per second
