@echo off
setlocal EnableExtensions
title Jupyter Notebook

rem 右键菜单会把选中的文件夹作为第 1 个参数传进来，%~1 会自动去掉外层引号
set "TARGET=%~1"

rem 不带参数时（例如直接双击本文件）就在当前目录启动
if not defined TARGET set "TARGET=%CD%"

if not exist "%TARGET%\" (
    echo.
    echo   [错误] 找不到文件夹：
    echo   %TARGET%
    echo.
    pause
    exit /b 1
)

cd /d "%TARGET%"
if errorlevel 1 (
    echo.
    echo   [错误] 无法进入文件夹：
    echo   %TARGET%
    echo.
    pause
    exit /b 1
)

echo ============================================================
echo   正在启动 Jupyter Notebook
echo   工作目录：%CD%
echo   关闭本窗口 或 按 Ctrl+C 可停止服务
echo ============================================================
echo.

"E:\anaconda\Scripts\jupyter-notebook.exe"

echo.
echo ============================================================
echo   Jupyter Notebook 已退出
echo ============================================================
pause
