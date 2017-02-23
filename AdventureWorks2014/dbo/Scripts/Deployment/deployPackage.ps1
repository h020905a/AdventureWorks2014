#Package location variables
$sqlPackageLocation="C:\DACTools\content\SqlPackage.exe" 
$environment = $OctopusParameters['Octopus.Environment.Name']
$filepath = $OctopusParameters['Octopus.Tentacle.CurrentDeployment.PackageFilePath']

#DACPAC location
$dacLocation = "";
$packages = Get-ChildItem $ExtractLocation | where {$_.extension -eq ".dacpac"} | % {
    $fileName = Split-Path $_.FullName -leaf -resolve
    if($fileName -eq "AdventureWorks2014.dacpac")
    {   
        $dacLocation = $_.FullName
    }
}

#Connection variables
#Connection string
$connectionString = $OctopusParameters["MyApp.ConnectionString"]

Write-Host "Deploying $dacLocation to $server"

#Required for output
$version = [io.path]::GetFileNameWithoutExtension($filepath)
$release = $OctopusParameters['Octopus.Release.Number']

#Deploy Database
$arguments="/Action:Publish /SourceFile:$dacLocation /TargetDatabaseName:'$TargetDatabaseName' /TargetServerName:'$server' /p:BlockOnPossibleDataLoss=True /p:DoNotDropObjectTypes='Aggregates;ApplicationRoles;Assemblies;AsymmetricKeys;BrokerPriorities;Certificates;Contracts;DatabaseRoles;DatabaseTriggers;Defaults;Filegroups;FileTables;FullTextCatalogs;FullTextStoplists;MessageTypes;PartitionFunctions;PartitionSchemes;Permissions;Queues;RemoteServiceBindings;RoleMembership;Rules;SearchPropertyLists;Sequences;Services;Signatures;SymmetricKeys;Synonyms;UserDefinedDataTypes;UserDefinedTableTypes;ClrUserDefinedTypes;Users;Views;Audits;Credentials;CryptographicProviders;DatabaseAuditSpecifications;Endpoints;ErrorMessages;EventNotifications;EventSessions;LinkedServerLogins;LinkedServers;Logins;Routes;ServerAuditSpecifications;ServerRoleMembership;ServerRoles;ServerTriggers' /p:DropObjectsNotInSource=True /p:IgnoreAnsiNulls=False /p:IgnoreQuotedIdentifiers=False"
Invoke-Expression "& `"$sqlPackageLocation`" $arguments"
