
###################################################
#
# Functions to allow switching the Path environment 
# variable to the proper VISUAL version specifics.
#
###################################################

$vm10_runtime_paths = "C:\Infor10\Runtime73\Axis2c\lib;C:\Infor10\Runtime73;"
$vm9_runtime_paths = "C:\Infor\Runtime70\Axis2c\lib;C:\Infor\Runtime70;"
$vm10_axis2c_home = "C:\Infor10\Runtime73\Axis2c"
$vm9_axis2c_home = "C:\Infor\Runtime70\Axis2c"
$vm10_local_path = "C:\Infor10\VISUAL\VISUAL MFG"
$vm9_local_path = "C:\Infor\VISUAL\VISUAL MFG"
$vmTextPlaceholder = "<vm-path-here>;"
$env:OriginalSystemPath = [Environment]::GetEnvironmentVariable("Path",[System.EnvironmentVariableTarget]::Machine)

function Which-VMVersion {
  # Returns the current VM Version that is set within the $env:OriginalSystemPath variable.

  $path = $env:OriginalSystemPath
  if ($path.contains($vm10_runtime_paths)) {
    $version = "10.0.0"
  } else {
    $version = "9.0.2"
  }

  return $version
}

function Set-VMVersion([int]$version=9) {
  # Swtiches the version of VISUAL within the PATH environment variable.
  $syspath = $env:OriginalSystemPath
  $path = $env:Path

  # Clear the current path of all previous VM versions.
  $workingSysPath = $syspath.replace($vm10_runtime_paths, $vmTextPlaceholder)
  $workingSysPath = $workingSysPath.replace($vm9_runtime_paths, $vmTextPlaceholder)
  $workingPath = $path.replace($vm10_runtime_paths, $vmTextPlaceholder)
  $workingPath = $workingPath.replace($vm9_runtime_paths, $vmTextPlaceholder)

  # If the vmTextPlaceholder is not present - put it at the end.
  if (!$workingSysPath.contains($vmTextPlaceholder)) {
    $workingSysPath = $workingSysPath + ";" + $vmTextPlaceholder
    $workingSysPath = $workingSysPath.replace(";;", "")
  }

  if (!$workingPath.contains($vmTextPlaceholder)) {
    $workingPath = $workingPath + ";" + $vmTextPlaceholder
    $workingPath = $workingPath.replace(";;", "")
  }

  # Determine which version of VM and AXIS2C to insert into the path.
  switch ($version) {
    9 { $insert_text = $vm9_runtime_paths; $insert_axis2c_text = $vm9_axis2c_home;}
    10 { $insert_text = $vm10_runtime_paths; $insert_axis2c_text = $vm10_axis2c_home;}
    default { $insert_text = $vm9_runtime_paths; $insert_axis2c_text = $vm9_axis2c_home;}
  }

  #perform the insertion into the Envirnment Variables.
  Write-Host "Setting to version:" $version
  $workingSysPath = $workingSysPath.replace($vmTextPlaceholder, $insert_text)
  [System.Environment]::SetEnvironmentVariable('Path', $workingSysPath, 'User')
  [System.Environment]::SetEnvironmentVariable('AXIS2C_HOME', $insert_axis2c_text, 'User')
  [System.Environment]::SetEnvironmentVariable('Path', $workingSysPath, 'Machine')
  [System.Environment]::SetEnvironmentVariable('AXIS2C_HOME', $insert_axis2c_text, 'Machine')

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
    "9.0.2" { $setToVersion=10 }
    "10.0.0" { $setToVersion=9 }
    default { $setToVersion=9 }
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
function Swap-RegKeys([int]$version=9) {
  $registryPath = "HKCU:\Software\Infor Global Solutions\VISUAL Manufacturing\Configuration"
  $installDirKey = "InstallDirectory"
  $localDirKey = "Local Directory"

  # Determine which version of VM to insert into registry keys.
  switch ($version) {
    9 { $value = $vm9_local_path }
    10 { $value = $vm10_local_path }
    default { $value = $vm9_local_path }
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