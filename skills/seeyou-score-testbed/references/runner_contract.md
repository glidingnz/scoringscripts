# Pascal Script runner contract (JSON)

## Input
Top-level fields:
- `script_path`: string, path to the Pascal Script file.
- `day_tag`: string, passed to script as DayTag.
- `class_id`: string, SeeYou `ClassID`.
- `task`: object (see below).
- `pilots`: array of pilot objects (see below).
- `options`: object (optional):
  - `use_handicaps`: 0|1|2 (mirrors script constant if you want override support).

### task
- `total_dis_m`: number
- `task_time_s`: number (0 for racing task)
- `no_start_before_s`: number
- `points`: optional array of task points with `lon`, `lat`, `d_m`, `crs_deg`

### pilots[]
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

## Output
Top-level fields:
- `info1`: string
- `info2`: string
- `info3`: string
- `pilots`: array with at least:
  - `comp_id`: string
  - `points`: integer
  - `sstart_s`, `sfinish_s`, `sdis_m`, `sspeed_ms`: numbers (score sheet fields)
  - `warning`: string (if set by script)

## Notes
- Units: meters, seconds, m/s.
- Keep runner deterministic; no file I/O beyond the script itself.
