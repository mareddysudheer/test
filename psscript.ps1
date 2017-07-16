param
(
[string] $domainName = "$1",

[string] $username = "$2",

[string] $password = "$3"
)

$usernamenNew = $domainName+"\"+${username}
Set-DnsClient `
    -InterfaceAlias "Ethernet*" `
    -ConnectionSpecificSuffix $domainName
$securePassword =  ConvertTo-SecureString $password `
    -AsPlainText `
    -Force

$cred = New-Object System.Management.Automation.PSCredential($usernamenNew, $securePassword)
    
Add-Computer -DomainName $domainName -Credential $cred -Restart
