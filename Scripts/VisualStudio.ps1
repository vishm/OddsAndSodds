
# Last ever vsvars ps1 needed:) Based off the good works of Chris T*
#
# Usage for this script:
#     Add to $PROFILE
#     invoke shell as powershell.exe -Command {Set-VsVars32 "11.0"}
#
# Vish Murden - Minor modifications, 
#   Tested VS2012 (aka VS11) Win8 x64 
#
# links of interest:
# * http://www.tavaresstudios.com/Blog/post/The-last-vsvars32ps1-Ill-ever-need.aspx 
# http://www.hanselman.com/blog/AwesomeVisualStudioCommandPromptAndPowerShellIconsWithOverlays.aspx


# Creeate new command shell, execute batch file, then parse out environment and 
# apply to ps shell
function Get-Batchfile ($file, $arg) {
    $cmd = "`"$file`" $arg & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}

function Get-VSTools($version, $platform)
{
    # default check key unique location for Win x64 (32bit emulation)
    $key = "HKLM:SOFTWARE\Wow6432Node\Microsoft\VisualStudio\" + $version
    if ( (Test-Path($key)) -eq $false)
    {
        $key = "HKLM:SOFTWARE\Microsoft\VisualStudio\" + $version  
    }

    $VsToolsDir = ""
    $VsKey = get-ItemProperty $key
    if ( $VsKey.PSObject.Properties.Match('InstallDir').Count) 
    {
        $VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallDir)
        $VsToolsDir = [System.IO.Path]::GetDirectoryName($VsInstallPath)
        $VsToolsDir = [System.IO.Path]::Combine($VsToolsDir, "..\VC")
    }     
    else 
    {
        if ( $versionNumeric -ge 15.0 ) # VS2017 and greater > 
        {       
            $key = "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\SxS\VS7"
            if ( (Test-Path($key)) -eq $true)
            {
                $VsKey = get-ItemProperty $key
                $VsToolsDir = [System.IO.Path]::Combine($VsKey.$version, "VC\Auxiliary\Build");
            }
        }
        
    }

    return $VsToolsDir
}


function Set-VsVarsXX($version = "8.0", $platform= "x86")
{
    $VsToolsDir = Get-VSTools $version $platform

    if ( $VsToolsDir -ne "" )
    {
        $BatchFile = [System.IO.Path]::Combine($VsToolsDir, "vcvarsall.bat")
        Get-Batchfile $BatchFile $platform
        [System.Console]::Title = "Visual Studio " + $version + " " + $platform + " Windows Powershell"
    }
    else
    {
        Write-Host "Unable to locate VSToolsDir for version:" $version "platform:" $platform
    }    
 }

function Set-VsVars32($version = "8.0")
{    
    $versionNumeric = [System.Convert]::ToDouble($version)    
    if ( $versionNumeric -le 15.0 )
    {
        Set-VsVarsXX $version "x86"
    }
    else {
        Set-VsVarsXX $version "x86"
    }
}

function Set-VsVars64($version = "8.0")
{
    Set-VsVarsXX $version "amd64"
}
 