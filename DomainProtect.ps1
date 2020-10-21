[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

$item = Get-ItemProperty -Path "HKCU:\Software\Policies\Google\Chrome" -Name "ExtensionSettings" -ErrorAction SilentlyContinue

if ($item) {
$settings = $item.ExtensionSettings | ConvertFrom-Json
} else {
$settings = New-Object psobject
}

# Create if needed
$settings | add-member -MemberType NoteProperty -Name "*" -value (New-object psobject)  -ErrorAction SilentlyContinue


function createList($name) {
if ($settings."*".PSObject.Properties.Match($name).Count) {
# Convert to ArrayList
$settings."*".$name = [System.Collections.ArrayList]$settings."*".$name
} else {
# Create empty ArrayList
$settings."*".$name
$settings."*" | add-member -MemberType NoteProperty -Name $name -value (New-object System.Collections.Arraylist)
}
}

createList "runtime_blocked_hosts"
createList "blocked_permissions"

function save() {
 $json = ConvertTo-Json $settings -Compress
 [microsoft.win32.registry]::SetValue("HKEY_CURRENT_USER\Software\Policies\Google\Chrome", "ExtensionSettings", $json)
 [microsoft.win32.registry]::SetValue("HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge", "ExtensionSettings", $json)
 [microsoft.win32.registry]::SetValue("HKEY_CURRENT_USER\Software\Policies\BraveSoftware\Brave", "ExtensionSettings", $json)
}

$Menu = [ordered]@{
 1 = 'Protect a domain'
 2 = 'Remove a domain'
 3 = 'Deny a permission'
 4 = 'Allow a permission'
}


function add($name, $message) {
 $data = [Microsoft.VisualBasic.Interaction]::InputBox($message, "DomainProtect");
 if(!$null -eq $data -And !$settings."*".$name.Contains($data)) {
  $settings."*".$name.Add($data)
  save
 }
 menu
}

function remove($name) {
 $remove =  $settings."*".$name | Out-GridView -PassThru  -Title 'What to remove?'
 if(!$null -eq $remove) {
  $settings."*".$name.Remove($remove)
  save
 }
 menu
}

function menu() {
$Result = $Menu | Out-GridView -PassThru  -Title 'What to do?'

if ($Result.Name -eq 1) {
 add "runtime_blocked_hosts" "Enter the domain to protect like https://*.youtube.com"
}

if ($Result.Name -eq 2) {
 remove "runtime_blocked_hosts"
}

if ($Result.Name -eq 3) {
 add "blocked_permissions" "Enter the permission to block like unlimitedStorage"
}

if ($Result.Name -eq 4) {
 remove "blocked_permissions"
}

}

# Load menu for first time
menu
