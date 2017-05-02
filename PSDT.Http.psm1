class User {
    [String]$Name;
    [String]$Listen;
    [String]$Delegate;
    [String]$SDDL;
}

class UrlAcl {
    [String]$ReservedUrl;
    [System.Collections.Generic.List[User]]$Users;

    UrlAcl(){
        $this.Users = [System.Collections.Generic.List[User]]::new();
    }
}

<#
.Synopsis
   Lists DACLs for the specified reserved URL or all reserved URLs.
.EXAMPLE
   Gets all reserved URLs.
   Get-HttpUrlAcl
.EXAMPLE
   Gets raw output. Same as netsh http show urlacl.
   Get-HttpUrlAcl -Raw
.EXAMPLE
   Matches reserved URL for port 80.
   Get-HttpUrlAcl -Name :80
.OUTPUTS
   List of UrlAcl objects.
.FUNCTIONALITY
   Uses netsh http show urlacl to get the list of reserved URLs.
#>
Function Get-HttpUrlAcl {
    [CmdletBinding()]
    [OutputType([UrlAcl])]
    Param(
        # Returns the matched URL name. If ommitted all reserved URL will returned.
        [Parameter(Mandatory=$false)]
        [string]$Name=".*",

        # Returns the default result when executing netsh http show urlacl
        [Parameter(Mandatory=$false)]
        [Switch]$Raw=$false
    )

    $netshUrlAcl = netsh http show urlacl;

    IF ($Raw) {
        return $netshUrlAcl;
    }

    $urlAclsRows = $netshUrlAcl -join "`r`n" | Select-String -Pattern "(?ms)\w*\s*\w*\s*:\shttp.*?^\s*$" -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value;
    $urlAcls = $urlAclsRows | ForEach-Object {
        $urlAcl = [UrlAcl]::new();
        $urlAcl.ReservedUrl = $_ | Select-String -Pattern "http.*[^\s]" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value;

        $users = $_ | Select-String -Pattern "(?ms)(?<=^\s{8})\w*.*?(?=^\s{8}\w|^\s*$)" -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value;
        $users | ForEach-Object {
            $user = [User]::new();

            $user.Name = $_ | Select-String -Pattern "(?<=^\w*:\s).*" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value;

            $userProperties = $_ | Select-String -Pattern "(?ms)(?<=^\s{12}\w*:\s).*?$" -AllMatches | Select-Object -ExpandProperty Matches

            If ($userProperties.Length -gt 0){
                $user.Listen = $userProperties[0].Value;
                $user.Delegate = $userProperties[1].Value;
                $user.SDDL = $userProperties[2];
            }
                
            $urlAcl.Users.Add($user);
        }

        $urlAcl;
    }

    $urlAcls | Where-Object {$_.ReservedUrl -match $Name};
}
 
<#
.Synopsis
   By adding ACL (URL reservation) the use is granted to create services that listen on that URL.
   Reservations are URL prefixes, meaning that the reservation covers all sub-paths of the reservation path.
.EXAMPLE
   Adds an URL reservation for services listening on port 8081 for the domain account specified by $env:USERDOMAIN and $env:USERNAME.
   Add-HttpUrlAcl -Url http://+:8081/
.EXAMPLE
   Adds an URL reservation for services listening on port 8081 for the domain account "NT AUTHORITY\Authenticated Users".
   Add-HttpUrlAcl -Url http://+:8081/ -DomainAccount "NT AUTHORITY\Authenticated Users"
.FUNCTIONALITY
   Uses netsh http add urlacl to add the URL.
#>
Function Add-HttpUrlAcl {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [Parameter(Mandatory = $false)]
        [string]$DomainAccount="$env:USERDOMAIN\$env:USERNAME"
    )
 
    Write-Verbose "Adding ACL for '$Url' for account '$DomainAccount'";

    . netsh http add urlacl url=$Url user=$DomainAccount listen=yes delegate=yes;
}

<#
.Synopsis
    Removes an URL reserveration.
.EXAMPLE
   Removes an URL reservation for services listening on port 8081.
   Remove-HttpUrlAcl -Url http://+:8081/
.EXAMPLE
   Removes an URL reservation for services listening on port 8081.
   Get-HttpUrlAcl 8081 | Remove-HttpUrlAcl
.FUNCTIONALITY
   Uses netsh http delete urlacl to delete the URL.
#>
Function Remove-HttpUrlAcl {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        DefaultParameterSetName='DefaultParameterSet'
    )]
    Param (      
        [Switch]$Force=$false,

        # The reserved url to remove.
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='DefaultParameterSet')]
        [string]$Url,

        # The UrlAcl instance to remove.
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='PipeParameterSet')]
        [UrlAcl]$UrlAcl
    )
 
    $reservedUrl = $Url;

    If ($null -ne $UrlAcl){
        $reservedUrl = $UrlAcl.ReservedUrl;
    }

    if ($pscmdlet.ShouldProcess($reservedUrl)) {
        If ($Force -or $pscmdlet.ShouldContinue("Removing ACL for $reservedUrl`?", "Confirmation required")) {
            Write-Verbose "Deleting ACL for $reservedUrl";

            . netsh http delete urlacl url=$reservedUrl;
        }
    }
}