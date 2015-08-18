#Script input params
[CmdletBinding()]
Param(
[Parameter(Mandatory=$True,Position=1)]
[alias("q")]
[string]$searchTermArg
);

$Date = Get-Date -format yyyy-MM-dd-HH-mm-ss
$Global:reportfile = $PSScriptRoot + "\TwitterReport-" + $searchTermArg + "-" + $Date + ".csv"

Add-Type -Assembly System.Web

$encodedSearchTerm = [System.Web.HttpUtility]::UrlEncode($searchTermArg) 
Write-Host "Encoded Search Term " $encodedSearchTerm  -ForegroundColor Green

$OAuth = @{'ApiKey' = 'YOURAPIKEYHERE'; 'ApiSecret' = 'YOURAPISECRETHERE'; 'AccessToken' = 'YOURACCESSTOKENHERE'; 'AccessTokenSecret' = 'YOURACCESSTOKENSECRETHERE'}
$response = Invoke-TwitterRestMethod -ResourceURL 'https://api.twitter.com/1.1/search/tweets.json' -RestVerb 'GET' -OAuthSettings $OAuth  -Parameters @{'q' = $searchTermArg ; 'count' = '100'; 'result_type' = 'recent'}
$reportData = $response.statuses
$resultsarray =@()

foreach ($item in $reportData) {

    $handle = foreach ($useritem in $item.user) {
        $useritem.screen_name
    }

    $tweetObj = new-object PSObject
    $tweetObj | add-member -membertype NoteProperty -name "CreatedDate" -Value $item.created_at
    $tweetObj | add-member -membertype NoteProperty -name "TweetBody" -Value $item.text
    $tweetObj | add-member -membertype NoteProperty -name "Language" -Value $item.lang
    $tweetObj | add-member -membertype NoteProperty -name "FavCount" -Value $item.favorite_count
    $tweetObj | add-member -membertype NoteProperty -name "Retweeted" -Value $item.retweeted
    $tweetObj | add-member -membertype NoteProperty -name "UserHandle" -Value $handle
    $tweetObj | add-member -membertype NoteProperty -name "URL" -Value ("http://www.twitter.com/" + $handle.ToString() + "/status/" + $item.id.ToString())
    $resultsarray += $tweetObj

    Write-Host $item.created_at, $item.text, $item.lang, $item.favorite_count, $item.retweeted, $handle
}
$resultsarray | Export-csv -path $Global:reportfile;
