@echo off
cd /d "%~dp0"

set "PYWEXE=C:\Users\Administrator\AppData\Local\Programs\Python\Python311\pythonw.exe"
if not exist "%PYWEXE%" (
  echo [错误] 没找到 pythonw.exe
  pause & exit /b 1
)

:: ---- 小助手：已运行就跳过 ----
netstat -ano | findstr ":18789" | findstr "LISTENING" >nul 2>&1
if %errorlevel%==0 goto agent_ok

echo [1/2] 后台启动 Hana 小助手（无窗口）...
start "" "%PYWEXE%" "%~dp0win_agent.py"
timeout /t 2 /nobreak >nul
netstat -ano | findstr ":18789" | findstr "LISTENING" >nul 2>&1
if %errorlevel%==0 goto agent_ok
echo [错误] 小助手启动失败，详情看 D:\HanaAgent\agent.log
pause & exit /b 1

:agent_ok
echo [小助手] 已就绪（18789 端口监听中）

:: ---- 隧道：已运行就跳过 ----
powershell -NoProfile -Command "if (Get-CimInstance Win32_Process -Filter \"Name='cloudflared.exe'\" | Where-Object { $_.CommandLine -like '*cloudflared-winagent*' }) { exit 0 } else { exit 1 }" >nul 2>&1
if %errorlevel%==0 goto tunnel_ok

echo [2/2] 后台启动 cloudflared 隧道（无窗口）...
powershell -NoProfile -WindowStyle Hidden -Command "Start-Process -FilePath 'D:\HanaAgent\cloudflared.exe' -ArgumentList 'tunnel --config D:\HanaAgent\cloudflared-winagent.yml --edge-ip-version 4 run' -WindowStyle Hidden -RedirectStandardError 'D:\HanaAgent\cloudflared-live.log'"
goto tunnel_done

:tunnel_ok
echo [隧道] 已在运行

:tunnel_done
echo.
echo ============================================================
echo   已后台隐藏启动（没有任何窗口）
echo   固定网址: https://winagent.clawskill.cloud
echo   Token:    D:\HanaAgent\token.txt
echo   日志:     D:\HanaAgent\agent.log / cloudflared-live.log
echo.
echo   停止服务：双击桌面「Hana停止」
echo   重启电脑后：双击桌面「Hana远程助手」即可恢复
echo ============================================================
echo.
echo 6 秒后本窗口自动关闭...
timeout /t 6 >nul
