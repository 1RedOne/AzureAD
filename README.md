# AzureAD
Need to set a user's manager using Azure AD/ MSOL?  Use this Cmdlet!

#Why does this exist?
The MSOnline module does not provide a mechanism for you to set a manager on a user.  But this cmdlet does!

*DESCRIPTION*
   
   Integrating some wonderful tips found on this blog post http://goodworkaround.com/node/73 by Marius Solbakken Mellum, we had the basis to connect to Azure AD.  Next, using the wonderful API provided 

*EXAMPLE*
   
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
