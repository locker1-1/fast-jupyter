@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Jupyter Notebook

rem 右键菜单会把选中的文件夹作为第 1 个参数传进来；直接双击时没有参数
set "TARGET=%~1"
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

rem 先在 PATH 里找 jupyter-notebook.exe
set "JUPYTER="
for %%P in (jupyter-notebook.exe) do if not defined JUPYTER set "JUPYTER=%%~$PATH:P"

rem PATH 里没有就查常见的 Anaconda / Miniconda / Python 安装位置
if not defined JUPYTER (
    for %%D in (
        "E:\anaconda"
        "D:\anaconda"
        "C:\anaconda"
        "C:\ProgramData\Anaconda3"
        "C:\ProgramData\Miniconda3"
        "C:\ProgramData\miniconda3"
        "%USERPROFILE%\anaconda3"
        "%USERPROFILE%\miniconda3"
        "%LOCALAPPDATA%\anaconda3"
        "%LOCALAPPDATA%\miniconda3"
        "%LOCALAPPDATA%\Programs\Python\Python38"
        "%LOCALAPPDATA%\Programs\Python\Python39"
        "%LOCALAPPDATA%\Programs\Python\Python310"
        "%LOCALAPPDATA%\Programs\Python\Python311"
        "%LOCALAPPDATA%\Programs\Python\Python312"
        "%LOCALAPPDATA%\Programs\Python\Python313"
    ) do (
        if not defined JUPYTER if exist "%%~D\Scripts\jupyter-notebook.exe" set "JUPYTER=%%~D\Scripts\jupyter-notebook.exe"
    )
)

rem 如果 Jupyter 来自 Anaconda / Miniconda，把它自己的 DLL 目录加进 PATH。
rem 否则 _ssl / libcrypto / libssl 这类 C 扩展会报
rem ImportError: DLL load failed while importing _ssl
if defined JUPYTER for %%I in ("%JUPYTER%") do set "JSCRIPTS=%%~dpI"
if defined JSCRIPTS for %%I in ("%JSCRIPTS%..") do set "JROOT=%%~fI"
if defined JROOT if exist "%JROOT%\Library\bin" (
    set "PATH=%JROOT%\Library\bin;%JROOT%\Library\mingw-w64\bin;%JROOT%\Library\usr\bin;%JROOT%\DLLs;%JROOT%;%JROOT%\Scripts;%PATH%"
    set "CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1"
)
if defined JROOT if exist "%JROOT%\Library\bin" if not exist "%JROOT%\Library\bin\libssl*.dll" (
    echo.
    echo   [警告] 这个 Anaconda 里缺少 OpenSSL 的 DLL（libssl*.dll），
    echo   Jupyter 很可能会报 ImportError: DLL load failed while importing _ssl。
    echo   处理方法见 README 的「_ssl DLL 加载失败」一节。
    echo.
)

if defined JUPYTER goto run_exe

where python >nul 2>nul
if not errorlevel 1 goto run_python

echo.
echo   [错误] 没有找到 Jupyter Notebook。
echo   请先安装：pip install notebook
echo   装好后重新右键即可。
echo.
pause
exit /b 1

:run_exe
echo ============================================================
echo   Jupyter Notebook
echo   工作目录：%CD%
echo   启动程序：%JUPYTER%
echo   关闭本窗口或按 Ctrl+C 可停止服务
echo ============================================================
echo.
"%JUPYTER%"
goto finished

:run_python
echo ============================================================
echo   Jupyter Notebook（通过 python -m jupyter notebook 启动）
echo   工作目录：%CD%
echo   关闭本窗口或按 Ctrl+C 可停止服务
echo ============================================================
echo.
python -m jupyter notebook

:finished
echo.
echo ============================================================
echo   Jupyter Notebook 已退出
echo ============================================================
pause
