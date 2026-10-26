# Windows counterpart of sync.sh. Keeps ~/.copilot identical on every machine through this
# repo. The repo is the source of truth for skills/ and instructions/: edit them HERE,
# never in ~/.copilot.
# Usage (from any directory):
#   powershell -NoProfile -ExecutionPolicy Bypass -File sync.ps1 pull                 git pull, then mirror the repo into ~/.copilot. Run BEFORE editing.
#   powershell -NoProfile -ExecutionPolicy Bypass -File sync.ps1 [push] ["message"]   mirror the repo into ~/.copilot, regenerate README tables, commit and push.
# MCP config is the exception: secrets live only in ~/.copilot/mcp-config.json, and sync.ps1
# does not redact it (mcp-config.redacted.json is left alone). Never copies session history,
# databases or logs. Needs only Windows PowerShell 5.1 and Git (no bash, rsync or python).

$ErrorActionPreference = 'Stop'

$Src = Join-Path $env:USERPROFILE '.copilot'
$Dest = $PSScriptRoot
$Utf8 = New-Object System.Text.UTF8Encoding($false)

$Command = 'push'
$rest = @($args)
if ($rest.Count -gt 0 -and ($rest[0] -eq 'pull' -or $rest[0] -eq 'push')) {
    $Command = $rest[0]
    $rest = @($rest | Select-Object -Skip 1)
}
$Message = $null
if ($rest.Count -gt 0) { $Message = [string]$rest[0] }
if (-not $Message) { $Message = 'Backup ' + (Get-Date -Format 'yyyy-MM-dd HH:mm') }

function Fail($text) {
    [Console]::Error.WriteLine($text)
    exit 1
}

$Git = $null
$cmd = Get-Command git -ErrorAction SilentlyContinue
if ($cmd) { $Git = $cmd.Source } else { $Git = 'C:\Program Files\Git\cmd\git.exe' }
if (-not (Test-Path -LiteralPath $Git)) { Fail 'git not found on PATH or at C:\Program Files\Git\cmd\git.exe' }

function Invoke-Git {
    & $Git @args
    if ($LASTEXITCODE -ne 0) { Fail "git $($args -join ' ') failed (exit $LASTEXITCODE)" }
}

Set-Location $Dest
foreach ($d in 'skills', 'instructions') { New-Item -ItemType Directory -Force -Path (Join-Path $Src $d) | Out-Null }

# Text is compared and written with LF line endings: the repo stores LF, while ~/.copilot
# files created on Windows may be CRLF.
function Get-NormalisedBytes($path) {
    $bytes = [IO.File]::ReadAllBytes($path)
    if ([Array]::IndexOf($bytes, [byte]0) -ge 0) { return , $bytes }
    $list = New-Object 'System.Collections.Generic.List[byte]' $bytes.Length
    for ($i = 0; $i -lt $bytes.Length; $i++) {
        if ($bytes[$i] -eq 13 -and ($i + 1) -lt $bytes.Length -and $bytes[$i + 1] -eq 10) { continue }
        $list.Add($bytes[$i])
    }
    return , $list.ToArray()
}

function Get-Hash($bytes) {
    $sha = [System.Security.Cryptography.SHA1]::Create()
    return [BitConverter]::ToString($sha.ComputeHash($bytes))
}

