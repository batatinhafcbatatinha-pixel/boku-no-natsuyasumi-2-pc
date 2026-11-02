@echo off
rem Headless Ghidra analysis of SCPS_150.26 (EE extension) and the function exports the generator reads.
setlocal
if not defined GHIDRA set "GHIDRA=C:\Users\dudua\Downloads\ghidra_12.1.4_PUBLIC_20260921\ghidra_12.1.4_PUBLIC"
if not exist "%GHIDRA%\support\analyzeHeadless.bat" (
  echo Ghidra not found at "%GHIDRA%". Set GHIDRA to your Ghidra folder.
  exit /b 1
)
if not exist "%~dp0ghidra" mkdir "%~dp0ghidra"
call "%GHIDRA%\support\analyzeHeadless.bat" "%~dp0ghidra" Boku2 -import "%~dp0game_files\SCPS_150.26" -overwrite ^
  -processor "r5900:LE:32:default" -analysisTimeoutPerFile 600 ^
  -scriptPath "%~dp0scripts" -postScript ExportPS2Functions.java "%~dp0config\ghidra.toml" "%~dp0config\ghidra-all-labels.csv"
if errorlevel 1 exit /b 1
call "%GHIDRA%\support\analyzeHeadless.bat" "%~dp0ghidra" Boku2 -process SCPS_150.26 -noanalysis -readOnly ^
  -scriptPath "%~dp0scripts" -postScript ExportBoku2FunctionsOnly.java "%~dp0config\ghidra-functions-only.csv"
exit /b %errorlevel%
