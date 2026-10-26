@echo off
"%~dp0..\recomp-python\Scripts\python.exe" "%~dp0scripts\generate.py" %*
exit /b %errorlevel%
