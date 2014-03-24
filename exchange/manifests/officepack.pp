

include 'exchange::param::powershell'
 
class officepac (
  

)

{
 
  # Include powershell module for windows feature installation 
 
  
    # Add Dot Net Framework Feature
# Pre-req for Office 2013 filter pack
  exec { 'Install OfficePack':
    command => "filterpack2010sp1-kb2460041-x64-fullfile-en-us.exe /quiet",
    path    => "$source",
}


}
