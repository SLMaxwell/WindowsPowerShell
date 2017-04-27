
###################################################
#
# Functions to allow switching the Path environment 
# variable to the proper VISUAL version specifics.
#
###################################################

$vm8_runtime_paths = "C:\Infor\Unify\Runtime62\Axis2C\Lib;C:\Infor\Unify\Runtime62;"
$vm7_runtime_paths = "C:\Infor\Unify\Runtime52\;"
$vm8_local_path = "C:\Infor\VISUAL Enterprise\VISUAL 8\"
$vm7_local_path = "C:\Infor\VISUAL Enterprise\VISUAL Manufacturing\"
$vmTextPlaceholder = "<vm-path-here>;"
$env:OriginalSystemPath = [Environment]::GetEnvironmentVariable("Path",[System.EnvironmentVariableTarget]::Machine)

function Which-VMVersion {
  # Returns the current VM Version that is set within the $env:OriginalSystemPath variable.

  $path = $env:OriginalSystemPath
  if ($path.contains($vm8_runtime_paths)) {
    $version = "8.0.0"
  } else {
    $version = "7.0.0"
  }

  return $version
}

function Set-VMVersion([int]$version=7) {
  # Swtiches the version of VISUAL within the PATH environment variable.
  $syspath = $env:OriginalSystemPath
  $path = $env:Path

  # Clear the current path of all previous VM versions.
  $workingSysPath = $syspath.replace($vm8_runtime_paths, $vmTextPlaceholder)
  $workingSysPath = $workingSysPath.replace($vm7_runtime_paths, $vmTextPlaceholder)
  $workingPath = $path.replace($vm8_runtime_paths, $vmTextPlaceholder)
  $workingPath = $workingPath.replace($vm7_runtime_paths, $vmTextPlaceholder)

  # If the vmTextPlaceholder is not present - put it at the end.
  if (!$workingSysPath.contains($vmTextPlaceholder)) {
    $workingSysPath = $workingSysPath + ";" + $vmTextPlaceholder
    $workingSysPath = $workingSysPath.replace(";;", "")
  }

  if (!$workingPath.contains($vmTextPlaceholder)) {
    $workingPath = $workingPath + ";" + $vmTextPlaceholder
    $workingPath = $workingPath.replace(";;", "")
  }

  # Determine which version of VM to insert into the path.
  switch ($version) {
    7 { $insert_text = $vm7_runtime_paths }
    8 { $insert_text = $vm8_runtime_paths }
    default { $insert_text = $vm7_runtime_paths }
  }

  #perform the insertion into the Envirnment Variables.
  Write-Host "Setting to version:" $version
  $workingSysPath = $workingSysPath.replace($vmTextPlaceholder, $insert_text)
  [Environment]::SetEnvironmentVariable( "Path", $workingSysPath, [System.EnvironmentVariableTarget]::Machine )
  $env:OriginalSystemPath = $workingSysPath

  $workingPath = $workingPath.replace($vmTextPlaceholder, $insert_text)
  $env:Path =  $workingPath
  
  # Perform the update to the Registry.
  Swap-RegKeys $version

  $newVersion = Which-VMVersion
  Write-Host "VISUAL Now on version:" $newVersion
}

function Toggle-VMVersion {
  $startingVersion = Which-VMVersion
  Write-Host "VISUAL changing from:" $startingVersion

  switch ($startingVersion) {
    "7.0.0" { $setToVersion=8 }
    "8.0.0" { $setToVersion=7 }
    default { $setToVersion=7 }
  }

  Set-VMVersion $setToVersion
}

###################################################
#
# Functions to allow switching the registry keys 
# to the proper VISUAL version specifics.
# Purposely not exposed in aliases.
#
###################################################
function Swap-RegKeys([int]$version=7) {
  $registryPath = "HKCU:\Software\Infor Global Solutions\VISUAL Manufacturing\Configuration"
  $installDirKey = "InstallDirectory"
  $localDirKey = "Local Directory"

  # Determine which version of VM to insert into registry keys.
  switch ($version) {
    7 { $value = $vm7_local_path }
    8 { $value = $vm8_local_path }
    default { $value = $vm7_local_path }
  }

  If (!(Test-Path $registryPath)) {
    # If the Registry Path does not exist - create it.
    New-Item -Path $registryPath -Force | Out-Null
  }

  # Update the keys to the correct VISUAL version location.
  New-ItemProperty -Path $registryPath -Name $installDirKey -Value $value -PropertyType STRING -Force | Out-Null
  New-ItemProperty -Path $registryPath -Name $localDirKey -Value $value -PropertyType STRING -Force | Out-Null
}


Set-Alias vmVersion Which-VMVersion
Set-Alias toggleVMVersion Toggle-VMVersion
Set-Alias setVMVersion Set-VMVersion

Export-ModuleMember `
  -Function Which-VMVersion, Set-VMVersion, Toggle-VMVersion -Alias `
  vmVersion, toggleVMVersion, setVMVersion