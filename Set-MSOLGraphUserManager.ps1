<#
.Synopsis
   The MSOnline module does not provide a mechanism for you to set a manager on a user.  But this cmdlet does!
.DESCRIPTION
   Integrating some wonderful tips found on this blog post http://goodworkaround.com/node/73 by Marius Solbakken Mellum, we had the basis to connect to Azure AD.  Next, using the wonderful API provided 
.EXAMPLE
   To set a user whose name is like Test, to the Manager of Stephen 
   Set-MSOLGraphUserManager -targetUser Test -targetManager Stephen

    Successfully found user to modify PSTest
    Successfully looked up manager Stephen Owen
    Updating the manager
    Verifying manager now set for PSTest
    Getting user manager
    value detected for objectID : 631929ec-acb6-4085-a440-78b01d7e197f

    userPrincipalName                                                                 displayName                                                                       objectId                                                                         
    -----------------                                                                 -----------                                                                       --------                                                                         
    sred13_gmail.com#EXT#@sred13gmail.onmicrosoft.com                                 Stephen Owen                                                                      631929ec-acb6-4085-a440-78b01d7e197f                                             
.INPUTS
   Provide parameter inputs to $targetUser and $targetManager (can be plain text, like 'Duck' or 'Stephen Owen')
.OUTPUTS
   Mostly text
.NOTES
   Integrating some wonderful tips found on this blog post http://goodworkaround.com/node/73 by Marius Solbakken Mellum, we had the basis to connect to Azure AD.  Next, using the wonderful API provided in the Azure AD Graph DLL (you can get it using the nuget command of '.\nuget.exe install Microsoft.IdentityModel.Clients.ActiveDirectory' and the Azure AD Rest API Reference guide, this work around was built https://msdn.microsoft.com/Library/Azure/Ad/Graph/api/users-operations#OperationsonusernavigationpropertiesAssignausersmanager.  This tool contains a number of worker functions, such as Get-MSOLGraphUser and Get-MsSOLGraphUserManager.  They can be liberated, but will need to be given their own begin{} scriptblock complete with all of the code from the begin{} codeblock of this function itself

#>
Function Set-MSOLGraphUserManager {
    param([parameter(Mandatory=$true)]$targetUser,
          [parameter(Mandatory=$true)]$targetManager)
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
process{
    
    Write-Verbose  "Looking up the user to change"
        $targetUser = Get-MsolGraphUser | ? DisplayName -like "*$targetUser*" 
        Write-host "Successfully found user to modify $($targetUser.DisplayName)"

    Write-Verbose "Looking up the target manager"
        $NewTargetManager = Get-MsolGraphUser | ? DisplayName -like "*$targetManager*" 
        write-host  "Successfully looked up manager $($NewTargetManager.displayName)"
        
        if ($NewTargetManager.ObjectID -ne $null){
            $Newmanager =  [pscustomobject]@{url="$serviceRootURL/directoryObjects/$($NewTargetManager.ObjectID)"} | ConvertTo-Json
            Write-Host -ForegroundColor Yellow "Updating the manager"
            #Set the manager
            $user = Invoke-RestMethod -Method Patch -Uri "$serviceRootURL/users/$($TargetUser.objectID)/`$links/manager?api-version=1.5" -Headers @{Authorization=$authenticationResult.CreateAuthorizationHeader()} -ContentType "application/json" -Body $Newmanager
            }
            else{
            Write-Warning "coudn't resolve the `$NewTargetManager's ObjectID,"
            BREAK
            }


}

end{
    Write-host "Verifying manager now set for $($targetUser.DisplayName)"
    $mgr = Get-MSOLGraphUserManager -objectID $targetUser.ObjectID
    "$($targetUser.DisplayName)'s manager is now $($mgr.DisplayName)"
        }


}