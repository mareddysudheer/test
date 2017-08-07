# TODO: This might be better served as a chef-marketplace-ctl command. We might
# want to eventually convert it into a recipe and have a ctl-command to pass
# the attributes to chef run when the process for publishing the Azure template
# has matured.

require "optparse"
require "mixlib/shellout"
require "open-uri"
require "fileutils"

@license = nil
@fqdn = nil
@adminUsername = nil
@firstname = nil 
@lastname = nil
@mailid = nil
@adminpassword = nil
@orguser = nil
OptionParser.new do |opts|
  opts.on("--fqdn FQDN", String, "The machine FQDN") { |fqdn| @fqdn = fqdn }
  opts.on("--adminUsername adminUsername", String, "The machine adminusername") { |adminUsername| @adminUsername = adminUsername }
  opts.on("--firstname firstname", String, "The machine firstname") { |firstname| @firstname = firstname }
  opts.on("--lastname lastname", String, "The machine lastname") { |lastname| @lastname = lastname }
  opts.on("--mailid mailid", String, "The machine mailid") { |mailid| @mailid = mailid }
  opts.on("--adminpassword adminpassword", String, "The machine adminpassword") { |adminpassword| @adminpassword = adminpassword }
  opts.on("--orguser orguser", String, "The machine orguser") { |orguser| @orguser = orguser }
  opts.on("--license [LICENSE]", "The Automate license file") do |license|
    @license = license
  end
end.parse!(ARGV)

# Write the Automate license file
if !@license.nil? && !@license.empty?
  license_dir = "/var/opt/delivery/license"
  license_file_path = File.join(license_dir, "delivery.license")

  FileUtils.mkdir_p(license_dir)
  File.write(license_file_path, open(@license, "rb").read)
end

# Append the FQDN to the marketplace config
open("/etc/chef-marketplace/marketplace.rb", "a") do |config|
  config.puts(%Q{api_fqdn "#{@fqdn}"})
end

# Configure the hostname
hostname = Mixlib::ShellOut.new("chef-marketplace-ctl hostname #{@fqdn}")
hostname.run_command

# Configure Automate
configure = Mixlib::ShellOut.new("chef-marketplace-ctl setup --preconfigure")
configure.run_command
#chef Upgrade shell Script
upgrade = Mixlib::ShellOut.new("chef-marketplace-ctl upgrade -y")
upgrade.run_command

 reconfigure = Mixlib::ShellOut.new("chef-server-ctl reconfigure")
 reconfigure.run_command

restartserver = Mixlib::ShellOut.new("chef-server-ctl restart")
restartserver.run_command

##Creating user for Chef Web UI
FileUtils.touch('/var/opt/delivery/.telemetry.disabled')
#exec(sudo touch /var/opt/delivery/.telemetry.disabled)
creatuser= Mixlib::ShellOut.new("automate-ctl create-user default #{@adminUsername} --password #{@adminpassword}")
creatuser.run_command

usercreate= Mixlib::ShellOut.new("chef-server-ctl user-create  #{@adminUsername}  #{@firstname}  #{@lastname}  #{@mailid}  #{@adminpassword} | tee /etc/opscode/#{@adminUsername}.pem")
usercreate.run_command

 orgcreate= Mixlib::ShellOut.new(" chef-server-ctl org-create #{@orguser} NewOrg  -a  #{@adminUsername} | tee /etc/opscode/#{@orguser}-validator.pem")
 orgcreate.run_command

# system("sed -i ' s/127.0.1.1       10.2.0.8 10/127.0.1.1       10.2.0.8/g' /etc/hosts")
system("hostname 10.2.0.8") 
system("chef-server-ctl reconfigure")
