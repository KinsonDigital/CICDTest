$packageName = "KinsonDigital.CICD";
$packageDirPath = "$PSScriptRoot/cicd-package";

# Create the dotnet tool manifest
dotnet new tool-manifest --force
Write-Host "✅DotNet Tool Manifest Created`n";

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
Write-Host "✅CICD DotNet Tool Installed";
