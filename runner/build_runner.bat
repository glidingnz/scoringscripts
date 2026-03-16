@echo off
REM Build script for FreePascal (fpc must be on PATH)
REM Outputs runner\bin\seeyou_runner.exe relative to this script

setlocal
set SCRIPT_DIR=%~dp0
set OUTDIR=%SCRIPT_DIR%bin
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

set PSSRC=%SCRIPT_DIR%vendor\pascalscript\Source
fpc -Mobjfpc -O2 -Fu"%PSSRC%" -FE"%OUTDIR%" "%SCRIPT_DIR%src\seeyou_runner.pas"
endlocal
