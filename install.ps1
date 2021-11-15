function invoke_admin {
    Start-Process PowerShell -verb runas -ArgumentList '-noexit','-File','path-to-script'
    if ($? -eq 'True') {
        return 0
    } else {
        Write-Host "This script requires administrator privileges."
        return 1
        Read-Host -Prompt "Press any key to exit"
        exit
    }
}

function edit_parameters($parameters, $path, $serviceName) {
    $line = Get-Content $path | Select-String outputfile | Select-Object -ExpandProperty Line
    $text = Get-Content $path
    (Get-Content $path) | Foreach-Object {$_ -replace '^outputfile.*$', ("outputfile|" + $parameters['outputFolderPath'] + $serviceName)} | Set-Content $path
    (Get-Content $path) | Foreach-Object {$_ -replace '^logDirectory.*$', ("logDirectory|" + $parameters['logsFolderPath'])} | Set-Content $path
    (Get-Content $path) | Foreach-Object {$_ -replace '^interval.*$', ("interval|" + $parameters['interval'])} | Set-Content $path
    (Get-Content $path) | Foreach-Object {$_ -replace '^ionapiFileName.*$', ("ionapiFileName|" + $parameters['apiTokenFilePath'])} | Set-Content $path
    return 0
}

function install_services($parameters, $servicesList) {
    foreach ($item in $servicesList) {
        New-Service -Name ("Infor DataLake " + $tenant + " " + $item) -BinaryPathName ($parameters['binFolderPath'] + $item + '_bin\Release\DataLake' + $item + '.exe')
        Start-Service -Name ("Infor DataLake " + $tenant + " " + $item)
    }
}

function structure_folders($parameters, $servicesList) {
    if (!$parameters['binFolderPath'].EndsWith('\')) { $parameters['binFolderPath']= $parameters['binFolderPath'] + '\' }
    if (!$parameters['outputFolderPath'].EndsWith('\')) { $parameters['outputFolderPath']= $parameters['outputFolderPath'] + '\' }
    if (!$parameters['logsFolderPath'].EndsWith('\')) { $parameters['logsFolderPath']= $parameters['logsFolderPath'] + '\' }
    foreach ($item in $servicesList)
    {
        New-Item -Force -Path ($parameters['outputFolderPath'] + $item) -Type Directory
        New-Item -Force -Path ($parameters['logsFolderPath'] + $item) -Type Directory
        Copy-Item -Path ($parameters['binFolderPath'] + $item + '_bin\Debug\*') ($parameters['binFolderPath'] + $item + '_bin\Release') -Recurse
        edit_parameters $parameters ($parameters['binFolderPath'] + $item + '_bin\Release\Parameters.txt') $item
    }
    install_services $parameters $servicesList
    return 0
}

function confirmation($parameters, $servicesList) {
    Write-Host ""
    Write-Host "binFolderPath="$parameters['binFolderPath']", outputFolderPath="$parameters['outputFolderPath']", logsFolderPath="$parameters['logsFolderPath']", interval="$parameters['interval']", apiTokenFilePath="$parameters['apiTokenFilePath']", tenant="$parameters['tenant']
    $answer = Read-Host "Are these informations correct? (y/n)"
    if ($answer -eq 'y') {
        structure_folders $parameters $servicesList
        return 0
    } elseif ($answer -eq 'n') {
        Write-Host ""
        set_variables
        return 1
    } else {
        confirmation $parameters $servicesList
    }
}

function set_variables {
    $parameters = @{}
    $binFolderPath = Read-Host -Prompt "Input the binaries folder's absolute path (eg: C:\Services\LN\TRN\)"
    $outputFolderPath = Read-Host -Prompt "Input the outputs folder's absolute path (eg: D:\data\LN\TRN\)"
    $logsFolderPath = Read-Host -Prompt "Input the logs folder's absolute path (eg: E:\Services\Log\TRN\)"
    $interval = Read-Host -Prompt "Input the interval time at which the service executes (in milliseconds)"
    $tenant = Read-Host -Prompt "Input the tenant on which the service will run (eg: TRN)"
    $apiTokenFilePath = Read-Host -Prompt "Input the path of the API Token file according to the tenant it will run on (eg: D:\api_tokens\FOCAL_TRN.ionapi)"
    $parameters.add('binFolderPath', $binFolderPath)
    $parameters.add('outputFolderPath', $outputFolderPath)
    $parameters.add('logsFolderPath', $logsFolderPath)
    $parameters.add('interval', $interval)
    $parameters.add('tenant', $tenant)
    $parameters.add('apiTokenFilePath', $apiTokenFilePath)
    $servicesList = @(
        'Addresses'
        'CitiesByCountry'
        'InventoryByWarehouse'
        'Items'
        'ItemsBySite'
        'ItemWarehouseData'
        'JobShopBOM'
        'JobShopOperations'
        'ProductionOrders'
        'ProductLines'
        'ProductTypes'
        'PurchaseOrderLines'
        'SalesOrderLines'
        'Units'
    )
    confirmation $parameters $servicesList
    return 0
}

function main {
    invoke_admin
    set_variables
    return 0
}

main