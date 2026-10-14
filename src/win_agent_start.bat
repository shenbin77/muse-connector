@echo off
chcp 65001 >nul
cd /d "%~dp0"

:: 找 Python（优先 python，其次 py 启动器）
set "PYEXE="
where python >nul 2>&1 && set "PYEXE=python"
if not defined PYEXE (
  where py >nul 2>&1 && set "PYEXE=py -3"
)
if not defined PYEXE (
  echo [错误] 没找到 Python。请安装 Python 3.8+（安装时勾选 Add python.exe to PATH）。
  pause & exit /b 1
)
if not exist win_agent.py (
  echo [错误] win_agent.py 不在当前目录。
  echo        请把 win_agent.py 和本文件一起放到 D:\抖音直播\_agent\ 里再双击。
  pause & exit /b 1
)

:: 后台启动小助手（token 会写入 D:\抖音直播\_agent\token.txt）
start "Hana小助手-勿关" %PYEXE% win_agent.py
echo 正在启动小助手，请稍候...

:: 轮询 token.txt（最长 20 秒）
set "TOKEN="
for /L %%i in (1,1,20) do (
  if exist token.txt (
    for /f "usebackq delims=" %%t in ("token.txt") do set "TOKEN=%%t"
    if defined TOKEN goto :ok
  )
  timeout /t 1 /nobreak >nul
)
:ok
if not defined TOKEN (
  echo [错误] 20 秒仍没读到 token.txt，请看「Hana小助手-勿关」窗口里的报错。
  pause & exit /b 1
)

:: 复制到剪贴板（无换行）
powershell -NoProfile -Command "Set-Clipboard -Value ((Get-Content token.txt -Raw).Trim())"

echo.
echo ============================================================
echo  小助手已启动，Token 已自动复制到剪贴板：
echo  %TOKEN%
echo.
echo  直接粘贴（Ctrl+V）发给 Hana 即可。
echo  保持「Hana小助手-勿关」窗口开着，不要关闭。
echo ============================================================
pause
