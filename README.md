# DomainProtect
Protect domains from malicious browser extensions.  
Works by blacklisting extensions for chosen domains (also supports per extension scope) :D  
This to prevent permission abuse like https://chris.partridge.tech/2020/extensions-the-next-generation-of-malware/help-for-users/  
Check to see if its working by going to chrome://policy/  
Currently supported browsers: Chrome, Edge, Brave, Vivaldi, Chromium

# How to fix “execution of scripts is disabled on this system.”
Run Set-ExecutionPolicy RemoteSigned in powershell as admin

# Why powershell?
Because its already installed for devices running windows and the code is easily viewable.
