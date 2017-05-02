@{
    RootModule = '.\PSDT.Http.psm1'
    ModuleVersion = '1.0.0.0'
    GUID = 'b9526baf-1421-4792-afe8-a66cc76f88aa'
    Author = 'Tauri-Code'
    CompanyName = 'Tauri-Code'
    Copyright = '(c) 2017 Tauri-Code. All rights reserved.'
    Description = 'A collection of Http related PowerShell developer tools.'
    RequiredModules = @("PSDT.App")
    FunctionsToExport = @("Get-HttpUrlAcl","Add-HttpUrlAcl","Remove-HttpUrlAcl")
}