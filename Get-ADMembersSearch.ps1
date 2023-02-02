#It first imports the ActiveDirectory module, then it uses the Get-ADUser cmdlet to retrieve all active directory users.
#Then it iterates through the users, gets their group memberships using the Get-ADPrincipalGroupMembership cmdlet, and creates a new object for each user with their name, SamAccountName, status (enabled/disabled), and group memberships.
#Then it exports this information to a CSV file.
#Next, it imports the CSV file, creates an HTML table using the ConvertTo-HTML cmdlet, applies a Bootstrap CSS style, adds a search bar and navigation bar, and then exports the HTML table to an HTML file.
#It also includes a JavaScript function to search the table by the UserName column, which is the first column of the table.

#The script also includes the links in the navigation bar to the additional HTML pages. The users_with_groups.html and the g#roups.html files should be created before running the script.

#Please make sure to change the paths before running the script, and that the links in the navbar match the names of the files.

Import-Module ActiveDirectory

# Get all active directory users
$users = Get-ADUser -Filter * -Properties *
$output = @()
foreach ($user in $users) {
    $groups = Get-ADPrincipalGroupMembership -Identity $user.SamAccountName
    $groupNames = $groups | Select-Object -ExpandProperty Name
    $status = if ($user.Enabled) { "Enabled" } else { "Disabled" }
    $output += New-Object PSObject -Property @{
        UserName = $user.Name
        SamAccountName = $user.SamAccountName
        UserStatus = $status
        PasswordLastSet = $user.passwordlastset
        GroupMemberships = ($groupNames -join ", ")
    }
}
$output | Export-Csv -Path "C:\temp\users_with_groups.csv" -NoTypeInformation

# Create HTML page
$csv = Import-Csv -Path "C:\temp\users_with_groups.csv"
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
$table | Out-File "C:\temp\users_with_groups.html"

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
    var input, table, tr, td, i, txtValue;
    input = document.getElementById("enabled");
    table = document.getElementsByClassName("table")[0];
    tr = table.getElementsByTagName("tr");
    for (i = 0; i < tr.length; i++) {
        td = tr[i].getElementsByTagName("td")[2];
        if (td) {
            txtValue = td.textContent || td.innerText;
            if (input.checked) {
                if (txtValue === "Enabled") {
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


Add-Content -Path "C:\temp\users_with_groups.html" -Value $script
