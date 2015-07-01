<#
.Synopsis
   Use this tool to resolve all MSOL/AzureAD Users. Be certain to update the begin{} codeblock with your information
.DESCRIPTION
   This tool will resolve all MSOL users, or a single user if $objectID is provided as a parameter.  This needs to be the GUID of a user.
.EXAMPLE
   To find a user with a displayname like 'Stephen Owen'
   $targetUser = Get-MsolGraphUser | ? DisplayName -like "*Stephen Owen*" 
.EXAMPLE
   To find a user based on their GUID 
   Get-MSOLGraphUser -objectid 631929ec-acb6-4085-a440-78b01d7e197f
    value detected for objectID : 631929ec-acb6-4085-a440-78b01d7e197f

    userPrincipalName                                                                 displayName                                                                       objectId                                                                         
    -----------------                                                                 -----------                                                                       --------                                                                         
    sred13_gmail.com#EXT#@sred13gmail.onmicrosoft.com                                 Stephen Owen                                                                      631929ec-acb6-4085-a440-78b01d7e197f
.INPUTS
   Provide the value ObjectId as a parameter to -objectID
.OUTPUTS
   PowerShell objects with a UserPrincipalName, DisplayName, and ObjectID field
.NOTES
   Integrating some wonderful tips found on this blog post http://goodworkaround.com/node/73 by Marius Solbakken Mellum, we had the basis to connect to Azure AD.  Next, using the wonderful API provided in the Azure AD Graph DLL (you can get it using the nuget command of '.\nuget.exe install Microsoft.IdentityModel.Clients.ActiveDirectory' and the Azure AD Rest API Reference guide, this work around was built https://msdn.microsoft.com/Library/Azure/Ad/Graph/api/users-operations#OperationsonusernavigationpropertiesAssignausersmanager.  This tool contains a number of worker functions, such as Get-MSOLGraphUser and Get-MsSOLGraphUserManager.  They can be liberated, but will need to be given their own begin{} scriptblock complete with all of the code from the begin{} codeblock of this function itself

#>
Function Get-MSOLGraphUser {
        param($objectid)
        begin{
    if (test-path -Path "C:\temp\GraphAPI\Microsoft.IdentityModel.Clients.ActiveDirectory.2.18.206251556\lib\net45\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"){
        Add-Type -Path "C:\temp\GraphAPI\Microsoft.IdentityModel.Clients.ActiveDirectory.2.18.206251556\lib\net45\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"}
        else{Write-warning 'This function requires the Microsoft Azure AD Graph DLL'
             Write-warning 'follow the steps in the blog post which is opening to install it'
             Start 'http://goodworkaround.com/node/73'
             Write-Warning 'If you already installed it, update the path in the function declaration of Set-MSOLUserManager'
             BREAK}
    

    # Change these three values to your application and tenant settings
    $clientID = "41f9bbda-c4ef-4e2b-9859-f46dccd98329" # CLIENT ID for application
    $clientSecret = "xbARGDHo8H/mcMz4gyGrv/fqQAo87JWkgb9hSTm0/Ng=" # KEY for application
    $tenant = "sred13gmail.onmicrosoft.com" # The tenant domain name
    $tenantID = '09014202-03db-4b06-a388-e5f23fb04bd25'

    # Static values
    $resAzureGraphAPI = "https://graph.windows.net";
    $serviceRootURL = "https://graph.windows.net/$tenant"
    $authString = "https://login.windows.net/$tenant";
 
    # Creates a context for login.windows.net (Azure AD common authentication)
    [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]$AuthContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]$authString
 
    # Creates a credential from the client id and key
    [Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential]$clientCredential = New-Object -TypeName "Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential"($clientID, $clientSecret)
 
    # Requests a bearer token
    $authenticationResult = $AuthContext.AcquireToken($resAzureGraphAPI, $clientCredential);
 
    # Output the token object
    Write-Verbose "Token object:"
    If ($VerbosePreference -ne 'SilentlyContinue' ){$authenticationResult | Format-List}

    }
        process{if ($objectid -eq $null){
            
            $users = Invoke-RestMethod -Method GET -Uri "$serviceRootURL/users?api-version=1.5" -Headers @{Authorization=$authenticationResult.CreateAuthorizationHeader()} -ContentType "application/json"
            $users = $users.Value
            }
            else{
            Write-verbose "value detected for objectID : $objectID"
            $users = Invoke-RestMethod -Method GET -Uri "$serviceRootURL/users?api-version=1.5" -Headers @{Authorization=$authenticationResult.CreateAuthorizationHeader()} -ContentType "application/json" 
            #Write-Debug 'ham'
            $users = $users.Value | ? ObjectID -eq $objectID
            }

        $users | Select UserPrincipalName,DisplayName,objectID}
    }