# Script.Template.Library 1.0.17061.4
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

$global:runningInIseChecked = $false
$global:runningInIse = $false
function RunningInIse
{
    if($global:runningInIseChecked -eq $false)
    {
        $variable = Get-Variable psISE -Scope Global -ErrorAction SilentlyContinue
        if($variable -ne $null)
        {
            $global:runningInIse = $true
        }
        else
        {
            $global:runningInIse = $false
        }
        $global:runningInIseChecked = $true
        Write-Verbose "Running in ISE: $($global:runningInIse)"
    }
    return $global:runningInIse
}

function LogInfo
{
    param($message)

    if($logger.IsInfoEnabled)
    {
        if(RunningInIse -eq $true)
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
        if(RunningInIse -eq $true)
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
        if(RunningInIse -eq $true)
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
        if(RunningInIse -eq $true)
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
        if(RunningInIse -eq $true)
        {
            Write-Host $message -BackgroundColor Blue -ForegroundColor White
        }    
        $logger.Debug($message)
    }    
}

$global:scriptFolder = [System.String]::Empty
function GetScriptFolder
{
    if([System.String]::IsNullOrEmpty($global:scriptFolder) -eq $true)
    {
        $global:scriptFolder = Split-Path -Parent $global:script
        Write-Verbose "ScriptFolder=$($global:scriptFolder)"
    }    
    return $global:scriptFolder
}

$global:remoteBatchScriptFolder = [System.String]::Empty
function GetRemoteBatchScriptFolder
{
    if([System.String]::IsNullOrEmpty($global:remoteBatchScriptFolder) -eq $true)
    {
        $global:remoteBatchScriptFolder = $env:BatchScriptFolder
        if([System.String]::IsNullOrEmpty($global:remoteBatchScriptFolder) -eq $true)
        {
            Write-Host "WARNING. 'ScriptFolder' not set as environment variable." -ForegroundColor Yellow             
        }
        Write-Verbose "From Environment (BatchScriptFolder): remoteBatchScriptFolder=$($global:remoteBatchScriptFolder)"        
    }
    return $global:remoteBatchScriptFolder
}

$global:localScriptFolder = [System.String]::Empty
function GetLocalScriptFolder
{        
    if([System.String]::IsNullOrEmpty($global:localScriptFolder) -eq $true)
    {
        $global:localScriptFolder = $env:LocalScriptFolder
        if([System.String]::IsNullOrEmpty($global:localScriptFolder) -eq $true)
        {
            Write-Host "WARNING. 'LocalScriptFolder' not set as environment variable." -ForegroundColor Yellow             
        }
        Write-Verbose "From Environment (LocalScriptFolder): LocalScriptFolder=$($global:localScriptFolder)"
    }
    return $localScriptFolder
}

$global:scriptName = [System.String]::Empty
function GetScriptName
{
    if([System.String]::IsNullOrEmpty($global:scriptName) -eq $true)
    {
        $global:scriptName = [System.IO.Path]::GetFileNameWithoutExtension($global:script)
        Write-Verbose "ScriptName=$($global:scriptName)"    
    }    
    return $scriptName
}

$global:remoteScriptName = [System.String]::Empty
function GetRemoteScriptName
{
    if([System.String]::IsNullOrEmpty($global:remoteScriptName) -eq $true)
    {
        $global:remoteScriptName = $env:ScriptName
        if([System.String]::IsNullOrEmpty($global:remoteScriptName) -eq $true)
        {
            Write-Host "WARNING. 'ScriptName' not set as environment variable." -ForegroundColor Yellow             
        }
        Write-Verbose "From Environment (ScriptName): RemoteScriptName=$($global:remoteScriptName)"
    }
    return $global:remoteScriptName
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

$global:messagesFolder = [System.String]::Empty
function GetMessagesFolder
{
    if([System.String]::IsNullOrEmpty($global:messagesFolder) -eq $true)
    {
        $scriptFolder = GetScriptFolder
        $global:messagesFolder = [System.IO.Path]::Combine($scriptFolder,"Messages")
        Write-Verbose "MessagesFolder=$($global:messagesFolder)"
    }    
    return $global:messagesFolder
}

function GetMessage
{
    param([System.Globalization.CultureInfo]$culture, [System.String]$messageKey, $defaultMessage)
    
    $oldCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture
    $oldUiCulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture
    try
    {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture        
        $scriptName = GetScriptName
        $messagesFolder = GetMessagesFolder      
        $messageFileName =   "$($scriptName)Messages.psd1"
        Import-LocalizedData -BaseDirectory "$messagesFolder" -BindingVariable messages -FileName $messageFileName 
        if($messages.ContainsKey($messageKey) -eq $true)
        {
            return $messages.Get_Item($messageKey)
        } 
        else
        {
            if($logger.IsWarnEnabled)
            {
                $logger.Warn("Using defalt message '$defaultMessage' for non existing message key '$messageKey'")
            }
            return $defaultMessage
        }
    }
    finally
    {
       [System.Threading.Thread]::CurrentThread.CurrentCulture = $oldCulture
       [System.Threading.Thread]::CurrentThread.CurrentUICulture = $oldUiCulture
    }
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
    $logFolder = [System.IO.Path]::Combine([System.IO.Path]::Combine($env:Public, "Logs"), $scriptName);
    $remoteBatchScriptFolder = GetRemoteBatchScriptFolder
    if(($storeLogFilesInPublicLogsFolder -eq $false) -and (![string]::IsNullOrEmpty($remoteBatchScriptFolder)))
    {    
        $logFolder = [System.IO.Path]::Combine($remoteBatchScriptFolder, "Logs");
    }
    else
    {
        $scriptFolder = GetScriptFolder
        if(($storeLogFilesInPublicLogsFolder -eq $false) -and (![string]::IsNullOrEmpty($scriptFolder)))
        {    
            $logFolder = [System.IO.Path]::Combine($scriptFolder, "Logs");
        }
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
    $scriptFolder = GetScriptFolder
    $log4NetDll = [System.IO.Path]::Combine([System.IO.Path]::Combine($scriptFolder,"Libs"),"log4net.dll")
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