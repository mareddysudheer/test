param(
[string] $splunkfqdn = "$1"
)
Invoke-WebRequest  -Uri https://download.splunk.com/products/universalforwarder/releases/6.6.2/windows/splunkforwarder-6.6.2-4b804538c686-x64-release.msi -OutFile c:/users/splunkforwarder-6.6.2-4b804538c686-x64-release.msi
c:/users/splunkforwarder-6.6.2-4b804538c686-x64-release.msi AGREETOLICENSE=Yes RECEIVING_INDEXER="$splunkfqdn:9997" MONITOR_PATH="C:\Windows\Logs" SERVICESTARTTYPE=auto /qn


