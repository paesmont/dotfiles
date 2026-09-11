<#
.SYNOPSIS
    Cria symlinks dos dotfiles para a home directory.
.DESCRIPTION
    Cria junctions (diretórios) e symlinks (arquivos) apontando da home
    para os arquivos em dotfiles. Junctions não precisam de admin;
    symlinks de arquivo precisam de Developer Mode ou admin.
#>

$ErrorActionPreference = "Stop"

$DotfilesDir = "$PSScriptRoot"
$HomeDir = "$env:USERPROFILE"

# ── Arquivos na raiz do dotfiles → home ──────────────────────────────
$RootFiles = @(
    ".bashrc",
    ".zshrc"
)

# ── Pastas/arquivos em .config/ → ~/.config/ ────────────────────────
$ConfigItems = @(
    "DankMaterialShell",
    "Thunar",
    "alacritty",
    "autostart",
    "doom",
    "fish",
    "ghostty",
    "hypr",
    "kitty",
    "niri",
    "nvim",
    "opencode",
    "starship.toml",
    "waybar",
    "wezterm"
)

# ── Pastas em .agents/ → ~/.agents/ ─────────────────────────────────
$AgentItems = @(
    "rules",
    "skills"
)

function New-SafeLink {
    param(
        [string]$LinkPath,
        [string]$TargetPath
    )

    $linkDir = Split-Path $LinkPath -Parent
    if (-not (Test-Path $linkDir)) {
        New-Item -ItemType Directory -Path $linkDir -Force | Out-Null
    }

    if (Test-Path $LinkPath) {
        try {
            $item = Get-Item $LinkPath -Force -ErrorAction Stop
        } catch {
            Write-Host "  [ERRO] Não foi possível ler $LinkPath : $_" -ForegroundColor Red
            return
        }

        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $existingTarget = $item.Target
            if ($existingTarget -eq $TargetPath) {
                Write-Host "  [SKIP] $LinkPath (já linkado)" -ForegroundColor DarkGray
                return
            }
            Write-Host "  [REPLACE] $LinkPath (removendo link antigo)" -ForegroundColor Yellow
            cmd /c rmdir "$LinkPath" 2>$null
            if (Test-Path $LinkPath) {
                Remove-Item $LinkPath -Force -Recurse -ErrorAction SilentlyContinue
            }
        } else {
            Write-Host "  [BACKUP] $LinkPath -> .bak" -ForegroundColor Yellow
            $bakPath = "$LinkPath.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Rename-Item $LinkPath $bakPath -Force
        }
    }

    $isDir = Test-Path $TargetPath -PathType Container
    try {
        if ($isDir) {
            New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath -Force | Out-Null
        } else {
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
        }
        Write-Host "  [OK] $LinkPath -> $TargetPath" -ForegroundColor Green
    } catch {
        Write-Host "  [ERRO] $LinkPath : $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Dotfiles Symlinker ===" -ForegroundColor Cyan
Write-Host "Dotfiles dir: $DotfilesDir"
Write-Host "Home dir:     $HomeDir"
Write-Host ""

# ── Arquivos raiz ───────────────────────────────────────────────────
Write-Host "--- Arquivos da raiz ---" -ForegroundColor Yellow
foreach ($file in $RootFiles) {
    $source = Join-Path $DotfilesDir $file
    $target = Join-Path $HomeDir $file
    if (Test-Path $source) {
        New-SafeLink -LinkPath $target -TargetPath $source
    } else {
        Write-Host "  [WARN] $source não encontrado, pulando..." -ForegroundColor DarkYellow
    }
}

# ── .config ─────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- .config/ ---" -ForegroundColor Yellow
foreach ($item in $ConfigItems) {
    $source = Join-Path $DotfilesDir ".config\$item"
    $target = Join-Path $HomeDir ".config\$item"
    if (Test-Path $source) {
        New-SafeLink -LinkPath $target -TargetPath $source
    } else {
        Write-Host "  [WARN] $source não encontrado, pulando..." -ForegroundColor DarkYellow
    }
}

# ── .agents ─────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- .agents/ ---" -ForegroundColor Yellow
foreach ($item in $AgentItems) {
    $source = Join-Path $DotfilesDir ".agents\$item"
    $target = Join-Path $HomeDir ".agents\$item"
    if (Test-Path $source) {
        New-SafeLink -LinkPath $target -TargetPath $source
    } else {
        Write-Host "  [WARN] $source não encontrado, pulando..." -ForegroundColor DarkYellow
    }
}

Write-Host ""
Write-Host "=== Concluído! ===" -ForegroundColor Cyan
