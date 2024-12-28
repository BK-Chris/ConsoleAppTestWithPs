<#
    Script Name: testCases.ps1
    Description: This script automates the testing of an executable by comparing its output to expected output files.
                 It allows for file selection through GUI dialogs or manual input. The script can process multiple input
                 and expected output files and evaluate if the program produces the expected results.

    Usage: testCases.ps1 [options]

    Options:
        -help                                   Display this help message.
        <exePath> <inputPath> <expectedOutputs> Specify the paths to the executable and input/output files.
                                                If not provided, the script will prompt for file selection.
    Example:
        .\testCases.ps1 -help
        .\testCases.ps1 C:\path\to\executable.exe C:\path\to\input C:\path\to\expectedOutputs

#>
$DEBUG = $true;

function ShowHelp {
    Write-Host @"
Usage: testCases.ps1 [options]

Options:
    -help                                   Display this help message.
    <exePath> <inputPath> <expectedOutputs> Specify the paths to the executable and input file.
                                            If not provided, the script will prompt for file selection.

Description:
    * This script runs a specified executable on input files and compares the output to expected files.
    * If paths are not provided, the script will prompt the user to select files or folders manually.

Example:
    .\testCases.ps1 C:\path\to\executable.exe C:\path\to\input C:\path\to\expectedOutputs
"@
}

function ObtainPath() {
    param(
        [string]$title = $args[0],
        [string]$extension = $args[1]
    )
    try {
        # Try to load Windows Forms for the file dialog
        Add-Type -AssemblyName "System.Windows.Forms" -ErrorAction Stop

        # Display a message box to inform the user
        [System.Windows.Forms.MessageBox]::Show(
            "The selected file either not found or was not provided!`nPlease select a file with the .$extension extension in the dialog box that follows.",
            $title,
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information,
            [System.Windows.Forms.MessageBoxDefaultButton]::Button1,
            [System.Windows.Forms.MessageBoxOptions]::DefaultDesktopOnly
        ) | Out-Null  # Discard the return value of the MessageBox

        $dialog = New-Object System.Windows.Forms.OpenFileDialog;
        $dialog.Filter = "All files (*.$extension)|*.$extension"
        $dialog.Title = $title
        $dialog.Multiselect = $false
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            return $(Resolve-Path -Path $dialog.FileName).Path;
        }
        else {
            Write-Error "File selection was canceled."
            return $null
        }
    }
    catch {
        # If GUI dialogs are not available, fall back to manual input
        Write-Warning "GUI dialog not available. Falling back to manual input."
        $filePath = Read-Host "$title (Enter the full path, expected extension: .$extension)"
        if (-not (Test-Path $filePath)) {
            Write-Error "The specified file does not exist: $filePath"
            return $null
        }
        return $(Resolve-Path -Path $filePath).Path;
    }
}

function ObtainFolder {
    try {
        # Try to load Windows Forms for the folder dialog
        Add-Type -AssemblyName "System.Windows.Forms" -ErrorAction Stop
        
        # Create a folder browser dialog
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.Description = "Select a folder";

        # Show the dialog and get the selected path
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            return $(Resolve-Path -Path $dialog.SelectedPath).Path;
        }
        else {
            Write-Error "Folder selection was canceled."
            return $null
        }
    }
    catch {
        # If GUI dialogs are not available, fall back to manual input
        Write-Warning "GUI dialog not available. Falling back to manual input."
        $folderPath = Read-Host "$title (Enter the full path to the folder)"
        if (-not (Test-Path -Path $folderPath -PathType Container)) {
            Write-Error "The specified folder does not exist: $folderPath"
            return $null
        }
        return $(Resolve-Path -Path $folderPath).Path;
    }
}

function EvaulateResults() {
    $inputFile = $args[0];
    $expectedOutputFile = $args[1];
    $result = $($args[2]).Trim();

    $expectedResult = $(Get-Content $($expectedOutputFile)).Trim();

    if ($DEBUG) {
        Write-Host "Input path: $($inputFile.FullName)";
        Write-Host "Output path: $($expectedOutputFile.FullName)";
        Write-Host "Expected result:"
        Write-Host $expectedResult;
        Write-Host "Actual result:";
        Write-Host $result;
    }

    return $($result -eq $expectedResult);
}

if ($args[0] -eq "-help") {
    ShowHelp
    Exit(0)
}

if ($args.Length -ne 0 -and $args.Length -ne 3) {
    Write-Error "Invalid number of arguments. Use -help for usage information."
    Exit(1)
}

$exePath = $null;

if ($args.Length -eq 3) {
    $exePath = $($args[0]);
    $inputFolder = $($args[1]);
    $expectedOutputFolder = $($args[2]);

    # Checking the provided exe's path.
    if (-not (Test-Path $exePath)) {
        Write-Error "The specified file does not exist: $exePath"
        $exePath = $(ObtainPath "Select an executable file!" "exe");
    }
    # Checking the provided input folder path.
    if (-not (Test-Path $inputFolder -PathType Container)) {
        Write-Error "The specified folder does not exist: $inputFolder"
        $inputFolder = $(ObtainFolder);
    }
    # Checking the provided expected output folder path.
    if (-not (Test-Path $expectedOutputFolder -PathType Container)) {
        Write-Error "The specified folder does not exist: $expectedOutputFolder"
        $expectedOutputFolder = $(ObtainFolder);
    }
}
else {
    # Obtaining the required path's.
    $exePath = $(ObtainPath "Select the executable file!" "exe");
    $inputFolder = $(ObtainFolder);
    $expectedOutputFolder = $(ObtainFolder);
}

Write-Host "inputFolder: $inputFolder";
Write-Host "expected_output_folder: $expectedOutputFolder";

$inputs = $(Get-ChildItem $inputFolder -File);
$expectedOutputs = $(Get-ChildItem $expectedOutputFolder -File);
$result = $null;
for ($i = 0; $i -lt $inputs.Length; $i++) {
    try {
        $tempOutputFile = New-Item ".\temp_output_$i_$([guid]::NewGuid()).txt";

        Start-Process $exePath -RedirectStandardInput $inputs[$i].FullName -RedirectStandardOutput $tempOutputFile  -NoNewWindow  -Wait
        $result = $(Get-Content $tempOutputFile);
    
        $passed = EvaulateResults $($inputs[$i].FullName) $($expectedOutputs[$i].FullName) $result;

        if ($passed) {
            Write-Host "TEST $($i+1) PASSED" -BackgroundColor Green
        }
        else {
            Write-Host "TEST $($i+1) FAILED" -BackgroundColor Red
        }
    }
    catch {
        Write-Error "An error occurred during execution: $_"
    }
    finally {
        try {
            if ($null -ne $tempOutputFile) {
                Remove-Item $tempOutputFile -Force
            }
        }
        catch {
            Write-Warning "Failed to clean up temporary file: $tempOutputFile"
        }
    }
}

Read-Host "Nyomj egy gombot a kilépéshez...";
Exit(0);