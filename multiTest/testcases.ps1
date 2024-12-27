<#
A script a jelenlegi komplex beadandohoz készült, ezért nincs beparaméterezve.
A script az összes bemeneti fájlt lefuttatja a megadott futtatható állománnyal majd összehasonlítja a várt kimenetekkel.
A fájloknak a nevei nem számítanak, de érdemes valamiféle számozást használni, hogy az n-edik bemeneti állományt az n-edik kimeneti állományal hasonlítsa össze.

Jelen project esetében test*.txt elnevezést kapták a fájlok.
Bemeneti fájlok helye: .\Program\betest
Kimeneti fájlok helye: .\Program\kitest

$DEBUG = $false, hatására csak az eredményt írja ki azaz hogy a kimenet a várt kimenettel megegyezik-e.
#>
$DEBUG = $true;
$exePath = ".\Program\B40T6A\bin\Release\net6.0\B40T6A.exe";
$inputs = Get-ChildItem ".\Program\betest";
$outputs = Get-ChildItem ".\Program\kitest";

function EvaulateResults(){
    if($args.Length -ne 3){
        Write-Error "Az argumentum hossza nem megfelelo!";
        return $false;
    }

    $inputFile = $args[0];
    $expectedOutputFile = $args[1];
    $result = $($args[2]).Trim();

    $expectedOutput = $(Get-Content $($expectedOutputFile.FullName)).Trim();

    if($DEBUG){
        Write-Host "Bemenet: $($inputFile.FullName)";
	Write-Host "Kimenet: $($expectedOutputFile.FullName)";
        Write-Host "Várt kimenet:"
        Write-Host $expectedOutput;
        Write-Host "Program kimenete:";
        Write-Host $result;
    }

    return $($result -eq $expectedOutput);
}

if(!(Test-Path $exePath)){
    Write-Error "$exePath nem létezik!";
    Read-Host "Nyomj egy gombot a kilépéshez...";
    Exit(1);
}

if($inputs.Length -ne $outputs.Length){
    Write-Error "A bemenet és kimeneti fájlok száma nem egyezik!";
    Read-Host "Nyomj egy gombot a kilépéshez...";
    Exit(1);
}

$result;
for($i = 0; $i -lt $inputs.Length; $i++){
    $tempOutputFile = ".\temp_output$i.txt";
    Start-Process $exePath -RedirectStandardInput $inputs[$i].FullName -RedirectStandardOutput $tempOutputFile  -NoNewWindow  -Wait
    $result = $(Get-Content $tempOutputFile);
    
    $passed = EvaulateResults $($inputs[$i]) $($outputs[$i]) $result;

    if($passed){
        Write-Host "$($i+1) TESZT SIKERES" -BackgroundColor Green
    } else{
        Write-Host "$($i+1) TESZT SIKERTELEN" -BackgroundColor Red
    }
     Remove-Item $tempOutputFile;
}

Read-Host "Nyomj egy gombot a kilépéshez...";
Exit(0);