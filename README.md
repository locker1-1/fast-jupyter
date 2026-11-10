# fast-jupyter

> A plugin for quickly launching Jupyter Notebook

在 Windows 资源管理器的右键菜单里加一项「**在此处启动 Jupyter Notebook**」——
右键任意文件夹就能以它为工作目录启动 Jupyter，并自动打开浏览器，不用再开命令行敲
`cd` / `jupyter notebook`。

## 功能

- **文件夹上**右键、**文件夹空白处**右键，都会出现菜单项
- 以该文件夹为工作目录启动 Jupyter Notebook，自动打开浏览器
- 自动查找本机的 Jupyter，依次尝试：
  1. `PATH` 里的 `jupyter-notebook.exe`
  2. 常见的 Anaconda / Miniconda / Python 安装位置
     （`E:\anaconda`、`D:\anaconda`、`C:\ProgramData\Anaconda3`、
     `%USERPROFILE%\anaconda3`、`%LOCALAPPDATA%\Programs\Python\Python3xx` …）
  3. 最后退回 `python -m jupyter notebook`

  所以换电脑、换盘符、重装 Python 都不用改脚本。
- 如果 Jupyter 来自 Anaconda / Miniconda，会自动把它的 `Library\bin` 等 DLL 目录
  加进 PATH（避免 `ImportError: DLL load failed while importing _ssl`）

## 安装

双击 `install.bat` 即可。

- 只写入 `HKEY_CURRENT_USER`，**不需要管理员权限**
- 安装时自动使用插件当前所在目录，插件放在哪都能用
- **换电脑时把整个文件夹拷过去，再双击一次 `install.bat` 就行**
- 写入后菜单立刻生效（个别情况下需重启一次「Windows 资源管理器」）

## 卸载

双击 `uninstall.bat`。

## 文件说明

| 文件 | 说明 |
|---|---|
| `launch_jupyter.bat` | 真正的启动脚本，注册表指向它 |
| `install.bat` / `uninstall.bat` | 入口，只负责调用 PowerShell 脚本 |
| `install.ps1` | 实际写入 / 删除注册表项（`-Uninstall` 为卸载） |

## 注册表改动位置

```
HKCU\Software\Classes\Directory\shell\LaunchJupyterNotebook
HKCU\Software\Classes\Directory\Background\shell\LaunchJupyterNotebook
```

## 换成 Jupyter Lab

把 `launch_jupyter.bat` 里的 `jupyter-notebook.exe` 改成 `jupyter-lab.exe`
（PATH 查找和目录查找两处），再把 `python -m jupyter notebook` 改成
`python -m jupyter lab`。

## 常见问题：`_ssl` DLL 加载失败

症状（Anaconda 环境常见，窗口一闪就退出，或者退出前打印一长串 Traceback）：

```
File "...\anaconda3\lib\site-packages\notebook\notebookapp.py", line 60, in <module>
    from tornado import httpserver
...
File "...\anaconda3\lib\ssl.py", line 98, in <module>
    import _ssl
ImportError: DLL load failed while importing _ssl: 找不到指定的模块。
```

原因：Anaconda 的 `_ssl.pyd` 依赖 `Library\bin` 下的 OpenSSL DLL 和 VC++ 运行库。
从「开始菜单 → Anaconda Prompt」启动时 PATH 里有这些目录，直接调用就会缺。

`launch_jupyter.bat` 现在会从 Jupyter 的位置反推 conda 根目录，把
`Library\bin`、`Library\mingw-w64\bin`、`Library\usr\bin`、`DLLs` 加进 PATH，
并设置 `CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1`，一般到这一步就好了。

还是不行，按顺序排查（**断网也能做**）：

1. 打开「Anaconda Prompt」，直接执行 `jupyter notebook`：
   - 能正常打开 → 就是 PATH 问题，用最新版 `launch_jupyter.bat` 即可；
   - 同样报错 → Anaconda 本身不完整，继续往下看。
2. 确认下面三个文件存在：
   ```
   C:\Users\<用户名>\anaconda3\DLLs\_ssl.pyd
   C:\Users\<用户名>\anaconda3\Library\bin\libssl-1_1-x64.dll
   C:\Users\<用户名>\anaconda3\Library\bin\libcrypto-1_1-x64.dll
   ```
   缺哪个就从**同版本** Anaconda 的机器上拷同名文件过去（版本不同可能报别的 ImportError）。
3. 如果报错里出现 `VCRUNTIME140.dll`（或 140_1），装
   Microsoft Visual C++ 2015-2022 运行库（x64），内网用离线安装包。
4. 环境已经乱了（例如整个 `anaconda3` 是从别的电脑直接拷过来的）：
   卸载重装 Anaconda 即可，装到 `C:\Users\<用户名>\anaconda3` 以外也行——
   脚本会自动在 PATH 和常见安装目录里找。

## 注意事项

- 目录可以随意移动，但**移动后要重新双击 `install.bat`**（注册表里记的是绝对路径）。
- 编码约定（改动文件时请保持）：
  - `launch_jupyter.bat`：**UTF-8 无 BOM + CRLF**，首行 `chcp 65001`，
    这样在中英文系统、以及开了「Beta: 使用 Unicode UTF-8」的系统上都能正常显示中文。
  - `install.ps1`：**UTF-8 带 BOM + CRLF**，PowerShell 5.1 才能正确识别中文。
  - `install.bat` / `uninstall.bat`：纯 ASCII，不涉及中文，避免代码页问题。
- 中文菜单文字**不要写回 `.bat` 或 `.reg`**：cmd.exe 会按当前代码页解码批处理，
  在 UTF-8 代码页的机器上写进注册表会变乱码（之前就是这样坏的）。
