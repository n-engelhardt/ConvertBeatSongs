#This script written to convert Beat Saber songs to the new format

#Set the beat saber directory
Write-Host "Setting Beat Saber directory.."

Try {
    #Attempt to get the beat saber directory from the registry
    $BSABER = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Where Name -Match "Steam App 620980" | % {Get-ItemProperty $_.PsPath} -ErrorAction Stop

    #Switch to the directory and check that the beat saber program exists
    Set-Location $BSABER.InstallLocation -ErrorAction Stop
    If (!(Test-Path ".\Beat Saber.exe")) {
            Read-Host -Prompt "Set beat saber dir, but unable to find beat saber program. Press enter to exit"
        }

    #Set the BeatSaberDir Variable
    $BeatSaberDir = $BSABER.InstallLocation
}

#If the previous steps didn't find the beat saber directory, prompt for it manually.
Catch {
    Try {
        #Prompt for the directory from the user
        $BeatSaberDir = Read-Host -Prompt "Please input your beat saber directory"

        #Switch to the directory and check that the program 
        Set-Location $BeatSaberDir -ErrorAction Stop
        If (!(Test-Path ".\Beat Saber.exe")) {
            Read-Host -Prompt "Set beat saber dir, but unable to find beat saber program. Press enter to exit"
        }
    }
    Catch {
        #If that didn't work, let them know and dip the hell out
        Write-Host "Error: Unable to set Beat Saber directory"
        Read-Host -Prompt "Press enter to continue..."
        Exit
    }
}

#Make sure there's a custom songs folder
If (!(Test-Path .\CustomSongs)) {
    Read-Host -Prompt "No custom songs directory found. Press enter to exit"
    Exit
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

#Copy the songs to the new folder
Write-Host "Copying songs to new folder..."

Try {
    #Get all the folders that have the weird numbered directories
    $KeyFolders = Get-ChildItem .\CustomSongs | Select-String -Pattern "\d{1,4}-\d{1,4}" -ErrorAction Stop
}
Catch {
    Write-Host "Failed to get child folders: $_"
}

ForEach ($KeySongDir in $KeyFolders) {
    #Copy the subfolder with the song name to the new song location
    Write-Host "Copying $KeySongDir"
    Try {
        Copy-Item .\CustomSongs\$KeySongDir\* -Recurse '.\Beat Saber_Data\CustomLevels\' -ErrorAction Stop
    }
    Catch {
        Write-Host "Failed to copy $KeySongDir\`: $_"
    }
}

#Now get a list of all the song folders
$CopyFolders = Get-ChildItem $BeatSaberDir\CustomSongs

#Get the ones we haven't already taken care of (the named, not numbered ones)
$DifferenceFolders = Compare-Object $KeyFolders $CopyFolders -PassThru

#Copy them to the new location
ForEach ($DifferenceFoldersSong in $DifferenceFolders) {
    Write-Host "Copying $DifferenceFoldersSong"
    Try {
        Copy-Item $BeatSaberDir\CustomSongs\$DifferenceFoldersSong -Recurse '.\Beat Saber_Data\CustomLevels\' -ErrorAction Stop
    }
    Catch {
        Write-Host "Failed to copy $DifferenceFoldersSong`: $_"
    }
}

#Let tem know we finished
Read-Host -Prompt "Finished. Press Enter to continue"