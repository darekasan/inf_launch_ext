# INFINITASのレジストリ インストール先の取得に使う
$InfRegistry = "HKLM:\SOFTWARE\KONAMI\beatmania IIDX INFINITAS"

# ゲーム本体のパス 通常はレジストリから取得
#$InfPath = "C:\Games\beatmania IIDX INFINITAS\"
$InfPath = Get-ItemPropertyValue -LiteralPath $InfRegistry -Name "InstallDir"
$InfExe = Join-Path $InfPath "\game\app\bm2dx.exe"
$InfLauncher = Join-Path $InfPath "\launcher\modules\bm2dx_launcher.exe"
cd $InfPath | Out-Null

# bm2dxinf:// のレジストリ
$InfOpen = "HKCR:bm2dxinf\shell\open\command\"

# このスクリプトのフルパス
$ScriptPath = $MyInvocation.MyCommand.Path

# 設定ファイル
$ConfigJson = Join-Path $PSScriptRoot "config.json"

# InfProxy用argsファイル
$InfProxyArgs = Join-Path $InfPath "args.txt"

# InfProxy.exeのパス
$InfProxyPath = Join-Path $InfPath "InfProxy.exe"
$InfProxySrcPath = Join-Path $InfPath "InfProxy.cs"

$Config = @{
    "Option"="0"
    "WindowWidth"="1280"
    "WindowHeight"="720"
    "WindowPositionX"="0"
    "WindowPositionY"="0"
    "Borderless"=$false
    "SteamUrl"="steam://rungameid/"
}

# ウィンドウスタイル（調べてもよくわかんなかった）
$WSDefault = 348651520
$WSBorderless = 335544320

# Win32API関数の定義
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class Win32Api {
        [DllImport("user32.dll")]
        public static extern int MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

        [DllImport("user32.dll")]
        public static extern int SetWindowLong(IntPtr hWnd, int nIndex, long dwLong);

        [DllImport("user32.dll")]
        public static extern long GetWindowLong(IntPtr hWnd, int nIndex);

        [DllImport("user32.dll")]
        internal static extern bool GetWindowRect(IntPtr hwnd, out RECT lpRect);

        [DllImport("user32.dll")]
        internal static extern bool GetClientRect(IntPtr hwnd, out RECT lpRect);

        [StructLayout(LayoutKind.Sequential)]
		internal struct RECT
		{
			public int left, top, right, bottom;
        }
        
        // 外枠の大きさを考慮したウィンドウサイズ変更
        public static void MoveWindow2(IntPtr hndl, int x, int y, int w, int h, bool isBl){
            if(isBl){
                MoveWindow(hndl, x, y, w, h, true);
            }else{
                RECT cRect = new RECT();
                RECT wRect = new RECT();

                GetClientRect(hndl, out cRect);
                GetWindowRect(hndl, out wRect);

                int cWidth = cRect.right - cRect.left;
                int cHeight = cRect.bottom - cRect.top;

                int wWidth = wRect.right - wRect.left;
                int wHeight = wRect.bottom - wRect.top;

                int newW = w + (wWidth - cWidth);
                int newH = h + (wHeight - cHeight);

                MoveWindow(hndl, x, y, newW, newH, true);
            }

        }
        
    }
"@


$InfProxySrc = @"
using System;
using System.Diagnostics;
using System.IO;
using Microsoft.Win32;

namespace InfProxy
{
    internal class Program
    {
        static void Main(string[] args)
        {
            var installDir = Registry.GetValue(@"HKEY_LOCAL_MACHINE\SOFTWARE\KONAMI\beatmania IIDX INFINITAS", "InstallDir", "").ToString();
            var myArgs = File.ReadAllText(installDir + "args.txt");

            var psi = new ProcessStartInfo();
            psi.Arguments = string.Format(@"-file ""{0}inf_launch_ext.ps1"" {1}", installDir, myArgs);
            psi.WorkingDirectory = installDir;
            psi.FileName = string.Format("PowerShell.exe");
            Process.Start(psi);
        }
    }
}
"@

function Save-Config() {
    $Config | ConvertTo-Json | Out-File -FilePath $ConfigJson -Encoding utf8
}

function Start-Exe($exe, $workDir, $arg){
    $info = New-Object System.Diagnostics.ProcessStartInfo
    $info.FileName = $exe
    $info.WorkingDirectory = $workDir
    $info.Arguments = $arg
    $info.UseShellExecute = $false

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $info
    
    $p.Start() | Out-Null

    return $p
}

