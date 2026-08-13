$folderName = (Read-Host "Name of Notes base directory").ToUpper()

if ([string]::IsNullOrWhiteSpace($folderName)) {
    Write-Warning "Invalid folder name. Please rerun the script."
    exit
}

$documentsPath = [Environment]::GetFolderPath('Documents')
$folderPath = Join-Path -Path $documentsPath -ChildPath $folderName

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
    $apiUrl = "https://api.nusmods.com/v2/2026-2027/modules/$folderName.json"
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction Stop
        $moduleTitle = $response.title
    } catch {
        Write-Warning "Could not retrieve module title from NUSMods API."
        $moduleTitle = ""
    }

    # Create README with populated title
    if ($moduleTitle -eq ""){
        Set-Content -Path "$notes\README.md" -Value "# $folderName"
    }
    else{
        Set-Content -Path "$notes\README.md" -Value "# $folderName - $moduleTitle"
    }

    # Create subdirectories and default file
    New-Item -ItemType Directory -Path "$notes\Week 1" | Out-Null
    New-Item -ItemType Directory -Path "$notes\assets" | Out-Null
    New-Item -Path "$notes\Week 1\Lecture 1 - Introduction.md" -ItemType File -Force | Out-Null

    # Initialize git repo
    cmd.exe /c "git init . & git add ."

    Write-Output "Done creating $folderName on Documents."
} else {
    Write-Output "$folderName already exists on Documents."
}
