# DomainProtect
Protect domains from malicious browser extensions.  
Works by blacklisting extensions for chosen domains (also supports per extension scope) :D

Check to see if its working by going to chrome://policy/  
Currently supported browsers: Chrome, Edge, Brave

# How to fix “execution of scripts is disabled on this system.”
Run Set-ExecutionPolicy RemoteSigned in powershell as admin

# Why powershell?
Because its already instaled for devices running windows and the code is easily viewable.
