# Script.Template.Library 1.0.16163.1
# 
# Copyright (C) 2016 github.com/trondr
#
# All rights reserved.
# 
# License: New BSD (https://github.com/trondr/Script.Template/blob/master/LICENSE.md)

function ExecuteAction([scriptblock]$action)
{
    $exitCode = & $action

    return $exitCode
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

function ConfigureAppConfig()
{
    Write-Verbose "Configuring app config..."
    $global:appConfig = [System.IO.Path]::Combine($scriptFolder,"$($scriptName).config")    
    [System.AppDomain]::CurrentDomain.SetData("APP_CONFIG_FILE", $appConfig)    
}

function ConfigureLogging
{
    Write-Verbose "Configuring logging..."
    $log4NetDll = [System.IO.Path]::Combine($scriptFolder,"Libs","log4net.dll")
    $library = LoadLibrary $log4NetDll
    if($library -eq $null)
    {
        Write-Host "Failed to load log4net.dll" -ForegroundColor Red
        exit 1
    }
    CreateFolder $logFolder;
    [log4net.GlobalContext]::Properties["LogFile"] = $logFile;    
    $xmlConfigurator = [log4net.Config.XmlConfigurator]::ConfigureAndWatch($appConfig);    
    $logManager = [log4net.LogManager]
    $global:logger = $logManager::GetLogger("$scriptName");    
}

function CreateFolder([string] $folder)
{
    if([string]::IsNullOrWhiteSpace($folder) -eq $true)
    {
        Write-Host "Failed to create folder. Folder '$folder' is null or empty or white space";
        return
    }
    if([System.IO.Directory]::Exists($folder) -eq $false)
    {
        Write-Host "Creating folder '$folder'"
        $directoryInfo = [System.IO.Directory]::CreateDirectory($folder);
    }
}

ConfigureAppConfig
ConfigureLogging