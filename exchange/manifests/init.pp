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
 
  #//10.204.147.99/razor/Exchange/UcmaRunTimeSetup.exe /quiet /restart
  #Get-WindowsFeature -name Server-Media-Foundation
  
  #Install-WindowsFeature AS-HTTP-Activation, Desktop-Exp//erience, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation
    # Add Dot Net Framework Feature


  # Pre-req for Exchange 2013

# Pre-req for other Filter pack
  exec { 'Install FilterPack':
    command => "",
    path    => "$source",
    timeout => 600 # 10 minute timeout due to the length of the install when SQL Express is installed204.
}


  exec { 'Install MediaFoundation':
     command   => "${exchange::param::powershell::command} -Command \"Install-WindowsFeature Server-Media-Foundation-Restart\"",
    path    => "$source",
    require => Exec['Install FilterPack'], # Require installation of the .NET Framework
    timeout => 600 # 10 minute timeout due to the length of the install when SQL Express is installed204.
}


#Start of line
# Pre-req for Few other features 
  exec { 'Install OtherFeatures':
     command   => "${exchange::param::powershell::command} -Command \"Install-WindowsFeature AS-HTTP-Activation, Desktop-Experience, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation -Restart\"",
    path    => "$source",
    require => Exec['Install MediaFoundation'], # Require installation of the .NET Framework
    timeout => 600 # 10 minute timeout due to tadminihe length of the install when SQL Express is installed
}


  exec { 'Add userdomain':
     command   => "${exchange::param::powershell::command} -Command \"netdom join ${hostname} /domain:mavnet.us.dell.com /userD:administrator",
    path    => "$source",
    require => Exec['Install OtherFeatures'], # Require installation of the .NET Framework
    timeout => 600 # 10 minute timeout due to the length of the install when SQL Express is installed
}

exec { 'Install ADfeatures':
     command   => "${exchange::param::powershell::command} -Command \"Install-WindowsFeature -name AD-Domain-Services\"",
    path    => "$source",
    require => Exec['Add userdomain'], # Require installation of the .NET Framework
    timeout => 600 # 10 minute timeout due to tadminihe length of the install when SQL Express is installed
}


# Pre-req for UCMA Runtime Setup 
  exec { 'Install UCMARuntime':
    command => "UcmaRunTimeSetup.exe /passive /norestart",
    path    => "$source",
    require => Exec['Install FilterPack','Install ADfeatures','Add userdomain','Install OtherFeatures'], # Require installation of the .NET Framework
    timeout => 600 # 10 minute timeout due to the length of the install when SQL Express is installed
}




# Pre-req for Office 2013 filter pack
  exec { 'Install OfficePack':
    command => "filterpack2010sp1-kb2460041-x64-fullfile-en-us.exe /quiet",
    path    => "$source",
    require => Exec['Install UCMARuntime'], # Require installation of the .NET Framework
    timeout => 600 # 10 minute timeout due to the length of the install when SQL Express is installed
}



# Need a user sai ( hardcoded for this POC)

   package { "Git version 1.8.4-preview20130916":
     ensure   => installed,
     source   => 'C:\\code\\puppetlabs\\temp\\windowsexample\\Git-1.8.4-preview20130916.exe',
     install_options => ['/VERYSILENT']
    }


#end of line



# Install Exchange from installation source
  exec { 'Install exchange':
    command => "setup.exe /mode:Install /role:ClientAccess,Mailbox /TargetDir:C:\ExchangeServer /IAcceptExchangeServerLicenseTerms",
    path    => "$source",
  require => Exec['Install OfficePack'], # Require installation of the .NET Framework
    timeout => 2400 # 40 minute timeout due to the length of the install when SQL Express is installed
}

}
