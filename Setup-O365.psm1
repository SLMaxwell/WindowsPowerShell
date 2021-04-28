<#
  ################## Mike's O365 Powershell Profile ########################

  $orgName="rammount.onmicrosoft.com"
  $acctName="scott.maxwell@rammount.com"
  $o365Credential = Get-Credential -UserName $acctName -Message "Type the account's password."

    ###### Or to load the password from SecureString file ######
    ###### To create / recreate the password file:
      read-host -assecurestring | convertfrom-securestring | out-file C:\Users\Scott\Documents\WindowsPowerShell\adSearchPass.dat

  $password = Get-Content 'C:\Users\Scott\Documents\WindowsPowerShell\adSearchPass.dat' | ConvertTo-SecureString
  $o365Credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password



  #Azure Active Directory
  Connect-AzureAD -Credential $o365Credential
  Connect-MsolService -Credential $o365Credential

  #Exchange Online
  Import-Module ExchangeOnlineManagement
  Connect-ExchangeOnline -Credential $o365Credential -ShowProgress $true

  #Teams
  Import-Module MicrosoftTeams
  Connect-MicrosoftTeams -Credential $o365Credential

  #SharePoint Online
  #Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
  #Connect-SPOService -Url https://$orgName-admin.sharepoint.com -credential $o365Credential

  #Security & Compliance Center
  Connect-IPPSSession -UserPrincipalName $acctName

  ##########################################################################
#>