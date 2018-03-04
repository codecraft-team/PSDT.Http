# PSDT.Http

[![Build status](https://ci.appveyor.com/api/projects/status/520p7cjxnt4eue59/branch/master?svg=true&passingText=Build%20Passing&failingText=Build%20Failing&pendingText=Build%20Pending)](https://ci.appveyor.com/project/codecraftteam/PSDT-Http)

Encapsulates netsh http command line. This is helpful when creating services and one do not want to start e.g. Visual Studio with elevated priviledges.
For more information see https://msdn.microsoft.com/en-us/library/ms733768.aspx.

# Cmdlets
All cmdlets within this module use "Http" as noun prefix.  
To get an overview of available cmdlets use the PowerShell Get-Command cmdlet.
> PS \\>Get-Command -noun Http*

## Get-HttpUrlAcl
Lists reserved URL ACLs.

Examples
List all reserved URLs.
>PS \\>Get-HttpUrlAcl

Get matched URLs. In this case the URL matches e.g. port 8081
>PS \\>Get-HttpUrlAcl -Name 8081

Get raw URL list. This is similar to the output of netsh http show urlacl.
>PS \\>Get-HttpUrlAcl -Raw

## Add-HttpUrlAcl
Adds the specified URL to the list of reserved URL.

Examples:
The specified URL will be added to the reserved URL list. By default the domain account is taken from $env:USERDOMAIN and $env:USERNAME.
>PS \\>Add-HttpUrlAcl -Url http://+:8081/

The specified URL will be added to the reserved URL list.
>PS \\>Add-HttpUrlAcl -Url http://+:8081/ -DomainAccount "NT AUTHORITY\Authenticated Users"

## Remove-HttpUrlAcl
Removes the specified URL from the list of reserved URL.

Examples:
The specified URL will be removed from the reserved URL list.
>PS \\>Remove-HttpUrlAcl -Url http://+:8081/

First a specific URL will be queried using Get-HttpUrlAcl and then piped to the Remove-HttpUrlAcl cmdlet.
>PS \\>Get-HttpUrlAcl -Name 8081 | Remove-HttpUrlAcl