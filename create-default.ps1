if(![bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) {
    Write-Warning "Please run as Administrator!"
    exit
}

$folderName = Read-Host "Name of Notes base directory"

if ([string]::IsNullOrWhiteSpace($folderName)) {
    Write-Warning "Invalid folder name. Please rerun the script."
    exit
}

$desktopPath = [Environment]::GetFolderPath('Desktop')
$folderPath = Join-Path -Path $desktopPath -ChildPath $folderName

if (-not (Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath | Out-Null
    Set-Location -Path $folderPath

    # Create the 'notes' subdirectory
    $notes = Join-Path -Path $folderPath -ChildPath "notes"
    New-Item -ItemType Directory -Path $notes | Out-Null
    Set-Location -Path $notes

    # Create and write to .gitignore file
    $content = ".obsidian/*",
        ".vscode/*",
        "excalidraw/*",
        "*.pdf"
    Set-Content -Path "$notes\.gitignore" -Value $content
    Set-Content -Path "$notes\README.md" -Value "# Week 1 Lecture"
    New-Item -ItemType Directory -Path "$notes\assets" | Out-Null
    cmd.exe /c "git init . & git add ."


    Write-Output "Done creating $folderName on Desktop."
}
