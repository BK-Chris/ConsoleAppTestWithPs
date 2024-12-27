function ShowHelp {
    Write-Host @"
Usage: testInput.ps1 [options]

Options:
    -help                 Display this help message.
    <exePath> <inputPath> Specify the paths to the executable and input file.
                         If not provided, the script will prompt for file selection.

Description:
    This script executes a specified executable file with an input file redirected
    and displays the output. If arguments are not provided, file dialogs are used
    to select the executable and input file.

Example:
    testInput.ps1 "C:\Path\to\program.exe" "C:\Path\to\input.txt"
    testInput.ps1 # Select the executable (exe) first then select the input (txt) file.
"@
}

function ObtainPath(){
    param(
        [string]$title = $args[0],
        [string]$extension = $args[1]
    )

    Add-Type -AssemblyName "System.Windows.Forms";
    $dialog = New-Object System.Windows.Forms.OpenFileDialog;
    $dialog.Filter = "All files (*.$extension)|*.$extension";
    $dialog.Title = $title;
    $dialog.Multiselect = $false;

     if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.FileName
    } else {
        return $null
    }
}

# Check for help argument
if ($args[0] -eq "-help") {
    ShowHelp
    Exit(0)
}

# Check for arguments or prompt the user to select the executable and input file
if ($args.Length -eq 2) {
    $exePath = $args[0];
    $inputPath = $args[1];
} else {
    $exePath = $(ObtainPath "Select the executable file!" "exe");
    $inputPath = $(ObtainPath "Select the input file to be redirected!" "txt");
}

if ($exePath -eq $null -or $inputPath -eq $null){
    Write-Error "Did not select the executable's or input's path!";
    Read-Host "Press any key to exit...";
    Exit(1);
}

$tempOutputFile = ".\temp_output.txt";
Start-Process $exePath -RedirectStandardInput $inputPath -RedirectStandardOutput $tempOutputFile  -NoNewWindow  -Wait;

Write-Host "Result:";
Write-Host $(Get-Content $tempOutputFile);

Read-Host "Press any key to exit...";
Exit(0);