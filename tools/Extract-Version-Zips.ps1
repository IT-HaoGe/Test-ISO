$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$zipFiles = @(Get-ChildItem -LiteralPath $root -File -Filter '*.zip')

if ($zipFiles.Count -eq 0) {
    Write-Host "No ZIP files found in: $root"
    exit 0
}

foreach ($zipFile in $zipFiles) {
    # Example: 26200.9550_amd64_en-us_multi_xxx_convert.zip -> 26200 / 26200.9550 / amd64
    if ($zipFile.BaseName -notmatch '^(?<version>\d+\.\d+)(?:_|$)') {
        Write-Warning "Skipping ZIP with an unrecognized version: $($zipFile.Name)"
        continue
    }

    $fullVersion = $Matches.version
    $buildNumber = ($fullVersion -split '\.')[0]
    if ($zipFile.BaseName -notmatch '(?:^|_)(?<architecture>x86|amd64)(?:_|$)') {
        Write-Warning "Skipping ZIP without a recognized architecture (x86 or amd64): $($zipFile.Name)"
        continue
    }
    $architecture = $Matches.architecture
    $matchingFolders = @(Get-ChildItem -LiteralPath $root -Directory | Where-Object {
        $_.Name -match "(?<!\d)$([regex]::Escape($buildNumber))\.\d+(?!\d)" -and
        $_.Name -match "(?:^|_)$([regex]::Escape($architecture))(?:_|$)"
    })

    if ($matchingFolders.Count -ne 1) {
        Write-Warning "Expected exactly one folder containing '$buildNumber' for '$($zipFile.Name)', found $($matchingFolders.Count). ZIP kept."
        continue
    }

    $sourceName = $matchingFolders[0].Name
    $updatedName = [regex]::Replace(
        $sourceName,
        "(?<!\d)$([regex]::Escape($buildNumber))\.\d+(?!\d)",
        [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $fullVersion },
        1
    )
    $targetName = $updatedName
    $targetFolder = Join-Path $root $targetName
    $sourceFolder = $matchingFolders[0].FullName

    if (-not [string]::Equals($sourceFolder, $targetFolder, [StringComparison]::OrdinalIgnoreCase)) {
        if (Test-Path -LiteralPath $targetFolder) {
            Write-Warning "Target folder already exists: $targetFolder. ZIP kept."
            continue
        }
        Rename-Item -LiteralPath $sourceFolder -NewName $targetName
    }

    # Clear the destination contents before extracting this archive.
    Get-ChildItem -LiteralPath $targetFolder -Force | Remove-Item -Recurse -Force
    Expand-Archive -LiteralPath $zipFile.FullName -DestinationPath $targetFolder -Force
    Remove-Item -LiteralPath $zipFile.FullName -Force
    Write-Host "Extracted '$($zipFile.Name)' to '$targetFolder' and removed the ZIP."
}
