# Infor Data Lake Services Installer

## INSTALL
### Variables
*binaries folder* - the folder where the \<service>_bin folders will be pasted
*output folder* - the folder where the csv data of each service will be created (service subdirectories are created to keep things organised)
*logs folder* - the folder where the logs for each service will be created (service subdirectories are created to keep things organised)
interval - interval between data retrieval, in milliseconds


### install.ps1 - *installs and sets up everything*

- Place the script inside the folder containing all the *_bin folders.
- Right click to launch the PowerShell script and follow the prompts.



## UNINSTALL

### uninstall.bat
- Run the script as administrator and wait until done.



## MONITORING INSTRUCTIONS

Check the logs (currently located in E:\Logs\LN)
Open services.msc (or search for Services), organize by description or look directly for:
- AddressesService 
- CitiesByCountryService 
- InventoryByWarehouseService 
- FocalItemsService 
- ItemsBySiteService 
- ItemWarehouseDataService 
- JobShopBOMService 
- JobShopOperationsService 
- ProductionOrdersService 
- ProductLinesService 
- ProductTypesService 
- PurchaseOrderLinesService 
- SalesOrderLinesService 
- UnitsService



## INSTALL & UNINSTALL SERVICES MANUALLY

To install a service, use the command "cd C:\Windows\Microsoft.NET\Framework\v4.0.30319>" and then "InstallUtils.exe <pathToService.exe>".

To modify the parameters: edit the Parameters.txt file in the *_bin\Release\ folder. Then restart the service.

You can start or stop a service manually from Services.msc or by using the command "net start <serviceName>" or "net stop <serviceName>".

You can also uninstall a service by stoping it first and then using the command "sc.exe delete <serviceName>"

------------

If you need any help or you want to request new features/updates, contact l.pierru@focal.com