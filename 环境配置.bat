@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title ClassIsland 插件开发环境配置

set "MODE=%~1"
set "CHECK=0"
if /i "%MODE%"=="check" set "CHECK=1"

echo ==========================================
echo   ClassIsland 插件开发环境配置
echo ==========================================
if "%CHECK%"=="1" echo   [检查模式] 只检测，不安装任何东西
echo.

echo [1/6] 检测 .NET 8 SDK ...
set "DOTNET_OK=0"
set "DOTNET_EXE="
set "DOTNET_ROOT="
set "DOTNET_SDKVER="
call :probeDotnet "C:\dotnet-sdk"
call :probeDotnet "%ProgramFiles%\dotnet"
call :probeDotnet "%LOCALAPPDATA%\Microsoft\dotnet"
if "%DOTNET_OK%"=="0" (
  where dotnet >nul 2>nul && (
    dotnet --list-sdks > "%TEMP%\ci_sdks.txt" 2>nul
    findstr /b "8." "%TEMP%\ci_sdks.txt" >nul 2>nul && (set "DOTNET_OK=1" & set "DOTNET_EXE=dotnet")
  )
)
if "%DOTNET_OK%"=="1" (
  echo    OK .NET 8 SDK: %DOTNET_EXE%  %DOTNET_SDKVER%
) else (
  echo    缺失 .NET 8 SDK
  if "%CHECK%"=="0" winget install --id Microsoft.DotNet.SDK.8 -e --accept-source-agreements --accept-package-agreements
)
echo.
echo [2/6] 检测 Git ...
where git >nul 2>nul && (echo    OK 已安装 Git) || (
  echo    缺失 Git
  if "%CHECK%"=="0" winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
)

echo.
echo [3/6] 检测 Node.js ...
where node >nul 2>nul && (echo    OK 已安装 Node.js) || (
  echo    缺失 Node.js
  if "%CHECK%"=="0" winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements
)

echo.
echo [4/6] 检测 Python 3 + edge-tts ...
set "PY_OK=0"
where python >nul 2>nul && set "PY_OK=1"
if "%PY_OK%"=="1" (
  echo    OK 已安装 Python
  python -c "import edge_tts" >nul 2>nul && (echo    OK edge-tts 已安装) || (
    echo    缺失 edge-tts
    if "%CHECK%"=="0" python -m pip install --upgrade edge-tts
  )
) else (
  echo    缺失 Python
  if "%CHECK%"=="0" (
    winget install --id Python.Python.3.12 -e --accept-source-agreements --accept-package-agreements
    echo    装完后请重开终端并执行: python -m pip install edge-tts
  )
)

echo.
echo [5/6] 定位 ClassIsland ...
set "CI_ROOT="
if defined CLASSISLAND_DIR if exist "%CLASSISLAND_DIR%\ClassIsland.exe" set "CI_ROOT=%CLASSISLAND_DIR%"
if not defined CI_ROOT if exist "C:\classisland\ClassIsland.exe" set "CI_ROOT=C:\classisland"
if not defined CI_ROOT if exist "%LOCALAPPDATA%\ClassIsland\ClassIsland.exe" set "CI_ROOT=%LOCALAPPDATA%\ClassIsland"
if not defined CI_ROOT (
  echo    未找到 ClassIsland，请设置环境变量 CLASSISLAND_DIR 后重试
  goto :summary
)
echo    OK ClassIsland: %CI_ROOT%
set "CI_APP="
for /d %%d in ("%CI_ROOT%\app-*") do set "CI_APP=%%d"
if not defined CI_APP set "CI_APP=%CI_ROOT%"
echo    OK 依赖目录: %CI_APP%

echo.
echo [6/6] 校验编译所需 DLL ...
set "MISSING=0"
for %%f in (ClassIsland.Core.dll ClassIsland.Shared.dll Avalonia.Base.dll Avalonia.Controls.dll CommunityToolkit.Mvvm.dll SkiaSharp.dll System.Drawing.Common.dll Edge_tts_sharp.dll) do (
  if exist "%CI_APP%\%%f" (echo    OK %%f) else (echo    缺失 %%f & set /a MISSING+=1)
)
if "%MISSING%"=="0" (echo    全部就绪) else (echo    共 %MISSING% 个缺失，确认 ClassIsland 为 2.1.x)
> "%CD%\classisland.env" echo CLASSISLAND_DIR=%CI_ROOT%
>> "%CD%\classisland.env" echo CLASSISLAND_APP=%CI_APP%
>> "%CD%\classisland.env" echo DOTNET_EXE=!DOTNET_EXE!
>> "%CD%\classisland.env" echo DOTNET_ROOT=!DOTNET_ROOT!

:summary
echo.
echo ==========================================
echo   完成
echo ==========================================
echo   编译插件: dotnet build -c Release
echo   检查模式: 环境配置.bat check
echo.
if "%CHECK%"=="0" pause
endlocal
:probeDotnet
set "ROOT=%~1"
if not exist "%ROOT%\dotnet.exe" exit /b 1
for /f "delims=" %%v in ('dir /b /ad "%ROOT%\sdk\8.*" 2^>nul') do (
  set "DOTNET_OK=1"
  set "DOTNET_EXE=%ROOT%\dotnet.exe"
  set "DOTNET_ROOT=%ROOT%"
  set "DOTNET_SDKVER=%%v"
)
exit /b 0