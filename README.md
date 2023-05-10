# PSDomainReports
Active Directory Domain HTML Reports


```
git clone https://github.com/dstencil-cybertrol/PSDomainReports.git
```

```
cd PSDomainReports
```

To Run All scripts
```
./PSRunDomainReports.ps1
```
To Run individual scripts
```
./Get-SoftwareInstalledSearch.ps1
```
files ends up in C:\temp\


*Only for Get-SoftwareInstalledSearch.ps1:*
- *Edit servers.txt to specify which servers to pull the Get-SoftwareInstalledSearch results from (doesn't pull and run all AD Computers due to time to run script)*


### To-Do:
- use a config file to specify csv and html file outputs.
- use the config file to specify which servers to scan.
