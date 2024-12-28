# Application test with redirection and powershell

> ## Content
> - [Project Goal](#project-goal)
> - [Requirements](#requirements)
> - [Single-Test .\testInput.ps1](#single-test-testinputps1)
>   - [Overview](#overview)
>   - [Usage](#usage)
> - [Multi-Test .\testCases.ps1](#multi-test-testcasesps1)
>   - [Overview](#overview-1)
>   - [Usage](#usage-1)
> - [Notes](#notes)
> - [Future Enhancements](#future-enhancements)
> - [License](#license)

---

## Project goal
The goal of the project is to provide easy, quick and somewhat user friendly way to redirect inputs to an application which is prepared for it. The scripts are meant to be used to test cases

Main working part in both scripts:
```powershell
Start-Process $executablePath -RedirectStandardInput $inputPath -RedirectStandardOutput $temporarlyFile -NoNewWindow -Wait
```

## Requirements

- **.NET Framework 4.0** or higher (required for Windows Forms support)
- **PowerShell 5.1** or higher (required for script compatibility)
- **ExecutionPolicy** set to at least `RemoteSigned` (for script execution)

## Single-Test .\testInput.ps1
*Note: Does not provide comperasion, meant to be used during development.*

### Overview

`testInput.ps1` is a PowerShell script designed to test Windows applications that accept redirected input from STDIN. The script executes a specified executable file with a redirected input file and displays the output. If the necessary arguments are not provided, the script will prompt the user to select the executable and input file through file dialogs. In environments where GUI dialogs are unavailable, the script falls back to manual input.

### Usage

You can use the script either by specifying the executable and input file as arguments or by letting the script prompt you to select the files.

#### Example 1: Specifying Arguments

```powershell
.\testInput.ps1 "C:\Path\to\program.exe" "C:\Path\to\input.txt"
```

#### Example 2: -help Flag

```powershell
.\testInput.ps1 -help
```

#### Example 3: No Arguments

```powershell
.\testInput.ps1
```

## Multi-Test .\testCases.ps1
*Note: Does provide comperasion, meant to be used in a development's final stages.*

### Overview

`testCases.ps1` is a PowerShell script designed to test Windows applications that accept redirected input from STDIN. The script executes a specified executable file with the redirected input files and compares the output with the expected outputs.
To work the script requires the **input files** and the **expected output files** to follow the **same naming convention**.

### Usage

You can use the script by specifying the executable's path the input' folder's path and the expected output's path as arguments. In case none of them were provided you can let the script prompt you to select the required paramters.

#### Example 1: Specifying Arguments

```powershell
.\testCases.ps1 "C:\Path\to\program.exe" "C:\Path\to\inputFolder" "C:\Path\to\expectedOutputFolder"
```

#### Example 2: -help Flag

```powershell
.\testInput.ps1 -help
```

#### Example 3: No Arguments

```powershell
.\testInput.ps1
```

## Notes
- **File Dialogs:** The script relies on file dialogs for file selection. If the script is executed in a non-GUI environment, the user will be prompted to manually input the required file paths.
*In non-GUI environment it is recommended to use the scripts with arguments.*
- **Naming Convention:** For testCases.ps1, ensure that the input and expected output files follow the same naming convention for proper comparison.
- **Execution Policy:** Ensure your PowerShell execution policy is set to RemoteSigned or higher to run the scripts.

## Future Enhancements
- Combine Scripts into a Unified Solution: Consider merging testInput.ps1 and testCases.ps1 into a single script with a mode selector (e.g., -SingleTest or -MultiTest) to reduce redundancy and improve usability.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
