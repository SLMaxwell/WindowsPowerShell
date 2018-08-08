# Directory where this file is located
$script:pwd = Split-Path $MyInvocation.MyCommand.Path

################################
#
# Load Environment path Prefixes
#
################################

$prefixPathFile = Join-Path $pwd additionalEnvPaths.txt
$prefixPaths = ""
if(Test-Path $prefixPathFile) {
  ForEach ($pathToAdd in Get-Content $prefixPathFile) {
    if(Test-Path $pathToAdd) {
      $prefixPaths = "$prefixPaths$pathToAdd;"
    }
  }
}
$env:path = "$prefixPaths$env:path"

############################################
#
# Load Environment path Powershell Specifics
#
############################################

$script:powershell_path = "C:\Windows\System32\WindowsPowerShell\v1.0".ToLower()
if((-Not $env:path.ToLower().contains($script:powershell_path)) -And (Test-Path $script:powershell_path)) {
  $env:path = "$env:path;$script:powershell_path"
}

$script:rsync_path = Join-Path $pwd 'rsync'
if(Test-Path $script:rsync_path) {
  $env:path = "$env:path;$script:rsync_path"
}

$env:SSL_CERT_FILE = Join-Path $pwd cacert.pem

###########################
#
# Load all modules
#
###########################

Get-ChildItem $pwd *.psm1 | foreach {
	Import-Module $_.VersionInfo.FileName -DisableNameChecking -verbose:$false
}

try {
  $script:git_exe = @((which git.exe).Definition)[0]
  if($script:git_exe) {
    $env:GITDIR =  split-path $script:git_exe | split-path
  }
}
catch {
  Write-Error "Error setting GITDIR! " + Error[0].Exception
}

## Enable use of Hyper-V for vagrant
$env:VAGRANT_DEFAULT_PROVIDER = "hyperv"

###########################
#
# Setup prompt
#
###########################

function prompt {
	$realLASTEXITCODE = $LASTEXITCODE

	$path = $(get-location).Path
	$index = $path.LastIndexOf('\') + 1
	$userLocation = $path

	if($index -lt $path.Length) {
		$userLocation = $path.Substring($index, $path.Length - $index)
	}
	
	Write-Host($userLocation) -nonewline -foregroundcolor Green 
	
	if (Test-GitRepository) {
		$branch = Get-GitBranch

		Write-Host '[' -nonewline -foregroundcolor Yellow
		Write-Host $branch -nonewline -foregroundcolor Cyan
		Write-Host ']' -nonewline -foregroundcolor Yellow
		
		$host.UI.RawUi.WindowTitle = "Git:$userLocation - $pwd"
	}
	elseif ($userLocation -eq $pwd) {
		$host.UI.RawUi.WindowTitle = "$pwd"
	}
	else {
		$host.UI.RawUi.WindowTitle = "$userLocation - $pwd"
	}
    
	$LASTEXITCODE = $realLASTEXITCODE
	return "> "
}

###########################
#
# Setup Tab Expansion
#
###########################

$defaul_tab_expansion = 'Default_Tab_Expansion'
if((Test-Path Function:\TabExpansion) -and !(Test-Path Function:\$defaul_tab_expansion)) {
    Rename-Item Function:\TabExpansion $defaul_tab_expansion
}

function TabExpansion($line, $lastWord) {
    $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()
    switch -regex ($lastBlock) {
        # Execute git tab completion for all git-related commands
        "$(Get-GitAliasPattern) (.*)" { GitTabExpansion $lastBlock }
        # Fall back on existing tab expansion
        default { & $defaul_tab_expansion $line $lastWord }
    }
}

##############################
#
# Override Powershell Defaults
#
##############################
Set-Alias ls Get-ChildItem-Format-Wide -option AllScope
if (Test-Path alias:\cd) { Remove-Item -Force alias:\cd }
function cd {
  if ($args[0] -eq '-') { 
    $pwd=$OLDPWD; 
  } else { 
    $pwd=$args[0]; 
  } 

  $tmp=pwd; 

  if ($pwd) { 
    Set-Location $pwd; 
  } 
  Set-Variable -Name OLDPWD -Value $tmp -Scope global;
}

# https://github.com/samneirinck/posh-docker
Import-Module posh-docker
$Env:COMPOSE_CONVERT_WINDOWS_PATHS=1
