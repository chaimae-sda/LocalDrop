@echo off
setlocal
cd /d "%~dp0"
python -B tool\demo_web.py
if errorlevel 1 pause
