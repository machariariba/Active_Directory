param( [Parameter(Mandatory = $true)] $OutputJSONFile)

$group_names = [System.Collections.ArrayList](Get-Content "data\group_names.txt")
$first_names = [System.Collections.ArrayList](Get-Content "data\first_names.txt")
$last_names = [System.Collections.ArrayList](Get-Content "data\last_names.txt")
$passwords = [System.Collections.ArrayList](Get-Content "data\passwords.txt")

$groups = @()
$users = @()

$num_groups = 10
for ($i = 0; $i -lt $num_groups; $i++) {
    $new_group = (Get-Random -InputObject $group_names )
    $groups += @{Name = "$new_group" }  
    $group_names.Remove($new_group)
}

$num_users = 20
for ($i = 0; $i -lt $num_users; $i++) {
    $first_name = (Get-Random -InputObject $first_names)
    $last_name = (Get-Random -InputObject $last_names)
    $password = (Get-Random -InputObject $passwords)
    $new_user = [ordered]@{
        Name     = "$first_name $last_name"
        Password = "$password"
        Group    = (Get-Random -InputObject $groups).Name
    }
    $users += $new_user

    $first_names.Remove($first_name)
    $last_names.Remove($last_names)
    $passwords.Remove($password)
}

ConvertTo-Json -InputObject @{
    Domain = "xyz.com"
    Groups = $groups
    Users  = $users
} | Out-File $OutputJSONFile
