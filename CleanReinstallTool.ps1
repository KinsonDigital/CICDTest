Clear-Host;


$baseSoftwareDevDirPath = "K:\SOFTWARE DEVELOPMENT";
$personalSoftware = "PERSONAL";
$projectName = "CICD";
$projectFileName = "$projectName.csproj";
$packageName = "KinsonDigital.CICD";
$solutionDirPath = "$baseSoftwareDevDirPath/$personalSoftware/$projectName";
$projectDirPath = "$solutionDirPath/$projectName";
$projectFilePath = "$projectDirPath/$projectFileName";
$packageDirPath = "$PSScriptRoot/cicd-package";

$configPath = "$PSScriptRoot/.config";

# Delete the cached nuget package tool
$nugetCacheFilePath = "C:/Users/$env:UserName/.nuget/packages/$packageName";
if (Test-Path -Path $nugetCacheFilePath)
{
    Remove-Item -Path $nugetCacheFilePath -Force -Recurse -Confirm:$false;
    Write-Host "✅Globally cached dotnet tool nuget package deleted`n";
}

# Delete the dotnet tool manifest if it exists
if (Test-Path -Path $configPath)
{
    Remove-Item -Path $configPath -Force -Recurse -Confirm:$false;
    Write-Host "✅DotNet tool manifest deleted`n";
}

# Delete all nuget pacakges
if (Test-Path -Path $packageDirPath)
{
    # Delete all nuget packages
    Remove-Item -Path "$packageDirPath" -Recurse -Confirm:$false;
    Write-Host "✅All NuGet packages deleted`n";
}

# Build the CICD project
dotnet build "$projectDirPath" -c "Debug";
Write-Host "✅$projectName Project Built`n";

# Create the nuget package
dotnet pack $projectFilePath -c "Debug" -o $packageDirPath;
Write-Host "✅$projectName NuGet package '$packageName' created`n";

# Create the dotnet tool manifest
dotnet new tool-manifest --force
Write-Host "✅DotNet Tool Manifest Restored`n";

[string[]]$packages = Get-ChildItem -Path "$packageDirPath/*.nupkg" | ForEach-Object { $_.Name };

# If there is more than 1 package, throw and error and fail
if ($packages.Length -gt 1)
{
    Write-Host "❌There is more than 1 package to choose from.  Cannot choose a package to extract the version from.";

    $packages | ForEach-Object { Write-Host "Package: $_" };

    exit 1;
}

# Extract the the version from the nuget package name
$packageVersion = $packages[0].Replace(".nupkg", "").Split("$packageName.")[1];

dotnet tool install "$packageName" --add-source $packageDirPath --version "$packageVersion";
Write-Host "✅$projectName DotNet Tool Installed";
