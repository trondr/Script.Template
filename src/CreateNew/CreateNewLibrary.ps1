Set-StrictMode -Version Latest

# User specified functions for use in the main script can be defined in this file.

function ResolveScriptTemplate
{
    param($templateScriptFolder, $newScriptFolder, $newScriptName)
    $exitCode = 0
    if([System.IO.Directory]::Exists($newScriptFolder) -eq $true)
    {
        LogError "Script '$newScriptName' ($newScriptFolder) allready exists."
        $exitCode = 1
        return $exitCode
    }
    LogInfo "Resolving script template '$templateScriptFolder'-> '$newScriptFolder'"
    Copy-Item -Path "$templateScriptFolder" -Filter *.* -Destination $newScriptFolder –Recurse
    
    LogInfo "Renaming 'SomeScript' -> '$newScriptName'"
    
    $files = [System.IO.Directory]::GetFiles($newScriptFolder,"*.*",[System.IO.SearchOption]::AllDirectories)

    foreach($file in $files)
    {
        $renamedFile = $file -ireplace "SomeScript", $newScriptName        
        Write-Host "Renaming: $file -> $renamedFile"
        [System.IO.File]::Move($file, $renamedFile)
    }
    return $exitCode
}

function GetScriptNameFromUser
{
    $newScriptName = $(
    Add-Type -AssemblyName Microsoft.VisualBasic 
    [Microsoft.VisualBasic.Interaction]::InputBox('Enter script name','Create new script', 'SomeNewScript')
    )
    return $newScriptName
}
