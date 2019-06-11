#This script written to convert Beat Saber songs to the new format

#Set the beat saber directory
Write-Host "Setting Beat Saber directory.."

Try {
    $BeatSaberDir = "${env:ProgramFiles(x86)}\Steam\steamapps\common\Beat Saber"
    Set-Location $BeatSaberDir -ErrorAction Stop
}
Catch {
    Try {
        $BeatSaberDir = Read-Host -Prompt "Please input your beat saber directory"
        Set-Location $BeatSaberDir -ErrorAction Stop
    }
    Catch {
        Write-Host "Error: Unable to set Beat Saber directory"
        Exit
    }
}

Write-Host "Downloading song converter..."
#Get the song converter
Try {
    Invoke-WebRequest -OutFile $BeatSaberDir\songe-converter.exe https://github.com/lolPants/songe-converter/releases/download/v0.5.0/songe-converter.exe -ErrorAction Stop
}
Catch {
    Write-Host "Error downloading file: $_"
}

Write-Host "Converting the songs..."
#Run the song convert on songs
.\songe-converter.exe -k -g '**/info.json' .\CustomSongs


Write-Host "Copying songs to new folder..."
Try {
    $KeyFolders = Get-ChildItem .\CustomSongs | Select-String -Pattern "\d{1,4}-\d{1,4}"
}
Catch {
    Write-Host "Failed to get child folders: $_"
}

ForEach ($KeySongDir in $KeyFolders) {
    Write-Host "Copying $KeySongDir"
    Try {
        Copy-Item .\CustomSongs\$KeySongDir\* -Recurse '.\Beat Saber_Data\CustomLevels\' -ErrorAction Stop
    }
    Catch {
        Write-Host "Failed to copy $KeySongDir\`: $_"
    }
}

$CopyFolders = Get-ChildItem .\CustomSongs

$Difference = Compare-Object $KeyFolders $CopyFolders -PassThru

ForEach ($DifferenceSong in $Difference) {
    Write-Host "Copying $DifferenceSong"
    Try {
        Copy-Item .\CustomSongs\$DifferenceSong -Recurse '.\Beat Saber_Data\CustomLevels\' -ErrorAction Stop
    }
    Catch {
        Write-Host "Failed to copy $DifferenceSong`: $_"
    }
}

Read-Host -Prompt "Press Enter to continue"