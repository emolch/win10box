Add-WindowsCapability -Online -Name OpenSSH.Server                           
Start-Service sshd                                                           
Set-Service -Name sshd -StartupType 'Automatic'
copy z:\sshd_config c:\ProgramData\ssh\sshd_config
cd c:\Users\IEUser
mkdir .ssh
copy z:\vagrant.pub .ssh\authorized_keys
Set-NetConnectionProfile -NetworkCategory Private                            
Read-Host -Prompt "Press any key to continue"
