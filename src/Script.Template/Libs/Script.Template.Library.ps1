# Script.Template.Library 1.0.17052.2
# 
# Copyright (C) 2016-2017 github.com/trondr
#
# All rights reserved.
# 
# License: New BSD (https://github.com/trondr/Script.Template/blob/master/LICENSE.md)

Set-StrictMode -Version Latest

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

function LogInfo
{
    param($message)

    if($logger.IsInfoEnabled)
    {
        if($psISE -ne $null)
        {
            Write-Host $message -BackgroundColor Green -ForegroundColor White
        }    
        $logger.Info($message)
    }    
}

function LogWarning
{
    param($message)

    if($logger.IsWarnEnabled)
    {
        if($psISE -ne $null)
        {
            Write-Host $message -BackgroundColor Yellow -ForegroundColor Red
        }    
        $logger.Warn($message)
    }    
}

function LogError
{
    param($message)

    if($logger.IsErrorEnabled)
    {
        if($psISE -ne $null)
        {
            Write-Host $message -BackgroundColor Red -ForegroundColor Yellow
        }    
        $logger.Error($message)
    }    
}

function LogFatal
{
    param($message)

    if($logger.IsFatalEnabled)
    {
        if($psISE -ne $null)
        {
            Write-Host $message -BackgroundColor Red -ForegroundColor Yellow
        }    
        $logger.Fatal($message)
    }    
}

function LogDebug
{
    param($message)

    if($logger.IsDebugEnabled)
    {
        if($psISE -ne $null)
        {
            Write-Host $message -BackgroundColor Blue -ForegroundColor White
        }    
        $logger.Debug($message)
    }    
}


function GetScriptFolder
{
    $scriptFolder = Split-Path -Parent $global:script
    Write-Verbose "ScriptFolder=$scriptFolder"
    return $scriptFolder
}

function GetRemoteScriptFolder
{
    $remoteScriptFolder = $env:ScriptFolder
    Write-Verbose "From Environment (ScriptFolder): RemoteScriptFolder=$remoteScriptFolder"
    return $remoteScriptFolder
}

function GetLocalScriptFolder
{        
    $localScriptFolder = $env:LocalScriptFolder
    Write-Verbose "From Environment (LocalScriptFolder): LocalScriptFolder=$localScriptFolder"
    return $localScriptFolder
}

function GetScriptName
{
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($global:script)
    Write-Verbose "ScriptName=$scriptName"
    return $scriptName
}

function GetRemoteScriptName
{
    $remoteScriptName = $env:ScriptName
    Write-Verbose "From Environment (ScriptName): RemoteScriptName=$remoteScriptName"
    return $remoteScriptName
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
    $scriptName = GetScriptName
    $logFolder = [System.IO.Path]::Combine($env:Public, "Logs", $scriptName);
    $remoteScriptFolder = GetRemoteScriptFolder
    if(($storeLogFilesInPublicLogsFolder -eq $false) -and (![string]::IsNullOrEmpty($remoteScriptFolder)))
    {    
        $logFolder = [System.IO.Path]::Combine($remoteScriptFolder, "Logs");
    }
    $scriptFolder = GetScriptFolder
    if(($storeLogFilesInPublicLogsFolder -eq $false) -and (![string]::IsNullOrEmpty($scriptFolder)))
    {    
        $logFolder = [System.IO.Path]::Combine($scriptFolder, "Logs");
    }
    if( ([System.IO.Path]::IsPathRooted($logFolder)) -eq $false)
    {
        Write-Host "Log folder '$logFolder' is not a full path."  -ForegroundColor Red
        throw [System.IO.DirectoryNotFoundException] "Directory not found: $logFolder"
    }
    CreateFolder $logFolder;  
    return $logFolder;
}

function GetLogFile()
{
    $logFolder = GetLogFolder
    $userName = $env:USERNAME
    $scriptName = GetScriptName
    $logFile = [System.IO.Path]::Combine($logFolder, "$scriptName-$userName.log");
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
Write-Verbose "CLR runtime version: $([System.Environment]::Version)";
$commandLine = [System.Environment]::CommandLine
LogInfo "Start: $scriptName $scriptVersion Command line: $commandLine"

$global:scriptExitCode = ExecuteAction([scriptblock]$function:Run)

$successExitCode = [int]0
$expectedExitCodeType = $successExitCode.GetType()
$exitCodeType = $scriptExitCode.GetType()
if($exitCodeType.Name -eq $expectedExitCodeType.Name)
{
    $errorMessage = GetErrorMessage($scriptExitCode)    
    LogInfo "Stop: $scriptName $scriptVersion Exit code: $scriptExitCode ($errorMessage)"
}
else
{
    $global:scriptExitCode = 1
    $errorMessage = "The Run() function did not return an exit code of type System.Int32. Please make sure that any code lines in Run() function is not returning '$exitCodeType' and there by intercepts the return statement."
    LogError "Stop: $scriptName $scriptVersion Exit code: $scriptExitCode ($errorMessage)"
}
Write-Verbose "Finished executing user script, Run().";