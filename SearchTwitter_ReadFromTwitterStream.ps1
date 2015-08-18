#Script input params
[CmdletBinding()]
Param(
[Parameter(Mandatory=$True,Position=1)]
[alias("q")]
[string]$searchTermArg, 

[Parameter(Mandatory=$True,Position=2)]
[alias("n")]
[string]$minsToCollect
);

$Date = Get-Date -format yyyy-MM-dd-HH-mm-ss
$Global:reportfile = $PSScriptRoot + "\TwitterReport-" + $searchTermArg + "-" + $Date + ".csv"

Add-Type -Assembly System.Web

$encodedSearchTerm = [System.Web.HttpUtility]::UrlEncode($searchTermArg) 
Write-Host "Encoded Search Term " $encodedSearchTerm  -ForegroundColor Green

$OAuth = @{'ApiKey' = 'YOURAPIKEYHERE'; 'ApiSecret' = 'YOURAPISECRETHERE'; 'AccessToken' = 'YOURACCESSTOKENHERE'; 'AccessTokenSecret' = 'YOURACCESSTOKENSECRETHERE'}

Invoke-ReadFromTwitterStream -OAuthSettings $OAuth -OutFilePath $Global:reportfile -ResourceURL 'https://stream.twitter.com/1.1/statuses/filter.json' -RestVerb 'POST' -Parameters @{'track' = $encodedSearchTerm} -MinsToCollectStream $minsToCollect
