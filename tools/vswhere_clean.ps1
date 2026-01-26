#!/usr/bin/env pwsh
# Clean vswhere wrapper that filters Detours debug output
param([Parameter(ValueFromRemainingArguments=$true)]$args)

$vswhereReal = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"

# Run vswhere with stderr redirected to filter out Detours pollution
$output = & $vswhereReal @args 2>$null

# Return clean output
Write-Output $output
