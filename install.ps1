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
    $text = Get-Content $path
    $text = $text[0,1,2]
    Set-Content -Path $path -Value $text
    Add-Content $path ("outputfile|" + $parameters['outputFolderPath'] + $serviceName)
    Add-Content $path ("logDirectory|" + $parameters['logsFolderPath'])
    Add-Content $path ("interval|" + $parameters['interval'])
    return 0
}

function install_services($parameters, $servicesList) {
    foreach ($item in $servicesList) {
        New-Service -Name $item -BinaryPathName ($parameters['binFolderPath'] + $item + '_bin\Release\DataLake' + $item + '.exe')
        Start-Service -Name $item
    }
}

function structure_folders($parameters, $foldersList, $servicesList) {
    if (!$parameters['binFolderPath'].EndsWith('\')) { $parameters['binFolderPath']= $parameters['binFolderPath'] + '\' }
    if (!$parameters['outputFolderPath'].EndsWith('\')) { $parameters['outputFolderPath']= $parameters['outputFolderPath'] + '\' }
    if (!$parameters['logsFolderPath'].EndsWith('\')) { $parameters['logsFolderPath']= $parameters['logsFolderPath'] + '\' }
    foreach ($item in $foldersList)
    {
        New-Item -Force -Path ($parameters['outputFolderPath'] + $item) -Type Directory
        New-Item -Force -Path ($parameters['logsFolderPath'] + $item) -Type Directory
        Copy-Item -Path ($parameters['currentLocation'] + '\' + $item + '_bin\') ($parameters['binFolderPath'] + $item + '_bin\') -Recurse
        Copy-Item -Path ($parameters['binFolderPath'] + $item + '_bin\Debug\*') ($parameters['binFolderPath'] + $item + '_bin\Release') -Recurse
        edit_parameters $parameters ($parameters['binFolderPath'] + $item + '_bin\Release\Parameters.txt') $item
    }
    install_services $parameters $servicesList
    return 0
}

function confirmation($parameters, $foldersList, $servicesList) {
    Write-Host ""
    Write-Host "binFolderPath="$parameters['binFolderPath']", outputFolderPath="$parameters['outputFolderPath']", logsFolderPath="$parameters['logsFolderPath']", interval="$parameters['interval']
    $answer = Read-Host "Are these informations correct? (y/n)"
    if ($answer -eq 'y') {
        structure_folders $parameters $foldersList $servicesList
        return 0
    } elseif ($answer -eq 'n') {
        Write-Host ""
        set_variables
        return 1
    } else {
        confirmation $parameters $foldersList $servicesList
    }
}

function set_variables {
    $parameters = @{}
    $binFolderPath = Read-Host -Prompt "Input the binaries' folder's absolute path (eg: C:\Services\LN\)"
    $outputFolderPath = Read-Host -Prompt "Input the outputs folder's absolute path (eg: D:\data\LN\)"
    $logsFolderPath = Read-Host -Prompt "Input the logs folder's absolute path (eg: E:\Services\Log\)"
    $interval = Read-Host -Prompt "Input the interval time at which the service executes (in milliseconds)"
    $currentLocation = Get-Location
    $currentLocation = $currentLocation.path
    $parameters.add('binFolderPath', $binFolderPath)
    $parameters.add('outputFolderPath', $outputFolderPath)
    $parameters.add('logsFolderPath', $logsFolderPath)
    $parameters.add('interval', $interval)
    $parameters.add('currentLocation', $currentLocation)
    $foldersList = @(
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
    $servicesList = @(
        'AddressesService'
        'CitiesByCountryService'
        'InventoryByWarehouseService'
        'FocalItemsService'
        'ItemsBySiteService'
        'ItemWarehouseDataService'
        'JobShopBOMService'
        'JobShopOperationsService'
        'ProductionOrdersService'
        'ProductLinesService'
        'ProductTypesService'
        'PurchaseOrderLinesService'
        'SalesOrderLinesService'
        'UnitsService'
    )
    confirmation $parameters $foldersList $servicesList
    return 0
}

function main {
    invoke_admin
    set_variables
    return 0
}

main