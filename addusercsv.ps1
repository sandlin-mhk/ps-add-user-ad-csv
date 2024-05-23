# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory
  
# Store the data from NewUsersFinal.csv in the $ADUsers variable
$ADUsers = Import-Csv "C:\path\yourfile.csv" -Delimiter ","

# Define UPN
$UPN = "yourdomain.com"

# Loop through each row containing user details in the CSV file
foreach ($User in $ADUsers) {

    $username = $User.username
    $password = $User.password
    $firstname = $User.firstname
    $lastname = $User.lastname
    $OU = $User.ou
    $email = $User.email
    $telephone = $User.telephone
    $jobtitle = $User.jobtitle
    $department = $User.department
    $description = $User.description
    $manager = $User.manager
    $ipphone = $User.ipphone
    $cellphone = $User.cellphone
    $proxyaddresses = $User.proxyaddresses

    if (Get-ADUser -Filter "SamAccountName -eq '$username'") {
        
        # If user does exist, give a warning
        Write-Warning "A user account with username $username already exists in Active Directory."
    }
    else {

        # User does not exist then proceed to create the new user account

        $NewUserParams = @{
            SamAccountName = $username
            UserPrincipalName = "$username@$UPN"
            Name = "$firstname $lastname"
            GivenName = $firstname
            Surname = $lastname
            Enabled = $true
            DisplayName = "$firstname $lastname"
            Path = $OU
            OfficePhone = $telephone
            EmailAddress = $email
            Title = $jobtitle
            Department = $department
            Description = $description
            Manager = $manager
            OtherAttributes = @{'proxyaddresses' = $proxyaddresses}
            Mobile = $cellphone
            AccountPassword = (ConvertTo-SecureString $password -AsPlainText -Force)
            ChangePasswordAtLogon = $true
        }
		# Checks to see if cells in the ip phone column are empty and skips them if they are
        if ($ipphone -ne "") {
            $NewUserParams.OtherAttributes.Add('ipphone', $ipphone)
        }

        New-ADUser @NewUserParams

        # If user is created, show message.
        Write-Host "The user account $username is created." -ForegroundColor Cyan
    }

}
