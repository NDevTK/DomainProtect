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

if($item) {
$policy = $item.ExtensionSettings
} else {
$policy = '{"*":{"runtime_blocked_hosts":[]}}'
}

$settings = $policy | ConvertFrom-Json

[System.Collections.ArrayList]$hosts = $settings."*".runtime_blocked_hosts

function save() {
 $settings."*".runtime_blocked_hosts = $hosts 
 $json = ConvertTo-Json $settings -Compress
 [microsoft.win32.registry]::SetValue("HKEY_CURRENT_USER\Software\Policies\Google\Chrome", "ExtensionSettings", $json)
 [microsoft.win32.registry]::SetValue("HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge", "ExtensionSettings", $json)
 [microsoft.win32.registry]::SetValue("HKEY_CURRENT_USER\Software\Policies\BraveSoftware\Brave", "ExtensionSettings", $json)

$Menu = [ordered]@{
 1 = 'Protect a domain'
 2 = 'Remove a domain'
}

function menu() {
$Result = $Menu | Out-GridView -PassThru  -Title 'What to do?'

if ($Result.Name -eq 1) {
 $domain = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the domain to protect like https://*.youtube.com", "DomainProtect");
 if(!$hosts.Contains($domain)) {
  $hosts.Add($domain)
  save
 }
 menu
}

if ($Result.Name -eq 2) {
 $remove =  $hosts | Out-GridView -PassThru  -Title 'What to remove?'
 if(!$null -eq $remove) {
  $hosts.Remove($remove)
  save
 }
 menu
}

}

# Load menu for first time
menu
