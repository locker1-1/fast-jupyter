param([switch]$Uninstall)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$bat  = Join-Path $root 'launch_jupyter.bat'
$keys = @(
    'HKCU:\Software\Classes\Directory\shell\LaunchJupyterNotebook',
    'HKCU:\Software\Classes\Directory\Background\shell\LaunchJupyterNotebook'
)

if ($Uninstall) {
    foreach ($k in $keys) {
        if (Test-Path $k) { Remove-Item $k -Recurse -Force }
    }
    Write-Host ''
    Write-Host '  已删除「在此处启动 Jupyter Notebook」右键菜单项。'
    Write-Host ''
    return
}

if (-not (Test-Path $bat)) {
    Write-Host ''
    Write-Host '  [错误] 没有找到 launch_jupyter.bat'
    Write-Host '  请把 install.bat、uninstall.bat、install.ps1 和 launch_jupyter.bat 放在同一个文件夹里。'
    Write-Host ''
    exit 1
}

$iconCandidates = @(
    'E:\anaconda\Menu\jupyter.ico',
    'D:\anaconda\Menu\jupyter.ico',
    'C:\anaconda\Menu\jupyter.ico',
    (Join-Path $env:ProgramData 'Anaconda3\Menu\jupyter.ico'),
    (Join-Path $env:ProgramData 'Miniconda3\Menu\jupyter.ico'),
    (Join-Path $env:USERPROFILE 'anaconda3\Menu\jupyter.ico'),
    (Join-Path $env:USERPROFILE 'miniconda3\Menu\jupyter.ico')
)
$icon = $iconCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $icon) {
    $exe = Get-Command 'jupyter-notebook.exe' -ErrorAction SilentlyContinue
    if ($exe) { $icon = $exe.Source + ',0' } else { $icon = $bat + ',0' }
}

$label = '在此处启动 Jupyter Notebook'

foreach ($k in $keys) {
    New-Item -Path $k -Force | Out-Null
    Set-ItemProperty -Path $k -Name '(default)' -Value $label
    Set-ItemProperty -Path $k -Name 'Icon' -Value $icon

    $commandKey = Join-Path $k 'command'
    New-Item -Path $commandKey -Force | Out-Null
    if ($k -like '*\Background\*') {
        $argument = '%V'
    } else {
        $argument = '%1'
    }
    Set-ItemProperty -Path $commandKey -Name '(default)' -Value ('"' + $bat + '" "' + $argument + '"')
}

Write-Host ''
Write-Host '  安装完成，右键菜单已写入（只改当前用户，不需要管理员权限）。'
Write-Host '  现在右键文件夹，或在文件夹空白处右键，就能看到'
Write-Host '  「在此处启动 Jupyter Notebook」。'
Write-Host ''
Write-Host '  如果菜单没有立刻出现，重启一次「Windows 资源管理器」即可。'
Write-Host ''
