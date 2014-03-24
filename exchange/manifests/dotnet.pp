# Class: exchange
#
#  This class is used to automate the installation of Microsoft Exchange 2013
#    
#   The windows firewall is automatically configured to allow the necessary ports
#   User Account Control needs to be disabled in order for the powershell operation to add the net-framework feature to work properly
#   The Net-Framework-Core windows feature is added automatically as it is required by the Xendesktop 7 installer
# 
# == Parameters: 
#
#  $source:: The location of the Xendesktop 7 installation files. 
#     Defaults to D:\x64\XenDesktop Setup which is the installation location on the DVD media.
#     Valid values: Network Share - '//server/networkshare/xendesktop/'
#
#  $sql:: The setting determines whether the included version of SQL Server 2012 is installed as part of the installation.
#     Default value: true (install SQL as part of the installation) 
#     Valid values: true and false
#
#  $controller:: The setting determines whether the delivery controller component will be installed.
#      Default value: true (install the delivery controller as part of the installation)
#      Valid values: true or false
#
#  $desktopstudio:: The setting determines whether the desktop studio component will be installed.
#      Default value: true (install desktop studio as part of the installation)
#      Valid values: true or false
#
#  $licenseserver:: The setting determines whether the license server component will be installed.
#      Default value: true (install the license server as part of the installation)
#      Valid values: true or false
#
#  $desktopdirector:: The setting determines whether the desktop director component will be installed.
#      Default value: true (install desktop director as part of the installation)
#      Valid values: true or false
#
#  $storefront:: The setting determine whether the store front component will be installed.
#      Default value: true (install store front as part of the installation)
#      Valid values: true or false
#
#
# == Requires:
# 
# puppetlabs/stdlib
# 
# == Sample Usage:
#
#  class {'citrix_xd7':
#   controller      => true,
#   desktopstudio   => true,
#   licenseserver   => false,
#   desktopdirector => false,
#   storefront      => false,
#   sql             => false,
#  }
#

include 'exchange::param::powershell'
 
class exchange (
  $source           = '//10.204.147.99/razor/Exchange',
  #$quiet            = true,  # ToDo
  #$firewall         = true,  # ToDo
  
  #Xendesktop Components
)

{
 
  # Include powershell module for windows feature installation 
 
  
    # Add Dot Net Framework Feature
  exec {'Install dotnet':
      command   => "${exchange::param::powershell::command} -Command \"Import-Module ServerManager; Add-WindowsFeature Net-Framework-Core\"",
      path      => "${exchange::param::powershell::path};${::path}",    
  } ->

  # Pre-req for Exchange 2013

# Pre-req for other Filter pack
  exec { 'Install FilterPack':
    command => "filterpack64bit.exe /quiet",
    path    => "$source",
}

# Pre-req for UCMA Runtime Setup 
  exec { 'Install UCMARuntime':
    command => "UcmaRunTimeSetup.exe /quiet /norestart",
    path    => "$source",
}

# Pre-req for Office 2013 filter pack
  exec { 'Install OfficePack':
    command => "filterpack2010sp1-kb2460041-x64-fullfile-en-us.exe /quiet",
    path    => "$source",
}


# Install Exchange from installation source
  exec { 'Install exchange':
    command => "setup.exe /mode:Install /role:ClientAccess,Mailbox /TargetDir:C:\ExchangeServer /IAcceptExchangeServerLicenseTerms",
    path    => "$source",
}

}
