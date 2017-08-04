
param(
[string] $adminusername = "$1",
[string] $adminPassword = "$2",
[string] $ChefServerFqdn = "$3",
[string] $organizationName= "$4",
[string] $splunkfqdn = "$5"
#[string] $wsNodeFqdn= "$6"
)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned  -Force
cd C:\opscode\chefdk\bin
chef generate app c:\Users\chef-repo
echo c:\Users\chef-repo\.chef\knife.rb | knife configure --server-url https://$chefServerfqdn/organizations/$organizationName --validation-client-name $organizationName-validator --validation-key c:/Users/chef-repo/.chef/$organizationName-validator.pem --user $adminUsername --repository c:/Users/chef-repo
echo n | & "C:\Program Files\PuTTY\pscp.exe"  -scp -pw $adminPassword ${adminUsername}@${chefServerfqdn}:/etc/opscode/$adminUsername".pem" C:\Users\chef-repo\.chef\$adminUsername".pem"
echo n | & "C:\Program Files\PuTTY\pscp.exe"  -scp -pw $adminPassword ${adminUsername}@${chefServerfqdn}:/etc/opscode/$organizationName-validator.pem C:\Users\chef-repo\.chef\$organizationName-validator.pem
knife ssl  fetch --config c:\Users\chef-repo\.chef\knife.rb  --server-url https://$chefServerfqdn/organizations/$organizationName
git clone https://github.com/sysgain/IOT-ChefCookbooks.git C:/Users/cookbookstore
cp -r C:\Users\cookbookstore\* C:\Users\chef-repo\cookbooks
(Get-Content C:\Users\chef-repo\cookbooks\splunk-uf-install/recipes/default.rb) ` | %{ $_ -replace 'localhost',$splunkfqdn} ` | Set-Content C:\Users\chef-repo\cookbooks\splunk-uf-install/recipes/default.rb
knife bootstrap windows winrm localhost --config c:\Users\chef-repo\.chef\knife.rb -x $adminusername  -P $adminPassword -N splunkNode 
knife cookbook upload --config c:\Users\chef-repo\.chef\knife.rb --server-url https://$ChefServerFqdn/organizations/$organizationName/ splunk-uf-install compat_resource audit 
knife node run_list add --config c:\users\chef-repo\.chef\knife.rb --server-url https://$ChefServerFqdn/organizations/$organizationName/ chefnode1 recipe[splunk-uf-install]
knife node run_list add --config c:\users\chef-repo\.chef\knife.rb --server-url https://$ChefServerFqdn/organizations/$organizationName/ chefnode1 recipe[audit]
chef-client
