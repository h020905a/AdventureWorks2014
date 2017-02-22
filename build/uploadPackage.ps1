param (
	[parameter(Position=1,Mandatory=$true)]
	[string]$ProjectPath,
	
	[parameter(Position=2, Mandatory=$true)]
	[string]$nuGetPackageFilePath,
	
	[parameter(Position=3, Mandatory=$true)]
	[string]$isRelease 
)

$found = $false

Function Push($package) {
	$pushOptions = "-ApiKey $apiKey -Source $nuGetRepositoryUri"
	$pushCommand = "& ""$nugetExe"" push ""$package"" $pushOptions"

	Write-Host "About to execute PUSH command: $pushCommand"

	$pushOutput = (Invoke-Expression -Command $pushCommand | Out-String).Trim()
	Write-Host $pushOutput
	
	Remove-Item $package
}

Function Upload ($outputText, $fileName) {
        Write-Host $outputText
        if ($isRelease -eq "1") {
            Push $fileName
        }
        else {
            $newFileName = [system.io.path]::GetFileNameWithoutExtension($fileName) + "-Dev.nupkg"
            $newFullName = [system.io.path]::combine([system.io.path]::GetDirectoryName($fileName),$newFileName)
			Rename-Item -path $fileName -newname $newFileName
            Push $newFullName
        }
        $script:found = $true
}

$publishPath = "$ProjectPath\build\publish.config.ps1"
$nugetPath = "$ProjectPath\.nuget"
$nugetExe = "$nugetPath\nuget.exe"

if (!(Test-Path $publishPath -pathType Leaf))
{
	Throw "Path (publish) $publishPath does not exist."
}

if (!(Test-Path $nugetPath -pathType container))
{
	Throw "Path (nuget) $nugetPath does not exist."
}

if (!(Test-Path $nuGetPackageFilePath -pathType Leaf) -and !(Test-Path $nuGetPackageFilePath -pathType Container))
{
	Throw "Path (package) $nuGetPackageFilePath does not exist."
}
	
.$publishPath
Write-Host "Publish variables read"

Write-Host "Checking $nuGetPackageFilePath"

$testPath = Test-Path $nuGetPackageFilePath -pathType Container
Write-Host "Testpath Result: $testPath"

if ($testPath)
{
	# Find nupkg files
	Write-Host "Searching for files"
	$packages = Get-ChildItem $nuGetPackageFilePath | where {$_.extension -eq ".nupkg"} | % {
		Upload "Multi file found" $_.FullName
	}
}
else
{
	Upload "Single file found" $nuGetPackageFilePath
}


if ($found -eq $true)
{
	return 0
}
else
{
	Throw "Didn't upload anything!"
}
