
###########################
#
# Get-Editor
#
###########################

function Get-Editor {
	$path = Resolve-Path (join-path (join-path "$env:PROGRAMW6432*" "Sublime*") "Sublime_text*");

	if($path.Path) {
		return $path.Path;
	}

	$path = Resolve-Path (join-path (join-path "$env:PROGRAMW6432*" "notepad*") "notepad*");
	if($path.Path) {
		return $path.Path;
	}
	
	$path = Join-Path $env:windir "\system32\notepad.exe"
	if(Test-Path $path) {
		return $path;
	}
	
	return $null;
}

###########################
#
# Approve-Syntax
# http://rkeithhill.wordpress.com/2007/10/30/powershell-quicktip-preparsing-scripts-to-check-for-syntax-errors/
#
###########################

function Test-Syntax {
	param($path, [switch]$verbose)

	if ($verbose) {
		$VerbosePreference = �Continue�
	}

	trap { Write-Warning $_; $false; continue }
	& `
	{
		$contents = get-content $path
		$contents = [string]::Join([Environment]::NewLine, $contents)
		[void]$ExecutionContext.InvokeCommand.NewScriptBlock($contents)
		Write-Verbose "Parsed without errors"
		$true
	}
}

###########################
#
# Reload Profile
#
###########################

function Reload-Profile {
	@(
		$Profile.AllUsersAllHosts,
		$Profile.AllUsersCurrentHost,
		$Profile.CurrentUserAllHosts,
		$Profile.CurrentUserCurrentHost
	) | foreach {
		if(Test-Path $_){
			Write-Verbose "Running $_"
			. $_
		}
	}    
}


# General Utility Functions
# https://github.com/dahlbyk/posh-git/blob/master/Utils.ps1

###########################
#
# Coalesce-Args
#
###########################

function Coalesce-Args {
    $result = $null
    foreach($arg in $args) {
        if ($arg -is [ScriptBlock]) {
            $result = & $arg
        } else {
            $result = $arg
        }
        if ($result) { break }
    }
    $result
}

Set-Alias ?? Coalesce-Args -Force

###########################
#
# Get-LocalOrParentPath
#
###########################

function Get-LocalOrParentPath($path) {
    $checkIn = Get-Item .
    while ($checkIn -ne $NULL) {
        $pathToTest = [System.IO.Path]::Combine($checkIn.fullname, $path)
        if (Test-Path $pathToTest) {
            return $pathToTest
        } else {
            $checkIn = $checkIn.parent
        }
    }
    return $null
}

###########################
#
# Debug
#
###########################

function Debug($Message, [Diagnostics.Stopwatch]$Stopwatch) {
    if($Stopwatch) {
        Write-Verbose ('{0:00000}:{1}' -f $Stopwatch.ElapsedMilliseconds,$Message) -Verbose # -ForegroundColor Yellow
    }
		# Write-Warning $Message
}

Set-Alias dbg Debug

###########################
#
# Get-ScriptDirectory
#
###########################

function Get-ScriptDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	Split-Path $Invocation.MyCommand.Path
}

###########################
#
# ConvertTo-PlainText
#
###########################

function ConvertTo-PlainText( [security.securestring]$secure ) {
	$marshal = [Runtime.InteropServices.Marshal];
	return $marshal::PtrToStringAuto( $marshal::SecureStringToBSTR($secure) );
}

function Get-Environment {
	Get-ChildItem Env:
}

function Create-Console($path = $(pwd)) {
  $console = Resolve-Path (join-path (join-path "$env:PROGRAMW6432*" "console*") "ConEmu64*");
  . $console /config "shell" /dir "$path" /cmd powershell -cur_console:n
}

function Get-PSVersion {
  Write-Host "`nHashtable listing for `$PSVersionTable:`n"
  $PSVersionTable
}

function Get-Version {
  $Host.Version
}

function Start-Sublime {
  #start "C:\Program Files\Sublime Text 3\sublime_text.exe" $args -n
  #ii "C:\Program Files\Sublime Text 3\sublime_text.exe $args"
  #& "C:\Program Files\Sublime Text 3\sublime_text.exe" $args
  #Invoke-Command -ScriptBlock { & "C:\Program Files\Sublime Text 3\sublime_text.exe" $args }
  Start-Process 'C:\Program Files\Sublime Text 3\sublime_text.exe' -ArgumentList $args
  #start-process sublime_text.exe $args -n
}

function Heroku-Migrate {
  heroku run rake db:migrate;
}

function Heroku-Quota {
  heroku ps -a radiant-meadow-14779;
}

function pi-1 {
  ssh pi@raspberrypi-1.local
}

function pi-2 {
  ssh pi@raspberrypi-2.local
}

function pi-3 {
  ssh pi@raspberrypi-3.local
}
function pi-4 {
  ssh pi@raspberrypi-4.local
}

Set-Alias sh Create-Console

Set-Alias Get-Env Get-Environment
#Set-Alias nano "$(Get-Editor)"
#Set-Alias sublime "$(Get-Editor)"
Set-Alias nano Start-Sublime
Set-Alias sublime Start-Sublime
Set-Alias version Get-Version
Set-Alias psversion Get-PSVersion
Set-Alias herMigrate Heroku-Migrate
Set-Alias herQuota Heroku-Quota
Set-Alias vscode code

Export-ModuleMember -Function `
	Get-Editor, Test-Syntax, Reload-Profile, Coalesce-Args, Get-LocalOrParentPath, `
  Debug, Get-ScriptDirectory, Get-Environment, ConvertTo-PlainText, `
  Heroku-Migrate, Heroku-Quota, `
  Get-PSVersion, Create-Console, Get-Version, Start-Sublime, `
  pi-1, pi-2, pi-3, pi-4 `
  -Alias `
  ??, dbg, Get-Env, nano, sublime, sh, version, psversion, herMigrate, herQuota, vscode