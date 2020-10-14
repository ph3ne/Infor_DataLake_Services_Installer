@echo off
goto :check_permissions

:check_permissions
echo Administrative permissions required. Detecting permissions...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Success: You have administrator privileges.
    echo.
    goto :main
) else (
    echo Failure: Please start this script as administrator.
    pause
    exit
)

:main
set list=AddressesService CitiesByCountryService InventoryByWarehouseService FocalItemsService ItemsBySiteService ItemWarehouseDataService JobShopBOMService JobShopOperationsService ProductionOrdersService ProductLinesService ProductTypesService PurchaseOrderLinesService SalesOrderLinesService UnitsService
for %%s in (%list%) do (
    net stop %%s
    sc.exe delete %%s
)
echo All services were uninstalled.
pause
exit 