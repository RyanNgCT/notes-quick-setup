if(![bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) {
    Write-Warning "Please run as Administrator!"
    exit
}

$folderName = (Read-Host "Name of Notes base directory").ToUpper()

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

    # Pull course title from NUSMods API
    $apiUrl = "https://api.nusmods.com/v2/2025-2026/modules/$folderName.json"
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction Stop
        $moduleTitle = $response.title
    } catch {
        Write-Warning "Could not retrieve module title from NUSMods API."
        $moduleTitle = ""
    }

    # Create README with populated title
    if ($moduleTitle -eq ""){
        Set-Content -Path "$notes\README.md" -Value "$folderName"
    }
    else{
        Set-Content -Path "$notes\README.md" -Value "$folderName - $moduleTitle"
    }

    # Create subdirectories and default file
    New-Item -ItemType Directory -Path "$notes\Week 1" | Out-Null
    New-Item -ItemType Directory -Path "$notes\assets" | Out-Null
    Set-Content -Path "$notes\Week 1\Lecture 1.md" -Value "# Week 1 Lecture"

    # Initialize git repo
    cmd.exe /c "git init . & git add ."

    Write-Output "Done creating $folderName on Desktop."
} else {
    Write-Output "$folderName already exists on Desktop."
}
