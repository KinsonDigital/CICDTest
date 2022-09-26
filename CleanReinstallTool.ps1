$baseSoftwareDevDirPath = "K:\SOFTWARE DEVELOPMENT";
$personalSoftware = "PERSONAL";
$projectName = "CICD";
$scriptFileName = "CreateToolPackage.ps1";
$packageName = "KinsonDigital.CICD";
$solutionDirPath = "$baseSoftwareDevDirPath/$personalSoftware/$projectName";
$packageSourcePath = "$solutionDirPath/$projectName";

# Path to other project script to build the package
$fullScriptFilePath = "$solutionDirPath/$scriptFileName";

# Execute the other script to create the package
& $fullScriptFilePath;


$basePath = "$PSScriptRoot";
$configPath = "$basePath/.config";
$nugetCacheFilePath = "C:/Users/$env:UserName/.nuget/packages/kinsondigital.cicd";

# Delete the dotnet tool manifest if it exists
if (Test-Path -Path $configPath) {
    Remove-Item -Path $configPath -Force -Recurse -Confirm:$false;
    Write-Host "✅DotNet tool manifest deleted.";
}

# Delete the cached nuget package tool
if (Test-Path -Path $nugetCacheFilePath) {
    Remove-Item -Path $nugetCacheFilePath -Force -Recurse -Confirm:$false;
    Write-Host "✅Globally cached dotnet tool nuget package deleted.";
}

# Create the dotnet tool manifest
dotnet new tool-manifest

# Installed the dotnet tool locally
$packagePath = Get-ChildItem -Path "$solutionDirPath/**/$packageName*.nupkg" -Recurse | ForEach-Object{$_.FullName};

# Get the vesion
$packageVersion = $packagePath.Replace(".nupkg", "").Split("$packageName.")[1];

dotnet tool install "KinsonDigital.CICD" --add-source $packageSourcePath --version $packageVersion
