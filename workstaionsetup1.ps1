Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chefdk -channel stable -version 2.0.26
setx PATH "$env:path;C:\opscode\chefDK\embedded\bin\" -m
Invoke-WebRequest -Uri https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.70-installer.msi -OutFile c:/users/Putty.msi 
Start-Process c:/Users/Putty.msi   /qn -Wait
Restart-Computer