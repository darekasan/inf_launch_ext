# INFINITASのレジストリ インストール先の取得に使う
$InfRegistry = "HKLM:\SOFTWARE\KONAMI\beatmania IIDX INFINITAS"

# ゲーム本体のパス 通常はレジストリから取得
#$InfPath = "C:\Games\beatmania IIDX INFINITAS"
$InfPath = Get-ItemPropertyValue -LiteralPath $InfRegistry -Name "InstallDir"
$InfExe = Join-Path $InfPath "game\app\bm2dx.exe"
$InfLauncher = Join-Path $InfPath "launcher\modules\bm2dx_launcher.exe"

# bm2dxinf:// のレジストリ
$InfOpen = "HKCR:bm2dxinf\shell\open\command\"

# このスクリプトのフルパス
$ScriptPath = $MyInvocation.MyCommand.Path

# 引数を指定しなかったときにレジストリ変更
if ([string]::IsNullOrEmpty($Args[0])) {
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
    $val = Get-ItemPropertyValue -LiteralPath $InfOpen -Name "(default)"

    echo("currently command: " + $val)
    echo ""
    echo("script path: " + $ScriptPath)
    echo("game path: " + $InfPath)
    echo ""
    
    echo "0 : revert to default"
    echo "1 : set to this script path"
    echo "3 : copy script file to game directory and set to new script path (recommended)"
    $num = Read-Host "number->"

    switch ($num) {
        0 {
            $val = """${InfLauncher}"" ""%1"""
        }
        1 {
            $val = """powershell"" ""-file"" ""${ScriptPath}"" ""%1"""
        }
        3 {
            $NewScriptPath = $InfPath+"\inf_launch_ext.ps1"
            Copy-Item $ScriptPath $NewScriptPath
            $val = """powershell"" ""-file"" ""${NewScriptPath}"" ""%1"""
        }
        Default {
            exit
        }
    }
    Set-ItemProperty $InfOpen -name "(default)" -value $val
    echo "done. Press enter key to exit."
    Read-Host
    exit
}

# ゲーム本体に渡す引数リスト
$InfArgs = @()

# 引数からトークンを拾う
$Args[0] -match "tk=(.{64})" | Out-Null
$InfArgs += "-t"
$InfArgs += $Matches[1]

# トライアルモードなら--trialをつける
if ($Args[0].Contains("trial")) {
    $InfArgs += "--trial"
}

echo "Please select option."
echo "0 : Launcher"
echo "1 : Normal"
echo "2 : Normal + window mode"
echo "3 : ASIO"
echo "4 : ASIO + window mode"

$num = Read-Host "number->"

switch ($num) {
    0 {
        Start-Process -FilePath $InfLauncher -ArgumentList $arg
        exit
    }
    1 {

    }
    2 {
        $InfArgs += "-w"
    }
    3 {
        $InfArgs += "--asio"
    }
    4 {
        $InfArgs += "-w"
        $InfArgs += "--asio"
    }
    Default {
        exit
    }
}

# INFINITASを起動
Start-Process -FilePath $InfExe -WorkingDirectory $InfPath -ArgumentList $InfArgs
