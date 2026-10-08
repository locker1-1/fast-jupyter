# fast-jupyter

> A plugin for quickly launching Jupyter Notebook

在 Windows 资源管理器的右键菜单里加一项「**在此处启动 Jupyter Notebook**」——
右键任意文件夹就能以它为工作目录启动 Jupyter，并自动打开浏览器，不用再开命令行敲
`cd` / `jupyter notebook`。

## 功能

- **文件夹上**右键、**文件夹空白处**右键，都会出现菜单项
- 以该文件夹为工作目录启动 Jupyter Notebook，自动打开浏览器
- 默认使用 Anaconda 自带的 Jupyter：
  `E:\anaconda\Scripts\jupyter-notebook.exe`
  （该环境已装齐 pandas / numpy / matplotlib / scikit-learn / torch）

## 安装

双击 `install.reg`，确认即可。

- 只写入 `HKEY_CURRENT_USER`，**不需要管理员权限**
- 写入后菜单立刻生效（个别情况下需重启一次「Windows 资源管理器」）

## 卸载

双击 `uninstall.reg`。

## 文件说明

| 文件 | 说明 |
|---|---|
| `launch_jupyter.bat` | 真正的启动脚本，注册表指向它 |
| `install.reg` | 安装右键菜单 |
| `uninstall.reg` | 卸载右键菜单 |

## 注册表改动位置

```
HKCU\Software\Classes\Directory\shell\LaunchJupyterNotebook
HKCU\Software\Classes\Directory\Background\shell\LaunchJupyterNotebook
```

## 换成 Jupyter Lab

把 `launch_jupyter.bat` 里那一行的 `jupyter-notebook.exe` 改成 `jupyter-lab.exe` 即可。

## 注意事项

- **本目录请勿随意移动**：`install.reg` 里是绝对路径。如果移动了，
  要同步改掉里面的路径并重新导入 `install.reg`。
- `launch_jupyter.bat` 的编码是 **GBK + CRLF 换行**。这是 cmd.exe 的要求：
  如果不是 CRLF 换行，多字节中文会被解析错乱（已踩过坑）。
- `.reg` 文件是 **UTF-16LE** 编码，regedit 需要这个编码才能正确读取中文。
