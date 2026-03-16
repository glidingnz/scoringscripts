# SeeYou data model summary

Source: SeeYou competition scripts README.

## General notes
- Unless noted, numeric fields are doubles.
- Time fields are in seconds since midnight.

## TPilots fields (daily script)
- `sstart`, `sfinish`, `sdis`, `sspeed`: values shown on score sheets.
- `Points`: final points for the day.
- `PointString`: points as string.
- `Hcap`: handicap (1.0 if no handicaps).
- `Penalty`: point penalty.
- `start`, `finish`, `dis`, `speed`: calculated flight values.
- `tstart`, `tfinish`, `tdis`, `tspeed`: task adjusted values.
- `takeoff`, `landing`, `phototime`: takeoff/landing/photo times.
- `isHC`: boolean flag for hors concours.
- `FinishAlt`, `DisToGoal`: finish altitude and distance to goal.
- `Tag`: pilot tag string.
- `Leg[]`, `LegT[]`: arrays of `TLeg` for actual and task legs.
- `Warning`: warning string for pilot.
- `CompID`: competitor id string.
- `PilotTag`: second tag string.
- `user_str1`, `user_str2`, `user_str3`: user strings.
- `td1`, `td2`, `td3`: temporary doubles.
- `Markers[]`: array of `TMarker`.
- `PotStarts[]`: array of potential starts (integers).

## TPilots fields (total script)
- `Total`: total points.
- `TotalString`: total points string.
- `DayPts[]`: array of per-day points.
- `DayPtsString[]`: array of per-day points strings.

## Task fields
- `TotalDis`: total task distance.
- `TaskTime`: task time for AAT.
- `NoStartBeforeTime`: start opening time.
- `Point[]`: array of `TTaskPoint`.
- `ClassID`: class id enum.
- `ClassName`: class name string.

## ClassID enum values
- `unknown`, `club`, `standard`, `15_meter`, `open`, `18_meter`, `double_seater`, `13_5_meter`.

## TTaskPoint fields
- `lon`, `lat`: coordinates.
- `d`, `crs`: distance and course to previous point.
- `td1`, `td2`, `td3`: temp doubles.

## TFix fields
- `Tsec`: time (integer).
- `AltQnh`, `AltQne`: altitudes.
- `Gsp`: ground speed.
- `DoT`, `Cur`, `Vol`, `Enl`, `Mop`: sensor fields.
- `EngineOn`: boolean engine state.

## TLeg fields
- `start`, `finish`: leg start/finish times.
- `d`, `crs`: leg distance and course.

## TMarker fields
- `Tsec`: time.
- `Msg`: message.
- `info1`, `info2`: strings.
- `DatTag`: data tag.
- `ShowMessage`: boolean.
