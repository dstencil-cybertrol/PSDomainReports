$computers = Get-ADComputer -Filter *
$output = @()
foreach ($computer in $computers) {
    try {
        $hotfixes = Get-Hotfix -ComputerName $computer.Name | Where-Object {$_.InstalledOn -GT (Get-Date).AddMonths(-3)}
        foreach ($hotfix in $hotfixes) {
            $output += New-Object PSObject -Property @{
                ComputerName = $computer.Name
                HotfixID = $hotfix.HotFixID
                InstalledOn = $hotfix.InstalledOn
            }
        }
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        Write-Host "Get-Hotfix cmdlet not found on computer $($computer.Name)"
    }
    catch {
        Write-Host "An error occurred while retrieving hotfixes from computer $($computer.Name)"
    }
}
$output | Export-Csv -Path C:\temp\HotfixReport.csv -NoTypeInformation


$csv = Import-Csv -Path C:\temp\HotfixReport.csv
$style = "<link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css' integrity='sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm' crossorigin='anonymous'>"
$search = "<div class='container'><div class='row'><div class='col-sm-6'><input type='text' class='form-control' id='search-box' placeholder='Search...' onkeyup='searchTable()'/> </div></div></div>"
$checkbox = "<input type='checkbox' id='enabled' onclick='filterEnabled()'>Show Enabled Users Only"
$navbar = @"
<nav class='navbar navbar-expand-lg navbar-light bg-light'>
  <a class='navbar-brand' href='#'>$env:USERDNSDomain</a>
  <button class='navbar-toggler' type='button' data-toggle='collapse' data-target='#navbarNav' aria-controls='navbarNav' aria-expanded='false' aria-label='Toggle navigation'>
    <span class='navbar-toggler-icon'></span>
  </button>
  <div class='collapse navbar-collapse' id='navbarNav'>
    <ul class='navbar-nav'>
      <li class='nav-item'>
        <a class='nav-link' href='groups.html'>Groups</a>
      </li>
      <li class='nav-item'>
        <a class='nav-link' href='users_with_groups.html'>Users</a>
      </li>
      <li class='nav-item'>
        <a class='nav-link' href='softwareinstalled.html'>Installed Software</a>
      </li>
      <li class='nav-item'>
        <a class='nav-link' href=HotfixReport.html>Installed Updates</a>
      </li>
    </ul>
  </div>
</nav>
"@
$table = $csv | ConvertTo-Html -Head $style -Body "$navbar $search"
$table = $table -replace '<table>', '<table class="table table-striped">'
$table = $table -replace '<thead>', "<thead><tr><th>$checkbox</th>"
$table | Out-File C:\temp\HotfixReport.html

$script = @"
<script>
function searchTable() {
    var input, filter, table, tr, td, i, txtValue;
    input = document.getElementById("search-box");
    filter = input.value.toUpperCase();
    table = document.getElementsByClassName("table")[0];
    tr = table.getElementsByTagName("tr");
    for (i = 0; i < tr.length; i++) {
        td = tr[i].getElementsByTagName("td")[0];
        if (td) {
            txtValue = td.textContent || td.innerText;
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }       
    }
}
function filterEnabled() {
  var input, table, tr, td, i, txtValue, select;
  input = document.getElementById("enabled");
  select = document.getElementById("selectServer");
  table = document.getElementsByClassName("table")[0];
  tr = table.getElementsByTagName("tr");
  for (i = 0; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td")[2];
    if (td) {
      txtValue = td.textContent || td.innerText;
      if (input.checked && select.value !== "All") {
        if (txtValue === "Enabled" && tr[i].getElementsByTagName("td")[0].textContent === select.value) {
          tr[i].style.display = "";
        } else {
          tr[i].style.display = "none";
        }
      } else if (input.checked) {
        if (txtValue === "Enabled") {
          tr[i].style.display = "";
        } else {
          tr[i].style.display = "none";
        }
      } else if (select.value !== "All") {
        if (tr[i].getElementsByTagName("td")[0].textContent === select.value) {
          tr[i].style.display = "";
        } else {
          tr[i].style.display = "none";
        }
      } else {
        tr[i].style.display = "";
      }
    }
  }
}
</script>
"@


Add-Content -Path C:\temp\HotfixReport.html -Value $script
