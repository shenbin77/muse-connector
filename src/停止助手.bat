@echo off
echo 正在停止 Hana 小助手和隧道...
powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { ($_.Name -match 'python' -and $_.CommandLine -like '*HanaAgent*win_agent.py*') -or ($_.Name -eq 'cloudflared.exe' -and $_.CommandLine -like '*cloudflared-winagent*') } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"
echo 已停止。
timeout /t 3 >nul
