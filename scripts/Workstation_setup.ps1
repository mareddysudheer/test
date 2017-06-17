param(
[string] $adminUsername = "$1",
[string] $adminPassword = "$2",
[string] $ChefAutoFqdn = "$3",
[string] $orguser= "$4"
)
Invoke-WebRequest -Uri https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.69-installer.msi -OutFile c:/users/Putty.msi 
Start-Process c:/users/Putty.msi   /qn -Wait
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned  -Force
cd C:\opscode\chefdk\bin
chef generate app c:\users\$adminUsername\chef-repo
git clone https://github.com/sysgain/ChefAutomateTD_Cookbooks.git c:/users/cookbookstore
cp -r C:\Users\cookbookstore\* C:\Users\$adminUsername\chef-repo\cookbooks
echo c:\users\$adminUsername\chef-repo\.chef\knife.rb | knife configure --server-url https://$ChefAutoFqdn/organizations/$orguser --validation-client-name $orguser-validator --validation-key c:/users/${adminUsername}/chef-repo/.chef/$orguser-validator.pem --user $adminUsername --repository c:/users/${adminUsername}/chef-repo
echo n | & "C:\Program Files\PuTTY\pscp.exe"  -scp -pw $adminPassword ${adminUsername}@${ChefAutoFqdn}:/etc/opscode/$adminUsername".pem" C:\Users\$adminUsername\chef-repo\.chef\$adminUsername".pem"
echo n | & "C:\Program Files\PuTTY\pscp.exe"  -scp -pw $adminPassword ${adminUsername}@${ChefAutoFqdn}:/etc/opscode/orguser-validator.pem C:\Users\$adminUsername\chef-repo\.chef\orguser-validator.pem
cd C:\opscode\chefdk\bin\
knife ssl  fetch --config c:\users\$adminUsername\chef-repo\.chef\knife.rb  --server-url https://$ChefAutoFqdn/organizations/$orguser
knife bootstrap windows winrm localhost --config c:\users\$adminUsername\chef-repo\.chef\knife.rb -x $adminUsername -P $adminPassword -N windownode1
chef-client 
knife cookbook upload --config c:\users\$adminUsername\chef-repo\.chef\knife.rb --server-url https://$ChefAutoFqdn/organizations/$orguser compat_resource audit
knife node run_list add --config c:\users\$adminUsername\chef-repo\.chef\knife.rb --server-url https://$ChefAutoFqdn/organizations/$orguser windownode1 recipe[audit]
chef-client