# Lists what mirroring $src into $dst would do (like rsync --delete -n): '+ file', '~ file', '- file'.
function Get-TreeChanges($src, $dst) {
    $changes = New-Object 'System.Collections.Generic.List[string]'
    $srcRoot = (Resolve-Path -LiteralPath $src).Path.TrimEnd('\')
    $dstRoot = $dst.TrimEnd('\')
    $seen = @{}
    Get-ChildItem -LiteralPath $srcRoot -Recurse -File -Force |
        Where-Object { $_.Name -ne '.DS_Store' } |
        ForEach-Object {
            $rel = $_.FullName.Substring($srcRoot.Length + 1)
            $seen[$rel.ToLowerInvariant()] = $true
            $target = Join-Path $dstRoot $rel
            if (-not (Test-Path -LiteralPath $target)) {
                $changes.Add("+ $rel")
            } elseif ((Get-Hash (Get-NormalisedBytes $_.FullName)) -ne (Get-Hash (Get-NormalisedBytes $target))) {
                $changes.Add("~ $rel")
            }
        }
    if (Test-Path -LiteralPath $dstRoot) {
        Get-ChildItem -LiteralPath $dstRoot -Recurse -File -Force |
            Where-Object { $_.Name -ne '.DS_Store' } |
            ForEach-Object {
                $rel = $_.FullName.Substring($dstRoot.Length + 1)
                if (-not $seen.ContainsKey($rel.ToLowerInvariant())) { $changes.Add("- $rel") }
            }
    }
    return , $changes.ToArray()
}

function Add-Prefix($prefix, $changes) {
    return @($changes | ForEach-Object { $_.Substring(0, 2) + $prefix + $_.Substring(2).Replace('\', '/') })
}

# Mirrors $src into $dst, deleting anything in $dst that is not in $src (like rsync --delete).
function Sync-Tree($src, $dst) {
    $srcRoot = (Resolve-Path -LiteralPath $src).Path.TrimEnd('\')
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    foreach ($change in (Get-TreeChanges $src $dst)) {
        $rel = $change.Substring(2)
        $target = Join-Path $dst $rel
        if ($change.StartsWith('-')) {
            Remove-Item -LiteralPath $target -Force
        } else {
            New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
            [IO.File]::WriteAllBytes($target, (Get-NormalisedBytes (Join-Path $srcRoot $rel)))
        }
    }
    Get-ChildItem -LiteralPath $dst -Recurse -Directory -Force |
        Sort-Object { $_.FullName.Length } -Descending |
        Where-Object { -not (Get-ChildItem -LiteralPath $_.FullName -Force) } |
        Remove-Item
}

function Sync-IntoCopilot {
    $applied = @()
    foreach ($d in 'skills', 'instructions') {
        $applied += Add-Prefix "$d/" (Get-TreeChanges (Join-Path $Dest $d) (Join-Path $Src $d))
        Sync-Tree (Join-Path $Dest $d) (Join-Path $Src $d)
    }
    return , $applied
}

# Mirroring overwrites ~/.copilot, so refuse if it holds edits that are not in the last commit.
function Assert-CopilotMatchesHead {
    $tmp = Join-Path $env:TEMP ('sync-head-' + [guid]::NewGuid().ToString('N'))
    $zip = "$tmp.zip"
    $changes = @()
    try {
        Invoke-Git archive --format=zip -o $zip HEAD skills instructions
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::ExtractToDirectory($zip, $tmp)
        foreach ($d in 'skills', 'instructions') {
            $changes += Add-Prefix "$d/" (Get-TreeChanges (Join-Path $Src $d) (Join-Path $tmp $d))
        }
    } finally {
        Remove-Item -LiteralPath $zip, $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
    if ($changes.Count -gt 0) {
        [Console]::Error.WriteLine('~/.copilot differs from the last commit (+ only in ~/.copilot, ~ modified, - missing from ~/.copilot; edits belong in the repo):')
        $changes | ForEach-Object { [Console]::Error.WriteLine($_) }
        Fail "Copy anything you want to keep into the repo's skills/ or instructions/, then re-run."
    }
}

if ($Command -eq 'pull') {
    if (& $Git status --porcelain -- skills instructions) {
        Fail "Repo has uncommitted edits in skills/ or instructions/. Run 'sync.ps1 push' first."
    }
    Assert-CopilotMatchesHead
    Invoke-Git pull -q --ff-only
    $applied = Sync-IntoCopilot
    if ($applied.Count -eq 0) {
        Write-Host 'Already up to date.'
    } else {
        $applied | ForEach-Object { Write-Host $_ }
        Write-Host 'Pulled.'
    }
    exit 0
}

# Pushing over a newer remote would silently drop the other machine's changes.
Invoke-Git fetch -q
if ((& $Git rev-list --count 'HEAD..@{u}') -ne '0') {
    Fail "The remote has commits that are not in this checkout.`nRun 'git stash', 'sync.ps1 pull', 'git stash pop', then re-run."
}
Assert-CopilotMatchesHead

# sync.sh blanks every env/header value in mcp-config.json. Re-serialising JSON here would
# change formatting and escaping, so redaction is not implemented: skip rather than risk a secret.
if (Test-Path -LiteralPath (Join-Path $Src 'mcp-config.json')) {
    Write-Host 'Note: mcp-config.json found but sync.ps1 does not redact it; mcp-config.redacted.json left unchanged.'
}

# Regenerate the README tables between the GENERATED markers from each file's frontmatter.
function Get-Frontmatter($path) {
    $fm = @{}
    $m = [regex]::Match([IO.File]::ReadAllText($path), '(?s)\A---\r?\n(.*?)\r?\n---')
    if ($m.Success) {
        foreach ($line in ($m.Groups[1].Value -split '\r?\n')) {
            if ($line -match '^[^#\s][^:]*:') {
                $i = $line.IndexOf(':')
                $fm[$line.Substring(0, $i).Trim()] = $line.Substring($i + 1).Trim().Trim('"').Trim("'")
            }
        }
    }
    return $fm
}

function Get-Cell($s) { return $s.Replace('|', '\|').Trim() }

function Get-SortedPaths($paths) {
    $arr = @($paths)
    [Array]::Sort($arr, [StringComparer]::Ordinal)
    return $arr
}

$out = New-Object 'System.Collections.Generic.List[string]'
$out.AddRange([string[]]@('### Instructions (`instructions/`)', '', '| File | Summary | applyTo |', '|---|---|---|'))
$instructionFiles = Get-SortedPaths (Get-ChildItem (Join-Path $Dest 'instructions') -Filter '*.md' -File | ForEach-Object { $_.FullName })
foreach ($path in $instructionFiles) {
    $fm = Get-Frontmatter $path
    $applies = 'none (always loaded)'
    if ($fm.ContainsKey('applyTo') -and $fm['applyTo']) { $applies = '`' + $fm['applyTo'] + '`' }
    $desc = '(no description)'
    if ($fm.ContainsKey('description')) { $desc = $fm['description'] }
    $out.Add('| `' + (Split-Path $path -Leaf) + '` | ' + (Get-Cell $desc) + ' | ' + $applies + ' |')
}

$out.AddRange([string[]]@('', '### Skills (`skills/`)', '', '| Skill | Summary | Load when |', '|---|---|---|'))
$skillFiles = Get-SortedPaths (Get-ChildItem (Join-Path $Dest 'skills') -Directory | ForEach-Object { Join-Path $_.FullName 'SKILL.md' } | Where-Object { Test-Path -LiteralPath $_ })
foreach ($path in $skillFiles) {
    $fm = Get-Frontmatter $path
    $desc = '(no description)'
    if ($fm.ContainsKey('description')) { $desc = $fm['description'] }
    $parts = (New-Object System.Text.RegularExpressions.Regex('\bUse when:\s*')).Split($desc, 2)
    $summary = $parts[0].TrimEnd(' ', '.') + '.'
    $triggers = ''
    if ($parts.Count -gt 1) { $triggers = $parts[1].TrimEnd(' ', '.') + '.' }
    $name = Split-Path (Split-Path $path -Parent) -Leaf
    $out.Add('| `' + $name + '` | ' + (Get-Cell $summary) + ' | ' + (Get-Cell $triggers) + ' |')
}

$readme = Join-Path $Dest 'README.md'
$text = [IO.File]::ReadAllText($readme)
$begin = '<!-- BEGIN GENERATED -->'
$end = '<!-- END GENERATED -->'
if (-not $text.Contains($begin) -or -not $text.Contains($end)) { Fail 'README.md is missing the GENERATED markers' }
$pre = $text.Substring(0, $text.IndexOf($begin))
$rest = $text.Substring($text.IndexOf($begin) + $begin.Length)
$post = $rest.Substring($rest.IndexOf($end) + $end.Length)
[IO.File]::WriteAllText($readme, $pre + $begin + "`n" + ($out -join "`n") + "`n" + $end + $post, $Utf8)

$secretPattern = 'glpat-|ghp_|github_pat_|AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH|PRIVATE)'
$hits = Get-ChildItem -LiteralPath $Dest -Recurse -File -Force |
    Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.Name -notin @('sync.sh', 'sync.ps1') } |
    Select-String -Pattern $secretPattern -List |
    ForEach-Object { $_.Path }
if ($hits) {
    $hits | ForEach-Object { [Console]::Error.WriteLine($_) }
    Fail 'Possible secret found in the files above; aborting.'
}

[void](Sync-IntoCopilot)

Invoke-Git add -A
& $Git diff --cached --quiet
if ($LASTEXITCODE -ne 0) { Invoke-Git commit -q -m $Message }
# Also covers a previous run that committed but failed to push.
if ((& $Git rev-list --count '@{u}..HEAD') -eq '0') {
    Write-Host 'No changes to back up.'
    exit 0
}
Invoke-Git push -q origin HEAD
Write-Host 'Backed up.'
