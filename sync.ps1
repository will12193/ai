# Windows counterpart of sync.sh. Copies shareable Copilot config from ~/.copilot into
# this repo, regenerates the README tables, then commits and pushes.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File .\sync.ps1 ["commit message describing what changed and why"]
# Never copies session history, databases, logs or unredacted MCP config.
# Needs only Windows PowerShell 5.1 and Git (no bash, rsync or python).
param([string]$Message)

$ErrorActionPreference = 'Stop'

$Src = Join-Path $env:USERPROFILE '.copilot'
$Dest = $PSScriptRoot
if (-not $Message) { $Message = 'Backup ' + (Get-Date -Format 'yyyy-MM-dd HH:mm') }
$Utf8 = New-Object System.Text.UTF8Encoding($false)

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

# Synced paths are overwritten below; refuse to destroy edits made in the repo by mistake.
$dirty = & $Git status --porcelain -- skills instructions mcp-config.redacted.json
if ($dirty) {
    [Console]::Error.WriteLine('Repo has uncommitted changes in synced paths (~/.copilot is the source of truth):')
    $dirty | ForEach-Object { [Console]::Error.WriteLine($_) }
    Fail 'Port them into ~/.copilot or discard them (git checkout -- <path>), then re-run.'
}

# Another machine may have pushed; sync from an up-to-date checkout.
Invoke-Git pull -q --ff-only

# The repo stores LF; ~/.copilot files on Windows are CRLF, so normalise text files on copy.
function Copy-Normalised($from, $to) {
    $bytes = [IO.File]::ReadAllBytes($from)
    if ([Array]::IndexOf($bytes, [byte]0) -lt 0) {
        $list = New-Object 'System.Collections.Generic.List[byte]' $bytes.Length
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            if ($bytes[$i] -eq 13 -and ($i + 1) -lt $bytes.Length -and $bytes[$i + 1] -eq 10) { continue }
            $list.Add($bytes[$i])
        }
        $bytes = $list.ToArray()
    }
    [IO.File]::WriteAllBytes($to, $bytes)
}

# Mirror $src into $dst, deleting anything in $dst that is not in $src (like rsync --delete).
function Sync-Tree($src, $dst) {
    $srcRoot = (Resolve-Path -LiteralPath $src).Path.TrimEnd('\')
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    $keep = @{}
    Get-ChildItem -LiteralPath $srcRoot -Recurse -File -Force |
        Where-Object { $_.Name -ne '.DS_Store' } |
        ForEach-Object {
            $target = Join-Path $dst $_.FullName.Substring($srcRoot.Length + 1)
            New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
            Copy-Normalised $_.FullName $target
            $keep[$target.ToLowerInvariant()] = $true
        }
    Get-ChildItem -LiteralPath $dst -Recurse -File -Force |
        Where-Object { -not $keep.ContainsKey($_.FullName.ToLowerInvariant()) } |
        Remove-Item -Force
    Get-ChildItem -LiteralPath $dst -Recurse -Directory -Force |
        Sort-Object { $_.FullName.Length } -Descending |
        Where-Object { -not (Get-ChildItem -LiteralPath $_.FullName -Force) } |
        Remove-Item
}

Sync-Tree (Join-Path $Src 'skills') (Join-Path $Dest 'skills')
Sync-Tree (Join-Path $Src 'instructions') (Join-Path $Dest 'instructions')

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

Invoke-Git add -A
& $Git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host 'No changes to back up.'
    exit 0
}
Invoke-Git commit -q -m $Message
Invoke-Git push -q origin HEAD
Write-Host 'Backed up.'
