# scoringscripts
Gliding NZ Scoring Scripts

For use with "SeeYou" Competition Scoring

Provides the "Aternative" Scoring algorithm descibed in FAI Sporting Code for Gliders and Motor Gliders

See the official guide   
https://naviter.com/2019/06/scoring-scripts-github/


IMPORTANT !!!!!!!!!!

The Class Names in SeeYou Soaringspot must be correctly configured so that the script knows how to apply minimum distances and handicaps

When setting up the contest on SoaringSpot, Rename the existing SoaringSpot Contest Classes as follows .....


'club'      =   'Club'                  //  NZ Club Class   
'open'      =   'Open'                  //  NZ Open Class   
'standard'  =   'Racing'                //  NZ Racing Class   
'13_5_meter' =  'Sports'                //  NZ Sportsa (Novice) Class   
'18_meter'  =   '18M Unhandicapped'     //  Unofficial Class (unhandicapped)   
'15_meter'  =   'Racing Unhandicapped'  //  Unofficial Class (unhandicapped)   
'unknown'   =   'Open Unhandicapped'    //  Unofficial Class (unhandicapped)   
'double_seater'  = '2 Seater'           //  Unofficial Class (uncandicapped)   

## Local Test Harness (FreePascal + Node.js)

This repo now includes a local scoring test harness to run the Pascal Script against fixture data.

### What was added
- `testbed/run.js`: Node.js harness that feeds JSON fixtures into a runner and diffs outputs.
- `testbed/fixtures/nz_annex_a_invented.json`: Invented fixture data matching the script inputs.
- `runner/src/seeyou_runner.pas`: FreePascal runner scaffold (JSON in/out).
- `runner/build_runner.bat`: Build script for the runner.
- `skills/`: Local Codex skills and references used to document the SeeYou data model and test schema.

### How to use
1. Install FreePascal and make sure `fpc` is on PATH.
2. Fetch Pascal Script sources (gitignored in this repo):
   ```powershell
   git clone https://github.com/remobjects/pascalscript runner\vendor\pascalscript
   ```
   If you hit a type conversion error in `uPSCompiler.pas`, replace `TempDouble := tbtDouble(p^.textended);` with `TempDouble := p^.textended;`.
3. Build the runner:
   ```powershell
   runner\build_runner.bat
   ```
4. Run the harness from the repo root:
   ```powershell
   node testbed\run.js testbed\fixtures\nz_annex_a_invented.json --runner runner\bin\seeyou_runner.exe --script "New Zealand Annex A scoring 2020.pas"
   ```

### Current limitations
- The runner now executes the Pascal Script engine.
- `expected.points` in fixtures is currently empty. Fill these in to get pass/fail diffs.
