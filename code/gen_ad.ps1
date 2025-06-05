param( [Parameter(Mandatory = $true)] $JSONFile)

function CreateADGroup() {
    param([Parameter(Mandatory = $true)] $groupObject)

    $name = $groupObject.name
    New-ADGroup -name $name -GroupScope global
}

function CreateADUser () {
    param([Parameter(Mandatory = $true)] $userObject)

    #Get the name from JSON file
    $name = $userObject.name
    $password = $userObject.password
    #Get firstname and lastname
    $firstname, $lastname = $name.Split(" ")

    #create user for AD
    $username = ($firstname[0] + $lastname).ToLower()
    $SamAccountName = $username
    $principalname = $username

    New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount
    
    foreach ($group_name in $userObject.groups) {
        try {
            Get-ADGroup -Identity "$group_name"
            Add-ADGroupMember -Identity $group_name -Members $username
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            Write-Warning "User $name not added to group $group_name cause it doesn't exist!"
        }
        
    }
}

$json = (Get-Content $JSONFile |  ConvertFrom-Json)
$Global:Domain = $json.domain

foreach ($group in $json.groups) {
    CreateADGroup $group
}
foreach ($user in $json.users) {
    CreateADUser $user
}