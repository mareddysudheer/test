Write-Host --------nodejs--installation--starts--------- -ForegroundColor Green
    cd c:\
    mkdir nodejs >> C:\log.txt
    $url = "https://nodejs.org/dist/v10.1.0/node-v10.1.0-x64.msi"
    $output = "c:\nodejs"
    Import-Module BitsTransfer >> C:\log.txt
    Start-BitsTransfer -Source $url -Destination $output >> C:\log.txt
    cd nodejs >> C:\log.txt
    #Write-Host --silent--installation--starts --- -ForegroundColor Green
    msiexec /i "node-v10.1.0-x64.msi" /passive /norestart ADDLOCAL=ALL /quiet
    sleep 100
    Write-Host  ----nodejs--installation--succeeded---------- -ForegroundColor Green