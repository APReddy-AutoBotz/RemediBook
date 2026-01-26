@echo off
setlocal
set "_NT_SYMBOL_PATH="
set "_NT_ALT_SYMBOL_PATH="
set "DETOURS_LOG_FILE="
flutter build windows %*
endlocal
