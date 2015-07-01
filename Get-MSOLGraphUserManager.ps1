Function Get-MSOLGraphUserManager {
        param($objectID)
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
        Process{
        Write-Host -ForegroundColor Yellow "Getting user manager"
        $Manager = Invoke-RestMethod -Method GET -Uri "$serviceRootURL/users/$objectID/`$links/manager?api-version=1.5" -Headers @{Authorization=$authenticationResult.CreateAuthorizationHeader()} -ContentType "application/json"
        $ManagerID = ($Manager.Url -replace '/Microsoft.DirectoryServices.User','' -replace ".*directoryObjects/",'')
        Get-MSOLGraphUser -objectid $managerID
        }
    }