<#
  https://stackoverflow.com/questions/6239647/using-powershell-credentials-without-being-prompted-for-a-password
  https://superuser.com/questions/1288270/get-aduser-searchbase
  https://adamtheautomator.com/ldap-filter/#The_SearchBase_and_SearchScope_Parameters
    -SearchScope Base – The object that has been specified as the SearchBase.
    -SearchScope OneLevel – searches for objects immediately contained by the SearchBase but not in any sub containers.
    -SearchScope SubTree – searches for objects contained by the SearchBase and in any subcontainers, recursively down through the AD hierarchy.
#>

#################################### Credential Set-up ###################################
<#
  # To create / recreate the password file:
  read-host -assecurestring | convertfrom-securestring | out-file C:\Users\Scott\Documents\WindowsPowerShell\adSearchPass.dat
#>

$username = "npi\slm"
$password = Get-Content 'C:\Users\Scott\Documents\WindowsPowerShell\adSearchPass.dat' | ConvertTo-SecureString
$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$SearchBase = "OU=NPI Users,OU=NPI OU,DC=nationalproductsinc,DC=COM"

###########################################################################################

function FindUser {

  <#
    Switch parameters are easy to use and are preferred over Boolean parameters, which have a more difficult syntax.
    For example, to use a switch parameter, the user types the parameter in the command.
    -IncludeAll
    
    We grab it in the function Param([switch]$IncludeAll)
  #>

  Param (
    [Parameter(Position=0, Mandatory = $false)]
    [string]$user
  )

  <#
    Search Setups:

    # All Users with data table output formatted.
    Get-Aduser -Server ares.nationalproductsinc.com:3268 -Filter * -Credential $credential | Format-Table

    # Search for a user with login 'mtg' - output all in a formatted list
    Get-Aduser -Server ares.nationalproductsinc.com:3268 -Identity mtg -Credential $credential
    Get-ADUser -Server ares.nationalproductsinc.com:3268 -SearchScope SubTree -SearchBase $SearchBase -Filter { samAccountName -like "mtg*" } -credential $credential | Format-List

    # Search for a user with displayname 'Scott' - output the sepcified columns in a formatted table
    Get-ADUser -Server ares.nationalproductsinc.com:3268 -Filter { displayName -like "Scott*" } -credential $credential | Format-Table Name, samAccountName

    # Search for user with either name or login 'Scott' - output the desired columns in a formatted table that has been autosized.
    Get-ADUser -Server ares.nationalproductsinc.com:3268 `
              -SearchScope SubTree -SearchBase $SearchBase `
              -Filter { displayName -like "Scott*" -or samAccountName -like "Scott*" } `
              -credential $credential | Format-Table Name, samAccountName -AutoSize
  #>
  
  # Search for user with either name or login 'Scott' - output the desired columns in a formatted table that has been autosized.
  $user = "$user*"
  Write-Host ""
  Write-Host "   Finding User(s): $user ..."
  Write-Host ""

  Get-ADUser  -Server ares.nationalproductsinc.com:3268 `
              -SearchScope SubTree -SearchBase $SearchBase `
              -Filter { displayName -like $user -or samAccountName -like $user } `
              -credential $credential | Format-Table Name, samAccountName -AutoSize
}

Set-Alias whois FindUser

Export-ModuleMember FindUser -Alias whois