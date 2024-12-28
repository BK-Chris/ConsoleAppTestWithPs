<#
testInput.ps1

Purpose:
    This script is designed to test Windows applications that accept redirected input from STDIN. It executes a specified executable file with a redirected input file and displays the output. If arguments are not provided, the script uses file dialogs to select the executable and input file.

Requirements:
    - .NET Framework 4.0 or higher (required for Windows Forms support)
    - PowerShell 5.1 or higher (required for script compatibility)
    - ExecutionPolicy set to at least RemoteSigned (for script execution)

Usage:
    The usage of this script is described in the `ShowHelp` function. Alternatively, you can use the `-help` option to view the usage instructions.

    Example 1:
        testInput.ps1 "C:\Path\to\program.exe" "C:\Path\to\input.txt"
    Example 2:
        testInput.ps1  # Select the executable (exe) first, then select the input (txt) file.

Notes:
    - When `$dialog.Topmost = $true` is uncommented in PowerShell ISE and Visual Studio Code, it causes the script to fall back to manual input, despite the intended behavior of displaying the file dialog.
    - In Visual Studio Code, this results in the file dialog being sent behind the main window, which can be inconvenient for the user experience.

    This behavior can be avoided by leaving `$dialog.Topmost` commented out.

    Additionally, if the script detects that GUI dialogs are unavailable (e.g., in headless environments or specific editors), it will prompt the user for manual input via `Read-Host`.
#>
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
        # $dialog.Topmost = $true
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            return $($dialog.FileName);
        } else {
            Write-Error "File selection was canceled."
            return $null
        }
    } catch {
        # If GUI dialogs are not available, fall back to manual input
        Write-Warning "GUI dialog not available. Falling back to manual input."
        $filePath = Read-Host "$title (Enter the full path, expected extension: .$extension)"
        if (-not (Test-Path $filePath)) {
            Write-Error "The specified file does not exist: $filePath"
            return $null
        }
        return $filePath
    }
}

# Check for help argument
if ($args[0] -eq "-help") {
    ShowHelp
    Exit(0)
}

if ($args.Length -ne 0 -and $args.Length -ne 2) {
    Write-Error "Invalid number of arguments. Use -help for usage information."
    Exit(1)
}
$exePath = $null;
$inputPath = $null;

if($args.Length -eq 2){
# Checking the provided exe's path.
    $exePath = $args[0];
    if(-not (Test-Path $exePath)){
        Write-Error "The specified file does not exist: $exePath"
        $exePath = $(ObtainPath "Select an executable file!" "exe");
    }
# Checking the provided input's path.
    $inputPath = $args[1];
    if(-not (Test-Path $inputPath)){
        Write-Error "The specified file does not exist: $inputPath"
        $inputPath = $(ObtainPath "Select the input file to be redirected!" "txt");
    }
} else {
# Obtaining the required path's.
    $exePath = $(ObtainPath "Select the executable file!" "exe");
    $inputPath = $(ObtainPath "Select the input file to be redirected!" "txt");
}


try {
    $tempOutputFile = New-Item ".\temp_output_$([guid]::NewGuid()).txt";
    Write-Host "Exe's path: $exePath";
    Write-Host "Input's path: $inputPath";
    Start-Process $exePath -RedirectStandardInput $inputPath -RedirectStandardOutput $tempOutputFile -NoNewWindow -Wait
    Write-Host "Result:"
    Write-Host $(Get-Content $tempOutputFile)
} catch {
    Write-Error "An error occurred during execution: $_"
} finally {
    try {
        if ($null -ne $tempOutputFile){
            Remove-Item $tempOutputFile -Force
        }
    } catch {
        Write-Warning "Failed to clean up temporary file: $tempOutputFile"
    }
}
Read-Host "Press any key to exit...";
Exit(0);