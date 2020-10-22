# Used for the InputBox
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

$item = Get-ItemProperty -Path "HKCU:\Software\Policies\Mozilla\Firefox" -Name "ExtensionSettings" -ErrorAction SilentlyContinue

if ($item) {
$settings = $item.ExtensionSettings | ConvertFrom-Json
} else {
$settings = New-Object psobject
}


function createList($name) {
if ($settings.$scope.PSObject.Properties.Match($name).Count) {
# Convert to ArrayList
$settings.$scope.$name = [System.Collections.ArrayList]$settings.$scope.$name
} else {
# Create empty ArrayList
$settings.$scope | add-member -MemberType NoteProperty -Name $name -value (New-object System.Collections.Arraylist)
}
}

function createLists() {
createList "restricted_domains"
}

function setScope($data) {
# Create if needed
$settings | add-member -MemberType NoteProperty -Name $data -value (New-object psobject)  -ErrorAction SilentlyContinue
$global:scope = $data
createLists
}

# Apply global scope
setScope "*"


function save() {
 $json = ConvertTo-Json $settings -Compress
 Write-Output $json
 [microsoft.win32.registry]::SetValue("HKEY_CURRENT_USER\Software\Policies\Mozilla\Firefox", "ExtensionSettings", $json)
}

$Menu = [ordered]@{
 1 = 'Protect a domain'
 2 = 'Remove domain protection'
 3 = 'Change scope'
}


function add($name, $message) {
 $data = [Microsoft.VisualBasic.Interaction]::InputBox($message, "DomainProtect");
 if(!$null -eq $data -and !$settings.$scope.$name.Contains($data) -and $data.length -gt 1) {
  $settings.$scope.$name.Add($data)
  save
 }
 menu
}

function remove($name) {
 $remove =  $settings.$scope.$name | Out-GridView -PassThru  -Title 'What to remove?'
 if(!$null -eq $remove) {
  $settings.$scope.$name.Remove($remove)
  save
 }
 menu
}

function menu() {
$Result = $Menu | Out-GridView -PassThru  -Title 'What to do?'

if ($Result.Name -eq 1) {
 add "restricted_domains" "Enter the domain name to protect like www.youtube.com"
}

if ($Result.Name -eq 2) {
 remove "restricted_domains"
}

if($Result.Name -eq 3) {
 $data = [Microsoft.VisualBasic.Interaction]::InputBox("What scope? this can be a extension id or * for the global policy", "DomainProtect");
 setScope $data
 menu
}

}

# Load menu for first time
menu