@echo off
setlocal
set "BIN_DIR=%~dp0build\native\ps2recomp\ps2xRuntime"
if exist "%~dp0build-location.txt" set /p BIN_DIR=<"%~dp0build-location.txt"
if not exist "%BIN_DIR%\ps2EntryRunner.exe" exit /b 1
cd /d "%~dp0"
"%BIN_DIR%\ps2EntryRunner.exe" "%~dp0game_files\SCPS_150.26"
exit /b %errorlevel%
