#Set-StrictMode -Version Latest
#####################################################
# Import-SitecoreAzureToolkit
#####################################################
<#PSScriptInfo

.VERSION 0.1

.GUID c5472179-f720-4985-80af-81213dbad9a7

.AUTHOR David Walker, Sitecore Dave, Radical Dave

.COMPANYNAME David Walker, Sitecore Dave, Radical Dave

.COPYRIGHT David Walker, Sitecore Dave, Radical Dave

.TAGS powershell sitecore package

.LICENSEURI https://github.com/SharedSitecore/Import-SitecoreAzureToolkit/blob/main/LICENSE

.PROJECTURI https://github.com/SharedSitecore/Import-SitecoreAzureToolkit

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>

<# 

.DESCRIPTION 
 PowerShell Script to Import (including download and install) Sitecore Azure Toolkit PowerShell Module

.PARAMETER name
Path of package

#> 
#####################################################
# Import-SitecoreAzureToolkit
#####################################################

[CmdletBinding(SupportsShouldProcess)]
Param(
	[Parameter(Mandatory=$false)]
	[string] $path,
	[Parameter(Mandatory=$false)]
	[string] $version,
	[Parameter(Mandatory=$false)]
	[string] $url = "",
	[Parameter(Mandatory=$false)]
	#[string] $packageName = "Sitecore Azure Toolkit 2.6.1-r02533.1198.zip"
	[string] $packageName = "Sitecore Azure Toolkit 2.7.0-r02533.1285.zip"
)
$ProgressPreference = "SilentlyContinue"
$PSScriptName = ($MyInvocation.MyCommand.Name.Replace(".ps1",""))
Write-Verbose "#####################################################"
Write-Verbose "# $PSScriptName $path $search"
try
{
	if (!$path -or -not(Test-Path $path)) { $path = Join-Path (Get-Location) "\SAT"}
	Write-Verbose "path:$path"
	if (!(Test-Path($path))) { New-Item -ItemType Directory -Force -Path $path | Out-Null }
	$versions = @{
		'2.5.0' = 'https://sitecoredev.azureedge.net/~/media/75A6FF723F0C48E991D7BB656DFA6FEF.ashx'
		'2.6.0' = 'https://sitecoredev.azureedge.net/~/media/75A6FF723F0C48E991D7BB656DFA6FEF.ashx'
		'2.6.1' = 'https://sitecoredev.azureedge.net/~/media/75A6FF723F0C48E991D7BB656DFA6FEF.ashx'
		'2.7.0' = 'https://sitecoredev.azureedge.net/~/media/0041D6C02A8041E89C13B611B2432834.ashx'
	}
	Write-Verbose "versions:$($versions.Count)"
	if (!$version) {
		$version = $versions.Keys | Select-Object -First 1
		$url = $versions[$version]
		Write-Verbose "version not provided. defaulting to latest:$version"
	}
	Write-Verbose "version:$version"
	Write-Verbose "url:$url"
	$packageName = "version.zip"
	if (!$version) { throw "ERROR $PSScriptName unable to find version:$version" }

	if (Test-Path -Path "$path\$packageName") {
		Write-Verbose "SKIPPING - $path folder already contains the $packageName file"
	}
	elseif ($url) {
		Write-Verbose "START - downloading the $packageName file from dev.sitecore.net"
		Invoke-WebRequest -Uri $url -OutFile "$path\$packageName"
		Write-Verbose "SUCCESS - Downloaded the $packageName file from dev.sitecore.net"
	}
	if (-not(Test-Path "$path\tools\Sitecore.Cloud.Cmdlets.dll")) {
		Expand-Archive -Path "$path\$packageName" -DestinationPath "$path" -Force
		Write-Verbose "SUCCESS - Extracted $packageName to the $path directory"
	}
	else {
		Write-Verbose "SKIPPING - $packageName is already extracted to the $path directory"
	}

	Import-Module (Join-Path $path "\tools\Sitecore.Cloud.Cmdlets.psm1")
	Import-Module (Join-Path $path "\tools\Sitecore.Cloud.Cmdlets.dll")
}
catch {
	Write-Error "ERROR $PSScriptName $($path) $($search):$_"
}