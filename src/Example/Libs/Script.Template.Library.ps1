# Script.Template.Library 1.0.16171.0
# 
# Copyright (C) 2016 github.com/trondr
#
# All rights reserved.
# 
# License: New BSD (https://github.com/trondr/Script.Template/blob/master/LICENSE.md)

###############################################################################
#
#   Functions
#
###############################################################################

function ExecuteAction([scriptblock]$action)
{
    $exitCode = & $action

    return $exitCode
}

function GetScriptFolder
{
    $scriptFolder = Split-Path -Parent $global:script
    Write-Verbose "ScriptFolder=$scriptFolder"
    return $scriptFolder
}

function GetScriptName
{
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($global:script)
    Write-Verbose "ScriptName=$scriptName"
    return $scriptName
}

function LoadLibrary([string]$libraryFilePath)
{
    if( [System.IO.File]::Exists($libraryFilePath) -eq $false )
    {
        Write-Error "Failed to load library. Library file not found: '$libraryFilePath'."
		return $null
    }    
    $library = [System.Reflection.Assembly]::LoadFrom($libraryFilePath)
    if($library -eq $null)
    {
        Write-Host -ForegroundColor Red "Failed to load library: '$libraryTargetFilePath'."
    }
    return $library
}

function CreateFolder([string] $folder)
{
    if([string]::IsNullOrWhiteSpace($folder) -eq $true)
    {
        Write-Host "Failed to create folder. Folder '$folder' is null or empty or white space" -ForegroundColor Red;
        return
    }
    if([System.IO.Directory]::Exists($folder) -eq $false)
    {
        Write-Host "Creating folder '$folder'"
        $directoryInfo = [System.IO.Directory]::CreateDirectory($folder);
    }
}

#$library = [System.Reflection.Assembly]::LoadWithPartialName("System.ComponentModel")
function GetErrorMessage([int] $errorCode)
{
     $win32Exception = New-Object System.ComponentModel.Win32Exception -ArgumentList @(,$errorCode)
     $message = $win32Exception.Message
     return $message
}

function GetAppConfig
{
    $scriptName = GetScriptName
    $appConfig = [System.IO.Path]::Combine($global:scriptFolder,"$($scriptName).config")
    Write-Verbose "App config file: $appConfig"
    return $appConfig
}

function ConfigureAppConfig()
{
    Write-Verbose "Configuring app config..."
    $appConfig = GetAppConfig
    [System.AppDomain]::CurrentDomain.SetData("APP_CONFIG_FILE", $appConfig)
}

function GetLogFolder()
{
    $logFolder = [System.IO.Path]::Combine($env:PUBLIC, "Logs", $global:scriptName);
    CreateFolder $logFolder;
    return $logFolder;
}

function GetLogFile()
{
    $logFolder = GetLogFolder
    $userName = $env:USERNAME
    $scriptName = GetScriptName
    $logFile = [System.IO.Path]::Combine($LogFolder, "$scriptName-$userName.log");
    Write-Host "Log file: $logFile"
    return $logFile;
}

function GetLog4NetDll
{
    $log4NetDll = [System.IO.Path]::Combine($global:scriptFolder,"Libs","log4net.dll")
    Write-Verbose "log4NetDll: $log4NetDll"
    return $log4NetDll
}

function ConfigureLogging
{
    Write-Verbose "Configuring logging...";
    $log4NetDll = GetLog4NetDll
    $library = LoadLibrary $log4NetDll
    if($library -eq $null)
    {
        Write-Host "Failed to load log4net.dll" -ForegroundColor Red
        exit 1
    }    
    $logFile = GetLogFile
    [log4net.GlobalContext]::Properties["LogFile"] = $logFile;    
    $appConfig = GetAppConfig
    $xmlConfigurator = [log4net.Config.XmlConfigurator]::ConfigureAndWatch($appConfig);
    $logManager = [log4net.LogManager]
    $scriptName = GetScriptName
    $global:logger = $logManager::GetLogger("$scriptName");
}

function Configure
{
    ConfigureAppConfig
    ConfigureLogging
}

###############################################################################
#
#   Configure script
#
###############################################################################

Configure

###############################################################################
#
#   Load user script library
#
###############################################################################
Write-Verbose "Loading user script library...";
$scriptFolder = GetScriptFolder
$scriptName = GetScriptName
$scriptLibrary = [System.IO.Path]::Combine($scriptFolder ,"$($scriptName)Library.ps1")
if((Test-Path $scriptLibrary) -eq $false)
{
    Write-Host -ForegroundColor Red "Script library '$scriptLibrary' not found."
    EXIT 1
}
Write-Verbose "ScriptLibrary=$scriptLibrary"
Write-Verbose "Loading script library '$scriptLibrary'..."
. $scriptLibrary
If ($? -eq $false) 
{ 
    Write-Host -ForegroundColor Red "Failed to load library '$scriptLibrary'. Error: $($error[0])"; break 
    EXIT 1
};

###############################################################################
#
#   Run user script
#
###############################################################################
Write-Verbose "Executing user script, Run()...";
$commandLine = [System.Environment]::CommandLine
$logger.Info("Start: $scriptName $scriptVersion Command line: $commandLine");

$global:scriptExitCode = ExecuteAction([scriptblock]$function:Run)

$errorMessage = GetErrorMessage($scriptExitCode)
$logger.Info("Stop: $scriptName $scriptVersion Exit code: $scriptExitCode ($errorMessage)");
Write-Verbose "Finished executing user script, Run().";