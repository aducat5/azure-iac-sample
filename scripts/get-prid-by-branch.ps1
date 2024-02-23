<#
.SYNOPSIS
This script fetches the ID of a pull request by its head branch name for a given GitHub repository.

.PARAMETER Owner
The owner (user or organization) of the GitHub repository.

.PARAMETER Repo
The name of the GitHub repository.

.PARAMETER BranchName
The name of the head branch for which the pull request ID should be fetched.

.PARAMETER Token
The GitHub Personal Access Token.

.EXAMPLE
.\get-prid-by-branch.ps1 -Owner "YourGitHubUsername" -Repo "YourRepositoryName" -BranchName "your-branch-name" -Token "YourPersonalAccessToken"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Owner,

    [Parameter(Mandatory=$true)]
    [string]$Repo,

    [Parameter(Mandatory=$true)]
    [string]$BranchName,

    [Parameter(Mandatory=$true)]
    [string]$Token
)

$headers = @{
    "Authorization" = "Bearer $Token"
    "Accept" = "application/vnd.github.v3+json"
}

$response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$Repo/pulls" -Headers $headers -Method Get

$pullRequest = $response | Where-Object { $_.head.ref -eq $BranchName }

if ($pullRequest) {
    Write-Host "ID of the pull request with head branch '$BranchName': $($pullRequest.id)"
    return $pullRequest.id
} else {
    Write-Host "No pull request found for head branch '$BranchName'"
    return $null
}