function Switch-Borderless($isBl){
    if ($isBl) {
        [Win32Api]::SetWindowLong($handle, -16, $WSBorderless) | Out-Null
    }else{
        [Win32Api]::SetWindowLong($handle, -16, $WSDefault) | Out-Null
    }
}


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
    echo "1 : copy script file to game directory and set to new script path"
    $num = Read-Host "number->"

    switch ($num) {
        0 {
            $val = """${InfLauncher}"" ""%1"""
        }
        1 {
            $NewScriptPath = Join-Path $InfPath "inf_launch_ext.ps1"
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

# ゲームを起動するためのもの　ここから
# 設定ファイルを読み込む
if(Test-Path $ConfigJson){
    $Config = @{}
(ConvertFrom-Json (Get-Content $ConfigJson -Encoding utf8 -Raw )).psobject.properties | Foreach { $Config[$_.Name] = $_.Value }
}


# ゲーム本体に渡す引数
$InfArgs = ""

# 引数からトークンを拾う
$Args[0] -match "tk=(.{64})" | Out-Null
$InfArgs += " -t "+$Matches[1]

# トライアルモードなら--trialをつける
if ($Args[0].Contains("trial")) {
    $InfArgs += " --trial"
}

echo "Please select option."
echo "0 : Launcher"
echo "1 : Normal"
echo "2 : Normal + window mode"
echo "3 : ASIO"
echo "4 : ASIO + window mode"
echo "5 : Run from Steam"

$num = Read-Host "number(last time: $($Config["Option"]))"
if([string]::IsNullOrEmpty($num)){
    $num=$Config["Option"]
}

switch ($num) {
    0 {
        Start-Process -FilePath $InfLauncher -ArgumentList $Args[0]
        exit
    }
    1 {

    }
    2 {
        $InfArgs += " -w"
    }
    3 {
        $InfArgs += " --asio"
    }
    4 {
        $InfArgs += " -w"
        $InfArgs += " --asio"
    }
    5 {
        # InfProxy.exeが存在しない場合ビルドする
        if(!(Test-Path $InfProxyPath)){
            echo "InfProxy.exe is not found."
            echo "Now building InfProxy.exe..."
            $InfProxySrc | Out-File -FilePath $InfProxySrcPath
            C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe .\InfProxy.cs | Out-Null
            echo ""
            echo "This is a path for InfProxy."
            echo $InfProxyPath
            echo "Add InfProxy as a non-Steam game in your Steam client."
            echo "Then create a shortcut for InfProxy on your desktop and get the URL."
            echo ""
            $Config["SteamUrl"] = Read-Host "Steam app URL(optional)"
            Save-Config
        }
        $Args[0] | Out-File -FilePath $InfProxyArgs
        rundll32.exe url.dll,FileProtocolHandler $Config["SteamUrl"]
        exit
    }
    Default {
        exit
    }
}

# 設定を保存
$Config["Option"] = [string]$num
Save-Config

# INFINITASを起動
$p = Start-Exe($InfExe,"",""""+$InfArgs+"""")

# ウィンドウモードのとき
if($InfArgs.Contains("-w")){
    # ウィンドウ作成まで待つ
    $p.WaitForInputIdle() | Out-Null

    # ウィンドウハンドルの取得
    $handle = $p.MainWindowHandle

    # 前回の位置と大きさにする
    Switch-Borderless($Config["Borderless"])
    [Win32Api]::MoveWindow2($handle, $Config["WindowPositionX"], $Config["WindowPositionY"], $Config["WindowWidth"], $Config["WindowHeight"], $Config["Borderless"])

    echo ""
    echo "window mode setting"
    echo "example:"
    echo "window size -> 1280x720"
    echo "window position -> 100,100"
    echo "Press enter key to switch to Borderless window."

    while($true){
        $inputStr=Read-Host " "
        if([string]::IsNullOrEmpty($inputStr)){
            $Config["Borderless"] = (-Not $Config["Borderless"])
        }elseif($inputStr.Contains("x")){
            $val = $inputStr.Split('x')
            $Config["WindowWidth"]=$val[0]
            $Config["WindowHeight"]=$val[1]
        }elseif($inputStr.Contains(",")){
            $val = $inputStr.Split(',')
            $Config["WindowPositionX"]=$val[0]
            $Config["WindowPositionY"]=$val[1]
        }

        # ボーダーレス化
        Switch-Borderless($Config["Borderless"])

        # 位置とサイズを反映
        [Win32Api]::MoveWindow2($handle, $Config["WindowPositionX"], $Config["WindowPositionY"], $Config["WindowWidth"], $Config["WindowHeight"], $Config["Borderless"])

        # 設定ファイルに書き込む
        Save-Config
    }
}




