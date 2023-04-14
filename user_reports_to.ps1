#Accepts input from report.py in teh form of a list of P#s does a lookup for users and their managers and writes a csv to a file
#input is the user id's in a list one per line
#output is a csv file with user id, user name (First Last), manager Name (First Last)

$user_not_found = @()
if (Test-Path -Path C:\Scripts\network_tools\az_parse\user_list.txt -PathType Leaf){
    $user_list = Get-Content C:\Scripts\network_tools\az_parse\user_list.txt
    Remove-Item -Path C:\Scripts\network_tools\az_parse\reports_to.csv -Force
    Add-Content -Path C:\Scripts\network_tools\az_parse\reports_to.csv -Value '"Employee P#","Employee","Manager"'
}

ForEach ($item in $user_list) {
    try {
        $userinfo = Get-ADUser -Identity $item -Properties *
        $username = $userinfo.GivenName+" "+$userinfo.SurName
        $manager_id = Write-Output $userinfo.Manager.Substring(3,7).replace(',', '')
    } catch {
        $user_not_found += $item
        Continue
    }

    try {
        $managerinfo = Get-ADUser -Identity $manager_id -Properties *
        $managername = $managerinfo.GivenName+" "+$managerinfo.SurName
    } catch {
        $managername = ''
    }
    Add-Content -Path C:\Scripts\network_tools\az_parse\reports_to.csv -Value ($item +(",") +$username +(",") +$managername)
}

#List of user id's not found
Write-Output $user_not_found | Out-File C:\Scripts\network_tools\az_parse\user_not_found.txt
